/***
*Created by: Solunus
*Last Updated Date: 08/21/2019
*Description : Class is related to QA/FOF case plans - This process creates Parent and child cases on Case Plans
***/
public class createQA_FOFCasesFromCasePlan_Controller {
    
    private Case_Plan__c casePlan;
    private case dummyCase;
    public id casePlanId;
    public List<String> selectedIds;
    public boolean DummyCaseexists {set;get;}
    private set<id> assetIds=new set<id>();
    public static id dummyCaseID {set;get;}
    
    
    public createQA_FOFCasesFromCasePlan_Controller (ApexPages.StandardsetController sc) {
        casePlanId = ApexPages.currentPage().getParameters().get('id');
        casePlan=[select id,name,Dummy_Case_Template__c from Case_Plan__c where id=:casePlanId limit 1];
        if(casePlan.Dummy_Case_Template__c != null){
            dummyCaseID=casePlan.Dummy_Case_Template__c;
        }
        else{
            DummyCaseexists = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'A Dummy Case Template must be selected on Case Plan to create new cases');
            ApexPages.addMessage(myMsg); 
        }
    }
    
    public List<Case_Plan_Asset__c> getdisplayCasePlassets() {
        return [select Id,Asset__c,Asset__r.SO_Number__c,Asset__r.name,Asset__r.Order__r.name,Asset__r.Product2.ProductCode,Asset__r.SerialNumber,Asset__r.Product2.DW_Product_Business_Unit__c  from Case_Plan_Asset__c where Case_Plan__c=:casePlanId order by Asset__r.Order__c];
    }
    
    //Get fields to be cloned from dummy Case
    public static case getDummyCaseValues(id dummyParentCaseId){
        List<String> fields = new List<String>();
        List<Schema.FieldSetMember> ListOfFields = Schema.SObjectType.Case.fieldSets.Clone_Field_Mapping_on_WCA.getFields();
        List<Schema.FieldSetMember> ListOfChildFields=Schema.SObjectType.Case.fieldSets.Clone_Field_Mapping_Child_Warranty.getFields();
        //System.debug('Field Set of Case'+ListOfFields);
        
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : ListOfFields) {
            query += f.getFieldPath() + ', ';
        }
        query +='(SELECT '; //Query Case Child records - Inner loop
        for(Schema.FieldSetMember ch:ListOfChildFields){
            query +=ch.getFieldPath() + ',';
        }
        query=query.removeEnd(',');
        query +=' from cases order by createddate desc),';
        string caseId=dummyParentCaseId;
        query += 'Id FROM Case where id= :caseId';
        //system.debug('Query '+Database.query(query)) ;
        return Database.query(query);
    }
    
    public static list<Case_Service_Code__c> getServiceCodesOndummyTemplate(Id childCaseID){
        List<Schema.FieldSetMember> ListOfFields = Schema.SObjectType.Case_Service_Code__c.fieldSets.Fields_to_be_mapped_for_QAFOF_Cases.getFields();
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : ListOfFields) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id,case__c FROM Case_Service_Code__c where Case__c= :childCaseID';
        //system.debug('Query in get serviceCOdes '+Database.query(query)) ;
        return Database.query(query);
    }
    
    @RemoteAction //Get selected Case plan assets from VF and create Cases by cloning Dummycase on CasePlan
    public static Integer createOrderAssets(String pId, List<String> lst) {
        List<Case> cases = new List<Case>();
        system.debug('lst size '+lst.size());
        List<Case> childCases=new List<Case>();
        List<Case_Plan_Asset__c>  cplanassets=new List<Case_Plan_Asset__c> ();
        Case_Plan__c  casePlan=[select id,name,Dummy_Case_Template__c from Case_Plan__c where id=:pId limit 1];
        id caseID=casePlan.Dummy_Case_Template__c;
        Id ParentCaseRecID= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        Id childCaseRecID=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();
        Case pcase=getDummyCaseValues(caseID);
        Map<id,List<Case_Plan_Asset__c>> orderCasePlanMap=new Map<id,List<Case_Plan_Asset__c>>();
        Map<id,List<Case_Plan_Asset__c>> cloneOrderCaMap=new Map<id,List<Case_Plan_Asset__c>>();
        
        for(Case_Plan_Asset__c css:[select Id,contact__c,Asset__c,Asset__r.name,Asset__r.Order__c,Asset__r.Order__r.name,Asset__r.Product2.ProductCode,Asset__r.SerialNumber,Asset__r.Product2.DW_Product_Business_Unit__c  from Case_Plan_Asset__c where Id in :lst]){
            cplanassets.add(css);
            if(orderCasePlanMap.containsKey(css.Asset__r.Order__c)) {   
                orderCasePlanMap.get(css.Asset__r.Order__c).add(css);}
            else {orderCasePlanMap.put(css.Asset__r.Order__c,new list<Case_Plan_Asset__c>{css}); }
        }     
        system.debug('cplanassets '+cplanassets.size());
        //system.debug('orderCasePlanMap '+orderCasePlanMap +' Keyset '+orderCasePlanMap.keyset());
        if(cplanassets!=null && cplanassets.size()>0){
            for(Case_Plan_Asset__c a :cplanassets){
                if(orderCasePlanMap.containskey(a.Asset__r.Order__c) && orderCasePlanMap.get(a.Asset__r.Order__c).size()>1){
                    list<Case_Plan_Asset__c> cpList=orderCasePlanMap.get(a.Asset__r.Order__c);
                    Case_Plan_Asset__c cp=cpList[0];
                    if(!cloneOrderCaMap.containskey(a.Asset__r.Order__c)){
                        Case cs = pcase.clone();
                        cs.Order__c=cp.Asset__r.Order__c;
                        cs.Case_Plan__c=pId;
                        cs.contactid=cp.contact__c;
                        cs.AssetId = cp.Asset__c;
                        cs.RecordTypeId = ParentCaseRecID;
                        cases.add(cs);
                        for(Case_Plan_Asset__c csss:cpList){
                            if(csss.id !=cp.Id){
                                if(cloneOrderCaMap.containsKey(csss.Asset__r.Order__c)) {   
                                    cloneOrderCaMap.get(csss.Asset__r.Order__c).add(csss);}
                                else {cloneOrderCaMap.put(csss.Asset__r.Order__c,new list<Case_Plan_Asset__c>{csss}); }
                            }
                        }
                    }
                }
                else{
                    Case c = pcase.clone();
                    c.Order__c=a.Asset__r.Order__c;
                    c.Case_Plan__c=pId;
                    c.contactid=a.contact__c;
                    c.AssetId = a.Asset__c;
                    c.RecordTypeId = ParentCaseRecID;
                    cases.add(c);}
            }
        }
        if(cases.size()>0){
            try{
                Database.executeBatch(new createQAFOFParentcases_batch(cases,cloneOrderCaMap,childCaseRecID,pcase), 100);
                system.debug('Pcases size '+cases.size() );//INsert Parent Case                
            }
            Catch (exception e) {
                system.debug('Exception '+e.getCause() +' - '+e.getMessage() +' - '+e.getLineNumber());
            }
        }
        return null;
    }
    
    
    public PageReference save() {
        PageReference redirectSuccess = new ApexPages.StandardController(casePlan).view();
        return (redirectSuccess);
    }
    public PageReference cancel() {
        PageReference redirectSuccess = new ApexPages.StandardController(casePlan).view();
        return (redirectSuccess);
    }
    public PageReference close() {
        PageReference redirectSuccess = new ApexPages.StandardController(casePlan).view();
        return (redirectSuccess);
    }
    
}