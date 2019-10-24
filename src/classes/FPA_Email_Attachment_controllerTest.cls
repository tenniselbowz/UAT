@isTest
public class FPA_Email_Attachment_controllerTest {
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
        SFO_Obj2.Name__c = 'test';
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
        
        
        
        //get record type of Read Only
        Id recordTypeId =
            Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName()
            .get('Read_Only').getRecordTypeId();
        
        // updating the record type Level 4-Special Feature to Read Only and Status to Approved
        SFO_Obj3.Status__c='Approved';
        SFO_Obj3.RecordTypeId=recordTypeId;
        update SFO_Obj3;
        
        
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
        Related_SFO__c RelatedSFO= [Select id,SFO__c,Unit_Detail__c,Notes__c from Related_SFO__c where Notes__c =:'Test1'];
        
        //Creating Attachments For Fpa Object
        String data = 'test data for attacement';
        List<Attachment> ListAttachments = new List<Attachment>();
        for(Integer i=0; i<5; i++){
            Attachment att = new Attachment();
            att.Name = 'Test Name'+i;
            att.Body = EncodingUtil.base64Decode(data);
            att.ParentId = RelatedSFO.id;
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
        
        PageReference pageRef= new pageReference('/apex/FPA_Approval_Email_Page?id='+FPAObj.Id);
        Test.setCurrentPage(pageRef); 
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPA_Email_Attachment_controller AttachmentController = new FPA_Email_Attachment_controller(sc);
    }
}