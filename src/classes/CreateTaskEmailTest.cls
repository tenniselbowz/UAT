@istest
public class CreateTaskEmailTest 
{
    @isTest
    static void createTaskEmailTestmethod()
    {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        Product__c productObj=TestUtility.createProductFormat();
        insert productObj;
        
        Special_Feature_Option__c SFOObj=TestUtility.createSFO(productObj.Id);
        
        insert SFOObj;
        
        FPA_Persona__c FPAPersonObj=TestUtility.createFPAPersona('Engineer','Product');
        FPAPersonObj.User_Id__c='test 12323';
        insert FPAPersonObj;
        
        Factory_Pricing_Authorization__c fpaObj = TestUtility.createFPA(FPAPersonObj.id, productObj.id);
        //fpaObj.Base_Unit_to_be_Modified__c = null;
        fpaObj.FPA_Number__c = 'ABCD1234';
        insert fpaObj;
        Factory_Pricing_Authorization__c fpaObj1 = TestUtility.createFPA(FPAPersonObj.id, productObj.id);
        //fpaObj.Base_Unit_to_be_Modified__c = null;
        fpaObj1.FPA_Number__c = 'ABCD1234';
        
        //Creating Approvers for FPA
        FPA_Approvers__c FpaApprover1 = new FPA_Approvers__c();
        FpaApprover1.FPA__c=fpaObj.id;
        FpaApprover1.Status__c='Sent';
        FpaApprover1.Email__c='Daikin@test.com';
        insert FpaApprover1;
        
        SFOObj=[Select id,name from Special_Feature_Option__c limit 1];
        
        // setup the data for the email
        email.subject = 'SFO Approval request for'+fpaObj.FPA_Number__c;
        email.fromAddress = 'Daikin@test.com';
        email.plainTextBody = 'email body\n2225256325\nTitle\n APPROVED';
        
        
        // call the email service class and test it with the data in the testMethod
        CreateTaskEmail  testInbound=new CreateTaskEmail ();
        testInbound.handleInboundEmail(email, env);
    }
    @isTest static void createTaskEmailTestmethod2()
    {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        Product__c productObj=TestUtility.createProductFormat();
        insert productObj;
        
        Special_Feature_Option__c SFOObj=TestUtility.createSFO(productObj.Id);
        
        insert SFOObj;
        
        FPA_Persona__c FPAPersonObj=TestUtility.createFPAPersona('Engineer','Product');
        FPAPersonObj.User_Id__c='test 12323';
        insert FPAPersonObj;
        
        Factory_Pricing_Authorization__c fpaObj = TestUtility.createFPA(FPAPersonObj.id, productObj.id);
        //fpaObj.Base_Unit_to_be_Modified__c = null;
        fpaObj.FPA_Number__c = 'AGFD1234';
        
        //Creating Approvers for FPA
        FPA_Approvers__c FpaApprover1 = new FPA_Approvers__c();
        FpaApprover1.FPA__c=fpaObj.id;
        FpaApprover1.Status__c='Sent';
        FpaApprover1.Email__c='Daikin@test.com';
        insert FpaApprover1;
        
        SFOObj=[Select id,name from Special_Feature_Option__c limit 1];
        
        // setup the data for the email
        email.subject = 'SFO Approval request for'+fpaObj.FPA_Number__c;
        email.fromAddress = 'Daikin@test.com';
        email.plainTextBody =  'email body\n2225256325\nTitle\n Dear';
        
        
        // call the email service class and test it with the data in the testMethod
        CreateTaskEmail  testInbound=new CreateTaskEmail ();
        testInbound.handleInboundEmail(email, env);
    }
        @isTest static void createTaskEmailTestmethod3()
    {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        Product__c productObj=TestUtility.createProductFormat();
        insert productObj;
        
        Special_Feature_Option__c SFOObj=TestUtility.createSFO(productObj.Id);
        
        insert SFOObj;
        
        FPA_Persona__c FPAPersonObj=TestUtility.createFPAPersona('Engineer','Product');
        FPAPersonObj.User_Id__c='test 12323';
        insert FPAPersonObj;
        
        Factory_Pricing_Authorization__c fpaObj = TestUtility.createFPA(FPAPersonObj.id, productObj.id);
        //fpaObj.Base_Unit_to_be_Modified__c = null;
        fpaObj.FPA_Number__c = 'AGFD1234';
        
        //Creating Approvers for FPA
        FPA_Approvers__c FpaApprover1 = new FPA_Approvers__c();
        FpaApprover1.FPA__c=fpaObj.id;
        FpaApprover1.Status__c='Sent';
        FpaApprover1.Email__c='Daikin@test.com';
        insert FpaApprover1;
        
        SFOObj=[Select id,name from Special_Feature_Option__c limit 1];
        
        // setup the data for the email
        email.subject = 'SFO Approval request for'+fpaObj.FPA_Number__c;
        email.fromAddress = 'Daikin@test.com';
        email.plainTextBody =  'email body\n2225256325\nTitle\n REJECTED';
        
        
        // call the email service class and test it with the data in the testMethod
        CreateTaskEmail  testInbound=new CreateTaskEmail ();
        testInbound.handleInboundEmail(email, env);
    }
}