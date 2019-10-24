trigger ApttusQuoteProposalTrigger on Apttus_Proposal__Proposal__c (after update, before Update, before insert) 
{
    public boolean Stopbatch = false;
    String NorthAmericaProposal_recordType =
        Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('North America Proposal').getRecordTypeId(); 
    System.debug('testing proposal'+TriggerUtility.tau.get('Proposal').isaccessible());
    Map<Id, Apttus_Proposal__Proposal__c> oldMapvalues = new Map<Id, Apttus_Proposal__Proposal__c>();
    Map<Id, Apttus_Proposal__Proposal__c> newMapValues = new Map<Id, Apttus_Proposal__Proposal__c> ();
    if(TriggerUtility.tau.get('Proposal').isaccessible()){
        TriggerUtility.tau.get('Proposal').increment();
        if(Trigger.isAfter)
        {
            If(Trigger.isUpdate) {
                system.debug('In After update - ApttusQuoteProposalTrigger');
                Map<Id, Apttus_Proposal__Proposal__c> newMap = new Map<Id, Apttus_Proposal__Proposal__c>();
                Map<Id, Apttus_Proposal__Proposal__c> oldMap = new Map<Id, Apttus_Proposal__Proposal__c>();
                for(Apttus_Proposal__Proposal__c proposal : trigger.new)
                {
                    if(proposal.recordTypeId == NorthAmericaProposal_recordType)
                    {
                        newMap = Trigger.newMap;
                        oldMap = Trigger.oldMap;
                    }
                }
                String newMapString = JSON.serialize(newMap);
                String oldMapString = JSON.serialize(newMap);
                if(QuoteProposalTriggerHandler.flag && !system.isBatch() && !system.isFuture())
                {
                    system.debug('In After update - ApptusQuoteProp_Trig');
                    QuoteProposalTriggerHandler.UpdatingCreditAuthorization(newMapString, oldMapString);            
                }    
            }
        }
        if(Trigger.isBefore)
        {
            If(Trigger.isUpdate && !system.isBatch()) {
                system.debug('In before update - ApptusQuoteProp_Trig');
                QuoteProposalTriggerHandler.concatenateTKClauses(Trigger.newMap, Trigger.oldMap);
                System.debug('Old Map'+trigger.oldMap);
                system.debug('new map'+trigger.newMap);
                
                
            }
          
            ApttusQuoteProposalHandler.HandleBeforeUpdate(trigger.new);
            if(QuoteProposalTestHandler.flag){
                system.debug('enter here');
                QuoteProposalTestHandler.UpdateOpportunityRollup(Trigger.newmap, Trigger.oldmap);
            }
            
        }
        
        if(Trigger.isinsert)
        {
            ApttusQuoteProposalHandler.HandleBeforeInsert(trigger.new);
        }
    }
    
    
    if(trigger.isAfter && !trigger.isInsert )
    {       system.debug('inside');
        if(trigger.isUpdate ) 
        {      
            try
            {
                ApttusQuoteProposalHandler.HandleAfterUpdate(Trigger.New, Trigger.oldMap);
                for(Apttus_Proposal__Proposal__c proposal : trigger.new){
                    system.debug('old value::'+trigger.oldMap.get(proposal.Id).Apttus_Proposal__Approval_Stage__c );
                    if(proposal.is_rejected__c ==true && trigger.oldMap.get(proposal.Id).is_rejected__c != proposal.is_rejected__c){
                        //system.debug('new value'+proposal.Apttus_Proposal__Approval_Stage__c)
                        oldMapvalues.put(proposal.Id, trigger.oldMap.get(proposal.Id));
                        newMapValues.put(proposal.Id, proposal);
                    }    
                    
                    if(oldMapvalues.size() > 0){
                    
                        system.debug('updateQuoteStatus in Trigger::');
                        system.debug('calling batch class::'+system.isBatch());
                        
                        if(system.isBatch())
                            StopBatchClass.stop=true;
                        QuoteProposalTriggerHandler.updateQuoteStatus(newMapValues, oldMapvalues,system.isBatch());    
                    }
                }
            }
            
            catch (Exception e)
            {
                system.debug('Excpeions are ::'+ e.getLineNumber() +'Message::'+e.getMessage()); 
            }
            
            //QuoteProposalTriggerHandler.syncQuotetoOpportunity(Trigger.newmap, Trigger.oldmap);
            
            
        }
        
    } else
        TriggerUtility.tau.get('Proposal').reset(); 
}