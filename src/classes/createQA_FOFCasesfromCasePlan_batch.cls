/***
*Created by: Solunus
*Last Updated Date: 08/21/2019
*Description : Batch is related to QA/FOF case plans - Child cases and case servicecodes are created in this batch
***/
global class createQA_FOFCasesfromCasePlan_batch implements Database.Batchable<sObject>,Database.AllowsCallouts ,Database.Stateful{
    
    private List<String> selectedIds;
    private Id casePlanId;
    private case pcase;
    Private Map<id,List<Case_Plan_Asset__c>> cloneOrderCaMap;
    Private List<Case> parentCases;
    private Id ParentCaseRecID;
    private Id childCaseRecID;
    global List<Case_Service_Code__c> updateServiceCodes = new List<Case_Service_Code__c>();
    global List<Id> updateServiceCodeIds = new List<Id>();
    global List<Case> updateCases =new List<Case>();
    
    global createQA_FOFCasesfromCasePlan_batch( case dumCase,Map<id,List<Case_Plan_Asset__c>> corderMap,List<case> PCases, Id childRtypID ) {
        pcase=dumcase; //
        cloneOrderCaMap=corderMap; //
        parentCases=PCases; //
        childCaseRecID = childRtypID; //
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id,Assetid,Contactid,Order__c from case where id =: parentCases ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> ParCases){
        //system.debug('In EXE method');
        List<Case> childCases=new List<Case>();
        for(case parCase:ParCases){
            updateCases.add(parCase);
            if(cloneOrderCaMap.containskey(parCase.Order__c))
            { 
                Case childcase1=pcase.cases[0].clone();
                childcase1.ParentId=parCase.id;
                childcase1.ContactId=parCase.ContactId;
                childcase1.AssetId=parCase.AssetId;
                childcase1.Order__c=parcase.Order__c;
                childcase1.RecordTypeId = childCaseRecID;
                childCases.add(childcase1);
                for(Case_Plan_Asset__c cpa:cloneOrderCaMap.get(parCase.Order__c)){
                    Case childcase=pcase.cases[0].clone();
                    childcase.ParentId=parCase.id;
                    childcase.ContactId=parCase.ContactId;
                    childcase.AssetId=cpa.Asset__c;
                    childcase.Order__c=parcase.Order__c;
                    childcase.RecordTypeId = childCaseRecID;
                    childCases.add(childcase);   
                }   
            }
            
            else{
                //system.debug('In Child ELSE');
                Case childcase=pcase.cases[0].clone();
                childcase.ParentId=parCase.id;
                childcase.ContactId=parCase.ContactId;
                childcase.AssetId=parCase.AssetId;
                childcase.RecordTypeId = childCaseRecID;
                childCases.add(childcase);
            }
        }
        
        if(childCases.size()>0){
            insert childCases; //Insert child cases
            system.debug('childCases '+childCases.size());
            list<Case_Service_Code__c> insertServiceCodes=new list<Case_Service_Code__c>();
            list<Case_Service_Code__c> serviceCodes= createQA_FOFCasesFromCasePlan_Controller.getServiceCodesOndummyTemplate(pcase.cases[0].id);
            //system.debug('serviceCodes '+serviceCodes);
            List<id> childcaseIDs=new List<id>();
            for(Case chCase:childCases){
                if(serviceCodes.size() >0){
                    Case_Service_Code__c caseCOde=serviceCodes[0].clone();
                    caseCode.Case__c=chCase.id;
                    insertServiceCodes.add(caseCode);}
                updateCases.add(chCase);
            } 
            if(insertServiceCodes.size() >0){
                insert insertServiceCodes;//Insert serviceCodes
                system.debug('INserted SV codes '+insertServiceCodes.size());
            } 
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('In FINISH');
        if(updateCases.size()>0){
            Database.executeBatch(new update_QAFOFCases_batch(updateCases), 50); // Call batch class to update QA/FOF Cases
        }
    }
}