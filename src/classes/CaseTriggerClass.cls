/*
* Author:
* Description:
* History:
*	12Oct2016 NBustillos(DC): Updated recalculate() method to include Case.ownerId as part of the query to prevent exception during account owner change in the UI.
*	  						  Updated commitShares() method to check if caseOld is null and proceed with processing under assumption that its an explict call from account owner change.
* 	02Nov2016 NBustillos(DC): FONCE-62 - Updated recalculate() method to only query Complaints cases for sharing recalculation.
* 							  FONCE-62 - Updated commitShares() method to only query Complaints cases for sharing recalculation. 
*
*	11May2017 JersonPoblete: Create a method to validate case closure if there's an open task
*	03July2017 JersonPoblete: Create a method for Case assignment logic
*/
public  class CaseTriggerClass {
	
    final static String COMMCASERT = 'Community Case';
    final static String COMPLAINTS = 'Complaints';
    final static Set<String> setCommCases = new Set<String>{COMMCASERT,COMPLAINTS};
    public static void setActiveAssignmentRule (Set<ID> caseIDs) {
        
        
        List<Case> forAssignment = new List<Case>();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        
        
        for(Case cse : [SELECT Id, Record_Type_Name__c FROM Case WHERE Id in: caseIDs]) {
            system.debug('##Case: ' + cse);
            if(cse.Record_Type_Name__c == COMMCASERT) {
                cse.setOptions(dmo);
                forAssignment.add(cse);
            }
        }
        
        
        if(!forAssignment.isEmpty()){
            update forAssignment;
        }
    }
    
    
    public static void setCaseStatusMapping (List<Case> lCases) {
        
        Map<String, Complaints_Statuses__c> mapComStatus = Complaints_Statuses__c.getAll();
        
        for(Case cse : lCases) {
            //Community Cases only
            if(cse.Record_Type_Name__c == COMMCASERT && cse.Status == 'New') {
                cse.Status = 'Received';
            }
            
            if(cse.Record_Type_Name__c == COMPLAINTS) {
                if(mapComStatus.containsKey(cse.Status)) {
                    cse.Status = mapComStatus.get(cse.Status).CC_Status__c;
                }
			}
		}
        
    }
    
    public static void commitShares ( case[] cases, map<id, case> caseOld ){

        caseshare[] shares = new caseshare[]{};
            
        set<id> accountIds = new set<id>();
        map<id,id> userRoles = new map<id,id>();
        map<id,id> groupRoles = new map<id,id>();
        map<id,id> accountGroups = new map<id,id>();
        
        
        for ( case o : cases ){
        	system.debug('record type' +o.Record_Type_Name__c);
        	if(o.Record_Type_Name__c==COMPLAINTS){
	        	// Check if caseOld is not blank, then its a call from case trigger
	        	if(caseOld!=null){
	            	if (o.accountId!= null && o.ownerId!=caseOld.get(o.id).ownerId){
	            		accountIds.add(o.accountId);
	            	}
	        	}else{
	        		// if caseOld is blank then its a call from account trigger
	        		if(o.accountId!=null){
	        			accountIds.add(o.accountId);
	        		}
	        	}
        	}
        }
        
        map<id,account> caseAccounts = new map<id, account>([select id, ownerId
                                                             from account where id in 
                                                             (select accountid from case where id =: cases AND Record_Type_Name__c=:COMPLAINTS)
                                                             and owner.isActive = true ]);
                                                             
        for ( case o : [select id, ownerid, accountid
                            from case where id =: cases
                            and accountId != null
                            and account.owner.isactive = true])
            if ( caseAccounts.get(o.accountId) != null && o.ownerId != caseAccounts.get(o.accountId).ownerid )
                shares.add (
                    new caseshare ( 
                        caseId = o.id,
                        UserOrGroupId = caseAccounts.get(o.accountId).ownerid,
                        CaseAccessLevel  = 'Read' ) );

        for (user u : [select userroleid, 
                       accountId from 
                       user where accountId =: accountIds ])
            userRoles.put( u.userroleid, u.accountId );
        
        for (group u: [ select id, relatedid
                       from group 
                       where relatedid =: userRoles.keySet() 
                       and type='RoleAndSubordinates'])
            groupRoles.put( u.relatedid, u.id );    
        
        for ( id i : groupRoles.keyset() )
            accountGroups.put( userRoles.get( i ) , groupRoles.get( i ) );
        
        for ( case o : cases )
            if( accountGroups.get( o.accountid ) != null )
                shares.add(
                    new caseshare ( 
                        caseId = o.id,
                        UserOrGroupId = accountGroups.get( o.accountid ),
                        CaseAccessLevel  = 'Read',
                        rowcause = 'Manual'));
        system.debug(shares);
        insert shares;
    }
    
    
    public static void recalculate ( account[] newList, map<id, account> oldMap ){
		set<id> accounts 	= new set<id>(), 
            	users 		= new set<id>();

        
        for ( account a : newList ) 
            if ( oldMap.get(a.id).ownerId != a.ownerId ){
                accounts.add ( a.id );
                users.add ( oldMap.get( a.id ).ownerId );
            }
        		
        
        case[] cases = [select id, accountid, OwnerId, Record_Type_Name__c from case where accountid =: accounts AND Record_Type_Name__c=:COMPLAINTS];
        
        deleteShares ( cases, users );
        
		commitShares( cases, null );
    }
    
    static void deleteShares (
        case[] cases, 
        set<id> users ){

        delete [select id from caseshare 
                where caseId =: cases 
                and UserOrGroupId =: users 
                and rowcause = 'Manual'];
    }
    
    /*	Author: Jerson Poblete
     * 	Description: Validate case before closure
     * 	Date: MAY-11-2017
     */
    public void validateCaseClose (Map<Id, Case> newMap, Map<Id, Case> oldMap)
    {
        Map<Id, Task> taskMap = new Map<Id, Task>();
        //query open task related to case and populate the map
        for(Task taskRec: [SELECT Id, WhatId, Status FROM Task WHERE Status <> 'Completed' AND WhatId in: newMap.keySet() AND IsRecurrence = false])
        {
            taskMap.put(taskRec.WhatId, taskRec);
        }
        for(Case c : newMap.values())
      {
          //check if the case has any open task and has just been changed to closed
            if(taskMap.containsKey(c.Id) && c.Status == 'Closed' && c.Status != oldMap.get(c.Id).Status)
            {
                c.addError('Please close your open tasks before closing the case.');        
            }
      }
    }
    /*	Author: Jerson Poblete
    * 	Description: Case Assignment Logic - disable notification
    * 	Date: July-3-2017
    */
    public void updateCaseOwner(List<Case> cases)
    {
        Set<ID> caseIDs = new Set<ID>(); 
        for(Case c : cases){
            if (c.Origin.Contains('Email') && (c.Status =='New' || c.Status == 'Closed - Interaction'))
            { 
                caseIDs.add(c.Id);
            } 
        }
        if(caseIDs.size() > 0) { 
            updateOwnership(caseIDs); 
        }
        // updateOwnership(setIds);        
    }
   /*	Author: Jerson Poblete
    * 	Description: Case Assignment Logic - disable notification
    * 	Date: July-3-2017
    * 	History: July-20-2017 Update logic to include checking of To and CC
    */
    @future 
    public static void updateOwnership(Set<Id> caseIDs) { 
        List<Case> cases = new List<Case>();
        Database.DMLOptions dmo = new Database.DMLOptions(); 
        dmo.EmailHeader.triggerUserEmail = false; 
        String emailToAddresses = '';
        String emailCcAddresses = '';
        for(Case cRec : [SELECT Id, OwnerId, ContactId, EmailMessagetoAddresses__c, EmailMessageCcAddresses__c, Origin FROM Case WHERE Id in :caseIDs AND RecordType.Name in ('Customer Cases', 'Interactions')]) {
            Case c = new Case();
            c.Id = cRec.Id;
            if(String.isNotBlank(cRec.EmailMessagetoAddresses__c)){
                emailToAddresses = cRec.EmailMessagetoAddresses__c;
            }
            if(String.isNotBlank(cRec.EmailMessageCcAddresses__c)){
                emailCcAddresses = cRec.EmailMessageCcAddresses__c;
            }
            //Contact not exist - Assign the case to User's ROC queue
            if(cRec.ContactId == null && cRec.Origin == 'Email'){
                String rocqueueId = caseOwnerROCQueueId(emailToAddresses, emailCcAddresses);
                if(String.isNotEmpty(rocqueueId)){
                    c.OwnerId = rocqueueId;
                    cases.add(c);
                }
            }
            //contact exist - Assign the case to Contact's Account Primary Service SOE
            //add filter for GDT
            else if(cRec.ContactId != null && !cRec.Origin.Contains('GDT')){
                Contact con = [SELECT Id, Account.Primary_Service_SOE__c FROM Contact WHERE Id = :cRec.ContactId LIMIT 1];
                if(con.Account.Primary_Service_SOE__c != null)
                {
                    c.OwnerId = con.Account.Primary_Service_SOE__c;
                    cases.add(c);
                }
                else if(cRec.Origin == 'Email')
                {
                    String rocqueueId = caseOwnerROCQueueId(emailToAddresses, emailCcAddresses);
                    if(String.isNotEmpty(rocqueueId)){
                        c.OwnerId = rocqueueId;
                        cases.add(c);
                    }
                }
            }
        }
        if(!cases.isEmpty())
        {
            Database.update(cases, dmo); // Actual DML operation is performed instead of implicit update
        }
    }
   /*	Author: Jerson Poblete
    * 	Description: Case Assignment Logic - look for QueueId for the user
    * 	Date: July-12-2017
    *   History: July-20-2017 Update logic to include checking of To and CC
    */
    public static String caseOwnerROCQueueId (String emailToAddresses, String emailCcAddresses)
    {
        String rocqueueId = null;
        List<String> toList = emailToAddresses.split(';');
        List<String> ccList = emailCcAddresses.split(';');
        
        String toAddStr = '' ;
        String ccAddStr = '' ;
        
        for(String str : toList)
            toAddStr += '\'' + str.deleteWhitespace().replaceAll('\'', '\\\\\'') + '\',';
        toAddStr = toAddStr.lastIndexOf(',') > 0 ? '(' + toAddStr.substring(0,toAddStr.lastIndexOf(',')) + ')' : toAddStr ;
        
        String qTo = 'SELECT Id, Name, ROC__c, Email FROM User WHERE  ROC__c in: rocset AND Profile.Name = \'SOE Full\' AND isActive = true AND (Email IN ' + toAddStr + 'OR Full_Name_Email__c IN' + toAddStr + ')';
        
        for(String str : ccList)
            ccAddStr += '\'' + str.deleteWhitespace().replaceAll('\'', '\\\\\'') + '\',';
        ccAddStr = ccAddStr.lastIndexOf(',') > 0 ? '(' + ccAddStr.substring(0,ccAddStr.lastIndexOf(',')) + ')' : ccAddStr ;
        
        String qCc = 'SELECT Id, Name, ROC__c, Email FROM User WHERE  ROC__c in: rocset AND Profile.Name = \'SOE Full\' AND isActive = true AND (Email IN ' + ccAddStr + 'OR Full_Name_Email__c IN' + ccAddStr + ')';
        
        Set<String> rocset = ROC__c.getall().keyset();
        List<User> uTo = new List<User>();
        List<User> uCc = new List<User>();
        ROC__c rocTo = new ROC__c();
        ROC__c rocCc = new ROC__c();
        if(String.isNotBlank(emailToAddresses))
        {
            uTo = Database.query(qTo);
            if(!uTo.isEmpty())
            {
                rocTo = ROC__c.getValues(uTo[0].ROC__c);
                if(rocTo != null)
                {
                    rocqueueId = rocTo.Queue__c;
                }
            }
            else if(String.isNotBlank(emailCcAddresses))
            {
                uCc = Database.query(qCC);
                if(!uCc.isEmpty()){
                    rocCC = ROC__c.getValues(uCc[0].ROC__c);
                    if(rocCC != null)
                    {
                        rocqueueId = rocCC.Queue__c;
                    }
                }
            }
        } 
        else if (String.isNotBlank(emailCcAddresses))
        {
            uCc = Database.query(qCC);
            if(!uCc.isEmpty()){
                rocCC = ROC__c.getValues(uCc[0].ROC__c);
                if(rocCC != null)
                {
                    rocqueueId = rocCC.Queue__c;
                }
            }
        }
        return rocqueueId;
    }
}