@istest
public class FPATriggerHandlerTest {
    @TestSetup 
    static void setup() {
        List<Approval_Criteria__c>  ApprovalCriteria = new List<Approval_Criteria__c>();
        List<FPA_Persona__c> Userss = new List<FPA_Persona__c>();
        List<FPA_Approval__c> FormatApprovers = new List<FPA_Approval__c>();
        
        // Creating the product
        
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        Product__c productObj=TestUtility.createProductFormat();
        productObj.IsActive__c=true;
        insert productObj;
        
        // Creating the FPA Users
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        Userss.add(FPAPersonRepObj);
        
        FPA_Persona__c FPAPersonRepObj1=TestUtility.createFPAPersona('Engineer',null);
        FPAPersonRepObj.User_Id__c='test 123';
        FPAPersonRepObj1.Name='Test 1';
        Userss.add(FPAPersonRepObj1);
        
        FPA_Persona__c FPAPersonRepObj2=TestUtility.createFPAPersona('Manager',null);
        FPAPersonRepObj.User_Id__c='test 12';
        FPAPersonRepObj1.Name='Test 2';
        Userss.add(FPAPersonRepObj2);
        
        FPA_Persona__c FPAPersonRepObj3=TestUtility.createFPAPersona('Director',null);
        FPAPersonRepObj.User_Id__c='test 1';
        FPAPersonRepObj1.Name='Test 3';
        Userss.add(FPAPersonRepObj3);
        
        //inserting users
        insert Userss;
        
        // Creating Approvers For Format 
        
        FPA_Approval__c FormatApproverA =TestUtility.CreateFormatApprover(productObj.Id,'Sent',True,False,False,False);
        FormatApproverA.Approver_Department__c='Applications';
        FormatApproverA.Approver_Role__c='Director';
        FormatApproverA.Email__c='test@gmail.com';
        FormatApprovers.add(FormatApproverA);
        
        FPA_Approval__c FormatApproverB =TestUtility.CreateFormatApprover(productObj.Id,'Sent',False,True,False,False);
        FormatApproverB.Approver_Department__c='Engineering';
        FormatApproverB.Approver_Role__c='Engineer';
        FormatApproverB.Email__c='test1@gmail.com';
        FormatApprovers.add(FormatApproverB);
        
        FPA_Approval__c FormatApproverC =TestUtility.CreateFormatApprover(productObj.Id,'Sent',False,False,True,False);
        FormatApproverC.Approver_Department__c='General';
        FormatApproverC.Approver_Role__c='Manager';
        FormatApproverC.Email__c='test2@gmail.com';
        FormatApprovers.add(FormatApproverC);
        
        // Insering Format Approvers
        insert FormatApprovers;
        
        // Creating FPA 
        UtilityClass.getSObjectRelatedFields('FPA_Approval__c','FPA_Person__r.Name','',true);
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,productObj.Id);
        FPAObj.Approval_Level__c= 'A';
        insert FPAObj;
        
        //Create FPA link
        FPA_Link__c FPALink = TestUtility.CreatesfpaLink(FPAObj.id);
        FPALink.FPA_Total_Drafting_Hours__c =5;
        insert FPALink;
        
    }
    
    @isTest
    public static void FPATriggerHandlerTest()
    {
        Factory_Pricing_Authorization__c sfObject = [select id,Approval_Level__c from Factory_Pricing_Authorization__c where Approval_Level__c= 'A' limit 1 ];
        
        test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(sfObject);
        FPATriggerHandler fpaHandlerCls1 = new FPATriggerHandler(controller);
        fpaHandlerCls1.performApprovals();
        fpaHandlerCls1.updateFPA_Approval_Status();
        test.stopTest();
    }
    
}