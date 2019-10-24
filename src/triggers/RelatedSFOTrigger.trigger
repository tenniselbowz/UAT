trigger RelatedSFOTrigger on Related_SFO__c (after insert,before update,after delete,after Update) {
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            FPAApprovalDetails.getFPADynamicFields(trigger.new);  
        }
        
    }
    if(trigger.isafter)
    {
        list<Related_SFO__c> relatedSFOs=new list<Related_SFO__c>();
        if(trigger.isDelete)
        {
            for(Related_SFO__c r:trigger.old){
                relatedSFOs.add(r);
            }
            if(relatedSFOs.size()>0)
                FPAApprovalDetails.updateUnitTagOnDelete(relatedSFOs); 
            system.debug(relatedSFOs);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isInsert || trigger.isUpdate)
        {
            System.debug('Inside Updating RSFO List Price');
            FPAApprovalDetails.getTotalListprice(trigger.new);  
            
        }
        if(trigger.isafter)
        {
            list<Related_SFO__c> relatedSFOs=new list<Related_SFO__c>();
            if(trigger.isDelete)
            {
                System.debug('Inside Delete');
                for(Related_SFO__c r:trigger.old){
                    relatedSFOs.add(r);
                }
                if(relatedSFOs.size()>0)
                    FPAApprovalDetails.getTotalListprice(relatedSFOs); 
                system.debug('relatedSFOs Delete'+relatedSFOs);
            }
        }
    }
}