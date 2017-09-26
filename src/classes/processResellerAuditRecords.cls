/**************
* Author: MahmoodZ(DC) 
* Description: Queuable Apex code for the the rolling down the encrypted field values for the Account Object. 
* History: 
* 10Aug2016 MahmoodZ(DC): Initial version. 
* 11Aug2016 MahmoodZ(DC) : Adding the insert of Audit_Notes records 
**********/

public class processResellerAuditRecords Implements Queueable{
    
    //Map to hold the Accounts Ids and the list of Fields Effected per accountid
    
    private Map<string,List<id>> resellerMap {get;set;}
    
    // Get Record type IDs
    final static id multipleResellersID = Schema.SObjectType.Audit__c.getRecordTypeInfosByName().get('3rd party warehouse - multiple resellers').getRecordTypeId();
        
    public processResellerAuditRecords(Map<string,List<Id>> resellerSetMap){
         resellerMap = new  Map<string,List<id>>();
         resellerMap = resellerSetMap;  
    } 
    
    public void execute(QueueableContext context){
        system.debug('### processResellerAuditRecords');
    
        system.debug(resellerMap);
        List<Audit__c> auditrecordsToInsert = new List<Audit__c>();
        List<Audit_Notes__c> auditNotesToInsert = new List<Audit_Notes__c>();
        List<Audit__c> auditRecordsProcess = [SELECT Id, Assessment_Completed_By__c,Assessment_Date__c,  Auditor_Signature_URL__c, Audit_Title__c, Authorized_Markets__c, Client_Site__c, Mark_as_Complete__c
                                                     ,Conducted_On__c, Document_No__c,Formyoula_Entry_ID__c, General_Questions_Score__c, General_Risk__c, Geolocation__c, Location__c, Next_Assessment_Due__c
                                                     ,Next_Progress_Action_List_Update_Due__c, Personnel__c, Prepared_By__c, Products_Ingredients_Stored__c, Q_10_Business_Continuity_Plan__c, Q_11_NZMP_Brand_Use__c
                                                     ,Q_12_Stock_Control_Spot_Check__c,Q_13_Facilities_Storage_Area__c, Q_14_Facilities_Loading_Bays__c,  Q_15_Control_of_Storage__c ,Q_16_Product_Storage__c
                                                     ,Q_17_Ambient_Temperature__c, Q_18_Relative_Humidity__c,Q_19_Water_Control__c,Q_1_Trading_Transperency__c,Q_20_Refrigeration__c,Q_21_Vehicle_Condition__c,Q_22_Property_Risk__c
                                                     ,Q_23_Warehouse_Equipment__c,Q_24_Food_Safety_Risk__c, Q_25_Security__c,Q_26_Pest_Management__c,Q_27_Inwards_Goods_Management__c,  Q_28_Product_Release__c
                                                     ,Q_29_On_Hold_Product__c, Q_2_Insurance__c,Q_30_Recall_Documentation__c,Q_31_Traceability_Documentation__c, Q_32_Traceability_level_of_trace__c, Q_33_Information_Security__c
                                                     ,Q_34_Stock_Management__c, Q_35_Stock_Reconciliation__c,Q_3_Organisation_Structure__c,  Q_4_Regulatory_Compliance__c,  Q_5_Quality_Systems__c,Q_6_Staff_Training__c
                                                     ,Q_7_Complaint_Handling__c, Q_8_Escalation__c, Q_9_Health_and_Safety_Procedures__c,  Region__c, Reseller__c, Reseller_Attendees__c, Reseller_Signature__c, Reseller_Signature_URL__c
                                                     ,Risk_Plan_In_Place__c, Risk_Plan_On_Track__c,Signature_URL__c, Stock_Management_System_Score__c,Systems_Risk__c,Total_Audit_Score__c,Warehouse_Office_Assessed__c, Warehouse_Facilities_Score__c
                                                     ,Warehouse_Risk__c , Third_Party_Warehousing__c, Product_Disposal__c
                                               FROM  Audit__c WHERE Formyoula_Entry_ID__c IN: resellerMap.Keyset()];        
        
        map<Id,Audit__c> AuditMap = new map<Id,Audit__c>();
        for(Audit__c adt :auditRecordsProcess){
           auditMap.put(adt.id,adt);    
        } 
        system.debug('!!!!!! auditRecordsProcess ' + auditRecordsProcess);
        system.debug('!!!!!! auditMap' + auditMap);
        ///List<Audit_Notes__c> auditNoteList = [SELECT Id, Name,Action_Plan__c,Audit__c,Audit__r.Formyoula_Entry_ID__c , Audit_Question__c,Category__c, Consequence__c, Controls__c, Controls_Rating__c , Description__c,
        ///                                           Due_Date__c,Help_Needed__c, Image__c, Likelihood__c, Notes__c, Photo_URL__c, Priority__c, Risk_Rating__c, Support__c, Title__c, User_Account__c
        ///                                      FROM Audit_Notes__c 
        ///                                      WHERE Audit__c IN: AuditMap.KeySet()];
        
        for(id auditId :auditMap.keyset() ){
           
            List<Id> newResellerIdList = resellerMap.get(auditMap.get(auditId).Formyoula_Entry_ID__c );
            system.debug('!!!!!! newResellerIdList ' + newResellerIdList );
            Audit__c oldAuditObj = new Audit__c();
            oldAuditObj  = auditMap.get(auditId);
            for (id resellerId : newResellerIdList){
                Audit__c auditObj = new Audit__c();
                auditObj.RecordTypeId                                   = multipleResellersID;
                auditObj.Assessment_Completed_By__c                     = oldAuditObj.Assessment_Completed_By__c ;                   
                auditObj.Assessment_Date__c                             = oldAuditObj.Assessment_Date__c ;                           
                auditObj.Auditor_Signature_URL__c                       = oldAuditObj.Auditor_Signature_URL__c ;                     
                auditObj.Audit_Title__c                                 = oldAuditObj.Audit_Title__c ;                               
                auditObj.Authorized_Markets__c                          = oldAuditObj.Authorized_Markets__c ;                        
                auditObj.Client_Site__c                                 = oldAuditObj.Client_Site__c ;                               
                auditObj.Mark_as_Complete__c                            = oldAuditObj.Mark_as_Complete__c ;                          
                auditObj.Conducted_On__c                                = oldAuditObj.Conducted_On__c ;                              
                auditObj.Document_No__c                                 = oldAuditObj.Document_No__c ;                               
                auditObj.Formyoula_Entry_ID__c                          = oldAuditObj.Formyoula_Entry_ID__c ;                        
                auditObj.General_Questions_Score__c                     = oldAuditObj.General_Questions_Score__c ;                                                                                
                auditObj.Location__c                                    = oldAuditObj.Location__c ;                                  
                auditObj.Next_Assessment_Due__c                         = oldAuditObj.Next_Assessment_Due__c ;                       
                auditObj.Next_Progress_Action_List_Update_Due__c        = oldAuditObj.Next_Progress_Action_List_Update_Due__c ;      
                auditObj.Personnel__c                                   = oldAuditObj.Personnel__c ;                                 
                auditObj.Prepared_By__c                                 = oldAuditObj.Prepared_By__c ;                               
                auditObj.Products_Ingredients_Stored__c                 = oldAuditObj.Products_Ingredients_Stored__c ;               
                auditObj.Q_10_Business_Continuity_Plan__c               = oldAuditObj.Q_10_Business_Continuity_Plan__c ;             
                auditObj.Q_11_NZMP_Brand_Use__c                         = oldAuditObj.Q_11_NZMP_Brand_Use__c ;                       
                auditObj.Q_12_Stock_Control_Spot_Check__c               = oldAuditObj.Q_12_Stock_Control_Spot_Check__c ;             
                auditObj.Q_13_Facilities_Storage_Area__c                = oldAuditObj.Q_13_Facilities_Storage_Area__c ;              
                auditObj.Q_14_Facilities_Loading_Bays__c                = oldAuditObj.Q_14_Facilities_Loading_Bays__c ;              
                auditObj.Q_15_Control_of_Storage__c                     = oldAuditObj.Q_15_Control_of_Storage__c ;                   
                auditObj.Q_16_Product_Storage__c                        = oldAuditObj.Q_16_Product_Storage__c ;                      
                auditObj.Q_17_Ambient_Temperature__c                    = oldAuditObj.Q_17_Ambient_Temperature__c ;                  
                auditObj.Q_18_Relative_Humidity__c                      = oldAuditObj.Q_18_Relative_Humidity__c ;                    
                auditObj.Q_19_Water_Control__c                          = oldAuditObj.Q_19_Water_Control__c ;                        
                auditObj.Q_1_Trading_Transperency__c                    = oldAuditObj.Q_1_Trading_Transperency__c ;                  
                auditObj.Q_20_Refrigeration__c                          = oldAuditObj.Q_20_Refrigeration__c ;                        
                auditObj.Q_21_Vehicle_Condition__c                      = oldAuditObj.Q_21_Vehicle_Condition__c ; 
                auditObj.Q_22_Property_Risk__c                          = oldAuditObj.Q_22_Property_Risk__c;                   
                auditObj.Q_23_Warehouse_Equipment__c                    = oldAuditObj.Q_23_Warehouse_Equipment__c ;                  
                auditObj.Q_24_Food_Safety_Risk__c                       = oldAuditObj.Q_24_Food_Safety_Risk__c ;                     
                auditObj.Q_25_Security__c                               = oldAuditObj.Q_25_Security__c ;                             
                auditObj.Q_26_Pest_Management__c                        = oldAuditObj.Q_26_Pest_Management__c ;                      
                auditObj.Q_27_Inwards_Goods_Management__c               = oldAuditObj.Q_27_Inwards_Goods_Management__c ;             
                auditObj.Q_28_Product_Release__c                        = oldAuditObj.Q_28_Product_Release__c ;                      
                auditObj.Q_29_On_Hold_Product__c                        = oldAuditObj.Q_29_On_Hold_Product__c ;                      
                auditObj.Q_2_Insurance__c                               = oldAuditObj.Q_2_Insurance__c ;                             
                auditObj.Q_30_Recall_Documentation__c                   = oldAuditObj.Q_30_Recall_Documentation__c ;                 
                auditObj.Q_31_Traceability_Documentation__c             = oldAuditObj.Q_31_Traceability_Documentation__c ;           
                auditObj.Q_32_Traceability_level_of_trace__c            = oldAuditObj.Q_32_Traceability_level_of_trace__c ;          
                auditObj.Q_33_Information_Security__c                   = oldAuditObj.Q_33_Information_Security__c ;                 
                auditObj.Q_34_Stock_Management__c                       = oldAuditObj.Q_34_Stock_Management__c ;                     
                auditObj.Q_35_Stock_Reconciliation__c                   = oldAuditObj.Q_35_Stock_Reconciliation__c ;                 
                auditObj.Q_3_Organisation_Structure__c                  = oldAuditObj.Q_3_Organisation_Structure__c ;                
                auditObj.Q_4_Regulatory_Compliance__c                   = oldAuditObj.Q_4_Regulatory_Compliance__c ;                 
                auditObj.Q_5_Quality_Systems__c                         = oldAuditObj.Q_5_Quality_Systems__c ;                       
                auditObj.Q_6_Staff_Training__c                          = oldAuditObj.Q_6_Staff_Training__c ;                        
                auditObj.Q_7_Complaint_Handling__c                      = oldAuditObj.Q_7_Complaint_Handling__c ;                    
                auditObj.Q_8_Escalation__c                              = oldAuditObj.Q_8_Escalation__c ;                            
                auditObj.Q_9_Health_and_Safety_Procedures__c            = oldAuditObj.Q_9_Health_and_Safety_Procedures__c ;          
                auditObj.Third_Party_Warehousing__c                     = oldAuditObj.Third_Party_Warehousing__c ;     
                auditObj.Product_Disposal__c                            = oldAuditObj.Product_Disposal__c ;     
                auditObj.Region__c                                      = oldAuditObj.Region__c ;                       
                auditObj.Reseller_Attendees__c                          = oldAuditObj.Reseller_Attendees__c ;                        
                auditObj.Reseller_Signature_URL__c                      = oldAuditObj.Reseller_Signature_URL__c ;                    
                auditObj.Risk_Plan_In_Place__c                          = oldAuditObj.Risk_Plan_In_Place__c ;                        
                auditObj.Risk_Plan_On_Track__c                          = oldAuditObj.Risk_Plan_On_Track__c ;                        
                auditObj.Signature_URL__c                               = oldAuditObj.Signature_URL__c ;                             
                auditObj.Stock_Management_System_Score__c               = oldAuditObj.Stock_Management_System_Score__c ;             
                auditObj.Total_Audit_Score__c                           = oldAuditObj.Total_Audit_Score__c ;                         
                auditObj.Warehouse_Office_Assessed__c                   = oldAuditObj.Warehouse_Office_Assessed__c ;                 
                auditObj.Warehouse_Facilities_Score__c                  = oldAuditObj.Warehouse_Facilities_Score__c ;                
                auditObj.ParentAuditId__c                               = oldAuditObj.Id;
//                system.debug('!!!!!! resellerId' + resellerId);
                auditObj.Formyoula_Entry_ID__c= null;
                auditObj.Reseller__c = resellerId;
                
                auditrecordsToInsert.add(auditObj);
            }           
        }
        
        if (auditrecordsToInsert.size() > 0){
            system.debug('!!!!!@#@!#!@# auditrecordsToInsert ' +auditrecordsToInsert );
            insert auditrecordsToInsert;    
        }              
    }    
}