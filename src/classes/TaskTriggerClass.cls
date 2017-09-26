/*
* Author: Nino Bustillos
* Description:
* History:
*     12Oct2016 NBustillos(DC): initial version
*/
public class TaskTriggerClass{
	// this will hold the real new status field (for recurssion checking)
    public static Map<Id,String> taskStatusOverrideMap;

    public static void afterEventHandler(List<Task> taskList, Map<Id,Task> oldMap, Map<Id,Task> newMap){
    	// Audit Note Status Update Logic Variables
    	String auditNotesPrefix = Audit_Notes__c.SObjectType.getDescribe().getKeyPrefix();
    	Map<Id,String> auditNoteIdMap = new Map<Id,String>();

    	// This initiates the recurssion logic check, please add additional if-condition as needed prior to the loop
        if(taskStatusOverrideMap==null){
        	taskStatusOverrideMap = new Map<Id,String>();
        }

        // START: After Event iteration
        // This will be the iteration for all after event, add all collate-logic inside
        List<Task> process_task_list = new List<Task>();
                for (Task t : taskList) {
                    if(t.Whatid!=NULL)
                      process_task_list.add(t);
                }


        for(Task t : process_task_list){

        	// Start: Audit Note Status Update Logic
        	// Check if this is for Audit Notes
          if(((String)t.WhatId).Left(3)==auditNotesPrefix){

        		// Get the updated cache Status value
        		String oldTaskStatus = (taskStatusOverrideMap.containsKey(t.Id))? taskStatusOverrideMap.get(t.Id) : ((oldMap!=null)? oldMap.get(t.Id).Status: null);

        		system.debug('oldTaskStatus: ' + oldTaskStatus);
        		system.debug('t.Status: ' + t.Status);
        		system.debug('trigger.isInsert: ' + trigger.isInsert);
        		system.debug('trigger.oldMap: ' + trigger.oldMap);
        		if(oldTaskStatus != t.Status){
        			auditNoteIdMap.put(t.WhatId, t.Status);
        			// add the new value so that possible next execution detects the new value
        			taskStatusOverrideMap.put(t.Id, t.Status);
        		}

        	}
        	// End: Audit Note Status Update Logic

        	// Add other logic here
        }
        // END: After Event Iteration

        // START: Post Iteration Logic
        // This will be the post processing section, add all post processing logic and DML calls here
        List<SObject> updateList = new List<SObject>();
        system.debug('auditNoteIdMap: ' + auditNoteIdMap);
        // Start: Audit Note Status update Logic
        if(auditNoteIdMap.size()>0){
        	for(Id auditNoteId : auditNoteIdMap.keySet()){
        		updateList.add(new Audit_Notes__c(Id=auditNoteId, Status__c=auditNoteIdMap.get(auditNoteId)));
        	}
        }
        // End: Audit Note Status update Logic

        system.debug('updateList:' + updateList.size());
        if(updateList.size()>0){
        	system.debug('HERE');
        	List<Database.SaveResult> updateResults = Database.update(updateList, false);
        	// TODO: log errors?
        }

        // END: Post Iteration Logic
    }

}