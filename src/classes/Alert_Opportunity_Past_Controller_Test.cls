@isTest
public class Alert_Opportunity_Past_Controller_Test {

    
    static testMethod void constructorTest2(){
        
        Test.startTest();
        // managed package settings
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        //account for test
        Account acct = new Account();
        acct = TestingUtils.createAccounts(1, 'TestAccount', false)[0];
        acct.Type = 'AccountFormsTest';
        insert acct;
        
        //address for test
        Address__c addy=new Address__c();
        addy = TestingUtils.createAddresses(1, true)[0];
        
        //opportunity for test
        Opportunity oppObj = new opportunity();
        oppObj.Name='test';
        oppObj.CloseDate = system.today();
        oppObj.StageName='Proposal/Price Quote/Bid';
        oppObj.Vertical_Market__c='Airports & Transportation';
        oppObj.AccountId=acct.id;
        oppObj.Job_Address__c = addy.id;
        insert oppObj;
        system.debug('oppObj synced prp--'+oppObj.Synced_Quote_Proposal__c);
        
        //Creating Testing Queue
        Group testGroup = new Group(Name='Service Credit', Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Apttus_Proposal__Proposal__c');
            insert testQueue;
        }
        
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c quoteObj1 = new Apttus_Proposal__Proposal__c(OwnerId = testGroup.Id);
        quoteObj1.Apttus_Proposal__Account__c = acct.id;
        quoteObj1.Apttus_Proposal__Opportunity__c = oppObj.id;
        quoteObj1.Credit_Approved__c = 1;
        quoteObj1.Credit_Rejected__c = 0;
        quoteObj1.Credit_Status__c='Approved';
        quoteObj1.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        quoteObj1.Approval_Status__c = 'Mgmt Approved';
         quoteObj1.Approval_Action__c = 'Submitted';
       quoteObj1.Apttus_Proposal__Approval_Stage__c = 'Credit Approval Requested';
        insert quoteObj1;
     
        // load the page       
        PageReference pageRef = Page.Alert_Opportunity_is_in_Past;
        pageRef.getParameters().put('Id',quoteObj1.id);
        Test.setCurrentPageReference(pageRef);
        
        // load the extension
        ApexPages.StandardController sc = new ApexPages.standardController(quoteObj1);
        Alert_Opportunity_Past_Controller  controller = new Alert_Opportunity_Past_Controller(sc);
        controller.Display();
       
        Test.stopTest();
    }
    
}