/***
*Created by: Solunus
*Last Updated Date: 08/21/2019
*Description : Batch is related to QA/FOF case plans - This process blind updates all the cases to rollup values from Case Service code updates
***/
global class update_QAFOFCases_batch implements Database.Batchable<sObject>, Database.Stateful {
    
    //public Set<Id> casesToUpdate;
    public List<Case> casesToUpdate;
    
    global update_QAFOFCases_batch(List<Case> casesToPro)
    {casesToUpdate=casesToPro;
    }
    
    global List<Case> start(Database.BatchableContext BC){
        return casesToUpdate;
    }
    
    global void execute(Database.BatchableContext BC, List<Case> allCases){
        update allCases;
        system.debug('allCases '+allCases.size());
    }
    global void finish(Database.BatchableContext BC){
        system.debug('In Finish Method - QAFOF Batch');
    }
    
    
}