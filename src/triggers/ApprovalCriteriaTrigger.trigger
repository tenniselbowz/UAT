trigger ApprovalCriteriaTrigger on Approval_Criteria__c (before insert,before update) {
    
    set<string> FormatIds =new set<string>();
    set<string> FormatToApprovalLevel =new set<string>();
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            
            for (Approval_Criteria__c appCriteriaRecord : trigger.new)
            {
                
                FormatIds.add(appCriteriaRecord.Format__c);
            }
            list<Approval_Criteria__c> appList=[select id,Approval_Level__c,Format__c from Approval_Criteria__c WHERE Format__c IN :FormatIds];
            for (Approval_Criteria__c app :appList)
            {
                FormatToApprovalLevel.add(app.format__c+'_'+app.Approval_Level__c); 
            }
            system.debug('FormatToApprovalLevel::'+FormatToApprovalLevel);
            for(Approval_Criteria__c app :trigger.new)
            {
                string Key =app.format__c+'_'+app.Approval_Level__c;
                if(FormatToApprovalLevel.contains(Key)) 
                {
                    app.addError('Approval Level with '+app.Approval_Level__c +' is already defined.');
                }
            }
        } 
    }
    if(trigger.isBefore)
    {
        if(trigger.isUpdate)
        {
            for(Approval_Criteria__c ap :trigger.new)
            {
                Approval_Criteria__c oldApp =trigger.oldMap.get(ap.id);
                if(ap.Approval_Level__c !=oldApp.Approval_Level__c)
                {
                    system.debug('Enter imto before update');
                  ap.addError('Approval Level with'+ap.Approval_Level__c+' is already defined.');  
                }
            }
        }
    }
}