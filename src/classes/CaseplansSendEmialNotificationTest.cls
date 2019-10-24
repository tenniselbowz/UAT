@isTest
public class CaseplansSendEmialNotificationTest {
    
    @future
    static void testSetUp(){    
        //Insert Email Template
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Test';
        validEmailTemplate.DeveloperName = 'AAH-Wty Auth for Serv Office';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();        
        insert validEmailTemplate;
    } 
    
    @testSetup
    static void testSetUp2()
    {
        Case_Plan__c cp =new Case_Plan__c();
        cp.name ='Test Case Plan';
        cp.Type__c='QA Program';
        cp.CurrencyIsoCode='USD';
        cp.Status__c='Completed';
        cp.Email_Templates__c='AAH-Wty Auth for Serv Office';
        insert cp;
        
        Case_Plan__c cp1=cp.clone();
        cp1.CurrencyIsoCode='CAD';
        cp1.Email_Templates__c='';
        insert cp1;
        
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        Account testAccount = APTPS_DaikinTestDataUtility.getAccount('accName');
        insert testAccount;
        
        Contact testContact = APTPS_DaikinTestDataUtility.getContact(testAccount);
        insert testContact;
        
        case c =new case();      
        c.AccountId = testAccount.Id;
        c.ContactId = testContact.id;
        c.Subject='Test';
        c.Origin='Mail';
        c.Priority='Low';
        c.Status='New';
        c.Case_Plan__c=cp.id;
        c.Case_Category__c='Claim';
        insert c;          
    }
    
    static testMethod void sendEmailNotification()
    {
        Test.startTest();     
        Case_Plan__c cp = [select id ,name from Case_Plan__c where CurrencyIsoCode='USD' limit 1]; 
        case c = [select id,Case_Plan__c,ContactId from case limit 1];
        EmailTemplate e =[select id ,DeveloperName from EmailTemplate limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(c.ContactId);
        //mail.whatid(c.id);
        mail.setTemplateId(e.Id);
        
        // Test.StartTest(); 
        PageReference pageRef = Page.CaseplansSendEmialNotification; // Initiate VF Page Action
        pageRef.getParameters().put('id', cp.Id); //Pass the recordID
        Test.setCurrentPage(pageRef); 
        ApexPages.StandardController sd = new ApexPages.StandardController(cp);
        CaseplansSendEmialNotification cs =new CaseplansSendEmialNotification(sd);
        cs.emialAlert(); //Send emails
        cs.getEmailResult(); //Get email result
        cs.cancel(); //Get redirected to Case plan detail page
        //Test.stopTest();
        
        //To display alert when the Case Plan donot have EMail template
        Case_Plan__c cp1 = [select id ,name from Case_Plan__c where CurrencyIsoCode='CAD' limit 1]; 
        PageReference pageRef1 = Page.CaseplansSendEmialNotification; // Initiate VF Page Action
        pageRef1.getParameters().put('id', cp1.Id); //Pass the recordID
        Test.setCurrentPage(pageRef1); 
        ApexPages.StandardController sd1 = new ApexPages.StandardController(cp1);
        CaseplansSendEmialNotification cs1 =new CaseplansSendEmialNotification(sd1);
        
    }
}