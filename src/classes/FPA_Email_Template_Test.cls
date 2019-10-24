@isTest
public class FPA_Email_Template_Test {
    
    
    @testSetup static void setup() {
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        Product__c ProductObj=TestUtility.createProductFormat();
        ProductObj.IsActive__c=false;
        insert productObj;
        
        ProductObj.IsActive__c=true;
        update productObj;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        insert FPAPersonRepObj;
        
    }
    @isTest
    public static void fpa_EmailApproverMethod()
    {
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA([Select Id from FPA_Persona__c limit 1].Id,[Select Id from Product__c limit 1].Id);
        insert FPAObj;
        
        FPA_Email_Template_Controller fpa_EmailTempCon = new FPA_Email_Template_Controller();
        fpa_EmailTempCon.getFPA_Id();
        fpa_EmailTempCon.setFPA_Id(FPAObj.id);
        fpa_EmailTempCon.FPA_Email_Template_Controller();
    }
}