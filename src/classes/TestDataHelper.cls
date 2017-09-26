/*
* Author:
* Description:
* History:
*     12Oct2016 NBustillos(DC): created new methods createAudit(), createAuditNotes() and createTask().
*	  17July2017 JPoblete(PDC): created new method - createCase();
*/
@isTest
public class TestDataHelper {
    
    public static Account createAccount(String recordTypeName, String accountGroup, String accountNumber, Boolean withInsert) {      
        SmartFactory.FillAllFields = true;
        Id accRecordTypeId = null;
        for (Schema.RecordTypeInfo recordType : SmartFactory.GlobalDescribe.get('Account').getDescribe().getRecordTypeInfos()) {
            if (recordType.getName() == recordTypeName) {
                accRecordTypeId = recordType.getRecordTypeId();
            }
        }
        Map<String, Object> accValues = new Map<String, Object> {
            'RecordTypeId' => accRecordTypeId,
                'Account_Group__c' => accountGroup,
                'Account_Group_Code__c' => '0001',
                'Segment__c' => '02',
                'Account_Number__c' => accountNumber,
                'SAP_Reference_Key__c' => accountNumber    
                };
                    Account account = (Account)SmartFactory.createSObject('Account', accValues);
        account.name='CC Test Account';
        if (withInsert) {
            insert account;
        }
        SmartFactory.FillAllFields = false;
        return account;
    }
    
    public static Account createAccountSAP(String recordTypeName, String accountGroup, String accountNumber, Boolean withInsert, String SAPAccountManager) {      
        SmartFactory.FillAllFields = true;
        Id accRecordTypeId = null;
        for (Schema.RecordTypeInfo recordType : SmartFactory.GlobalDescribe.get('Account').getDescribe().getRecordTypeInfos()) {
            if (recordType.getName() == recordTypeName) {
                accRecordTypeId = recordType.getRecordTypeId();
            }
        }
        Map<String, Object> accValues = new Map<String, Object> {
            'RecordTypeId' => accRecordTypeId,
                'Account_Group__c' => accountGroup,
                'Account_Number__c' => accountNumber
                };
                    Account account = (Account)SmartFactory.createSObject('Account', accValues);
        account.name='CC Test Account';
        account.SAP_Account_Manager__c = SAPAccountManager;
        if (withInsert) {
            insert account;
        }
        SmartFactory.FillAllFields = false;
        return account;
    }
    
    public static Partner_Function__c createPartnerFunction(Account customer, Account partner, String pFunction, Boolean withInsert) {      
        
        Partner_Function__c partnerFunction = new Partner_Function__c();
        partnerFunction.Customer__c = customer.Id;
        partnerFunction.Partner__c = partner.Id;
        partnerFunction.Partner_Function_Description__c = pFunction;
        if (withInsert) {
            insert partnerFunction;
        }
        return partnerFunction;
    }
    
    
    
    public static Account_Plan__c createAccountPlan(String accountId, Boolean withInsert) {      
        SmartFactory.FillAllFields = true;
        Map<String, Object> accPlanValues = new Map<String, Object> {
            //'Name' => name,
            'Account__c' => accountId
                };
                    Account_Plan__c accountPlan = (Account_Plan__c)SmartFactory.createSObject('Account_Plan__c', accPlanValues);
        // added by Eric on 19th July as part of Visibility release
        // new validation rule to make sure the start and end date are always 1/8 and 31/7
        Date testDate=Date.today();
        accountPlan.Start_Date__c=Date.newInstance(testDate.year()-1,8,1);
        accountPlan.End_Date__c=Date.newInstance(testDate.year(),7,31);
        if (withInsert) {
            insert accountPlan;
        }
        SmartFactory.FillAllFields = false;
        return accountPlan;
    }
    
    public static Key_Initiative__c createKeyInitiative(String accountId, String status, Boolean withInsert) {      
        SmartFactory.FillAllFields = true;
        Map<String, Object> keyInitValues = new Map<String, Object> {
            'Status__c' => status,
                'Account__c' => accountId
                };
                    Key_Initiative__c keyInitiative = (Key_Initiative__c)SmartFactory.createSObject('Key_Initiative__c', keyInitValues);
        if (withInsert) {
            insert keyInitiative;
        }
        SmartFactory.FillAllFields = false;
        return keyInitiative;
    }
    
    public static Call_Plan__c createCallPlan(String accountId, Boolean withInsert) {      
        Call_Plan__c callPlan = new Call_Plan__c(Account__c = accountId);
        if (withInsert) {
            insert callPlan;
        }
        return callPlan;
    }
    
    public static GDT_Price_Bet__c createGDTPriceBet(Boolean withInsert, string gdtEvent, integer amtBet, integer amfBet8, 
                                                     integer smpBet, integer smpBet8, integer wmpBet, integer wmpBet8){
                                                         
                                                         SmartFactory.FillAllFields = true;
                                                         Map<String, Object> keyInitValues = new Map<String, Object> {
                                                             'GDT_Event__c' => gdtEvent,
                                                                 'AMF_Bet__c' => amtBet,
                                                                 'AMF_Bet_8__c' => amfBet8,  
                                                                 'SMP_bet__c' => smpBet,
                                                                 'SMP_Bet_8__c' => smpBet8,
                                                                 'WMP_bet__c' => wmpBet,
                                                                 'WMP_Bet_8__c' => wmpBet8};
                                                                     
                                                                     GDT_Price_Bet__c gdtBet = (GDT_Price_Bet__c)SmartFactory.createSObject('GDT_Price_Bet__c', keyInitValues);
                                                         if(withInsert){
                                                             insert gdtBet;
                                                         }
                                                         SmartFactory.FillAllFields = false;
                                                         return gdtBet;
                                                     }
    
    public static GDT_Event__c createGDTEvent(Boolean withInsert){
        GDT_Event__c previousgdtEvent = new GDT_Event__c(Name='1234', Event_Date__c =Date.today().addDays(-7)); //to bypass the custom validation in GDT_Price_Bet__c
        GDT_Event__c gdtEvent = new GDT_Event__c(Name='123', Event_Date__c =Date.today().addDays(7));
        if(withInsert){
            insert previousgdtEvent;
            gdtEvent.Previous_GDT_Event__c = previousgdtEvent.Id;
            insert gdtEvent;
        }
        return gdtEvent;
    }
    
    /*
public static Customer_Snapshot__c createCustomerSnapshot(String accountId, String recordTypeName, Boolean withInsert) {      
SmartFactory.FillAllFields = true;
Id csRecordTypeId = null;
for (Schema.RecordTypeInfo recordType : SmartFactory.GlobalDescribe.get('Customer_Snapshot__c').getDescribe().getRecordTypeInfos()) {
if (recordType.getName() == recordTypeName) {
csRecordTypeId = recordType.getRecordTypeId();
}
}
Map<String, Object> csValues = new Map<String, Object> {
'RecordTypeId' => csRecordTypeId,
'Account__c' => accountGroup
};

Customer_Snapshot__c customerSnapshot = (Customer_Snapshot__c)SmartFactory.createSObject('Customer_Snapshot__c', csValues);
if (withInsert) {
insert customerSnapshot;
}
SmartFactory.FillAllFields = false;
return customerSnapshot;
}

Select  c.Name, c.Metric_Type__c,  c.External_Id__c, c.Edit_URL__c,  c.Action__c, c.Account__c From Customer_Snapshot__c c

Select c.RecordTypeId, c.Name, , c.External_Id__c,  c.Customer_Snapshot__c, c.Commodity_Group__c, From Customer_Snapshot_Line__c c
*/
    
    /*
public static Contact createContact(Boolean withInsert) {      
SmartFactory.FillAllFields = true;
Map<String, Object> contactValues = new Map<String, Object> {
'MailingCountry' => 'Viet Nam',
'OtherCountry' => 'Viet Nam'
};
Contact contact = (Contact)SmartFactory.createSObject('Contact', contactValues);
if (withInsert) {
insert contact;
}
SmartFactory.FillAllFields = false;
return contact;
}

public static Task createTask(Boolean withInsert) {      
SmartFactory.FillAllFields = false;
Task task = (Task)SmartFactory.createSObject('Task');
if (withInsert) {
insert task;
}
SmartFactory.FillAllFields = false;
return task;
}

*/
    
    public static Event createEvent(Boolean withInsert) {      
        SmartFactory.FillAllFields = false;
        Map<String, Object> evtValues = new Map<String, Object> {
            'Subject' => 'test event subject',
                'StartDateTime' => Datetime.now(),
                'EndDateTime' => Datetime.now()
                };
                    Event event = (Event)SmartFactory.createSObject('Event', evtValues);
        if (withInsert) {
            insert event;
        }
        SmartFactory.FillAllFields = false;
        return event;
    }
    
    public static Opportunity createOpportunity(String accountId, Boolean withInsert) {//, String name, Date closeDate, String stageName, Boolean withInsert) {      
        SmartFactory.FillAllFields = true;
        Map<String, Object> optyValues = new Map<String, Object> {
            //'Name' => name,
            //'CloseDate' => closeDate,
            //'StageName' => stageName,
            'AccountId' => accountId
                };
                    Opportunity opportunity = (Opportunity)SmartFactory.createSObject('Opportunity', optyValues);
        if (withInsert) {
            insert opportunity;
        }
        SmartFactory.FillAllFields = false;
        return opportunity;
    }
    
    public static Product2 createProduct2(Boolean withInsert, decimal fPrice) {      
        SmartFactory.FillAllFields = true;
        Product2 product2 = (Product2)SmartFactory.createSObject('Product2');
        product2.name='CC Test Product';
        product2.Forecast_Price__c = fPrice;
        if (withInsert) {
            insert product2;
        }
        SmartFactory.FillAllFields = false;
        return product2;
    }
    
    public static Product2 createProduct2(Boolean withInsert) {      
        SmartFactory.FillAllFields = true;
        Product2 product2 = (Product2)SmartFactory.createSObject('Product2');
        product2.name='CC Test Product';
        if (withInsert) {
            insert product2;
        }
        SmartFactory.FillAllFields = false;
        return product2;
    }
    
    public static User createUser(String usernameEmail, String profileName, Boolean withInsert) {  
        UserRole r = new UserRole(Name = 'Sales Operations'); //added for user validation
        //insert r;
        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name=:profileName];
        u.username = usernameEmail;
        u.email = usernameEmail;
        u.lastName = usernameEmail;
        //u.firstName = data.firstName;
        String alias = usernameEmail;
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_NZ';
        u.emailEncodingKey = 'ISO-8859-1';
        u.timeZoneSidKey = 'Pacific/Auckland';
        u.profileId = p.Id;
        //u.UserRoleId = r.Id;
        if (withInsert) {
        insert u;
        }
        return u;
    }
    
    public static User createUserSAP(String usernameEmail, String profileName, Boolean withInsert, String SAPKey, Boolean isSAPDefault) {
        UserRole r = new UserRole(Name = 'Sales Operations'); //JP Jul2017 - fixed for users custom validation
        insert r;
        
        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name=:profileName];
        u.username = usernameEmail;
        u.email = usernameEmail;
        u.lastName = usernameEmail;
        u.SAP_Employee_Key__c = SAPKey;
        u.Default_Owner_for_Account_Integration__c = isSAPDefault;
        //u.firstName = data.firstName;
        String alias = usernameEmail;
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_NZ';
        u.emailEncodingKey = 'ISO-8859-1';
        u.timeZoneSidKey = 'Pacific/Auckland';
        u.profileId = p.Id;
        u.UserRoleId = r.Id; //JP Jul2017 - fixed for users custom validations
        if (withInsert) {
            insert u;
        }
        return u;
    }
    
    // Description: Creates an Audit record
    //              Overload this method if needed
    public static Audit__c createAudit(){
        Audit__c a = new Audit__c();
        // Add required fields here if needed
        return a;
    }
    
    // Description: Creates Audit Notes per Audit record
    //              Overload this method if needed
    public static Map<Id,List<Audit_Notes__c>> createAuditNotes(Set<Id> auditIds, Integer maxAuditNotes){
        Map<Id,List<Audit_Notes__c>> auditNotesMap = new Map<Id,List<Audit_Notes__c>>();
        
        for(Id auditId : auditIds){
            for(Integer x=1;x<=maxAuditNotes;x++){
                List<Audit_Notes__c> auditNotesList = new List<Audit_Notes__c>();
                if(!auditNotesMap.containsKey(auditId)){
                    auditNotesList.add(new Audit_Notes__c(Audit__c=auditId, Title__c = 'Test Question' + x, Description__c= 'Test Description' + x));
                }else{
                    auditNotesList = auditNotesMap.get(auditId);    
                    auditNotesList.add(new Audit_Notes__c(Audit__c=auditId, Title__c = 'Test Question' + x, Description__c= 'Test Description' + x));
                }
                
                auditNotesMap.put(auditId, auditNotesList);
            }
        }
        
        return auditNotesMap;
    }
    
    // Description: Creates Task record
    //              Overload this method if needed
    public static Task createTask(){
        Task t = new Task();
        // Add required fields here if needed
        return t;
    }
    
    public static CameleonCPQ__Quote__c createQuote2(Account acc, Opportunity opp,Boolean withInsert)
    {
        CameleonCPQ__Quote__c qt = new CameleonCPQ__Quote__c();
        qt.CameleonCPQ__AccountId__c = acc.id;
        qt.ShiptoAccount__c = acc.id;
        if(withInsert){
            insert qt;
        }
        return qt;
    }
    /*
    * @description: Create n cases for given record type parameter
    * author: Jerson Poblete
    */
    public static List<Case> createCases (integer numCases, string recType, string caseOrigin)
    {
		List<Case> cases = new List<Case>();
        Id caseTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recType).getRecordTypeId();
        for (Integer i=0; i<numCases; i++) {
            Case c = new Case();
            c.Subject = 'Test Case' + i;
            c.Description = 'Test Case Description';
            c.Status = 'New';
            c.Origin = caseOrigin;
            c.RecordTypeId = caseTypeId;
            c.Unread_Emails__c = true;
            cases.add(c);
        }
        return cases;
    }
    /*
    * @description: Create ROC Custom Settings for given record type parameter
    * author: Jerson Poblete
    */
    public static void createROC(String roc){
        Group testGroup = new Group(Name= roc, Type='Queue');
        insert testGroup;
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
        insert testQueue;
        ROC__c rocs = new ROC__c();
        rocs.Name = roc;
        rocs.Queue__c = testQueue.Id;
        insert rocs;
    }
    public static CameleonCPQ__Quote__c createQuote(Boolean withInsert)
    {
        CameleonCPQ__Quote__c qt = new CameleonCPQ__Quote__c();
        qt.Name = 'Test Quote';
        if(withInsert){
            insert qt;
        }
        return qt;
    }
}