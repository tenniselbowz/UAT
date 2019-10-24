@istest
public class FPASearchControllerTest 
{
    @testSetup static void fPASearchControllTestSetUp() {
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        Product__c productObj=TestUtility.createProductFormat();
        insert productObj;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        insert FPAPersonRepObj;
        
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,productObj.Id);
        FPAObj.Status__c='Approved';
        FPAObj.Name='Test FPA';
        insert FPAObj;
    }
	@isTest static void FPASearchControllerTestMethod() 
    {
        
        Factory_Pricing_Authorization__c FPAObj=[Select id,Sales_Person_Name__c from Factory_Pricing_Authorization__c where Name=:'Test FPA'];
        
        system.debug('FPAObj '+ FPAObj);
        
        pageReference pageRef=new pageReference('/apex/FPASearchPage');
        Test.setCurrentPage(pageRef);
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = FPAObj.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPASearchController FPASearchControllerObj=new FPASearchController(sc);
        FPASearchControllerObj.removeValues();
        FPASearchControllerObj.getFields();
        FPASearchControllerObj.resetFilters();
        FPASearchControllerObj.filter();
        FPASearchControllerObj.cloneFPA();
        FPASearchControllerObj.selectedFpa=null;
        FPASearchControllerObj.selectWrapper();
        FPASearchControllerObj.selectedFpa=FPAObj.id;
        FPASearchControllerObj.cloneFPA();
        FPASearchControllerObj.createFPA();
        FPASearchControllerObj.searchVal='Test';
        FPASearchControllerObj.salesPersonName='FPA User';
        /*FPASearchControllerObj.officeName='Test Office';
        FPASearchControllerObj.jobName='Test Job';
        FPASearchControllerObj.location='Test Location';
        FPASearchControllerObj.FPANumber='Test1234';*/
        FPASearchControllerObj.doSearch();
        FPASearchControllerObj.selectWrapper();
        FPASearchControllerObj.selectedFpa=FPAObj.Id;
        FPASearchControllerObj.selectWrapper();
    }
    
    @isTest static void TestMethod2(){
        Factory_Pricing_Authorization__c FPAObj=[Select id,Sales_Person_Name__c from Factory_Pricing_Authorization__c where Name=:'Test FPA'];
       
        pageReference pageRef=new pageReference('/apex/FPASearchPage');
        Test.setCurrentPage(pageRef);
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = FPAObj.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPASearchController FPASearchControllerObj=new FPASearchController(sc);
        FPASearchControllerObj.officeName='Test Office';
         FPASearchControllerObj.removeValues();
        FPASearchControllerObj.getFields();
        FPASearchControllerObj.resetFilters();
        FPASearchControllerObj.filter();
        FPASearchControllerObj.cloneFPA();
        FPASearchControllerObj.selectedFpa=null;
        FPASearchControllerObj.selectWrapper();
        FPASearchControllerObj.selectedFpa=FPAObj.id;
        FPASearchControllerObj.cloneFPA();
        FPASearchControllerObj.createFPA();
        FPASearchControllerObj.searchVal='Test';
        FPASearchControllerObj.officeName='Test Office';
        FPASearchControllerObj.doSearch();
    }
        @isTest static void TestMethod3(){
        Factory_Pricing_Authorization__c FPAObj=[Select id,Sales_Person_Name__c from Factory_Pricing_Authorization__c where Name=:'Test FPA'];
       
        pageReference pageRef=new pageReference('/apex/FPASearchPage');
        Test.setCurrentPage(pageRef);
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = FPAObj.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPASearchController FPASearchControllerObj=new FPASearchController(sc);
        
         FPASearchControllerObj.removeValues();
        FPASearchControllerObj.getFields();
        FPASearchControllerObj.resetFilters();
        FPASearchControllerObj.filter();
        FPASearchControllerObj.cloneFPA();
        FPASearchControllerObj.selectedFpa=null;
        FPASearchControllerObj.selectWrapper();
        FPASearchControllerObj.selectedFpa=FPAObj.id;
        FPASearchControllerObj.cloneFPA();
        FPASearchControllerObj.createFPA();
        FPASearchControllerObj.searchVal='Test';
         FPASearchControllerObj.jobName='Test Job';
        FPASearchControllerObj.doSearch();
    }
}