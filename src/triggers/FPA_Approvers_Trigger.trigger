trigger FPA_Approvers_Trigger on FPA_Approvers__c (before insert, after update) {
if(trigger.isAfter){
        if(trigger.isUpdate){
            Map<String, FPA_Approvers__c > approvals = new Map<String, FPA_Approvers__c >();
            for(FPA_Approvers__c app : trigger.new){
                if(app.Status__c != trigger.oldMap.get(app.Id).Status__c){
                    approvals.put(app.Id, app);    
                }    
            }
            FPA_ApprovalHelper.updateFPAStatus(approvals);
        }
    }
}