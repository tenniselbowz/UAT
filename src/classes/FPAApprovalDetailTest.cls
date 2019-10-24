@isTest
public class FPAApprovalDetailTest{
   
    //Test Method for Approval Details and Approval Criteria Class
    
    
    public static testmethod void  FPAApprovalDetailMethod(){
        List<SFO_Dynamic_Fields__c> DynamicFields = new List<SFO_Dynamic_Fields__c>();
        List<Approval_Criteria__c>  ApprovalCriteria = new List<Approval_Criteria__c>();
        List<FPA_Link__c> UnitDetailObject = new List<FPA_Link__c>();
        Map<String, Factory_Pricing_Authorization__c> FPAMap = new Map<String, Factory_Pricing_Authorization__c>();
        Id recordTypeId =
            Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName()
            .get('Read_Only').getRecordTypeId();
        Special_Feature_Option__c TestSFO = new Special_Feature_Option__c();
        TestSFO.Status__c='Approved';
        TestSFO.RecordTypeId=recordTypeId;
        insert TestSFO;
        
        SFO_Fields__c SFOField = new SFO_Fields__c();
        SFOField.Name='Material Cost';
        SFOField.Field_Data_Type__c='Number';
        insert SFOField;
        
        //Creating the Dynamic Fields for the SFO
        
        SFO_Dynamic_Fields__c DynamicField1 = new SFO_Dynamic_Fields__c();
        DynamicField1.Field_Value__c='100';
        DynamicField1.SFO__c=TestSFO.Id;
        DynamicField1.Name='Material Cost';
        DynamicField1.SFO_Field__c=SFOField.Id;
        DynamicFields.add(DynamicField1);
        
        SFO_Dynamic_Fields__c DynamicField2 = new SFO_Dynamic_Fields__c();
        DynamicField2.Field_Value__c='101';
        DynamicField2.SFO__c=TestSFO.Id;
        DynamicField2.SFO_Field__c=SFOField.Id;
        DynamicField2.Name='Drafting Hours';
        DynamicFields.add(DynamicField2);
        
        SFO_Dynamic_Fields__c DynamicField3 = new SFO_Dynamic_Fields__c();
        DynamicField3.Field_Value__c='104';
        DynamicField3.SFO__c=TestSFO.Id;
        DynamicField3.SFO_Field__c=SFOField.Id;
        DynamicField3.Name='Manufacturing Hours';
        DynamicFields.add(DynamicField3);
        
        SFO_Dynamic_Fields__c DynamicField4 = new SFO_Dynamic_Fields__c();
        DynamicField4.Field_Value__c='106';
        DynamicField4.SFO__c=TestSFO.Id;
        DynamicField4.SFO_Field__c=SFOField.Id;
        DynamicField4.Name='Engineering Hours';
        DynamicFields.add(DynamicField4);
        
        insert DynamicFields;
        
        Product__c ProductObj=TestUtility.createProductFormat();
        ProductObj.IsActive__c=true;
        insert productObj;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        insert FPAPersonRepObj;
       
        //Insert FPA(Factory_Pricing_Authorization)
        
        UtilityClass.getSObjectRelatedFields('FPA_Approval__c','FPA_Person__r.Name','',true);
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,ProductObj.Id);
        insert FPAobj;
        FPAMap.put(FPAObj.Id,FPAObj);
  
        //Insert Approval Criteria Related to the product
        
        Approval_Criteria__c AppcriteriaA = TestUtility.ApprovalCriteria('A',ProductObj.Id,'1000','1000','1000','1000','1000','1000','1000','1000','1000');
        ApprovalCriteria.add(AppcriteriaA);
        Approval_Criteria__c AppcriteriaB = TestUtility.ApprovalCriteria('B',ProductObj.Id,'100','100','100','700','100','100','100','100','700');
        ApprovalCriteria.add(AppcriteriaB);
        Approval_Criteria__c AppcriteriaC = TestUtility.ApprovalCriteria('C',ProductObj.Id,'10','10','10','500','10','10','10','10','500');
        ApprovalCriteria.add(AppcriteriaC);
        Approval_Criteria__c AppcriteriaD = TestUtility.ApprovalCriteria('D',ProductObj.Id,Null,Null,Null,Null,Null,Null,Null,Null,Null);
        ApprovalCriteria.add(AppcriteriaD);
        insert ApprovalCriteria;
        
        //Unit Details Creation
        
        FPA_Link__c UnitDetailObj =TestUtility.CreatesfpaLink(FPAObj.Id);
        insert UnitDetailObj;
        
        
        List<Related_SFO__c> SFOList = new List<Related_SFO__c>();
        for(Integer i=0; i<50; i++){
            Related_SFO__c RelatedSFO = new Related_SFO__c();
            RelatedSFO.SFO__c=TestSFO.Id;
            RelatedSFO.Unit_Detail__c=UnitDetailObj.Id;
            SFOList.add(RelatedSFO);
        }
        insert SFOList;
        System.assertEquals(50, SFOList.size());
        FPAApprovalDetails.getFPADynamicFields(SFOList);
        FPAApprovalDetails.updateUnitTagOnDelete(SFOList);
        
        //updating the unitdetails with the Approver Criteria of the FPA
        
        UnitDetailObj.Max_QTY_of_Units_On_Single_Line_Item__c=800;
        UnitDetailObj.FPA_Total_Engineering_Hours__c=150;
        UnitDetailObj.FPA_Total_Manufacturing_Hours__c=150;
        UnitDetailObj.Max_Total_Material_Cost_for_Single_Line__c=150;
        UnitDetailObj.QTY_of_line_Item_with_Specials__c=800;
        UnitDetailObj.FPA_Total_Drafting_Hours__c=150;
        
        update UnitDetailObj;
     
        FPAobj.FPA_Number__c='998123456BC';  
        FPAobj.Approval_Level__c='A';
        update FPAobj;
        
        System.assertEquals(FPAobj.Approval_Level__c,'A');
    } 
}