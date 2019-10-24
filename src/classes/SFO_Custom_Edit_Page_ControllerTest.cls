@istest
public class SFO_Custom_Edit_Page_ControllerTest 
{
    @testsetUp
    static void setupData()
    {
        // Insert SFO Fields
        List<SFO_Fields__c> sfoFieldsList = new List<SFO_Fields__c>();
        SFO_Fields__c unitCost_field = TestUtility.createSFOFields('Test','Number');
        unitCost_field.Name ='unit cost';
        sfoFieldsList.add(unitCost_field);
        
        SFO_Fields__c quantity_field = TestUtility.createSFOFields('Test2','Number');
        quantity_field.Name ='quantity';
        sfoFieldsList.add(quantity_field);
        
        SFO_Fields__c formula_field = TestUtility.createSFOFields('Test3','Formula');
        formula_field.Name ='Total Cost';
        formula_field.Formula_Editor__c = '(unit cost*quantity)';
        sfoFieldsList.add(formula_field);
        
        SFO_Fields__c picklist_field = TestUtility.createSFOFields('Test4','Picklist');
        picklist_field.Picklist_Entries__c ='Completed';
        sfoFieldsList.add(picklist_field);
        
        
        insert sfoFieldsList;                                        // Insert SFO Fields
        
        Product2 product = TestUtility.createProduct();
        insert product;
        
        // Create Product__c record
        Product__c productObj= new Product__c();
        productObj.Name = '997';
        productObj.IsActive__c=true;
        productObj.Description__c ='Vision/Skyline';
        productObj.PCL__c='0002';
        insert productObj;
        
        //get record type of Special_Feature_Option__c
        Id RecordTypeIdSFO = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 2-Section').getRecordTypeId();    
        //Create SFO record
        Special_Feature_Option__c SFO_Obj1 = TestUtility.createSFO(productObj.id);
        SFO_Obj1.Name__c = 'test';
        SFO_Obj1.RecordTypeId = RecordTypeIdSFO;
        SFO_Obj1.Base_Unit_to_be_Modified__c =productObj.id;
        insert SFO_Obj1;
        
        //Create SFO Dynamic fields
        list<SFO_Dynamic_Fields__c> SFODynamicFieldsList = new list<SFO_Dynamic_Fields__c>();
        
        SFO_Dynamic_Fields__c SFODynamicFields = TestUtility.createSFODynamicFields(quantity_field.id, SFO_Obj1.id);
        SFODynamicFieldsList.add(SFODynamicFields);
        
        SFO_Dynamic_Fields__c SFODynamicFields2 = TestUtility.createSFODynamicFields(picklist_field.id, SFO_Obj1.id);
        SFODynamicFields2.Field_Value__c ='20000';
        SFODynamicFieldsList.add(SFODynamicFields2);
        
        insert SFODynamicFieldsList;
    }
    
    @isTest
    static void testSFOCreation()
    {
        
        Product__c productObj=[Select id from Product__c limit 1];
        Special_Feature_Option__c SFOObj=[select id from Special_Feature_Option__c limit 1];
        
        pageReference pageRef=new pageReference('/apex/SFO_Custom_Edit_Page_Test');
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('id', SFOObj.id);

        
        ApexPages.StandardController sc = new ApexPages.StandardController(SFOObj);
        SFO_Custom_Edit_Page_Controller SFOEditController = new SFO_Custom_Edit_Page_Controller(sc);
        SFOEditController.cancel();
        
        SFOEditController.sfo_Obj.Base_Unit_to_be_Modified__c=productObj.Id;
        //SFOEditController.getdynamiclistEntries();
        SFOEditController.saveSFO();
        
        
        sc = new ApexPages.StandardController(SFOObj);
        SFOEditController = new SFO_Custom_Edit_Page_Controller(sc);
        
        pageRef=new pageReference('/apex/SFO_Custom_Edit_Page_Test?clone=1');
        Test.setCurrentPage(pageRef);
        
        sc = new ApexPages.StandardController(SFOObj);
        SFOEditController = new SFO_Custom_Edit_Page_Controller(sc);
        SFOEditController.saveSFO();
        
        pageRef=new pageReference('/apex/SFO_Custom_Edit_Page_Test?version=1');
        Test.setCurrentPage(pageRef);
        
        sc = new ApexPages.StandardController(SFOObj);
        SFOEditController = new SFO_Custom_Edit_Page_Controller(sc);
        
    }
       
    //For Testing the Formula Field Expression class
    @isTest
    static void testMethodForEvaluateExpression()
    {
         Special_Feature_Option__c SFOObj=[select id from Special_Feature_Option__c limit 1];
        Map<String, String> keyValueMap = new Map<String, String>();
        List<Estimate__c> estimateList = new List<Estimate__c>();
        Product__c productObj=[Select id from Product__c limit 1];
        
        //Created SFO Formula Field
        SFO_Fields__c sfoFields = new SFO_Fields__c();
        sfoFields.Name='Test Field';
        sfoFields.Field_Data_Type__c='Formula';
        sfoFields.Formula_Editor__c='c=a+b-a*b+a/d';
        sfoFields.IsActive__c=true;
        insert sfoFields;
        
        // Creating Dynamic Field
         SFO_Dynamic_Fields__c SFODynamicFields = TestUtility.createSFODynamicFields(sfoFields.id, SFOObj.id);
        SFODynamicFields.Name='Test Dynamic Field';
        SFODynamicFields.Field_Value__c='10';
        SFODynamicFields.SFO__c=SFOObj.id;
        SFODynamicFields.SFO_Field__c=sfoFields.id;
        insert SFODynamicFields;
        
        String formula = SFODynamicFields.SFO_Field__r.Formula_Editor__c;
        
        String format = productObj.id;
         estimateList = Database.query(UtilityClass.getSObjectFields('Estimate__c', 'Product__c =:format', true));
        for(Estimate__c e :estimateList){
            String key = e.Estimate_Lable__c.toLowerCase();
            keyValueMap.put(key, String.valueOf(e.Hour__c));    
            
        }
        
        pageReference pageRef=new pageReference('/apex/SFO_Custom_Edit_Page_Test');
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('id', SFOObj.id);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(SFOObj);
        SFO_Custom_Edit_Page_Controller SFOEditController = new SFO_Custom_Edit_Page_Controller(sc);
        SFOEditController.saveSFO();
        //List<SelectOption> options = SFOEditController.getdynamiclistEntries();
        Evaluate_Expression  evalExp = new Evaluate_Expression();
        Evaluate_Expression.evaluate('5.20');
       Evaluate_Expression.applyOp(3, 4, '+');
        Evaluate_Expression.applyOp(3, 4, '-');
        Evaluate_Expression.applyOp(3, 4, '*');
        Evaluate_Expression.applyOp(3, 4, '/');
        Evaluate_Expression.applyOp(3, 0, '/');
        Evaluate_Expression.applyOp(3, 4, '%');
        
    }
    
        //For Testing the Formula Field Expression class
    @isTest
    static void testMethodForTriggerHandler()
    {
        List<Special_Feature_Option__c> Sfolist = new List<Special_Feature_Option__c>();
         Special_Feature_Option__c SFOObj=[select id from Special_Feature_Option__c limit 1];
        Map<String, String> keyValueMap = new Map<String, String>();
        List<Estimate__c> estimateList = new List<Estimate__c>();
        Product__c productObj=[Select id from Product__c limit 1];
        
        //Created SFO Formula Field
        SFO_Fields__c sfoFields = new SFO_Fields__c();
        sfoFields.Name='Test Field';
        sfoFields.Field_Data_Type__c='Formula';
        sfoFields.Formula_Editor__c='c=a+b-a*b+a/d';
        sfoFields.IsActive__c=true;
        insert sfoFields;
        
        // Creating Dynamic Field
         SFO_Dynamic_Fields__c SFODynamicFields = TestUtility.createSFODynamicFields(sfoFields.id, SFOObj.id);
        SFODynamicFields.Name='Test Dynamic Field';
        SFODynamicFields.Field_Value__c='10';
        SFODynamicFields.SFO__c=SFOObj.id;
        SFODynamicFields.SFO_Field__c=sfoFields.id;
        insert SFODynamicFields;
        
        String formula = SFODynamicFields.SFO_Field__r.Formula_Editor__c;
        
        String format = productObj.id;
         estimateList = Database.query(UtilityClass.getSObjectFields('Estimate__c', 'Product__c =:format', true));
        for(Estimate__c e :estimateList){
            String key = e.Estimate_Lable__c.toLowerCase();
            keyValueMap.put(key, String.valueOf(e.Hour__c));    
            
        }
        Sfolist.add(SFOObj);
        SFO_Trigger_Handler SFOTriggerHandlerCls = new SFO_Trigger_Handler();
        SFO_Trigger_Handler.updateUnitTags(Sfolist);
        SFO_Trigger_Handler.Insert_ChildRec_for_SFOs(Sfolist);
        SFO_Trigger_Handler.createDynamicFields(Sfolist);
    }
    /*@isTest static void testLeadStatusOptions()
    {
        Special_Feature_Option__c SFOObj=[select id from Special_Feature_Option__c limit 1];
        pageReference pageRef=new pageReference('/apex/SFO_Custom_Edit_Page_Test');
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('id', SFOObj.id);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(SFOObj);
        SFO_Custom_Edit_Page_Controller SFOEditController = new SFO_Custom_Edit_Page_Controller(sc);

        Test.startTest();
            List<SelectOption> options = SFO_Custom_Edit_Page_Controller.getdynamiclistEntries();
        Test.stopTest();

        system.assertEquals(options.get(0).getValue(), 'test');

    }*/
}