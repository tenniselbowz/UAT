/***
*Created by: Solunus
*Created Date: 05/09/2019
*Last Updated Date: 05/10/19
*Description : TestClass for createQA_FOFCasesFromCasePlan_Controller 
***/
@isTest
public class createQA_FOFCasesFromCasePlan_ConTest {
    
    @TestSetup
    private static void testData(){
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
        
        //Insert Asset 2
          Asset asset2 = new Asset();
        asset2.Name = 'TEST 2';
        asset2.SerialNumber = 'TEST 3';
        asset2.Product2Id = p.Id;
        asset2.AccountId = a.Id;
        asset2.ContactId = c.Id;
        asset2.Order__c = order.Id;
        insert asset2;
        
        Case war = new Case();
        war.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        war.Subject = 'TEST';
        war.Origin = 'Email';
        war.AccountId = a.Id;
        war.ContactId = c.Id;
        war.Is_dummy_Case_for_creating_New_cases__c=true;
        war.Date_of_Failure__c = System.today();
        war.Date_Received__c = System.today();
        war.Reason_for_Authorization_Request__c = 'TEST';
        war.Case_Category__c = 'Claim';
        war.Business_Unit_Picklist__c = 'AAH';
        war.AssetId = asset.Id;
        war.Order__c = order.Id;
        insert war;
        
        //Insert Case Plan
        Case_Plan__c casePlan= new Case_Plan__c();
        casePlan.Type__c='QA Program';
        casePlan.Dummy_Case_Template__c=war.id;
        casePlan.Status__c='New';
        insert casePlan;
        
        //INsert CasePlan Asset
        Case_Plan_Asset__c caPlanAsset=new Case_Plan_Asset__c();
        caPlanAsset.Asset__c=asset.id;
        caPlanAsset.Case_Plan__c=casePlan.id;
        caPlanAsset.Contact__c=c.Id;
        insert caPlanAsset;
        
        //INsert 2nd Case Plan Asset
        Case_Plan_Asset__c caPlanAsset2=new Case_Plan_Asset__c();
        caPlanAsset2.Asset__c=asset2.id;
        caPlanAsset2.Case_Plan__c=casePlan.id;
        caPlanAsset2.Contact__c=c.Id;
        insert caPlanAsset2;
        
        Case wc = war.clone();
        wc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();
        wc.Case_Category__c = 'Claim';
        wc.ParentId = war.Id;
        insert wc;
            System.debug('childCaseID - wc '+wc.id);

        
        /*wc = wc.clone();
        insert wc; */
        
        //Insert ServiceCodes
        Case_Service_Code__c serviceCOde=new Case_Service_Code__c();
        serviceCOde.Case__c=wc.id;
        serviceCOde.Hours_Approved__c=12;
        serviceCOde.Daikin_Parts_Amount_Approved__c=10;
        serviceCOde.X3rd_Party_Parts_Amount_Approved__c=12;
        serviceCOde.Labor_Amount_Approved__c=28;
        serviceCOde.Labor_Amount_Requested__c=30;
        insert serviceCOde;
        
        system.debug('serviceCOde '+serviceCOde);
        
        //Test.stopTest();
    }
    private static Case getTestCase(){
        return [select Id, Subject, Origin, AccountId, ContactId, Date_of_Failure__c, Date_Received__c, Reason_for_Authorization_Request__c, Business_Unit_Picklist__c, AssetId, Order__c from Case where Case_Category__c != 'Claim' Limit 1];
    }
    private static Case_Plan__c getCasePlan(){
        return [select id from Case_Plan__c limit 1];
    }
    
    private static List<Case_Plan_Asset__c> getCasePlanAsset(){
        return [select id,name,Asset__c,Case_Plan__c from Case_Plan_Asset__c];
    }
    static testMethod void createQA_FOFCasesFromCasePlan_ControllerTest() {
        List<Case_Plan__c> casePlans=new list<Case_Plan__c>();
        List<string> selectedAssetIDs=new List<string>();
        
        Case_Plan__c casePlan=getCasePlan();
        List<id> caseplanAssIds=new List<id>();
        //List<Case_Plan_Asset__c> caseplanAsset=getCasePlanAsset();
        for(Case_Plan_Asset__c cpa:getCasePlanAsset()){
            caseplanAssIds.add(cpa.id);
        }
        system.debug('selectedAssetIDs '+selectedAssetIDs);
        //selectedAssetIDs.add(caseplanAsset.id);
        casePlans.add(casePlan);
        
        Test.StartTest(); 
        PageReference pageRef = Page.createQAorFOFCasesFromCasePlan; // Initiate VF Page Action
        pageRef.getParameters().put('id', casePlan.Id); //Pass the recordID
        Test.setCurrentPage(pageRef);   
        ApexPages.StandardsetController sc = new ApexPages.StandardsetController(casePlans);
        createQA_FOFCasesFromCasePlan_Controller testCAsePlan = new createQA_FOFCasesFromCasePlan_Controller(sc);
        integer casesInserted=createQA_FOFCasesFromCasePlan_Controller.createOrderAssets(casePlan.Id, caseplanAssIds);
        testCAsePlan.save();
        testCasePlan.getdisplayCasePlassets();
        testCAsePlan.cancel();
        testCAsePlan.close();
        //system.assertEquals(1, casesInserted) ;      
        test.stopTest();
    }
}