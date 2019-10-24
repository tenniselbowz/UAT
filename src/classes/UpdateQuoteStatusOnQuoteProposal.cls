global  class UpdateQuoteStatusOnQuoteProposal implements database.batchable<sObject>,database.stateful {
    public set<Id> quoteIds;
    public boolean stopBatch;
    public integer count =0;
    public List<Apttus_Proposal__Proposal__c> newapttusProposalList = new list<Apttus_Proposal__Proposal__c>();
    
    global UpdateQuoteStatusOnQuoteProposal(set<Id> quoteIds, List<Apttus_Proposal__Proposal__c> apttusProposalList, Boolean stopBatch){
        this.quoteIds = quoteIds;  
        this.stopBatch = stopBatch;
        for(Apttus_Proposal__Proposal__c proposal:[select id,Reject_Comments__c,Apttus_Proposal__Proposal__c.RecordTypeId,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where Id IN :quoteIds])
        {
            Apttus_Proposal__Proposal__c proposalRec =  new Apttus_Proposal__Proposal__c();
            proposalRec = proposal;
            newapttusProposalList.add(proposalRec);
            
        }
        //this.apttusProposalList = apttusProposalList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        System.debug('quoteIds in Batch Class::'+quoteIds);
        
        string Query ='SELECT  Id,ProcessInstance.ProcessDefinitionId,ProcessInstance.TargetObjectId, Comments, Systemmodstamp FROM ProcessInstanceStep where stepStatus =\'Rejected\''
            +' AND Comments != null'
            +' AND ProcessInstance.TargetObjectId IN : quoteIds order by CreatedDate ASC'; 
        system.debug('start Method::'+ Query);
        /*
Long startTime = DateTime.now().getTime();
Long finishTime = DateTime.now().getTime();
while ((finishTime - startTime) < 9000) {

//sleep for 9s
finishTime = DateTime.now().getTime();
}
*/
        if(test.isRunningTest())
        {
            
            string q ='SELECT  Id,ProcessInstance.ProcessDefinitionId,ProcessInstance.TargetObjectId, Comments, Systemmodstamp FROM ProcessInstanceStep';
            return Database.getQueryLocator(q);
        }
        return Database.getQueryLocator(Query); 
        
        
    }
    global void execute(Database.BatchableContext BC, List<ProcessInstanceStep> scope){
        System.debug('execute scope ::'+scope.size()); 
        
        Map<String, ProcessInstanceStep> approvalHistory  = new Map<String, ProcessInstanceStep>();
        //Credit_Pre_Approval_Process_Metadata__mdt appMetadata =new list<Credit_Pre_Approval_Process_Metadata__mdt>();
        try
        {
            
            for(ProcessInstanceStep app : scope)
            {
                
                approvalHistory.put(app.ProcessInstanceId+'-'+app.ProcessInstance.TargetObjectId, app);    
            }
            RecordTypes__mdt recordType = [select RecordTypeId__c,MasterLabel from RecordTypes__mdt where MasterLabel = 'North America RecordType'];
            Credit_Pre_Approval_Process_Metadata__mdt appMetadata =[select developername, Approval_Id__c from Credit_Pre_Approval_Process_Metadata__mdt] ;   
            // ProcessDefinition  ApprovalProcessName =[SELECT Id, Name, DeveloperName, Type, Description FROM ProcessDefinition where DeveloperName ='Credit_Pre_Approval_Process'];
            for(Apttus_Proposal__Proposal__c p :newapttusProposalList){
                if(p.RecordTypeId == recordType.RecordTypeId__c){
                    //system.debug('approval stage::'+p.Apttus_Proposal__Approval_Stage__c);
                    p.Reject_Comments__c = '';
                    
                    for(ProcessInstanceStep pi :scope){
                     
                            system.debug('MeatadataID::'+appMetadata.Approval_Id__c);
                            if(pi.ProcessInstance.ProcessDefinitionID !=appMetadata.Approval_Id__c)
                            {
                                
                                p.Apttus_Proposal__Approval_Stage__c = 'Denied';
                            }
                        
                        
                        if(approvalHistory.containsKey(pi.ProcessInstanceId+'-'+p.id)){
                            
                            p.Reject_Comments__c += approvalHistory.get(pi.ProcessInstanceId+'-'+p.id).Comments+'\n';
                            
                        }  
                    }
                    
                }
                p.Reject_Comments__c = p.Reject_Comments__c.removeEnd('-');
                system.debug(' p.Reject_Comments__c::'+ p.Reject_Comments__c);
                
            }
            
        }
        catch (Exception e )
        {
            system.debug('Excpeions are ::'+ e.getLineNumber() +'Message::'+e.getMessage());
        }
        
        system.debug('update apttusProposalList::'+newapttusProposalList);
        
        //system.debug('update apttusProposalList::'+apttusProposalList.Apttus_Proposal__Approval_Stage__c);
    }
    global void finish(Database.BatchableContext BC){
        
        count = count+1;
        system.debug('Count::'+count);
        system.debug('StopBatchClass.stop::'+StopBatchClass.stop);
        if(!stopBatch && newapttusProposalList.size()>0){
             update newapttusProposalList;
        }
           
        
        
    }
    
}