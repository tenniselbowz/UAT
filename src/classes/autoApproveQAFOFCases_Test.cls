@isTest
public class autoApproveQAFOFCases_Test {
    @TestSetup
    public static void testData(){
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;
        
        Address__c address = new Address__c();
        address.Address_Line_1__c = 'TEST';
        address.City__c = 'Minneapolis';
        address.Postal_Code__c = '55421';
        address.Country__c = 'United States';
        address.State_Province__c = 'Minnesota';
        insert address;
        
        Account a = new Account();
        a.Name = 'TEST';
        a.Type = 'Developer';
        a.Physical_Address__c = address.Id;
        insert a;
        
        Account_Address__c aa = new Account_Address__c();
        aa.Account__c = a.Id;
        aa.Address__c = address.Id;
        aa.Active__c = true;
        aa.Physical__c = true;
        insert aa;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'TEST';
        c.Email = 'test@test.com';
        insert c;
        
        Product2 p = new Product2();
        p.Name = 'TEST';
        p.IsActive = true;
        p.ProductCode = 'TEST';
        p.DW_Product_Business_Unit__c = 'Applied Air Handler';
        insert p;
        
        Order__c order = new Order__c();
        insert order;
        
        Asset asset = new Asset();
        asset.Name = 'TEST';
        asset.SerialNumber = 'TEST';
        asset.Product2Id = p.Id;
        asset.AccountId = a.Id;
        asset.ContactId = c.Id;
        asset.Order__c = order.Id;
        insert asset;
        
        Asset ass2=asset.clone();
        insert ass2;
        
        Case war3 = new Case();
        war3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        war3.Subject = 'TEST';
        war3.Origin = 'Email';
        war3.AccountId = a.Id;
        war3.ContactId = c.Id;
        // war3.Case_Plan__c=casePlan.id;
        war3.Is_dummy_Case_for_creating_New_cases__c=true;
        war3.Date_of_Failure__c = System.today();
        war3.Date_Received__c = System.today();
        war3.Reason_for_Authorization_Request__c = 'TEST';
        war3.Case_Category__c = 'Claim';
        war3.Business_Unit_Picklist__c = 'AAH';
        war3.AssetId = asset.Id;
        war3.Order__c = order.Id;
        insert war3;
        
        //Insert Case Plan
        Case_Plan__c casePlan= new Case_Plan__c();
        casePlan.Type__c='QA Program';
        casePlan.Dummy_Case_Template__c=war3.id;
        casePlan.Status__c='New';
        insert casePlan;
        system.debug('casePlan '+casePlan);
        
        Case war = new Case();
        war.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        war.Subject = 'TEST';
        war.Origin = 'Email';
        war.AccountId = a.Id;
        war.ContactId = c.Id;
        war.Case_Plan__c=casePlan.id;
        war.Is_dummy_Case_for_creating_New_cases__c=true;
        war.Date_of_Failure__c = System.today();
        war.Date_Received__c = System.today();
        war.Reason_for_Authorization_Request__c = 'TEST';
        war.Case_Category__c = 'Claim';
        war.Business_Unit_Picklist__c = 'AAH';
        war.AssetId = asset.Id;
        war.Order__c = order.Id;
        insert war;
        
        Case wc = war.clone();
        wc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();
        wc.Case_Category__c = 'Claim';
        wc.ParentId = war.Id;
        insert wc;
        
    }
    static testMethod void approveCasesSelected() {
        
        Case_Plan__c casePlan=[select id,name,Type__c from Case_Plan__c where Type__c=:'QA Program' limit 1];
        
        List<Case>  cases=[select Id,Status,casenumber,CreatedDate,Subject,Case_Plan__c,Approval_Status__c from Case where Case_Plan__c=:casePlan.id];
        List<Case> caseList=new list<Case>();
        for(Case c: cases){
            caseList.add(c);
        }
        ApexPages.standardSetController sc = new ApexPages.standardSetController(caseList);
        sc.setSelected(caseList);
        autoApproveQAFOFCases_Controller testAccPlan = new autoApproveQAFOFCases_Controller(sc);
        testAccPlan.goback();
        
        PageReference pageRef = Page.autoApproveQAFOFCasesVF;
        pageRef.getParameters().put('Id', String.valueOf(cases[0].Id));
        Test.setCurrentPage(pageRef); 
        testAccPlan.updateStatusOnCases();
    }
    static testMethod void approveCasesUnSelected() {
        List<Case>  cases=[select Id,Status,casenumber,CreatedDate,Subject,Case_Plan__c,Approval_Status__c from Case where Subject = 'TEST' limit 1];
        List<Case> casePlans=new list<Case>();
        for(Case c: cases){
            casePlans.add(c);
            PageReference pageRef1 = Page.autoApproveQAFOFCasesVF; // Initiate VF Page Action
            pageRef1.getParameters().put('id', String.valueOf(cases[0].Id)); //Pass the recordID
            Test.setCurrentPage(pageRef1);   
        }   
        ApexPages.StandardsetController sc = new ApexPages.StandardsetController(casePlans);
        autoApproveQAFOFCases_Controller testCAsePlan = new autoApproveQAFOFCases_Controller(sc);
        testCAsePlan.updateStatusOnCases();
    }
}