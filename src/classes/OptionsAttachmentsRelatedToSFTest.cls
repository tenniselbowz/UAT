@isTest
public class OptionsAttachmentsRelatedToSFTest {
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
        
        //get record type of Option
        Id RecordTypeIdSFO3 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 5-Option').getRecordTypeId();    
        
        //Create SFO record of record type Level 5-Option Feature
        Special_Feature_Option__c SFO_Obj4 = TestUtility.createSFO(productObj.id);
        SFO_Obj4.Name__c ='Option';
        SFO_Obj4.RecordTypeId = RecordTypeIdSFO3;
        SFO_Obj4.Option_Parent__c = SFO_Obj3.id;
        insert SFO_Obj4;
        
        // Creating the Attachments For the SFO object(Special Feature and Option record type)
        List<Attachment> ListAttachments = new List<Attachment>();
        String data = 'test data for attacement';
        for(Integer i=0; i<20; i++){
            Attachment att = new Attachment();
            att.Name = 'Test Name'+i;
            att.Body = EncodingUtil.base64Decode(data);
            if(i<10){
            att.ParentId = SFO_Obj3.id;
            }
            else{
               att.ParentId = SFO_Obj4.id; 
            }
            ListAttachments.add(att);
        } 
        insert ListAttachments;
        
        // Creating the ContentDocumentLinks i.e Files For the SFO object(Special Feature and Option record type)
        List<ContentVersion> conlist = new List<ContentVersion>();
        for(Integer i=0;i<20;i++){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins'+i,
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
         conlist.add(contentVersion); 
        }
        insert conlist;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record for the FPA 
        
        List<ContentDocumentLink> contentList = new List<ContentDocumentLink>();
        for(Integer i=0;i<20;i++){
            ContentDocumentLink cdl = New ContentDocumentLink();
            if(i<10){
            cdl.LinkedEntityId = SFO_Obj3.id;
            cdl.ContentDocumentId = documents[i].Id;
            }
            else{
                cdl.LinkedEntityId = SFO_Obj4.id;
                cdl.ContentDocumentId = documents[i].Id;
            }
            cdl.shareType = 'V';
            contentList.add(cdl);
        }
        insert contentList;
    }
    @isTest static void SFOPageAttachmentsMethod(){
        Special_Feature_Option__c  sfoObj = [Select id, Name__c,RecordTypeId From Special_Feature_Option__c where Name__c = :'Option'];
         PageReference pgRef = new PageReference('/apex/OptionAttachmentsRelatedToSF?id='+sfoObj.id);  
        Test.setCurrentPage(pgRef); 
        Apexpages.StandardController str = new Apexpages.StandardController(sfoObj);
        OptionsAttachmentsRelatedToSF optionAttachmentObj = new OptionsAttachmentsRelatedToSF(str);
    }
        @isTest static void SFOPageAttachmentsMethod2(){
        Special_Feature_Option__c  sfoObj = [Select id, Name__c,RecordTypeId From Special_Feature_Option__c where Name__c = :'Sample Special feature'];
         PageReference pgRef = new PageReference('/apex/OptionAttachmentsRelatedToSF?id='+sfoObj.id);  
        Test.setCurrentPage(pgRef); 
        Apexpages.StandardController str = new Apexpages.StandardController(sfoObj);
        OptionsAttachmentsRelatedToSF optionAttachmentObj = new OptionsAttachmentsRelatedToSF(str);
            optionAttachmentObj.currenpageId=sfoObj.id;
    }
}