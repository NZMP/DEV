/*
 * Copyright (c) 2016 by PROS, Inc.  All Rights Reserved.
 * This software is the confidential and proprietary information of
 * PROS, Inc. ("Confidential Information").
 * You may not disclose such Confidential Information, and may only
 * use such Confidential Information in accordance with the terms of
 * the license agreement you entered into with PROS.
 *
 * author Shawn Wang
 */
/***************************
* @description: Trigger for Opportunity
*               This trigger is used to generate the Opportunity Quote in SAP, it Leverage's Future methods to do so.
* @author: Mahmood Zubair(DC)
* @history:
* 15March2016 MahmoodZ(DC): Making changes in the tigger to accomodate 
* 
*
*******************************/
trigger OpportunityContractTrigger on Opportunity (after update, after Insert) {
    if (Trigger.IsUpdate && Trigger.IsAfter && !OpportunityTriggerHandler.isExecuted ){
       
        OpportunityTriggerHandler.processOppsForSAP(Trigger.new, Trigger.OldMap);
        OpportunityTriggerHandler.opportunityContactTrigger2(Trigger.new, Trigger.OldMap, Trigger.NewMap);
        List<Opportunity> opportunitesChangedList = new List<Opportunity>();
        List<Opportunity> opportunitesApprovalList = new List<Opportunity>();
        
        For(Opportunity oppObj : Trigger.New ){
           if( oppObj.Ship_To__c != Trigger.oldMap.get(oppObj.id).Ship_To__c || oppObj.Payer__c != Trigger.oldMap.get(oppObj.id).Payer__c ) {
               opportunitesChangedList.add(oppObj);
           }
        }
        if (opportunitesChangedList.size() > 0){
         //   OpportunityTriggerHandler.processShipToAndPayerChange(opportunitesChangedList);
            OpportunityQueuebleJob oQJ = new OpportunityQueuebleJob(opportunitesChangedList);     
            system.enqueueJob(oQJ);    
        }
        
        For(Opportunity oppObj : Trigger.New ){
     
            //Ensure this just expired to prevent recurrence of the trigger.
             if(oppObj.offer_status__c == 'Expired' && Trigger.oldMap.get(oppObj.id).offer_status__c != 'Expired'){
                 opportunitesApprovalList.add(oppObj);
               }
           }
              
              if (opportunitesApprovalList.size() > 0){
                    OpportunityTriggerHandler.rejectRecord(opportunitesApprovalList);
                   }
          //  }

       /* }catch(Exception e){
            Trigger.new[i].addError(e.getMessage());
        }*/
    
       }
      
         
}