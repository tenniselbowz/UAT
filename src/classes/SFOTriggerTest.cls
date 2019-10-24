@istest
public class SFOTriggerTest 
{
    @isTest static void SFOTriggerTestMethod() 
    {
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        // Create Product__c record
        Product__c productObj= new Product__c();
        productObj.Name = '997';
        productObj.IsActive__c=true;
        productObj.Description__c ='Vision/Skyline';
        productObj.PCL__c='0002';
        insert productObj;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        insert FPAPersonRepObj;
        
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,productObj.Id);
        insert FPAObj;
        
        //get record type of Special_Feature_Option__c
        Id RecordTypeIdSFO = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 2-Section').getRecordTypeId();    
        //Create SFO record
        Special_Feature_Option__c SFO_Obj1 = TestUtility.createSFO(productObj.id);
        SFO_Obj1.Name__c = 'test';
        SFO_Obj1.RecordTypeId = RecordTypeIdSFO;
        SFO_Obj1.Base_Unit_to_be_Modified__c =productObj.id;
        insert SFO_Obj1;
        
        Attachment attach=new Attachment();   	
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=SFO_Obj1.Id;
        insert attach;
        
        Estimate__c estRec=new Estimate__c();
        estRec.SFO__c=SFO_Obj1.Id;
        estRec.Name='AGENCY';
        estRec.Type__c='Hours';
        estRec.Hour__c=50;
        insert estRec;
        
        FPA_Link__c FPALinkObj =new FPA_Link__c();
        FPALinkObj.SFO__c=SFO_Obj1.Id;
        FPALinkObj.FPA__c=FPAObj.Id;
        FPALinkObj.Unit_Tag__c='test 1';
        insert FPALinkObj;
        
        SFO_Obj1.Unit_Tags__c='test 1';
        SFO_Obj1.Fixed_Unit_Cost__c=12;
        update SFO_Obj1;
        
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
        List<Special_Feature_Option__c> Sfolist = new List<Special_Feature_Option__c>();
        Sfolist.add(SFO_Obj4);
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
        
        //Create FPA link
        FPA_Link__c FPALink = TestUtility.CreatesfpaLink(FPAObj.id);
        FPALink.FPA_Total_Drafting_Hours__c =5;
        FPALink.SFO__c = SFO_Obj4.id;
        insert FPALink;
       
        test.startTest();
        Special_Feature_Option__c SFOObj3=[select id,Name__c from Special_Feature_Option__c where id=:SFO_Obj3.id];
        List<SFO_Dynamic_Fields__c> dList =[SELECT Id,SFO__c FROM SFO_Dynamic_Fields__c where SFO__c =:SFOObj3.id];
        Special_Feature_Option__c SFOObj4=[select id,Name__c,Option_Parent__c from Special_Feature_Option__c where id=:SFO_Obj4.id];
        System.assertEquals(SFOObj4.Name__c,'Option');
        SFO_Trigger_Handler SFOTriggerHandlerCls = new SFO_Trigger_Handler();
        SFO_Trigger_Handler.updateUnitTags(Sfolist);
        test.stopTest();
        
    }
    
     @isTest static void SFOTriggerTestMethod2() 
    {
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        // Create Product__c record
        Product__c productObj= new Product__c();
        productObj.Name = '997';
        productObj.IsActive__c=true;
        productObj.Description__c ='Vision/Skyline';
        productObj.PCL__c='0002';
        insert productObj;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        insert FPAPersonRepObj;
        
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,productObj.Id);
        insert FPAObj;
        
        //get record type of Special_Feature_Option__c
        Id RecordTypeIdSFO = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 2-Section').getRecordTypeId();    
        //Create SFO record
        Special_Feature_Option__c SFO_Obj1 = TestUtility.createSFO(productObj.id);
        SFO_Obj1.Name__c = 'test';
        SFO_Obj1.RecordTypeId = RecordTypeIdSFO;
        SFO_Obj1.Base_Unit_to_be_Modified__c =productObj.id;
        insert SFO_Obj1;
        
        Attachment attach=new Attachment();   	
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=SFO_Obj1.Id;
        insert attach;
        
        Estimate__c estRec=new Estimate__c();
        estRec.SFO__c=SFO_Obj1.Id;
        estRec.Name='AGENCY';
        estRec.Type__c='Hours';
        estRec.Hour__c=50;
        insert estRec;
        
        FPA_Link__c FPALinkObj =new FPA_Link__c();
        FPALinkObj.SFO__c=SFO_Obj1.Id;
        FPALinkObj.FPA__c=FPAObj.Id;
        FPALinkObj.Unit_Tag__c='test 1';
        insert FPALinkObj;
        
        SFO_Obj1.Unit_Tags__c='test 1';
        SFO_Obj1.Fixed_Unit_Cost__c=12;
        update SFO_Obj1;
        
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
        List<Special_Feature_Option__c> Sfolist = new List<Special_Feature_Option__c>();
        Sfolist.add(SFO_Obj4);
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
        
        SFO_Dynamic_Fields__c SFODynamicFields = TestUtility.createSFODynamicFields(sfo_Fields.id, SFO_Obj1.id);
        SFODynamicFieldsList.add(SFODynamicFields);
        
        SFO_Dynamic_Fields__c SFODynamicFields2 = TestUtility.createSFODynamicFields(sfo_Fields2.id, SFO_Obj1.id);
        SFODynamicFields2.Field_Value__c ='20000';
        SFODynamicFieldsList.add(SFODynamicFields2);
        
        insert SFODynamicFieldsList;
        
        //Create FPA link
        FPA_Link__c FPALink = TestUtility.CreatesfpaLink(FPAObj.id);
        FPALink.FPA_Total_Drafting_Hours__c =5;
        FPALink.SFO__c = SFO_Obj4.id;
        insert FPALink;
        
        test.startTest();
        Special_Feature_Option__c SFOObj1=[select id,Name__c from Special_Feature_Option__c where id=:SFO_Obj1.id];
        Special_Feature_Option__c SFOObj2=[select id,Name__c from Special_Feature_Option__c where id=:SFO_Obj2.id];
        Special_Feature_Option__c SFOObj3=[select id,Name__c from Special_Feature_Option__c where id=:SFO_Obj3.id];
        Special_Feature_Option__c SFOObj4=[select id,Name__c from Special_Feature_Option__c where id=:SFO_Obj4.id];
        System.assertEquals(SFOObj4.Name__c,'Option');
        SFO_Trigger_Handler SFOTriggerHandlerCls = new SFO_Trigger_Handler();
        SFO_Trigger_Handler.updateUnitTags(Sfolist);
        SFO_Trigger_Handler.Insert_ChildRec_for_SFOs(Sfolist);
      //  SFO_Trigger_Handler.updateFPA_totals(Sfolist);
        test.stopTest();
        
    }
   
}