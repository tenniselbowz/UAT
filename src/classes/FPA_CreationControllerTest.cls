@isTest
public class FPA_CreationControllerTest {
    
    @testSetup static void setup() {
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
       /* Product__c productObj=[Select id from Product__c limit 1];
        productObj.IsActive__c=true;
        //productObj.Revenue__c = 'High';
        update productObj;*/
        
        Product__c productObj=TestUtility.createProductFormat();
        productObj.IsActive__c=false;
        insert productObj;
        productObj.IsActive__c=true;
        update productObj;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        insert FPAPersonRepObj;
        
    }
    
    @isTest static void FPACreationTestMethod() 
    {
        
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA([Select Id from FPA_Persona__c limit 1].Id,[Select Id from Product__c limit 1].Id);        
        FPAObj.Risk__c = 'High';
        //FPAObj.CapX__c = 'Likely';
        FPAObj.Eng_Mfg_Effort__c = 'High';
       // FPAObj.Previous_FPA__c = 'No';
        FPAObj.Approval_Level__c='A';
        pageReference pageRef=new pageReference('/apex/FPA_Creation?&pageType=Creation&retUrl=/apex/FPASearchPage');
        Test.setCurrentPage(pageRef);
        
        //Below lines to cover New FPA Creation
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPA_CreationController fpaCreation = new FPA_CreationController(sc);
        fpaCreation.FPAObj = FPAObj;
        fpaCreation.saveFPA();
        fpaCreation.backtofpasearch();  
        Test.stopTest();
        
        System.assertEquals(FPAObj.Approval_Level__c, 'A');
        System.assertEquals(fpaCreation.vfTitle, 'FPA Creation Page');
    }
    
    @isTest static void FPACloneTestMethod() 
    {
        
         Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA([Select Id from FPA_Persona__c limit 1].Id,[Select Id from Product__c limit 1].Id);
        insert FPAObj;
        
        pageReference pageRef=new pageReference('/apex/FPA_Creation?&pageType=Creation&retUrl=/apex/FPASearchPage');
        Test.setCurrentPage(pageRef);
        
        //Below lines to cover Clone FPA
        Test.startTest();
        FPAObj = Database.query(UtilityClass.getSObjectFields('Factory_Pricing_Authorization__c', 'Id !=Null limit 1', true));
        pageRef=new pageReference('/apex/FPA_Creation?id='+FPAObj.Id+'&pageType=Clone&retUrl=/apex/FPASearchPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPA_CreationController fpaCreation = new FPA_CreationController(sc);
        fpaCreation.saveFPA();
        fpaCreation.backtofpasearch();
        Test.stopTest();
        
        System.assertEquals(fpaCreation.vfTitle, 'FPA Clone Page');
    }
    // For FPA_Version_Controller  Class 
    @isTest static void FPAVersionTestMethod() 
    {
         Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA([Select Id from FPA_Persona__c limit 1].Id,[Select Id from Product__c limit 1].Id);
        FPAObj.Version__c = '';
        //FPAObj.Parent_FPA__c=FPAObjParent.id;
        insert FPAObj;
        
        //Creating FPA Link For FPA Object
        FPA_Link__c fpaLink = TestUtility.CreatesfpaLink(FPAObj.Id);
        insert fpaLink;
         // Creating Attachments for FPA Parent
        String data = 'test data for attacement';
        List<Attachment> ListAttachments = new List<Attachment>();
        for(Integer i=0; i<5; i++){
            Attachment att = new Attachment();
            att.Name = 'Test Name'+i;
            att.Body = EncodingUtil.base64Decode(data);
            att.ParentId = FPAObj.id;
            ListAttachments.add(att);
        } 
        insert ListAttachments;
        
        // Creating ContentDocumentLink
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record for the FPA 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = FPAObj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl; 
        
        pageReference pageRef=new pageReference('/apex/FPA_Creation?&pageType=Creation');
        Test.setCurrentPage(pageRef);
        
        //Below lines to cover Version FPA
        Test.startTest();
        FPAObj = Database.query(UtilityClass.getSObjectFields('Factory_Pricing_Authorization__c', 'Id !=Null limit 1', true));
        pageRef=new pageReference('/apex/FPA_Creation?id='+FPAObj.Id+'&pageType=Version');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPA_CreationController fpaCreation = new FPA_CreationController(sc);
        fpaCreation.saveFPA(); 
        Test.stopTest();
        
        System.assertEquals(fpaCreation.vfTitle, 'FPA Versioning Page');
    }
    
    @isTest static void FPAExceptionTestMethod1() 
    {
         Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA([Select Id from FPA_Persona__c limit 1].Id,[Select Id from Product__c limit 1].Id);
        FPAObj.Base_Unit_to_be_Modified__c=Null;
        
        pageReference pageRef=new pageReference('/apex/FPA_Creation');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPA_CreationController fpaCreation = new FPA_CreationController(sc);
        fpaCreation.FPAObj = FPAObj;
        fpaCreation.saveFPA();
        Test.stopTest();
    }
    
     @isTest static void FPAExceptionTestMethod2() 
    {
         Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA([Select Id from FPA_Persona__c limit 1].Id,[Select Id from Product__c limit 1].Id);
        FPAObj.Quantity__c=0;
        
        pageReference pageRef=new pageReference('/apex/FPA_Creation');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPA_CreationController fpaCreation = new FPA_CreationController(sc);
        fpaCreation.FPAObj = FPAObj;
        fpaCreation.fpaQuantityString='5';
        fpaCreation.addRow();
        fpaCreation.saveFPA();  
        fpaCreation.generateUnitDetails();
        fpaCreation.delRow();
        Test.stopTest();
    }
    
    // For FPA_Version_Controller class
         @isTest static void FPAExceptionTestMethod3() 
    {
         Factory_Pricing_Authorization__c FPAObjParent=TestUtility.createFPA([Select Id from FPA_Persona__c limit 1].Id,[Select Id from Product__c limit 1].Id);
        FPAObjParent.Quantity__c=0;
        id FPA_Id = FPAObjParent.id;
       
        pageReference pageRef=new pageReference('/apex/FPA_Creation?Id='+FPA_Id+'&version=1&retUrl=/'+FPA_Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        FPA_Version_Controller fpaCreation = new FPA_Version_Controller();
        FPA_Version_Controller.redirectToFPACreation();
        Test.stopTest();
    }
}