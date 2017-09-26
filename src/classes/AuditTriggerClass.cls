// Updated by NM: added logic for updating multiple audit records

public with sharing class AuditTriggerClass {
    
    final static Set<String> WEIGHTEDANSWERS = new Set<String>{'Yes','Acceptable'};
    final static string NotApplicablestring = 'Not Applicable';
    private Map<string,List<id>> finalResellerMap {get;set;}
    public AuditTriggerClass() {
        finalResellerMap = new Map<string,List<id>>();        
    }
    
    // Get Record type IDs
    final static id noWarehouse = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('Reseller - no warehouse').getRecordTypeId();
    final static id includingWarehouse = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('Reseller - including warehouse').getRecordTypeId();
    final static id multipleResellers = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('3rd party warehouse - multiple resellers').getRecordTypeId();

    public static void calculateQuestionScores(List<Audit__c> auditsList) {
        //system.debug('@@@ calculateQuestionScores');
        List<Schema.FieldSetMember> systemMgmtQuestions = new List<Schema.FieldSetMember>();
        
        // Reseller - no warehouse    
        List<Schema.FieldSetMember> generalQuestionsNW = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> warehouseQuestionsNW = new List<Schema.FieldSetMember>();
        
        // Reseller - including warehouse
        List<Schema.FieldSetMember> generalQuestionsIW = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> warehouseQuestionsIW = new List<Schema.FieldSetMember>();
        
        // 3rd party - multiple resellers
        List<Schema.FieldSetMember> generalQuestionsMR = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> warehouseQuestionsMR = new List<Schema.FieldSetMember>();
        
        
        // Get fields from defined field sets
        systemMgmtQuestions =  SObjectType.Audit__c.FieldSets.Qs_Stock_Management_System.getFields();
        
        // Reseller - no warehouse
        generalQuestionsNW = SObjectType.Audit__c.FieldSets.Qs_General_Questions_no_warehouse.getFields();
        warehouseQuestionsNW =  SObjectType.Audit__c.FieldSets.Qs_Warehouse_Facilities_no_warehouse.getFields();
        
        // Reseller - including warehouse
        generalQuestionsIW = SObjectType.Audit__c.FieldSets.Qs_General_Questions_including_warehous.getFields();
        warehouseQuestionsIW =  SObjectType.Audit__c.FieldSets.Qs_Warehouse_Facilities_including_wareh.getFields();
        
        // 3rd party - multiple resellers
        generalQuestionsMR = SObjectType.Audit__c.FieldSets.Qs_General_Questions_multiple_resellers.getFields();
        warehouseQuestionsMR =  SObjectType.Audit__c.FieldSets.Qs_Warehouse_Facilities_multiple_resell.getFields();
                
        //generalQuestions = SObjectType.Audit__c.FieldSets.Qs_General_Questions.getFields();
        //warehouseQuestions =  SObjectType.Audit__c.FieldSets.Qs_Warehouse_Facilities.getFields();
        //systemMgmtQuestions =  SObjectType.Audit__c.FieldSets.Qs_Stock_Management_System.getFields();
        //system.debug('##generalQuestionsNW: ' + generalQuestionsNW);
        //system.debug('##warehouseQuestionsNW: ' + warehouseQuestionsNW);
        //system.debug('##generalQuestionsIW: ' + generalQuestionsIW);
        //system.debug('##warehouseQuestionsMR: ' + warehouseQuestionsMR);
        //system.debug('##generalQuestionsMR: ' + generalQuestionsMR);
        //system.debug('##warehouseQuestionsMR: ' + warehouseQuestionsMR);
        //system.debug('##systemMgmtQuestions: ' + systemMgmtQuestions);

        List<String> systemMgmtQuestionsAPI = new List<String>();
        
        // Reseller - no warehouse
        List<String> generalQuestionsNWAPI = new List<String>();
        List<String> warehouseQuestionsNWAPI = new List<String>();
        
        // Reseller - including warehouse
        List<String> generalQuestionsIWAPI = new List<String>();
        List<String> warehouseQuestionsIWAPI = new List<String>();
        
        // 3rd party - multiple resellers
        List<String> generalQuestionsMRAPI = new List<String>();
        List<String> warehouseQuestionsMRAPI = new List<String>();

        if(generalQuestionsNWAPI != null) {
            for(FieldSetMember fsm : generalQuestionsNW) {
                generalQuestionsNWAPI.add(fsm.getFieldPath());
            }
        }
        //system.debug('##generalQuestionsNWAPI: ' + generalQuestionsNWAPI);

        if(warehouseQuestionsNWAPI != null) {
            for(FieldSetMember fsm : warehouseQuestionsNW) {
                warehouseQuestionsNWAPI.add(fsm.getFieldPath());
            }
        }
        //system.debug('##warehouseQuestionsNWAPI: ' + warehouseQuestionsNWAPI);

        if(systemMgmtQuestionsAPI != null) {
            for(FieldSetMember fsm : systemMgmtQuestions) {
                systemMgmtQuestionsAPI.add(fsm.getFieldPath());
            }
        }
        //system.debug('##systemMgmtQuestionsAPI: ' + systemMgmtQuestionsAPI);

        if(generalQuestionsIWAPI != null) {
            for(FieldSetMember fsm : generalQuestionsIW) {
                generalQuestionsIWAPI.add(fsm.getFieldPath());
            }
        }
        //system.debug('##generalQuestionsIWAPI: ' + generalQuestionsIWAPI);

        if(warehouseQuestionsIWAPI != null) {
            for(FieldSetMember fsm : warehouseQuestionsIW) {
                warehouseQuestionsIWAPI.add(fsm.getFieldPath());
            }
        }
        //system.debug('##warehouseQuestionsIWAPI: ' + warehouseQuestionsIWAPI);
        
        if(generalQuestionsMRAPI != null) {
            for(FieldSetMember fsm : generalQuestionsMR) {
                generalQuestionsMRAPI.add(fsm.getFieldPath());
            }
        }
        //system.debug('##generalQuestionsMRAPI: ' + generalQuestionsMRAPI);

        if(warehouseQuestionsMRAPI != null) {
            for(FieldSetMember fsm : warehouseQuestionsMR) {
                warehouseQuestionsMRAPI.add(fsm.getFieldPath());
            }
        }
        system.debug('##warehouseQuestionsMRAPI: ' + warehouseQuestionsMRAPI);       
                
        for(Audit__c au: auditsList) {
                   
            List<String> gQAPI = new List<String>();
            List<String> wFAPI = new List<String>();
            if(au.recordtypeid == noWarehouse) {
                gQAPI = generalQuestionsNWAPI;
                wFAPI = warehouseQuestionsNWAPI;
                //system.debug('##NO WAREHOUSE');
            }
            else if(au.recordtypeid == includingWarehouse) {
                gQAPI = generalQuestionsIWAPI;
                wFAPI = warehouseQuestionsIWAPI;
                //system.debug('##INCLUDING WAREHOUSE');
            }
            else if(au.recordtypeid == multipleResellers) {
                gQAPI = generalQuestionsMRAPI;
                wFAPI = warehouseQuestionsMRAPI;
                //system.debug('##MULTIPLE RESELLER');
            }
            
            // CALCULATE GENERAL SCORE
            //system.debug('##AUDIT: ' + au.ID);
            Decimal generalScore = 0;
            Decimal generalNotApplicable = 0;
            for(String fieldAPI : gQAPI) {
                //system.debug('##FIELD VALUE: ' + fieldAPI + ' ' + au.get(fieldAPI));
                //system.debug('##WEIGHTEDANSWERS: ' + WEIGHTEDANSWERS);              
                if(WEIGHTEDANSWERS.contains(String.valueOf(au.get(fieldAPI)))) {
                    generalScore = generalScore+1;
                }
                if(String.ValueOf(au.get(fieldAPI)) == NotApplicablestring){
                    generalNotApplicable = generalNotApplicable + 1;
                }
            }
            //system.debug('##GENERAL SCORE:' + generalScore);      
            
            //Calculate Percentage      
            if ((gQAPI.size() - generalNotApplicable) != 0){
                au.General_Questions_Score__c = (generalScore/(gQAPI.size() - generalNotApplicable) )*100;
            }else {
                 au.General_Questions_Score__c = 0;
            }
            
            // CALCULATE WAREHOUSE SCORE
            Decimal warehouseScore = 0;
            Decimal WarehousenotApplicable= 0;
            for(String fieldAPI : wFAPI) {
                if(WEIGHTEDANSWERS.contains(String.valueOf(au.get(fieldAPI)))) {
                    warehouseScore = warehouseScore+1;
                }
                if(String.ValueOf(au.get(fieldAPI)) == NotApplicablestring ){
                    WarehousenotApplicable= WarehousenotApplicable + 1;
                }
            }
            //system.debug('##WAREHOUSE SCORE:' + warehouseScore);
            
            //Calculate Percentage
            if ((wFAPI.size() - WarehousenotApplicable) != 0){
                au.Warehouse_Facilities_Score__c = (warehouseScore/(wFAPI.size() - WarehousenotApplicable))*100;
            }else {
                au.Warehouse_Facilities_Score__c = 0;
            }
            
            // CALCULATE SYSTEM MANAGEMENT SYSTEMS SCORE
            Decimal systemMgmtScore = 0;
            Decimal systemMgmtNotApplicable = 0;
            for(String fieldAPI : systemMgmtQuestionsAPI) {
                if(WEIGHTEDANSWERS.contains(String.valueOf(au.get(fieldAPI)))) {
                    systemMgmtScore = systemMgmtScore+1;
                }
                if(String.ValueOf(au.get(fieldAPI)) == NotApplicablestring ){
                    systemMgmtNotApplicable = systemMgmtNotApplicable +1;
                }
            }
            //system.debug('##SYSTEM SCORE:' + systemMgmtScore);
            
            //Calculate Percentage
            if ((systemMgmtQuestionsAPI.size()-systemMgmtNotApplicable) != 0){
                au.Stock_Management_System_Score__c = (systemMgmtScore/(systemMgmtQuestionsAPI.size()-systemMgmtNotApplicable ))*100;
            }else {
                au.Stock_Management_System_Score__c = 0;
            }
            
            
            // CALCULATE TOTAL AUDIT SCORE
            Decimal totalScore = generalScore+warehouseScore+systemMgmtScore;
            Integer totalQuestionSize = (gQAPI.size() - integer.valueof(generalNotApplicable) )+(wFAPI.size() - integer.valueof(WarehousenotApplicable)) +(systemMgmtQuestionsAPI.size() - integer.valueof(systemMgmtNotApplicable) ) ;
            
            if (totalQuestionSize  != 0){
                au.Total_Audit_Score__C = (totalScore/totalQuestionSize)*100;
            }else {
                au.Total_Audit_Score__C = 0;
            }
        }
    }
    
    public static void copyPreviousAuditScores(List<Audit__c> newAudits) {
        //system.debug('@@@ copyPreviousAuditScores');
        
        Set<Id> accIds = new Set<Id>();
        //Retrieve Account IDs
        for(Audit__c au : newAudits) {
            accIDs.add(au.Reseller__c);
        }
                
        List<Account> accForUpdate = new List<Account>();
        if(!accIds.isEmpty()) {
        for(Account acc : [SELECT id, Previous_General_Questions_Score__c, Previous_Stock_Management_System_Score__c,Previous_Total_Audit_Score__c,Previous_Warehouse_Facilities_Score__c,
                           (SELECT Id, General_Questions_Score__c,Stock_Management_System_Score__c,Total_Audit_Score__c,Warehouse_Facilities_Score__c 
                            FROM Audits__r
                            ORDER BY CreatedDate DESC)
                           FROM Account 
                           WHERE Id in: accIds ]) {
                               //Retrieve Last Created Audit
                               if(acc.Audits__r.size() > 1) {
                                   Audit__c prevAudit = acc.Audits__r[1];
                                   
                                   acc.Previous_General_Questions_Score__c = prevAudit.General_Questions_Score__c;
                                   acc.Previous_Stock_Management_System_Score__c = prevAudit.Stock_Management_System_Score__c;
                                   acc.Previous_Warehouse_Facilities_Score__c = prevAudit.Warehouse_Facilities_Score__c;
                                   acc.Previous_Total_Audit_Score__c = prevAudit.Total_Audit_Score__c;
                                   accForUpdate.add(acc);
                               }
                           }
        }
        
        //system.debug('@@@ accForUpdate: ' + accForUpdate);
        if(!accForUpdate.isEmpty()) {
            update accForUpdate;
        }
    }
    /*
    public static void commitShares( audit__c[] audits ){
        // @author JS @Davanti 09/16
        audit__share[] shares = new audit__share[]{};
            
            map<id,id> accountGroups = getRoles( audits );
        
        for ( audit__c a : [select id, ownerid, reseller__r.ownerId 
                            from audit__c where id =: audits and reseller__c != null and reseller__r.owner.isactive = true ])
            if ( a.ownerId != a.reseller__r.ownerId   )
                shares.add (
                    new audit__share ( 
                        parentid = a.id,
                        UserOrGroupId = a.reseller__r.ownerid,
                        AccessLevel = 'Read' ) );
        
        
        for ( audit__c a : audits)
            if ( accountGroups.get( a.reseller__c ) != null )
                shares.add(
                    new audit__share ( 
                        parentid = a.id,
                        UserOrGroupId = accountGroups.get( a.reseller__c ),
                        AccessLevel = 'Read'));

        insert shares;
    }
    static map<id, id> getRoles( audit__c[] audits ){
        // gets roles for the supplied accounts ids
        set<id> accounts = new set<id>();
        for ( audit__c i : audits )
            accounts.add ( i.reseller__c );
        
        map<id,id> userRoles = new map<id,id>();
        for (user u: [select accountid, userroleid 
                      from user where accountId =: accounts ])
            userRoles.put( u.userroleid, u.accountid );
        
        return rolesHelper(userRoles);
    }
    
    static map<id, id> rolesHelper( map<id, id> userRoles ){
        // gets groups for the supplied role ids, as we can only share with groups
        map<id,id> groupRoles = new map<id,id>();
        map<id,id> accountGroups = new map<id,id>();
                
        for (group u: [ select id, relatedid
                       from group 
                       where relatedid =: userRoles.keySet() 
                       and type='RoleAndSubordinates'])
            groupRoles.put( u.relatedid, u.id );    
        
        for ( id i : groupRoles.keyset() )
            accountGroups.put( userRoles.get( i ) , groupRoles.get( i ) );
        
        return accountGroups;
    }
    */
    
    public map<string,List<id>> gatherResellerInfo(List<Audit__c> auditList){
        //system.debug('@@@ gatherResellerInfo');
        
        map<string,List<Id>> resellersetMap = new map<string,List<id>>();
        List<id> resellerInfoSet = new List<Id>();
        finalResellerMap =  new map<string,List<id>>();
        for (Audit__c adt : auditList){
            if (adt.Formyoula_Entry_ID__c != null){
                If (adt.Reseller2__c != null){
                    resellerInfoSet.add(adt.Reseller2__c);
                    adt.Reseller2__c = null;                
                }
                If (adt.Reseller3__c != null){
                    resellerInfoSet.add(adt.Reseller3__c);   
                    adt.Reseller3__c = null ;              
                }
                If (adt.Reseller4__c != null){
                    resellerInfoSet.add(adt.Reseller4__c);  
                    adt.Reseller4__c = null ;                
                }
                If (adt.Reseller5__c != null){
                    resellerInfoSet.add(adt.Reseller5__c); 
                    adt.Reseller5__c = null;                 
                }
                If (adt.Reseller6__c != null){
                    resellerInfoSet.add(adt.Reseller6__c); 
                    adt.Reseller6__c = null ;                
                }
                If (adt.Reseller7__c != null){
                    resellerInfoSet.add(adt.Reseller7__c);  
                    adt.Reseller7__c = null ;      
                }    
                If (adt.Reseller8__c != null){
                    resellerInfoSet.add(adt.Reseller8__c);
                    adt.Reseller8__c = null;                  
                }
                If (adt.Reseller9__c != null){
                    resellerInfoSet.add(adt.Reseller9__c); 
                    adt.Reseller9__c = null;               
                }
                If (adt.Reseller10__c != null){
                    resellerInfoSet.add(adt.Reseller10__c);
                    adt.Reseller10__c = null;                   
                }
                resellersetMap.put(adt.Formyoula_Entry_ID__c ,resellerInfoSet); 
            }
        }
        
        //system.debug('!!!!! fire code before insert' + resellersetMap );
        finalResellerMap = resellersetMap;
        system.debug('@@@ call processResellerAuditRecords');
        processResellerAuditRecords pRAR = new processResellerAuditRecords(finalResellerMap ); 
        System.enqueueJob(pRAR );
        return resellersetMap;      
    }    
    
    // Update multiple audit records
    public static void updateMultipleAuditRecords(List<Audit__c> auditList) {
        //system.debug('@@@ updateMultipleAuditRecords');
        
        // Get Parent Audit
        List<Audit__c> parentAudit = new List<Audit__c>();
        for (integer i = 0; i < auditList.size(); i ++){
            parentAudit.add(auditList[i]);
        }
        //system.debug('@@@ parentAudit: ' + parentAudit);
        
        if(!parentAudit.isEmpty()) {            
            // Get fields of audit linked to parent audit
            List<Audit__c> auditToUpdateList = new List<Audit__c>([select Id, Reseller__c, Authorized_Markets__c, Warehouse_Office_Assessed__c, 
                                                                            Products_Ingredients_Stored__c, Assessment_Completed_By__c, Assessment_Date__c, 
                                                                            Next_Assessment_Due__c, Next_Progress_Action_List_Update_Due__c, Reseller_Attendees__c, 
                                                                            Q_17_Ambient_Temperature__c, Q_10_Business_Continuity_Plan__c, Q_7_Complaint_Handling__c, Q_15_Control_of_Storage__c, Q_8_Escalation__c,
                                                                            Q_14_Facilities_Loading_Bays__c, Q_13_Facilities_Storage_Area__c, Q_24_Food_Safety_Risk__c, Q_9_Health_and_Safety_Procedures__c, Q_33_Information_Security__c,
                                                                            Q_2_Insurance__c, Q_27_Inwards_Goods_Management__c, Q_11_NZMP_Brand_Use__c, Q_29_On_Hold_Product__c, Q_3_Organisation_Structure__c, Q_26_Pest_Management__c,
                                                                            Q_28_Product_Release__c, Q_16_Product_Storage__c, Q_22_Property_Risk__c, Q_5_Quality_Systems__c, Q_30_Recall_Documentation__c, Q_20_Refrigeration__c,
                                                                            Q_4_Regulatory_Compliance__c, Q_18_Relative_Humidity__c, Q_25_Security__c, Q_6_Staff_Training__c, Q_12_Stock_Control_Spot_Check__c, Q_34_Stock_Management__c,
                                                                            Q_35_Stock_Reconciliation__c, Q_31_Traceability_Documentation__c, Q_32_Traceability_level_of_trace__c, Q_1_Trading_Transperency__c, Q_21_Vehicle_Condition__c,
                                                                            Q_23_Warehouse_Equipment__c, Q_19_Water_Control__c, Third_Party_Warehousing__c, Product_Disposal__c, Mark_as_Complete__c, Reseller_Signature_URL__c,
                                                                            Auditor_Signature_URL__c, ParentAuditId__c
                                                                    from Audit__c where ParentAuditId__c = :parentAudit[0].Id]);
            //system.debug('### auditToUpdateList: ' + auditToUpdateList);
            
            List<Audit__c> updateList;
            // Copy details from parent audit
            if(auditToUpdateList.size() > 0) {
                updateList = new List<Audit__c>();
                for(integer i = 0; i < auditToUpdateList.size(); i++) {
                    if(auditToUpdateList[i].Id != parentAudit[0].Id) {
                        auditToUpdateList[i].Authorized_Markets__c = parentAudit[0].Authorized_Markets__c;
                        auditToUpdateList[i].Warehouse_Office_Assessed__c =  parentAudit[0].Warehouse_Office_Assessed__c;
                        auditToUpdateList[i].Products_Ingredients_Stored__c =  parentAudit[0].Products_Ingredients_Stored__c;
                        auditToUpdateList[i].Assessment_Completed_By__c =  parentAudit[0].Assessment_Completed_By__c;
                        auditToUpdateList[i].Assessment_Date__c =  parentAudit[0].Assessment_Date__c;
                        auditToUpdateList[i].Next_Assessment_Due__c =  parentAudit[0].Next_Assessment_Due__c;
                        auditToUpdateList[i].Next_Progress_Action_List_Update_Due__c =  parentAudit[0].Next_Progress_Action_List_Update_Due__c;
                        auditToUpdateList[i].Reseller_Attendees__c =  parentAudit[0].Reseller_Attendees__c;
                        auditToUpdateList[i].Q_17_Ambient_Temperature__c =  parentAudit[0].Q_17_Ambient_Temperature__c;
                        auditToUpdateList[i].Q_10_Business_Continuity_Plan__c =  parentAudit[0].Q_10_Business_Continuity_Plan__c;
                        auditToUpdateList[i].Q_7_Complaint_Handling__c =  parentAudit[0].Q_7_Complaint_Handling__c;
                        auditToUpdateList[i].Q_15_Control_of_Storage__c =  parentAudit[0].Q_15_Control_of_Storage__c;
                        auditToUpdateList[i].Q_8_Escalation__c =  parentAudit[0].Q_8_Escalation__c;
                        auditToUpdateList[i].Q_14_Facilities_Loading_Bays__c =  parentAudit[0].Q_14_Facilities_Loading_Bays__c;
                        auditToUpdateList[i].Q_13_Facilities_Storage_Area__c =  parentAudit[0].Q_13_Facilities_Storage_Area__c;
                        auditToUpdateList[i].Q_24_Food_Safety_Risk__c =  parentAudit[0].Q_24_Food_Safety_Risk__c;
                        auditToUpdateList[i].Q_9_Health_and_Safety_Procedures__c =  parentAudit[0].Q_9_Health_and_Safety_Procedures__c;
                        auditToUpdateList[i].Q_33_Information_Security__c =  parentAudit[0].Q_33_Information_Security__c;
                        auditToUpdateList[i].Q_2_Insurance__c =  parentAudit[0].Q_2_Insurance__c;
                        auditToUpdateList[i].Q_27_Inwards_Goods_Management__c =  parentAudit[0].Q_27_Inwards_Goods_Management__c;
                        auditToUpdateList[i].Q_11_NZMP_Brand_Use__c =  parentAudit[0].Q_11_NZMP_Brand_Use__c;
                        auditToUpdateList[i].Q_29_On_Hold_Product__c =  parentAudit[0].Q_29_On_Hold_Product__c;
                        auditToUpdateList[i].Q_3_Organisation_Structure__c =  parentAudit[0].Q_3_Organisation_Structure__c;
                        auditToUpdateList[i].Q_26_Pest_Management__c =  parentAudit[0].Q_26_Pest_Management__c;
                        auditToUpdateList[i].Q_28_Product_Release__c =  parentAudit[0].Q_28_Product_Release__c;
                        auditToUpdateList[i].Q_16_Product_Storage__c =  parentAudit[0].Q_16_Product_Storage__c;
                        auditToUpdateList[i].Q_22_Property_Risk__c =  parentAudit[0].Q_22_Property_Risk__c;
                        auditToUpdateList[i].Q_5_Quality_Systems__c =  parentAudit[0].Q_5_Quality_Systems__c;
                        auditToUpdateList[i].Q_30_Recall_Documentation__c =  parentAudit[0].Q_30_Recall_Documentation__c;
                        auditToUpdateList[i].Q_20_Refrigeration__c =  parentAudit[0].Q_20_Refrigeration__c;
                        auditToUpdateList[i].Q_4_Regulatory_Compliance__c =  parentAudit[0].Q_4_Regulatory_Compliance__c;
                        auditToUpdateList[i].Q_18_Relative_Humidity__c =  parentAudit[0].Q_18_Relative_Humidity__c;
                        auditToUpdateList[i].Q_25_Security__c =  parentAudit[0].Q_25_Security__c;
                        auditToUpdateList[i].Q_6_Staff_Training__c =  parentAudit[0].Q_6_Staff_Training__c;
                        auditToUpdateList[i].Q_12_Stock_Control_Spot_Check__c =  parentAudit[0].Q_12_Stock_Control_Spot_Check__c;
                        auditToUpdateList[i].Q_34_Stock_Management__c =  parentAudit[0].Q_34_Stock_Management__c;
                        auditToUpdateList[i].Q_35_Stock_Reconciliation__c =  parentAudit[0].Q_35_Stock_Reconciliation__c;
                        auditToUpdateList[i].Q_31_Traceability_Documentation__c =  parentAudit[0].Q_31_Traceability_Documentation__c;
                        auditToUpdateList[i].Q_32_Traceability_level_of_trace__c =  parentAudit[0].Q_32_Traceability_level_of_trace__c;
                        auditToUpdateList[i].Q_1_Trading_Transperency__c =  parentAudit[0].Q_1_Trading_Transperency__c;
                        auditToUpdateList[i].Q_21_Vehicle_Condition__c =  parentAudit[0].Q_21_Vehicle_Condition__c;
                        auditToUpdateList[i].Q_23_Warehouse_Equipment__c =  parentAudit[0].Q_23_Warehouse_Equipment__c;
                        auditToUpdateList[i].Q_19_Water_Control__c =  parentAudit[0].Q_19_Water_Control__c;
                        auditToUpdateList[i].Third_Party_Warehousing__c =  parentAudit[0].Third_Party_Warehousing__c;
                        auditToUpdateList[i].Product_Disposal__c =  parentAudit[0].Product_Disposal__c;
                        auditToUpdateList[i].Mark_as_Complete__c =  parentAudit[0].Mark_as_Complete__c;
                        auditToUpdateList[i].Reseller_Signature_URL__c =  parentAudit[0].Reseller_Signature_URL__c;
                        auditToUpdateList[i].Auditor_Signature_URL__c =  parentAudit[0].Auditor_Signature_URL__c;
                        
                        updateList.add(auditToUpdateList[i]);
                    }
                }
            }
            //system.debug('### updateList: ' + updateList);
            
            // Update audit
            if(updateList != null && updateList.size() > 0) {
                update updateList;
            }  
        }
    }
   
}