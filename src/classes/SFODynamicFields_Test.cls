@isTest
public class SFODynamicFields_Test {
    @TestSetup
    public static void setup()
    { 
        
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        // Product__c productObj=[Select id from Product__c limit 1];
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
        
        //get record type of Component
        Id RecordTypeIdSFO1 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 3-Component').getRecordTypeId();    
        
        //Create SFO(Section) record
        Special_Feature_Option__c SFO_Obj2 = TestUtility.createSFO(productObj.id);
        SFO_Obj2.Name__c = 'test';
        SFO_Obj2.RecordTypeId = RecordTypeIdSFO1;
        SFO_Obj2.Parent_SFO__c = SFO_Obj1.id;
        insert SFO_Obj2;
        
        //get record type of Special Feature
        Id RecordTypeIdSFO2 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 4-Special Feature').getRecordTypeId();    
        
        //Create SFO(Special feature) record
        Special_Feature_Option__c SFO_Obj3 = TestUtility.createSFO(productObj.id);
        SFO_Obj3.Name__c ='Sample Special feature';
        SFO_Obj3.RecordTypeId = RecordTypeIdSFO2;
        SFO_Obj3.Special_Feature_Parent__c = SFO_Obj2.id;
        insert SFO_Obj3;
        
        System.assertEquals(SFO_Obj3.Base_Unit_to_be_Modified__c, productObj.id);
        
        Estimate__c est = new Estimate__c();
        est.Name = 'Test Estimate';
        est.Est_Hours__c = 5.00;
        est.Hour__c = 12;
        est.Total_Cost__c = 300;
        est.Unit_Cost__c = 40;
        est.Actual_Cost__c = 300;
        est.SFO__c = SFO_Obj3.id;
        insert est;
        
        System.assertEquals(est.SFO__c, SFO_Obj3.id);
        
        list<SFO_Fields__c> SFOFieldsList = new list<SFO_Fields__c>();
        
        SFO_Fields__c sfo_Fields =  TestUtility.createSFOFields('Manufacturing Communication','Number');
        //sfo_Fields.Picklist_Entries__c = 'four five six one two three'; 
        sfo_Fields.IsActive__c =true;  
        sfo_Fields.Field_Data_Type__c ='Number';
        sfo_Fields.Field_Length__c = 10000;
        SFOFieldsList.add(sfo_Fields);
        
        SFO_Fields__c sfo_Fields2 =  TestUtility.createSFOFields('Drafting Cost','Text');
        //sfo_Fields.Picklist_Entries__c = 'four five six one two three'; 
        sfo_Fields2.IsActive__c =true;  
        sfo_Fields2.Field_Length__c = 5000;
        SFOFieldsList.add(sfo_Fields2);
        
        SFO_Fields__c sfo_Fields3 =  TestUtility.createSFOFields('Drafting Cost','Formula');
        sfo_Fields3.IsActive__c =true; 
        sfo_Fields3.Formula_Editor__c = 'MFG*Manufacturing Hours';
        sfo_Fields3.Field_Length__c = 5000;
        SFOFieldsList.add(sfo_Fields3);
        
        insert SFOFieldsList;
        
        list<SFO_Dynamic_Fields__c> SFODynamicFieldsList = new list<SFO_Dynamic_Fields__c>();
        
        SFO_Dynamic_Fields__c SFODynamicFields = TestUtility.createSFODynamicFields(sfo_Fields.id, SFO_Obj3.id);
        SFODynamicFieldsList.add(SFODynamicFields);
        
        SFO_Dynamic_Fields__c SFODynamicFields2 = TestUtility.createSFODynamicFields(sfo_Fields2.id, SFO_Obj3.id);
        SFODynamicFields2.Field_Value__c ='20000';
        SFODynamicFieldsList.add(SFODynamicFields2);
        
        insert SFODynamicFieldsList;
    }
    @isTest
    public static void sfo_FieldsMethodTest()
    {
        Special_Feature_Option__c sfObject = [select id,Name__c from Special_Feature_Option__c where Name__c ='Sample Special feature' limit 1 ];
        List<SFO_Fields__c> sf = [select id,Picklist_Entries__c,Field_Data_Type__c,Name from SFO_Fields__c];
        test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(sfObject);
        SFODynamicFields dynamicsfo = new SFODynamicFields(controller);
        dynamicsfo.getDynamicFields();
        dynamicsfo.saveSFODynamicFields();
        //List<SelectOption> selOpts=dynamicsfo.getdynamiclistEntries();
        test.stopTest();
        //SFODynamicFields.dynamicWrapper dynamincWrap = new SFODynamicFields.dynamicWrapper(sf);
        // dynamincWrap.dynamicWrapper(sf);
        //dynamincWrap.getdynamiclistEntries();
    }
    
        @isTest
    public static void sfo_FieldsMethodTest2()
    {
        Special_Feature_Option__c sfObject = [select id,Name__c from Special_Feature_Option__c where Name__c ='Sample Special feature' limit 1 ];
        List<SFO_Fields__c> sf = [select id,Picklist_Entries__c,Field_Data_Type__c,Formula_Editor__c,Name from SFO_Fields__c];

    //Created SFO Formula Field
        SFO_Fields__c sfoFields = new SFO_Fields__c();
        sfoFields.Name='Test Field';
        sfoFields.Field_Data_Type__c='Formula';
        sfoFields.Formula_Editor__c='c=1+2';
        sfoFields.IsActive__c=true;
        insert sfoFields;
        
        // Creating Dynamic Field
         SFO_Dynamic_Fields__c SFODynamicFields = TestUtility.createSFODynamicFields(sfoFields.id, sfObject.id);
        SFODynamicFields.Name='Test Dynamic Field';
        SFODynamicFields.Field_Value__c='10';
        SFODynamicFields.SFO__c=sfObject.id;
        SFODynamicFields.SFO_Field__c=sfoFields.id;
        insert SFODynamicFields;
        
        test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(sfObject);
        SFODynamicFields dynamicsfo = new SFODynamicFields(controller);
        dynamicsfo.getDynamicFields();
        dynamicsfo.saveSFODynamicFields();
        //List<SelectOption> selOpts=dynamicsfo.getdynamiclistEntries();
        test.stopTest();
        //SFODynamicFields.dynamicWrapper dynamincWrap = new SFODynamicFields.dynamicWrapper(sf);
        // dynamincWrap.dynamicWrapper(sf);
        //dynamincWrap.getdynamiclistEntries();
    }
    
}