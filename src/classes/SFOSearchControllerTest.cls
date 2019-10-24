@isTest
public class SFOSearchControllerTest {
    @testSetup
    public Static void Setup(){
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = [Select Id, Name, Email from User where Id =: userInfo.getUserId()];
        
        // Creating the Product 
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        // Creating the Format i.e parent for the SFO Record Type Section
        Product__c productObj = TestUtility.createProductFormat();
        productObj.IsActive__c=true;
        insert productObj;
        
        //Creating User 
        // Creating the SalesPerson for FPA
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Engineer','Operations');
        FPAPersonRepObj.User_Id__c='DKN1113';
        FPAPersonRepObj.Email__c='deepika.a@solunuscorp.com';
        insert FPAPersonRepObj;
        
        //Creating FPA with parameters salesperson and projectid
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,productObj.Id);
        FPAObj.Name = 'Test FPA';
        FPAObj.Application_Engineer__c = u.id;
        FPAObj.Status__c='Approved';
        insert FPAObj;
        
        //Creating Unitdetails for FPA object i.e FPA Link
        
        FPA_Link__c fpaLink = TestUtility.CreatesfpaLink(FPAObj.Id);
        insert fpaLink;   
        
        //get record type of Special_Feature_Option__c
        Id RecordTypeIdSFO = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 2-Section').getRecordTypeId();    
        //Create SFO record of record Type Section
        Special_Feature_Option__c SFO_Obj1 = TestUtility.createSFO(productObj.id);
        SFO_Obj1.Name__c = 'test';
        SFO_Obj1.RecordTypeId = RecordTypeIdSFO;
        SFO_Obj1.Base_Unit_to_be_Modified__c =productObj.id;
        insert SFO_Obj1;
        
        //get record type of Component
        Id RecordTypeIdSFO1 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 3-Component').getRecordTypeId();    
        
        //Create SFO record of record type  Component
        Special_Feature_Option__c SFO_Obj2 = TestUtility.createSFO(productObj.id);
        SFO_Obj2.Name__c = 'test Component';
        SFO_Obj2.RecordTypeId = RecordTypeIdSFO1;
        SFO_Obj2.Parent_SFO__c = SFO_Obj1.id;
        insert SFO_Obj2;
        
        //get record type of Special Feature
        Id RecordTypeIdSFO2 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 4-Special Feature').getRecordTypeId();    
        
        //Create SFO record of record type Level 4-Special Feature
        Special_Feature_Option__c SFO_Obj3 = TestUtility.createSFO(productObj.id);
        SFO_Obj3.Name__c ='Sample Special feature';
        SFO_Obj3.RecordTypeId = RecordTypeIdSFO2;
        SFO_Obj3.Special_Feature_Parent__c = SFO_Obj2.id;
        insert SFO_Obj3;
        
        
        
          //get record type of Option
        Id RecordTypeIdSFO3 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 5-Option').getRecordTypeId(); 
        
        SFO_Obj3.RecordTypeId=RecordTypeIdSFO3;
        SFO_Obj3.Status__c='Approved';
        update SFO_Obj3;
        
               // Id ReadOnlyRecordTypeIdSFO = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Read Only').getRecordTypeId();    
        List<Related_SFO__c> SFOList = new List<Related_SFO__c>();
        for(Integer i=0; i<50; i++){
            Related_SFO__c RelatedSFO = new Related_SFO__c();
            RelatedSFO.SFO__c=SFO_Obj3.Id;
            RelatedSFO.Notes__c='Test'+i;
            //RelatedSFO.CurrencyIsoCode='CAD - Canadian Dollar';
            RelatedSFO.Unit_Detail__c=fpaLink.Id;
            SFOList.add(RelatedSFO);
        }
        insert SFOList;
    }
    @isTest static void   SendEmailFPARelatedAttachmentsMethod(){
        Factory_Pricing_Authorization__c   FPAObj =[Select id,Name,Application_Engineer__c,Status__c from Factory_Pricing_Authorization__c where Name=:'Test FPA'];
        Special_Feature_Option__c SFOObj= [Select id,Name__c,Status__c,RecordTypeId,Option_Parent__c from Special_Feature_Option__c where Name__c=:'Sample Special feature'];
        FPA_Link__c fpalink = [Select id, Name From FPA_Link__c limit 1];
        Id readOnlyRecordTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName()
            .get('Read_Only').getRecordTypeId();
        SFOObj.RecordTypeId=readOnlyRecordTypeId;
        update SFOObj;
        Related_SFO__c RelatedSFo = [Select id,SFO__c,Notes__c,Unit_Detail__c from Related_SFO__c where Notes__c =:'Test1'];
        
        Test.startTest();
        PageReference pgref = new Pagereference('/apex/SFOSearchPage?id='+FPAObj.id);
        Test.setCurrentPage(pgref); 
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        SFOSearchController SFOApprovalControllerObj = new SFOSearchController(sc);
        SFOSearchController.SFOWrapper sfoWrap = new SFOSearchController.SFOWrapper(SFOObj);
        SFOSearchController.UnitTagWrapper sfoUnitTagWrap = new SFOSearchController.UnitTagWrapper(SFOObj,fpalink);
        SFOApprovalControllerObj.getUnitDetails();
        SFOApprovalControllerObj.searchVal='Approved';
        SFOApprovalControllerObj.isSearched = true;
        SFOApprovalControllerObj.getFields('Special_Feature_Option__c');
        SFOApprovalControllerObj.doSearch();
        SFOApprovalControllerObj.associateSFO();
        SFOApprovalControllerObj.closePopup();
        SFOApprovalControllerObj.showPopup();
        SFOApprovalControllerObj.createSFO();
        SFOApprovalControllerObj.backToFPA();
        SFOApprovalControllerObj.Beginning();
        SFOApprovalControllerObj.Next();
        SFOApprovalControllerObj.getDisableNext();
        SFOApprovalControllerObj.Previous();
        SFOApprovalControllerObj.getDisablePrevious();
        SFOApprovalControllerObj.relatedSFOID=RelatedSFo.id;
        SFOApprovalControllerObj.deleteRow();
        Test.stopTest();
        
    }
    @isTest static void   SendEmailFPARelatedAttachmentsMethod2(){
        Factory_Pricing_Authorization__c   FPAObj =[Select id,Name,Application_Engineer__c,Status__c from Factory_Pricing_Authorization__c where Name=:'Test FPA'];
        Special_Feature_Option__c SFOObj= [Select id,Name__c,Status__c,RecordTypeId,Option_Parent__c from Special_Feature_Option__c where Name__c=:'Sample Special feature'];
        FPA_Link__c fpalink = [Select id, Name From FPA_Link__c limit 1];
        
        Related_SFO__c RelatedSFo = [Select id,SFO__c,Notes__c,Unit_Detail__c from Related_SFO__c where Notes__c =:'Test1'];
        
        Test.startTest();
        PageReference pgref = new Pagereference('/apex/SFOSearchPage?id='+FPAObj.id);
        Test.setCurrentPage(pgref); 
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        SFOSearchController SFOApprovalControllerObj = new SFOSearchController(sc);
        SFOSearchController.SFOWrapper sfoWrap = new SFOSearchController.SFOWrapper(SFOObj);
        SFOSearchController.UnitTagWrapper sfoUnitTagWrap = new SFOSearchController.UnitTagWrapper(SFOObj,fpalink);
        SFOApprovalControllerObj.getUnitDetails();
        SFOApprovalControllerObj.searchVal='Approved';
        SFOApprovalControllerObj.searchsfoVal='';
        SFOApprovalControllerObj.isSearched = true;
        SFOApprovalControllerObj.getFields('Special_Feature_Option__c');
        SFOApprovalControllerObj.doSearch();
        SFOApprovalControllerObj.associateSFO();
        Test.stopTest();
        
    }
    
    // Test Method to cover the method in TestUtility Class
    @isTest static void TestUtilityMethod(){
        Factory_Pricing_Authorization__c   FPAObj =[Select id,Name,Application_Engineer__c,Status__c from Factory_Pricing_Authorization__c where Name=:'Test FPA'];
        Integer MaxQuantitySingleLineItem =2;
        Integer FpaTotalEngHours =3;
        Integer FpaTotalMagHours=4;
        Integer MaxMaterialCost=5;
        Integer QLineItemSpecial=6;
       Integer FpaTotalDrfHours=4;
        FPA_Link__c UnitDetailObject = TestUtility.CreatesfpaLink(FPAObj.id,MaxQuantitySingleLineItem,FpaTotalEngHours,FpaTotalMagHours,MaxMaterialCost,QLineItemSpecial,FpaTotalDrfHours);
      
        //Creating FpaApprover
        FPA_Approval__c FPAApprover = TestUtility.CreateFpaApprover(FPAObj.id,'Approved');
        
        // Creating the Format i.e parent for the SFO Record Type Section
        Product__c productObj = TestUtility.createProductFormat();
        productObj.IsActive__c=true;
        insert productObj;
        
        //Creating Format Approver
        FPA_Approval__c FormatApprover = TestUtility.CreateFormatApprover(productObj.id, 'Approved', true, true, true, false);
    }
    
    //Test Method To Cover For Updating the SFO with Different UnitDetails(Trigger Handler Class )
    
    @isTest static void SFOTriggerHandlerMethod(){
        Factory_Pricing_Authorization__c   FPAObj =[Select id,Name,Application_Engineer__c,Status__c from Factory_Pricing_Authorization__c where Name=:'Test FPA'];
        Special_Feature_Option__c SFOObj= [Select id,Name__c,Status__c,RecordTypeId,Option_Parent__c from Special_Feature_Option__c where Name__c=:'test Component'];
        
        // Creating Product
        
        Product__c productObj = TestUtility.createProductFormat();
        productObj.IsActive__c=true;
        insert productObj;
        
         //get record type of Special Feature
        Id RecordTypeIdSFO2 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 4-Special Feature').getRecordTypeId();    
        //Create SFO record of record type Level 4-Special Feature
        Special_Feature_Option__c SFO_Obj3 = TestUtility.createSFO(productObj.id);
        SFO_Obj3.Name__c ='Sample Special feature test';
        SFO_Obj3.RecordTypeId =RecordTypeIdSFO2;
        SFO_Obj3.Special_Feature_Parent__c = SFOObj.id;
        insert SFO_Obj3;
        
        //get record type of Option
        Id RecordTypeIdSFO3 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 5-Option').getRecordTypeId(); 
        Special_Feature_Option__c SFO_Obj4 = TestUtility.createSFO(productObj.id);
        SFO_Obj4.Name__c ='Option test';
        SFO_Obj4.RecordTypeId = RecordTypeIdSFO3;
        SFO_Obj4.Option_Parent__c = SFO_Obj3.id;
        insert SFO_Obj4;
        
        //Creating Unitdetails for FPA object i.e FPA Link
        
        FPA_Link__c fpaLink = TestUtility.CreatesfpaLink(FPAObj.Id);
        fpaLink.SFO__c=SFO_Obj4.id;
        insert fpaLink;  

        
        List<Special_Feature_Option__c> Sfolist = new List<Special_Feature_Option__c>();
        Sfolist.add(SFO_Obj3);
        SFO_Trigger_Handler SFOTriggerHandlerCls = new SFO_Trigger_Handler();
        SFO_Trigger_Handler.createDynamicFields(Sfolist);
        SFO_Trigger_Handler.Insert_ChildRec_for_SFOs(Sfolist);
        SFO_Trigger_Handler.updateRevisionInfo(Sfolist);
        SFO_Trigger_Handler.updateUnitTags(Sfolist);
    }
    
    // TestMethod For removeDraftRejectedSFO Class 
      @isTest static void   removeDraftRejectedSFOS(){
        Factory_Pricing_Authorization__c   FPAObj =[Select id,Name,Application_Engineer__c,Status__c from Factory_Pricing_Authorization__c where Name=:'Test FPA'];
          Special_Feature_Option__c SFOObj= [Select id,Name__c,Status__c,RecordTypeId,Option_Parent__c from Special_Feature_Option__c where Name__c=:'Sample Special feature'];
          FPA_Link__c fpalink = [Select id, Name From FPA_Link__c limit 1];
          Id readOnlyRecordTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName()
              .get('Read_Only').getRecordTypeId();
          SFOObj.RecordTypeId=readOnlyRecordTypeId;
          update SFOObj;
          SFOObj.Status__c='Draft';
          update SFOObj;
          //Related_SFO__c RelatedSFo = [Select id,SFO__c,Notes__c,Unit_Detail__c from Related_SFO__c where Notes__c =:'Test1']; 
    }
}