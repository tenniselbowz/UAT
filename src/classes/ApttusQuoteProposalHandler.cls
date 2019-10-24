public class ApttusQuoteProposalHandler {
    
    public static void HandleBeforeInsert(List<Apttus_Proposal__Proposal__c> quoteList)
    {
/*        List<ID> quoteListIDs = new List<ID>();
        for(Apttus_Proposal__Proposal__c app:quoteList){
            quoteListIDs.add(app.Id);
        }
        futureHandleBeforeInsert(quoteListIDs);
    }
    @future
    public static void futureHandleBeforeInsert(List<ID> quoteListIDs)
    {
        List<Apttus_Proposal__Proposal__c> quoteList = [select Id, RecordTypeId, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Primary__c, LA_Total_Net_Price_for_Contract__c, Turnkey_Contingency_Amount__c, Turnkey_Contingency_Amount_in_words__c from Apttus_Proposal__Proposal__c where Id in :quoteListIDs];
*/        ApttusQuoteProposalServices.setQuoteDefaults(quoteList);
        ApttusQuoteProposalServices.setTotalNetPriceInWords(quoteList);
        ApttusQuoteProposalServices.makeOnlyPrimaryQuote(quoteList);
    }
    
    public static void HandleBeforeUpdate(List<Apttus_Proposal__Proposal__c> quoteList)
    {
/*        List<ID> quoteListIDs = new List<ID>();
        for(Apttus_Proposal__Proposal__c app:quoteList){
            quoteListIDs.add(app.Id);
        }
        futureHandleBeforeUpdate(quoteListIDs);
    }
    @future
    private static void futureHandleBeforeUpdate(List<ID> quoteListIDs){
        List<Apttus_Proposal__Proposal__c> quoteList = [select Id, LA_Total_Net_Price_for_Contract__c, Turnkey_Contingency_Amount__c, Turnkey_Contingency_Amount_in_words__c from Apttus_Proposal__Proposal__c where Id in :quoteListIDs];
*/        ApttusQuoteProposalServices.setTotalNetPriceInWords(quoteList);
        /*for(Apttus_Proposal__Proposal__c p : quoteList){
              if(p.Apttus_Proposal__Approval_Stage__c=='Generated')
                  p.Approval_Status__c=null;
        }*/        
    }
    public static void HandleAfterUpdate(List<Apttus_Proposal__Proposal__c> quoteList,Map<Id, Apttus_Proposal__Proposal__c> oldQuoteMap)
    {
/*        List<ID> quoteListIDs = new List<ID>();
        for(Apttus_Proposal__Proposal__c app:quoteList){
            quoteListIDs.add(app.Id);
        }
        futureHandleAfterUpdate(quoteListIDs);
    }
    
    @future
    private static void futureHandleAfterUpdate(List<ID> quoteListIDs){
        List<Apttus_Proposal__Proposal__c> quoteList = [select Id, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Primary__c from Apttus_Proposal__Proposal__c where Id in :quoteListIDs];
*/        ApttusQuoteProposalServices.synchronizeOpportunityLineItems(quoteList,oldQuoteMap);//IS THIS LATAM?
        ApttusQuoteProposalServices.makeOnlyPrimaryQuote(quoteList);        
    }
    
}