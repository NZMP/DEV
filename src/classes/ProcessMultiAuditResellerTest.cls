/*********************
 * Author: Mahmood Zubair (Davanti)
 * Description: test class to handle multi-reseller create implementation
 * History 
 * 11Aug16: inital version
 * 
 * 
 * ****************************/
 
@isTest(SeeAllData=false)
private class ProcessMultiAuditResellerTest{

    // Get Record type IDs
    final static id noWarehouseId = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('Reseller - no warehouse').getRecordTypeId();
    final static id includingWarehouseId = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('Reseller - including warehouse').getRecordTypeId();
    final static id multipleResellersId = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('3rd party warehouse - multiple resellers').getRecordTypeId();
    
    @testSetup 
    static void setup() {
        List<Account> accObjList = new List<Account>();
    
        for (integer i = 0; i < 10 ; i++){
            Account accObj = new Account();
            accObj.Name = 'Reseller ' + string.valueof(i);
            accObj.AccountNumber = string.valueof(i);
            accObjList.add(accObj);
        } 
        
        insert accObjList;
        
        Audit__c auditObj = new Audit__c();
        auditObj.RecordTypeId = multipleResellersId;
        auditObj.Reseller__c  = accObjList[0].Id;
        auditObj.Reseller2__c  = accObjList[1].Id;
        auditObj.Reseller3__c  = accObjList[2].Id;
        auditObj.Formyoula_Entry_ID__c = 'Testing';
        auditObj.Q_1_Trading_Transperency__c = 'Applicable';
        auditObj.Q_2_Insurance__c = 'Applicable';
        auditObj.Q_3_Organisation_Structure__c= 'Applicable';
        auditObj.Q_4_Regulatory_Compliance__c= 'Applicable';
        auditObj.Q_5_Quality_Systems__c= 'Applicable';
        
        insert auditObj;
    
    }
    
    static testMethod void createAuditOnlyRecord_Test(){
        List<Account> accObjList = [SELECT ID, Name FROM Account LIMIT 3];
        Test.StartTest();
        Audit__c auditObj = new Audit__c();
        auditObj.RecordTypeId = multipleResellersId;
        auditObj.Reseller__c  = accObjList[0].Id;
        auditObj.Reseller2__c  = accObjList[1].Id;
        auditObj.Reseller3__c  = accObjList[2].Id;
        auditObj.Formyoula_Entry_ID__c = 'Testing';
        auditObj.Q_1_Trading_Transperency__c = 'Applicable';
        auditObj.Q_2_Insurance__c = 'Applicable';
        auditObj.Q_3_Organisation_Structure__c= 'Applicable';
        auditObj.Q_4_Regulatory_Compliance__c= 'Applicable';
        auditObj.Q_5_Quality_Systems__c= 'Applicable';
        
        insert auditObj;
        
        Audit_Notes__c auditNoteObj1 = new Audit_Notes__c();
        auditNoteObj1.Audit__c = auditObj.Id;
        auditNoteObj1.Title__c = 'Testing';
        auditNoteObj1.Description__c = 'Testing'; 
        auditNoteObj1.Consequence__c = 'Minor'; 
        auditNoteObj1.Help_Needed__c = 'No';  
        
        insert auditNoteObj1;
        
        
        // 3rd party warehouse - multi resellers
        Audit__c auditObj2 = new Audit__c();
        auditObj2.RecordTypeId = multipleResellersId;
        auditObj2.Reseller__c  = accObjList[0].Id;
        //auditObj2.Reseller2__c  = accObjList[1].Id;
        //auditObj2.Reseller3__c  = accObjList[2].Id;
        auditObj2.Formyoula_Entry_ID__c = 'Testing';
        auditObj2.Q_1_Trading_Transperency__c = 'Applicable';
        auditObj2.Q_2_Insurance__c = 'Applicable';
        auditObj2.Q_3_Organisation_Structure__c= 'Applicable';
        auditObj2.Q_4_Regulatory_Compliance__c= 'Applicable';
        auditObj2.Q_5_Quality_Systems__c= 'Applicable';
        
        insert auditObj2;
        
        Audit__c auditObj3 = new Audit__c();
        auditObj3.RecordTypeId = multipleResellersId;
        auditObj3.Reseller__c  = accObjList[1].Id;
        auditObj3.ParentAuditId__c = auditObj2.Id;
        auditObj3.Formyoula_Entry_ID__c = 'Testing';
        auditObj3.Q_1_Trading_Transperency__c = 'Applicable';
        auditObj3.Q_2_Insurance__c = 'Applicable';
        auditObj3.Q_3_Organisation_Structure__c= 'Applicable';
        auditObj3.Q_4_Regulatory_Compliance__c= 'Applicable';
        auditObj3.Q_5_Quality_Systems__c= 'Applicable';
        
        insert auditObj3;
        
        Audit_Notes__c auditNoteObj2 = new Audit_Notes__c();
        auditNoteObj2.Audit__c = auditObj2.Id;
        auditNoteObj2.Title__c = 'Testing';
        auditNoteObj2.Description__c = 'Testing'; 
        auditNoteObj2.Consequence__c = 'Minor'; 
        auditNoteObj2.Help_Needed__c = 'No';  
        
        insert auditNoteObj2;
        
        Audit_Notes__c auditNoteObj3 = new Audit_Notes__c();
        auditNoteObj3.Audit__c = auditObj3.Id;
        auditNoteObj3.Title__c = 'Testing';
        auditNoteObj3.Description__c = 'Testing'; 
        auditNoteObj3.Consequence__c = 'Minor'; 
        auditNoteObj3.Help_Needed__c = 'No';  
        
        insert auditNoteObj3;
                
        Test.StopTest();
    }
    
    /*
    static testMethod void createAuditNotesRecord_Test(){
       Audit__c auditObj = [SELECT ID, Name FROM Audit__c LIMIT 1];
       
       List<Audit_Notes__c> auditNoteList = new List<Audit_Notes__c>();
       
       Audit_Notes__c auditNoteObj1 = new Audit_Notes__c();
       auditNoteObj1.Audit__c = auditObj.Id;
       auditNoteObj1.Title__c = 'Testing';
       auditNoteObj1.Description__c = 'Testing'; 
       auditNoteObj1.Consequence__c = 'Minor'; 
       auditNoteObj1.Help_Needed__c = 'No';  
       auditNoteList.add(auditNoteObj1);
       
       Audit_Notes__c auditNoteObj2 = new Audit_Notes__c ();
       auditNoteObj2.Audit__c = auditObj.Id;
       auditNoteObj2.Title__c = 'Testing';
       auditNoteObj2.Description__c = 'Testing'; 
       auditNoteObj2.Consequence__c = 'Minor'; 
       auditNoteObj2.Help_Needed__c = 'No';  
       auditNoteList.add(auditNoteObj2);
       
       Audit_Notes__c auditNoteObj3 = new Audit_Notes__c();
       auditNoteObj3.Audit__c = auditObj.Id;
       auditNoteObj3.Title__c = 'Testing';
       auditNoteObj3.Description__c = 'Testing'; 
       auditNoteObj3.Consequence__c = 'Minor'; 
       auditNoteObj3.Help_Needed__c = 'No';  
       auditNoteList.add(auditNoteObj3);

       insert auditNoteList; 
    }   
    */
}