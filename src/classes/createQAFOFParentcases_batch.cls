/***
*Created by: Solunus
*Last Updated Date: 08/21/2019
*Description : Batch is related to QA/FOF case plans - This process creates all parent cases related to QA/FOF Case Plan
***/
global class createQAFOFParentcases_batch implements Database.Batchable<sObject>, Database.Stateful  {
    
    public List<case> ParentCases;
        public List<case> InsertParentCases=new List<case>();
    private Id childCaseRecID;
    Private Map<id,List<Case_Plan_Asset__c>> cloneOrderCaMap;
    private case dummyCase;
    
    global createQAFOFParentcases_batch(List<Case> parentCas,Map<id,List<Case_Plan_Asset__c>> cloneOrdeMap,Id childCsRecID,case dumyCase)
    {
        system.debug('In createQAFOFParentcases_batch '+parentCas.size());
        ParentCases=parentCas;
        childCaseRecID=childCsRecID;
        cloneOrderCaMap=cloneOrdeMap;
        dummyCase=dumyCase;
    }
    global List<Case> start(Database.BatchableContext BC)
    {
        return ParentCases;
    }
    global void execute(Database.BatchableContext BC, List<Case> allCases)
    {
        for(Case cs:allCases){
            InsertParentCases.add(cs);
                   // system.debug('Par Case Size '+InsertParentCases.size());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('In Finish Method - ParentQAFOF Batch - '+InsertParentCases.size());
        if(InsertParentCases.size()>0){
            insert InsertParentCases; // Insert Parent Cases
        //Batch class to create child cases and Case service Codes
        Database.executeBatch(new createQA_FOFCasesfromCasePlan_batch(dummyCase,cloneOrderCaMap,InsertParentCases,childCaseRecID), 100);
        }  
    }  
}