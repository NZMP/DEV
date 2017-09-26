@isTest
private class AuditTriggerClassTest {

    // Get Record type IDs
    final static id noWarehouseId = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('Reseller - no warehouse').getRecordTypeId();
    final static id includingWarehouseId = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('Reseller - including warehouse').getRecordTypeId();
    final static id multipleResellersId = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('3rd party warehouse - multiple resellers').getRecordTypeId();


    @testSetup static void testData() {
        Id SoldToRtypeID = [SELECT Id FROM RecordType WHERE Name = 'Sold To Party'].Id;

        Account acc = new Account();
        acc.Name = 'TestAuditAccount';
        acc.RecordtypeId = SoldToRtypeID;
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'TestAuditAccount2';
        acc2.RecordtypeId = SoldToRtypeID;
        insert acc2;
    }
    
    @isTest static void AuditTriggerTest() {
        AuditTriggerClass atc = new AuditTriggerClass();
        
        Audit__c aud1 = new Audit__c();
        aud1.Reseller__c = [SELECT Id FROM Account WHERE Name ='TestAuditAccount'].Id;
        aud1.RecordtypeId = noWarehouseId;
        aud1.Q_1_Trading_Transperency__c = 'Acceptable';
        aud1.Q_10_Business_Continuity_Plan__c = 'Acceptable';
        aud1.Q_12_Stock_Control_Spot_Check__c = 'Acceptable';
        aud1.Q_29_On_Hold_Product__c = 'Acceptable';
        aud1.Q_30_Recall_Documentation__c = 'Acceptable';
        aud1.Q_32_Traceability_level_of_trace__c = 'Acceptable';
        aud1.Formyoula_Entry_ID__c = 'formyoulaId';

        Test.startTest();
        insert aud1;
        
        // Reseller - no warehouse
        Audit__c audScores = [SELECT Id,    General_Questions_Score__c,Stock_Management_System_Score__c,Warehouse_Facilities_Score__c, Total_Audit_Score__c FROM Audit__c WHERE  Reseller__r.Name = 'TestAuditAccount'];
        system.debug('##AUDIT SCORES: ' + audScores);
        system.assert(audScores.General_Questions_Score__c != null);
        system.assert(audScores.Stock_Management_System_Score__c != null);
        system.assert(audScores.Warehouse_Facilities_Score__c != null);
        system.assert(audScores.Total_Audit_Score__c != null);

        aud1.Q_1_Trading_Transperency__c = '';
        update aud1;
        
        Audit__c audScores2 = [SELECT Id,   General_Questions_Score__c,Stock_Management_System_Score__c,Warehouse_Facilities_Score__c, Total_Audit_Score__c FROM Audit__c WHERE  Reseller__r.Name = 'TestAuditAccount'];
        system.debug('##AUDIT SCORES: ' + audScores2);
        system.assert(audScores.General_Questions_Score__c != audScores2.General_Questions_Score__c);
        system.assert(audScores.Total_Audit_Score__c != audScores2.Total_Audit_Score__c);


        // Reseller - single warehouse
        Audit__c aud2 = new Audit__c();
        aud2.Reseller__c = [SELECT Id FROM Account WHERE Name ='TestAuditAccount'].Id;
        aud2.RecordtypeId = includingWarehouseId;
        aud2.Warehouse_Office_Assessed__c = 'Test Warehouse';
        aud2.Q_1_Trading_Transperency__c = 'Acceptable';
        aud2.Product_Disposal__c = 'Acceptable';
        aud2.Q_29_On_Hold_Product__c = 'Acceptable';
        aud2.Formyoula_Entry_ID__c = 'formyoulaId2';

        insert aud2;
        
        Audit__c audScores3 = [SELECT Id, General_Questions_Score__c,Stock_Management_System_Score__c,Warehouse_Facilities_Score__c, Total_Audit_Score__c FROM Audit__c WHERE  Id =: aud2.Id];       
        system.debug('##AUDIT SCORES: ' + audScores);
        system.assert(audScores3.General_Questions_Score__c != null);
        system.assert(audScores3.Stock_Management_System_Score__c != null);
        system.assert(audScores3.Warehouse_Facilities_Score__c != null);
        system.assert(audScores3.Total_Audit_Score__c != null);

        Account acc = [SELECT Id,Previous_General_Questions_Score__c,Previous_Stock_Management_System_Score__c,
                        Previous_Warehouse_Facilities_Score__c,Previous_Total_Audit_Score__c FROM Account WHERE Name = 'TestAuditAccount'];
        system.debug(acc);
        system.assertEquals(acc.Previous_General_Questions_Score__c, audScores2.General_Questions_Score__c);
        system.assertEquals(acc.Previous_Stock_Management_System_Score__c, audScores2.Stock_Management_System_Score__c);
        system.assertEquals(acc.Previous_Warehouse_Facilities_Score__c, audScores2.Warehouse_Facilities_Score__c);
        system.assertEquals(acc.Previous_Total_Audit_Score__c, audScores2.Total_Audit_Score__c);

        // 3rd party warehouse - multi resellers
        Audit__c aud3 = new Audit__c();
        aud3.Reseller__c = [SELECT Id FROM Account WHERE Name ='TestAuditAccount'].Id;
        //aud3.Reseller2__c = [SELECT Id FROM Account WHERE Name ='TestAuditAccount2'].Id;
        aud3.RecordtypeId = multipleResellersId;
        aud3.Warehouse_Office_Assessed__c = 'Test warehouse for multiple resellers';
        aud3.Q_2_Insurance__c = 'Acceptable';
        aud3.Q_12_Stock_Control_Spot_Check__c = 'Acceptable';
        aud3.Q_33_Information_Security__c = 'Acceptable';
        aud3.Formyoula_Entry_ID__c = 'formyoulaId3';

        insert aud3;
        
        Audit__c aud4 = new Audit__c();
        aud4.Reseller__c = [SELECT Id FROM Account WHERE Name ='TestAuditAccount2'].Id;
        aud4.RecordtypeId = multipleResellersId;
        aud4.Warehouse_Office_Assessed__c = 'Test warehouse for multiple resellers';
        aud4.Q_2_Insurance__c = 'Acceptable';
        aud4.Q_12_Stock_Control_Spot_Check__c = 'Acceptable';
        aud4.Q_33_Information_Security__c = 'Acceptable';
        aud4.Formyoula_Entry_ID__c = 'formyoulaId3';
        aud4.ParentAuditId__c = aud3.Id;

        insert aud4;
        
        Audit__c audScores4 = [SELECT Id, General_Questions_Score__c,Stock_Management_System_Score__c,Warehouse_Facilities_Score__c, Total_Audit_Score__c FROM Audit__c WHERE  Id =: aud3.Id];       
        system.debug('##AUDIT SCORES: ' + audScores);
        system.assert(audScores4.General_Questions_Score__c != null);
        system.assert(audScores4.Stock_Management_System_Score__c != null);
        system.assert(audScores4.Warehouse_Facilities_Score__c != null);
        system.assert(audScores4.Total_Audit_Score__c != null);

        aud3.Q_33_Information_Security__c = 'Not Applicable';
        update aud3;
        
        Account acc2 = [SELECT Id,Previous_General_Questions_Score__c,Previous_Stock_Management_System_Score__c,
                        Previous_Warehouse_Facilities_Score__c,Previous_Total_Audit_Score__c FROM Account WHERE Name = 'TestAuditAccount2'];
        system.debug(acc);
        system.assertEquals(acc.Previous_General_Questions_Score__c, audScores2.General_Questions_Score__c);
        system.assertEquals(acc.Previous_Stock_Management_System_Score__c, audScores2.Stock_Management_System_Score__c);
        system.assertEquals(acc.Previous_Warehouse_Facilities_Score__c, audScores2.Warehouse_Facilities_Score__c);
        system.assertEquals(acc.Previous_Total_Audit_Score__c, audScores2.Total_Audit_Score__c);

        Test.stopTest();
    }
}