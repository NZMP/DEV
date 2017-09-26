public with sharing class OpportunityRefreshExCon {
    public String strAccountId {get;set;}
    public Opportunity opp {get;set;}  // Opportunity
    public Revised_Account_Plan__c accountPlan {get;set;}
    public List<Revised_Account_Plan__c> listAccountPlan {get;set;}  // Account Plan  
    public ApexPages.StandardController stdCtrl;  
    public Boolean bIsEdit{get;set;}
    public Boolean bEditClicked {get;set;}
    public List<Revised_Account_Plan__c> lstAccountPlan;    
    public String strOppId15 {get;set;}
    public String conditionalRequiredString {get;set;}
    public Boolean checkConditionalRequired {get;set;}
    public string lastModifiedDate {get; private set;}
    public string createdDate {get; private set;}
    public list<selectOption> getStages(){
        list<selectOption> stages = new list<selectOption>();
        for (Schema.Picklistentry s : Opportunity.fields.Stage_in_Buying_Cycle__c.getDescribe().getpicklistvalues() )
            stages.add(new selectOption (s.getvalue(),s.getvalue() ));
        return stages;
    }   
    public OpportunityRefreshExCon (ApexPages.StandardController std) { 
        bEditClicked = false;
        accountPlan = new Revised_Account_Plan__c();
        
        //this.stdCtrl = std;
        if(ApexPages.currentPage().getParameters().get('Id') != null){
             opp = new Opportunity(Id = ApexPages.currentPage().getParameters().get('Id'));
        } 
        else bIsEdit = true;
        
        strAccountId = ApexPages.currentPage().getParameters().get('accid');
       
        // Address for conditional Required
        
        
        if(opp != null){          
            opp = [Select Id,Value_Drivers__c
                   ,FOR_customer_role__c
                   ,Needed_Information__c
                   ,Potential_Help__c
                   ,LastModifiedBy.name
                   ,LastModifiedDate
                   ,LastModifiedBy.id
                   ,CreatedBy.name
                   ,CreatedDate
                   ,CreatedById
                   , Stuck_Opty_Date__c 
                   ,Business_Case_Review_Date_Stamp__c 
                   , Stuck_Counter__c 
                   ,Business_Case_Submit_for_Approval__c 
                   ,Next_Stuck_Date__c 
                   ,Business_Case_Status__c 
                   ,Last_Active_Update__c 
                   , Business_Case_Approval_Date__c 
                   , Previous_FY_Stuck_Count__c 
                   , Business_Case_Approval_Duration__c 
                   , Optimisation_BM__c 
                   , Closing_This_Fiscal__c 
                   , Probability 
                   ,isClosed_Date__c 
                   , FIA_product__c 
                   , of_Products__c 
                   ,RecordTypeId,RecordType.Name,Account.Customer_Needs_1__c, Account.Customer_Needs_2__c, Account.Customer_Needs_3__c, Account.Customer_Needs_4__c, Account.Customer_Needs_5__c,AccountId,Account.Name, 
                    Opportunity_Type_Overview__c,Opportunity_Sub_Type__c,Agreement_Details__c,Nature_of_Opportunity__c,Total_Quantity__c,Total_PA_Volume__c,Total_Margin__c,Sub_Application__c,
                    Estimated_Revenue_Change__c,FOD_Problem_1__c,FOD_Problem_2__c,FOD_Problem_3__c,FOP_Problems_1__c,FOP_Problems_2__c,FOP_Problems_3__c,Opportunity.Name, CloseDate,implementation_Expectations_to_Communic__c,
                    FOD_Implication_1__c,FOD_Implication_2__c,FOD_Implication_3__c,FOP_Implication_1__c,FOP_Implication_2__c,FOP_Implication_3__c,StageName,Stage_in_Buying_Cycle__c,Customer_Application__c,  
                    FOD_Needs_Implied_or_Explcit_1__c,FOD_Needs_Implied_or_Explcit_2__c,FOD_Needs_Implied_or_Explcit_3__c,FOP_Needs_Implied_or_Explcit_1__c,FOP_Needs_Implied_or_Explcit_2__c,FOP_Needs_Implied_or_Explcit_3__c,
                    TSA_Sign_Date__c,FOP_Decision_Criteria_1__c,FOP_Decision_Criteria_2__c,FOP_Decision_Criteria_3__c,FOP_Competitor_Abiltity_to_Meet_1__c,FOP_Competitor_Abiltity_to_Meet_2__c,FOP_Competitor_Abiltity_to_Meet_3__c,
                    FOP_Fonterra_Ability_to_Meet_1__c,FOP_Fonterra_Ability_to_Meet_2__c,FOP_Fonterra_Ability_to_Meet_3__c,Potential_Consequences_Personal__c,Potential_Consequences_Technical__c,Potential_Consequences_Organisational__c,
                    Resolution_Strategy__c,Product_Source__c,Preferred_Supply_Region__c,Ship_To_Countries__c,Market_Access_Assured__c,Market_Access_Requirements__c,Technical_Teams_Required_for_Assistances__c,
                    Moved_to_APO__c,MDM_Reference_Number__c,eProject__c,Other_Pricing_Model__c,Reference_Price__c,Terms_and_Conditions_Agreed__c,Price_Risk_Solutions__c,Primary_Opportunity_Source__c,CampaignId,Reseller_Type__c,
                    Reseller_Assessment_and_Action_Plan__c,Implementation_Risk_or_Obstacles_to_Suc__c,Good_News_to_Document__c,Referral_Opportunties__c,Changes_Anticipated__c,New_Opportunties__c,
                    Plant_Lab_Assessment_Required__c, Fonterra_Solution__c, Benefi_of_Fonterra_for_Saving__c, Share_of_Business__c,Transition_From_GDT__c,Growth__c, Lost_Reason__c, Lost_Comments__c,Description,
                    Total_Target_Margin_MT__c,Nature_of_Value_Benefit__c,Opportunity_No__c,FOD_Implied1__c,FOD_Explicit1__c,FOD_Implied2__c,FOD_Explicit2__c,FOD_Implied3__c,FOD_Explicit3__c,
                    FOP_Implied1__c,FOP_Explicit1__c,FOP_Implied2__c,FOP_Explicit2__c,FOP_Implied3__c,FOP_Explicit3__c, Business_Case_Approvers__c, Total_Base_Price_MT2__c, Total_Target_PA_MT__c, OwnerId, Qualification_Status__c,Rank__c,
                    Ease_of_Implementation__c,Ease_of_Resourcing__c,Aligned_to_Strategy__c,MSR_ID__c,MSR_Status__c,Pricing__c,Category__c, 
                    Total_Quantity_Final__c, Total_Estimated_PA_Final__c, Estimated_Revenue_Final__c, 
                    Total_Quantity_SP_Rollup__c, Total_Estimated_PA_SP_Rollup__c, Estimated_Revenue_SP_Rollup__c, CBT_Application__c,CBT_Category__c,
                    Amount, Total_Estimated_PA__c,
                    Next_Step_Key_Milestone_Date__c
                    from Opportunity where Id = : opp.Id]; 
            string defaultDateFormat = 'dd/MM/yy HH:mm a';
            lastModifiedDate = ( opp.LastModifiedDate != null ) ? opp.LastModifiedDate.format( defaultDateFormat ) : '' ;
            createdDate = ( opp.createdDate != null ) ? opp.createdDate.format( defaultDateFormat ) : '' ;
            
            lstAccountPlan = [select Customer_Postioning_Statement__c,Total_PA_Goal_0_1_yr__c,Total_PA_Goal_1_2_yrs__c,Total_PA_Goal_3_5_yrs__c,Account_Name__r.Id,Detailed_Needs_1__c,
                            Strategic_Goal_0_1_yr__c,Strategic_Goal_1_2_yrs__c,Strategic_Goal_3_5_yrs__c,Theme_0_1_yr__c,Theme_1_2_yrs__c,Theme_3_5_yrs__c,Detailed_Needs_2__c,
                            Detailed_Needs_3__c,Detailed_Needs_4__c,Detailed_Needs_5__c
                            from Revised_Account_Plan__c where Account_Name__r.Id = : opp.AccountId  order by Account_Planning_Status__c asc limit 1];
            
            strOppId15 = string.valueof(opp.Id).substring(0,15);
            
        }
        else{
            opp = (Opportunity)std.getRecord();
            //Account acc = [Select id,Name FROM Account WHERE Id=:opp.AccountId];
            //opp.Name = acc.Name + ' Opp';
            opp.Name ='Type name here';
            opp.CloseDate = System.Today();
            //System.debug('strAccountId'+strAccountId);
            if(strAccountId != NULL){
                lstAccountPlan = [select Customer_Postioning_Statement__c,Total_PA_Goal_0_1_yr__c,Total_PA_Goal_1_2_yrs__c,Total_PA_Goal_3_5_yrs__c,Account_Name__r.Id,Detailed_Needs_1__c,
                                Strategic_Goal_0_1_yr__c,Strategic_Goal_1_2_yrs__c,Strategic_Goal_3_5_yrs__c,Theme_0_1_yr__c,Theme_1_2_yrs__c,Theme_3_5_yrs__c,Detailed_Needs_2__c,
                                Detailed_Needs_3__c,Detailed_Needs_4__c,Detailed_Needs_5__c
                                from Revised_Account_Plan__c where Account_Name__r.Id = : strAccountId  order by Account_Planning_Status__c asc limit 1];
            }
            //if(lstAccountPlan!=null) accountPlan = lstAccountPlan[0];
        }
        if(lstAccountPlan!=null) if(!lstAccountPlan.isEmpty())  accountPlan = lstAccountPlan[0];
    }
    
    String tabInFocus = System.currentPageReference().getParameters().get('tab'); 
    public String getTabInFocus() {
        if(tabInFocus == null) {
            tabInFocus = '1';           
        }        
        return tabInFocus;
    }
    public void setTabInFocus(String s) {this.tabInFocus = s;} 
    
    public void tabMethod() {  
         
    }
    
     //Determine if this is SF1 app
    public static Boolean isSF1(){
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
           String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
           ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
           (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
          ){ return true;}
        else{
              return false;
          }
    }// IF in SF1 app change to mobile page layout
    public PageReference redirect() {
        
        //
        Map<String, OpportunityFieldRequired__c>mapFieldRequired=new Map<String, OpportunityFieldRequired__c>();
        For(OpportunityFieldRequired__c obj: OpportunityFieldRequired__c.getAll().Values()){
            mapFieldRequired.put(obj.Name.ToUpperCase(),obj);
        }
        
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
        System.debug('M------------------------->'+M);
        For(string fName : M.keySet()){
            String fieldName=fName.left(40);
            if(mapFieldRequired!=null && mapFieldRequired.get(fieldName.toUpperCase())!=null && mapFieldRequired.get(fieldName.toUpperCase()).IsRequired__c){
                conditionalRequiredString += '-'+fieldName.toUppercase();
            }
        }
        
        
        //
        PageReference pref = null;
        String recordTypeIdCurrent = System.currentPageReference().getParameters().get('RecordType');
        if(recordTypeIdCurrent == null && opp.REcordTypeId != null){
            recordTypeIdCurrent = opp.REcordTypeId;
        } 
        else if(recordTypeIdCurrent == null && opp.REcordTypeId == null){
            List<String> availableOppTypes = GetAvailableRecordTypeNamesForSObject(Opportunity.SObjectType);
            recordTypeIdCurrent = [select Id from recordtype where sObjectType='Opportunity' and IsActive = true and Name IN:availableOppTypes limit 1].Id;
        }
        
        if(isSF1()) {
            PageReference p = new PageReference('/'+ ApexPages.currentPage().getParameters().get('Id'));
            p.getParameters().put('nooverride','1');
            return p;
        } else if(recordTypeIdCurrent == fonterraSmartPrice&& opp.Id == null){
            recordTypeIdCurrent = recordTypeIdCurrent != null ? recordTypeIdCurrent : '';
            PageReference p = new PageReference('/006/e?newid=opp.id&opp11=Negotiation&retURL=%2F006%2Fo%3Fsdtd%3D1&RecordType='+recordTypeIdCurrent+'&ent=Opportunity&saveURL=/apex/SmartPricePartnerSelection&nooverride=1');
            return p;     
        } 
        else if(recordTypeIdCurrent != fonterraIngredients && opp.Id == null){
            recordTypeIdCurrent = recordTypeIdCurrent != null ? recordTypeIdCurrent : '';
            PageReference p = new PageReference('/006/e?retURL=%2F006%2Fo%3Fsdtd%3D1&RecordType='+recordTypeIdCurrent+'&ent=Opportunity&nooverride=1');
            return p;     
        }
        else if(recordTypeIdCurrent != fonterraIngredients ){
            PageReference p = new PageReference('/'+opp.Id+'?nooverride=1');
            return p;     
        }
        return pref;
    }           
    private static Id fonterraIngredients = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Fonterra_Ingredients' LIMIT 1].Id;
    private static Id fonterraSmartPrice = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Fonterra_SmartPrice' LIMIT 1].Id;
    //private static Id fonterraIngredients = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Fonterra Ingredients').getRecordTypeId();
    //private static Id fonterraSmartPrice= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Fonterra-SmartPrice').getRecordTypeId();
    
    // Cancel
    public PageReference cancel() {
        PageReference pref = null;
        if(ApexPages.currentPage().getParameters().get('retURL') != null) {
            pref = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));       
        }
        else if(ApexPages.currentPage().getParameters().get('cancelURL') != null) {
            pref = new PageReference(ApexPages.currentPage().getParameters().get('cancelURL'));       
        }               
        else if(opp.Id != null) {
            pref = new PageReference('/' + opp.Id); 
        } 
        else {
            pref = new PageReference('/home/home.jsp'); 
        }
        return pref;
    }

    // VALIDATION
    /*public Boolean validate() {
        Boolean bReturnValue = true;
        if(opp.name == null) {
            addPageMessage(ApexPages.severity.ERROR, 'Please provide Opporunity Name');
            bReturnValue = false;
            
        }
        if(opp.AccountId == null) {
            addPageMessage(ApexPages.severity.ERROR, 'Please provide Account Name');
            bReturnValue = false;
            
        }
        return bReturnValue;
    }*/
    
   
    
    // For Saving Opportunity
    public PageReference saveCustom() { 
        PageReference pref = null;
      //  if(validate() == false) return pref;
        System.debug('### in save()');
        try {
            if(opp.Id == null) {
                system.debug('###: insert '+opp);
                //stdCtrl.save();
                //Opportunity oppNew = (Opportunity)stdCtrl.getRecord();
                //System.debug('*&*&'+oppNew.Id);
                //pref = new PageReference('/apex/OpportunityRefresh?id='+oppNew.Id);
                insert opp; 
                bIsEdit = false;
                
            } 
            else {
                system.debug('###: update '+opp);
                //stdCtrl = new ApexPages.StandardController(opp);
                //stdCtrl.save();
                update opp;
                bIsEdit = false;
                //addPageMessage(ApexPages.severity.confirm, 'Opportunity successfully updated.');
            }
            pref = new PageReference('/apex/OpportunityRefresh?id='+opp.Id);
            pref.getParameters().put('tab', tabInFocus);
            pref.setRedirect(true);

        }  
        catch(System.DMLException e) { 
            system.debug('## e =>' + e);
            addPageMessage(ApexPages.severity.ERROR, e.getDMLMessage(0));
            return pref;
        }  
                               
        return pref;
    } 
    /*
    public PageReference submitForApproval(){
        PageReference pref = new PageReference('/p/process/Submit?id=' + opp.Id + '&retURL=%2F' + opp.Id);
        pref.setRedirect(true);
        return pref;
    }
    */
    public  void editPage(){
        bIsEdit = true;
        bEditClicked = true;
    }
    
     // Add Page Messages
    public void addPageMessage(ApexPages.severity severity, Object objMessage) {
        ApexPages.Message pMessage = new ApexPages.Message(severity, String.valueOf(objMessage));
        ApexPages.addMessage(pMessage);
    }
    public void addPageMessage(Object objMessage) {
        addPageMessage(ApexPages.severity.INFO, objMessage);
    }  
    
    // Returns a List of the Names of all RecordTypes
    // available to the running user for a given SOBject type
    public static List<String> GetAvailableRecordTypeNamesForSObject(Schema.SObjectType objType) {
        List<String> names = new List<String>();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        // If there are 2 or more RecordTypes...
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
               if (i.isAvailable() 
               // Ignore the Master Record Type, whose Id always ends with 'AAA'.
               // We check the Id because Name can change depending on the user's language.
                && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
                    names.add(i.getName());
            }
        } 
        // Otherwise there's just the Master record type,
        // so add it in, since it MUST always be available
        else names.add(infos[0].getName());
        return names;
    }
    
    // 1/12/2016 - Submit For Approval
    // reason for change: staring Winter'16, you will not be able to use the Custom Buttons to call standard URL for Approval Process Submission 
    // 1/13/2016 - JS@Davanti Consulting: resolution was using JavaScript - emulate click of button located below in a related list.
    /*public void submitForApproval() {
        if((opp.StageName == 'Business Case Review' && opp.Opportunity_Type_Overview__c == 'Increase Volume' && opp.RecordType.Name == 'Fonterra Ingredients') || 
                (opp.RecordType.Name == 'Fonterra Ingredients' && opp.StageName == 'Business Case Review' && opp.Opportunity_Type_Overview__c == 'Agreements' && opp.Opportunity_Sub_Type__c == 'Reseller') || 
                (opp.RecordType.Name == 'Fonterra Ingredients' && opp.StageName == 'Business Case Review' && opp.Opportunity_Type_Overview__c == 'Services' && opp.Opportunity_Sub_Type__c == 'Technical in Market') || 
                (opp.RecordType.Name == 'Fonterra Ingredients' && opp.StageName == 'Business Case Review' && opp.Opportunity_Type_Overview__c == 'Services' && opp.Opportunity_Sub_Type__c == 'Technical IP Services') ||
                (opp.RecordType.Name == 'Fonterra Ingredients' && opp.StageName == 'Business Case Review' && opp.Opportunity_Type_Overview__c == 'Agreements' && (opp.Opportunity_Sub_Type__c == 'Long Contract' || opp.Opportunity_Sub_Type__c == 'Bilateral')) ||
                (opp.RecordType.Name == 'Fonterra Ingredients' && opp.StageName == 'Business Case Review' && (opp.Opportunity_Type_Overview__c == 'Renovation' || opp.Opportunity_Type_Overview__c == 'Innovation') && opp.of_Products__c >= 1)) {
        
            Approval.ProcessSubmitRequest approve1 = new Approval.ProcessSubmitRequest();
            approve1.setComments('Submitting request for approval.');
            approve1.setObjectId(opp.id);
    
            approve1.setProcessDefinitionNameOrId(null);
            approve1.setSkipEntryCriteria(true);
    
            Approval.ProcessResult result = Approval.process(approve1);
            
            system.debug('@@@ INSIDE IF STATEMENT');
        }
        else {
            system.debug('@@@ ELSE');
        }
    }*/
}