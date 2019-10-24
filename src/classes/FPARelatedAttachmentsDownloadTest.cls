@isTest
public class FPARelatedAttachmentsDownloadTest {
    
    @isTest static void FPARelatedAttchmentControllerTestMethod() 
    {
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        Product__c productObj = TestUtility.createProductFormat();
        productObj.IsActive__c=true;
        insert productObj;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Engineer','Operations');
        FPAPersonRepObj.User_Id__c='DKN1113';
        insert FPAPersonRepObj;
        
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,productObj.Id);
        FPAObj.Name = 'Test FPA';
        FPAObj.Status__c='Approved';
        insert FPAObj;
        System.assertEquals('Test FPA',  FPAObj.Name);
        System.assertEquals('Approved',  FPAObj.Status__c);
        
        
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
        
         System.assertEquals('V', cdl.shareType);
        System.assertEquals(FPAObj.id, ListAttachments[0].ParentId);
        
        FPA_Link__c fpaLink = new FPA_Link__c();
        fpalink.FPA__c = FPAObj.id;
        insert fpaLink;
        System.assertEquals(fpalink.FPA__c, FPAObj.id);
        
        /*Special_Feature_Option__c sfo = testUtility.createSFO(productObj.Id);
        sfo.Base_Unit_to_be_Modified__c=null;
        insert sfo;
        sfo.Base_Unit_to_be_Modified__c=productObj.Id;
        update sfo;
        

        
        Related_SFO__c relatedSfo = new Related_SFO__c();
        relatedSfo.SFO__c=sfo.id;
        relatedSfo.CurrencyIsoCode='USD - U.S. Dollar';
        relatedSfo.Unit_Detail__c=fpaLink.id;
        
        
        String data = 'test data for attacement';
        
        Attachment att = new Attachment();
        att.Name = 'Test Name';
        att.Body = EncodingUtil.base64Decode(data);
        att.ParentId = sfo.id;
        insert att;
        
        System.assertEquals('Test Name', att.Name);
        System.assertEquals(sfo.id, att.ParentId);*/
        
        pageReference pageRef=new pageReference('/apex/FPARelatedAttachmentsDownload?id='+FPAObj.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        FPARelatedAttachmentsDownloadController dController = new FPARelatedAttachmentsDownloadController(sc);
        dController.fpaID=FPAObj.id;
        FPARelatedAttachmentsDownloadController.getXMLFiles(FPAObj.ID);
        FPARelatedAttachmentsDownloadController.saveData(FPAObj.id, 'test file name', data);
        FPARelatedAttachmentsDownloadController.saveData(FPAObj.id, 'test file name', data);
        FPARelatedAttachmentsDownloadController.delData(ListAttachments[0].Id);
          
    }
}