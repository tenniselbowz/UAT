/**************************************************************************************
Author       :   Amarendar Junuthula
Created Date :   December 08, 2015
Description  :   Trigger on Tasks to count number of activities related to Accounts, Contacts, Opportunities, Cases and Change Requests
***************************************************************************************/

trigger TaskTrigger on Task (after insert, after update, after delete, after undelete, before update) {
    //This trigger has to go and update the Number of Activities field on Case after a task is Created or Updated or Deleted or after undeleted.
    
    //Before events
    if(trigger.isBefore){
   
    }
    
    //After Events
    if(trigger.isAfter){
        
        /*sObject[] triggerRecords;
if(!trigger.isDelete) triggerRecords = trigger.new;
else triggerRecords = trigger.old;

//Update Open Activity Count
ActivityUtils au = new ActivityUtils(triggerRecords);
au.updateAccountActivityCount();
au.updateContactActivityCount();
au.updateLeadActivityCount();
au.updateOpportunityActivityCount();
au.updateLeadActivityCount();
au.updateCaseActivityCount();
au.updateChangeRequestActivityCount();     */  
        
        if(trigger.isInsert){
            TaskUtility.getCaseTasksCount(Trigger.new);
            TaskUtility.hasAttachment(Trigger.new);
            
            List<Id> cids = new List<Id>();
            for(Task t :Trigger.new){
                if(t.WhatId != null && String.valueOf(t.WhatId).startsWith('500') && t.Status=='Completed' && t.Subject != null && t.Subject.startsWith('Email:'))//cases
                    cids.add(t.WhatId);
            }
            
            if(cids.size()>0){
                List<Case> casesToUpdate = new List<Case>();
                List<Case> cases = [select Id, Status, Business_Unit_Picklist__c from Case where (Status = 'Warranty Approved' OR Status like 'Warranty Reject%') and Id in :cids];
                for(Case c : cases){
                    if(c.Status == 'Warranty Approved'){
                        if(c.BusinesS_Unit_Picklist__c== 'Chillers')
                            c.Status='Approved: Waiting';
                    } else{
                        c.Status='Closed';
                        c.Closed_Reason__c='Rejected';
                    }
                    casesToUpdate.add(c);
                }
                if(casesToUpdate.size()>0){
                    System.debug('COMPLETE CASE: ===============> '+casesToUpdate.size());
                    update casesToUpdate;
                }
            }
        }
        if(trigger.isUpdate){
            TaskUtility.getCaseTasksCount(Trigger.new);
            TaskUtility.hasAttachment(Trigger.new);
                 
            if(trigger.isUpdate && TaskUtility.runTaskTriggerOnce){ //Update DSO Task score when updated
            ///Get DSO recordID
            Id dsoRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DSO').getRecordTypeId();
            List<id> taskIds=new List<id>();
            List<Task> Tasks=new LIst<Task>();
            for(Task tsk:trigger.new){
                Task oldTask=trigger.oldmap.get(tsk.id);
                if(tsk.RecordTypeId == dsoRecordTypeId /* && (tsk.Valid_Business_Reason__c != oldTask.Valid_Business_Reason__c || tsk.WhatId != oldTask.WhatId || tsk.WhoId != oldTask.whoid) */)
                {
                    taskIds.add(tsk.id);
                    Tasks.add(tsk);
                }
                if(taskIds.size() >0){
                taskutility.updateDSOSalesCallScore(taskIds);
                }
            }
        }
        }
        if(trigger.isDelete){
            TaskUtility.getCaseTasksCount(Trigger.old); 
        }
        if(trigger.isUndelete){
            TaskUtility.getCaseTasksCount(Trigger.new);
        }
    }   
    
}