/*********************
 * Author: Mahmood Zubair (Davanti)
 * Description: Trigger helper class to handle multi-reseller create implementation
 * History 
 * 11Aug16: inital version
 * 
 * Updated by NM: added logic for updating multiple audit note records
 * ****************************/
public class AuditNotesTriggerHandler {
    
    public static void createMultiResellerRecords(List<Audit_Notes__c> auditNoteList){
        //system.debug('@@@ createMultiResellerRecords');
    
        set<id> auditparentidSet = new set<id>();
        for (integer i = 0; i < auditNoteList.size(); i ++){
            auditparentidSet.add(auditNoteList[i].Audit__c);
        }
        //system.debug('@@@ auditparentidSet: ' + auditparentidSet);
        
        
        List<Audit_Notes__c> auditNotesToInsert = new List<Audit_Notes__c>();
       /* List<Audit_Notes__c> newAuditNoteList = [SELECT Id, Name,Action_Plan__c,Audit__c,Audit__r.Formyoula_Entry_ID__c , Audit_Question__c,Category__c, Consequence__c, Controls__c, Controls_Rating__c , Description__c,
                                                   Due_Date__c,Help_Needed__c, Image__c, Likelihood__c, Notes__c, Photo_URL__c, Priority__c, Risk_Rating__c, Support__c, Title__c, User_Account__c
                                              FROM Audit_Notes__c 
                                              WHERE ID IN: auditNoteidSet AND Audit__r.Formyoula_Entry_ID__c != null];
       */
       
        Map<Id,Audit__c> newAuditMap = new map<Id,Audit__c>([SELECT ID, Name, ParentAuditId__c FROM Audit__c Where ParentAuditId__c IN :auditparentidSet AND ParentAuditId__c != null]);
        //system.debug('!!!!!!! newAuditMap ' + newAuditMap);
        //system.debug('!!!!!!! auditNoteList ' + auditNoteList);
        for (Audit__c auditObj :newAuditMap.values()) {
            for (integer i = 0; i < auditNoteList.size(); i ++){
                Audit_Notes__c oldAuditNoteObj = auditNoteList[i];
                //system.debug('!!!!!!! oldAuditNoteObj ' + oldAuditNoteObj);
                if (auditObj.ParentAuditId__c == auditNoteList[i].Audit__c){
                    Audit_Notes__c auditNoteObj = new Audit_Notes__c();
                    /*
                    auditNoteObj.Action_Plan__c = oldAuditNoteObj.Action_Plan__c ;
                    auditNoteObj.Audit__c = auditObj.Id ;
                    auditNoteObj.Audit_Question__c = oldAuditNoteObj.Audit_Question__c ;
                    auditNoteObj.Category__c =  oldAuditNoteObj.Category__c ;
                    auditNoteObj.Controls__c = oldAuditNoteObj.Controls__c ;
                    auditNoteObj.Controls_Rating__c = oldAuditNoteObj.Controls_Rating__c ; 
                    auditNoteObj.Description__c = oldAuditNoteObj.Description__c ;
                    auditNoteObj.Due_Date__c = oldAuditNoteObj .Due_Date__c ;
                    auditNoteObj.Likelihood__c = oldAuditNoteObj.Likelihood__c ;
                    auditNoteObj.Notes__c = oldAuditNoteObj.Notes__c ;
                    auditNoteObj.Photo_URL__c = oldAuditNoteObj.Photo_URL__c ;
                    auditNoteObj.Priority__c = oldAuditNoteObj.Priority__c ;                          
                    auditNoteObj.Support__c = oldAuditNoteObj.Support__c ;
                    auditNoteObj.Title__c = oldAuditNoteObj.Title__c ;
                    */               
                    auditNoteObj = oldAuditNoteObj.clone(false,false,false,false);
                    auditNoteObj.Audit__c = auditObj.Id ;
                    auditNoteObj.ParentAuditNoteId__c = oldAuditNoteObj.Id;
                            
                    auditNotesToInsert.add(auditNoteObj);                
                }
            }
        }
        //system.debug('!!!!!! auditNotesToInsert' + auditNotesToInsert);
        if (auditNotesToInsert.size() > 0){
            insert auditNotesToInsert;
        }
    }  

    public static void updateMultipleAuditNoteRecords(List<Audit_Notes__c> auditNoteList) {
        system.debug('@@@ updateMultipleAuditNoteRecords');
        
        // Get Parent Audit Note
        List<Audit_Notes__c> parentAudit = new List<Audit_Notes__c>();
        for (integer i = 0; i < auditNoteList.size(); i ++){
            parentAudit.add(auditNoteList[i]);
        }
        system.debug('@@@ parentAudit: ' + parentAudit);
        
        if(!parentAudit.isEmpty()) {            
            // Get fields of audit note linked to parent audit note
            List<Audit_Notes__c> auditNoteToUpdateList = new List<Audit_Notes__c>([select Id, Audit__c, Audit__r.ParentAuditId__c, Notes__c, Photo_URL__c, 
                                                                                        Title__c, Description__c, Priority__c, Due_Date__c, 
                                                                                        Controls__c, Controls_Rating__c, Progress_status__c, Likelihood__c, Consequence__c, Action_Plan__c, Help_Needed__c, Support__c, Audit_Question__c, ParentAuditNoteId__c
                                                                                from Audit_Notes__c where Audit__r.ParentAuditId__c = :parentAudit[0].Audit__c]);
            system.debug('### auditNoteToUpdateList: ' + auditNoteToUpdateList);
            
            List<Audit_Notes__c> updateList;
            // Copy details from parent audit note
            if(auditNoteToUpdateList.size() > 0) {
                updateList = new List<Audit_Notes__c>();
                for(integer i = 0; i < auditNoteToUpdateList.size(); i++) {
                    //system.debug('### auditNoteToUpdateList[i]: ' + auditNoteToUpdateList[i]);
                    if(auditNoteToUpdateList[i].Id != parentAudit[0].Id && auditNoteToUpdateList[i].ParentAuditNoteId__c == parentAudit[0].Id) {
                        auditNoteToUpdateList[i].Notes__c = parentAudit[0].Notes__c;
                        auditNoteToUpdateList[i].Photo_URL__c =  parentAudit[0].Photo_URL__c;
                        auditNoteToUpdateList[i].Title__c =  parentAudit[0].Title__c;
                        auditNoteToUpdateList[i].Description__c =  parentAudit[0].Description__c;
                        auditNoteToUpdateList[i].Priority__c =  parentAudit[0].Priority__c;
                        auditNoteToUpdateList[i].Due_Date__c =  parentAudit[0].Due_Date__c;
                        auditNoteToUpdateList[i].Controls__c =  parentAudit[0].Controls__c;
                        auditNoteToUpdateList[i].Controls_Rating__c =  parentAudit[0].Controls_Rating__c;
                        auditNoteToUpdateList[i].Progress_status__c =  parentAudit[0].Progress_status__c;
                        auditNoteToUpdateList[i].Likelihood__c =  parentAudit[0].Likelihood__c;
                        auditNoteToUpdateList[i].Consequence__c =  parentAudit[0].Consequence__c;
                        auditNoteToUpdateList[i].Action_Plan__c =  parentAudit[0].Action_Plan__c;
                        auditNoteToUpdateList[i].Help_Needed__c =  parentAudit[0].Help_Needed__c;
                        auditNoteToUpdateList[i].Support__c =  parentAudit[0].Support__c;
                        
                        updateList.add(auditNoteToUpdateList[i]);
                    }
                }
            }
            system.debug('### updateList: ' + updateList);
            
            // Update audit notes
            if(updateList != null && updateList.size() > 0) {
                update updateList;
            }  
        }
    }
    
}