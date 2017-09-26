/**
* @author Jerson Poblete
* @date 06/23/2017
* @description Scheduler Class used for updating UnreadEmail flag.
* @history: 08/29/2017 - Jerson Poblete Update the logic to check only the latest emailmessage
*/
global class MarkCaseAsRead_Batch_Scheduler implements Schedulable, Database.Batchable<sobject>{
    /*******************************************************************************************************
    * @description Executes the logic implementation of the scheduler class
    ********************************************************************************************************/
    global void execute(SchedulableContext ctx) {        
        // We now call the batch class to be scheduled
        MarkCaseAsRead_Batch_Scheduler batch = new MarkCaseAsRead_Batch_Scheduler();
       // Parameters of ExecuteBatch(context,BatchSize)
       	database.executebatch(batch,200);
    }
    /*******************************************************************************************************
    * @description Interface method of Batchable interface used to for retrieving records to be processed
    ********************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Query case with unread email flag true
        String query = 'SELECT Id, Unread_Emails__c FROM Case WHERE Unread_Emails__c = true';
        return Database.getQueryLocator(query);
    }
    /*******************************************************************************************************
    * @description Executes the logic implementation of the batch class
    ********************************************************************************************************/
	global void execute(Database.BatchableContext BC, List<Case> cases)
    {
        List<Case> casesToUpdate = new List<Case>(); //Case to update the Unread Email Flag to false
        Set<Id> caseIdwUnreadEmail = (new Map<Id,SObject>(cases)).keySet(); // set of case Id where unread email flag checked
		Set<Id> emailMessageParentIds = new Set<Id>(); // set of ParentId of EmailMessage with New Status
        
        //Start:8/29 check only latest email
        Set<Id> emailMessageParentIdsholder = new Set<Id>();
        List<EmailMessage> elist = Database.query('SELECT Id, Status, ParentId, CreatedDate FROM EmailMessage WHERE Incoming = true AND ParentId IN:caseIdwUnreadEmail ORDER BY CreatedDate desc');
        for(EmailMessage cc: elist){
            if(!emailMessageParentIdsholder.contains(cc.ParentId)){
                emailMessageParentIdsholder.add(cc.ParentId);
                if(cc.Status == '0'){
                    emailMessageParentIds.add(cc.ParentId);
                }
            }
        }
        
        /*List<AggregateResult> emailMessages = Database.query('SELECT ParentId FROM EmailMessage WHERE Status = \'0\' AND ParentId IN:caseIdwUnreadEmail GROUP BY ParentId'); 
        for(AggregateResult em: emailMessages){
            emailMessageParentIds.add((Id)em.get('ParentId'));
        }*/
        //End:8/29 check only latest email
		//create a list of case Id where Unread Email flag to false        
        for(Id cIds : emailMessageParentIds){
            if(caseIdwUnreadEmail.contains(cIds))
                caseIdwUnreadEmail.remove(cIds);
        }
        for(Case c : [SELECT Id, Unread_Emails__c FROM Case WHERE Id IN :caseIdwUnreadEmail]){
            c.Unread_Emails__c = false;
            casesToUpdate.add(c);
        }
        if(casesToUpdate.size()>0){
            Database.update(casesToUpdate);
        }
		        
    }
    /*******************************************************************************************************
    * @description Executes post logic implementation
    ********************************************************************************************************/
    global void finish(Database.BatchableContext BC)
    {
        //No Implementation
    }
}