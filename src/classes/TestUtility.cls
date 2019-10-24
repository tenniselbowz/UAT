public class TestUtility 
{  
    public static Product2 createProduct()
    {
        Product2 product = new Product2();
        product.Name = 'Test Product';
        return product;
    }
    public static Office__c createOffice()
    {
        Office__c office = new Office__c();
        office.Name =  'Daikin Office';
        return office;
    }
    public static FPA_Persona__c createFPAPersona(String role, String department)
    {
        FPA_Persona__c person = new FPA_Persona__c();
        person.Name ='FPA User';
        person.Office__c = createOffice().Id;
        person.Role__c = role;
        person.Department__c = department;
        person.Email__c = 'Daikin@test.com';
        return person;
    }
    public static Factory_Pricing_Authorization__c createFPA(String salesPersonId, String productId)
    {
        Factory_Pricing_Authorization__c fpa = new Factory_Pricing_Authorization__c();
        fpa.Name = 'Test FPA';
        fpa.Job_ID__c = '1234';
        fpa.Discreet_Identifier__c ='FPA-1234';
        fpa.Sales_Person__c = salesPersonId;
        fpa.Entry_Date__c = System.today();
        fpa.Project__c = 'Daikin';
        fpa.Office__c = createOffice().Id;
        fpa.Risk__c = '';
        fpa.Eng_Mfg_Effort__c = '';
       // fpa.CapX__c = '';
        //fpa.Previous_FPA__c = '';
        fpa.Description__c = 'Test Description';
        fpa.Base_Unit_to_be_Modified__c = productId;
        //fpa.Base_Unit_to_be_Modified__c=TestUtility.createProductFormat().p.Id;
        fpa.Quantity__c = 10;
        fpa.Submitted__c = date.newInstance(2019, 01, 01);
        return fpa;
    }
    public static Special_Feature_Option__c createSFO(String ProductId)
    {
        Special_Feature_Option__c SFO_Obj = new Special_Feature_Option__c();
        SFO_Obj.Base_Unit_to_be_Modified__c = ProductId;
        SFO_Obj.Name__c = 'test Name';
        SFO_Obj.Notes__c = '5K Flat HX TEMPLATE';
        SFO_Obj.Entry_Date__c = system.today();
        SFO_Obj.Modifier_Location__c = 'Top, End';
        SFO_Obj.Unit_Tags__c = 'test units';
        return SFO_Obj;
    }
    public static SFO_Fields__c createSFOFields(String fieldLabel, String dataType)
    {
        SFO_Fields__c field = new SFO_Fields__c();
        field.Name   = fieldLabel;
        field.Field_Data_Type__c = dataType;
        return field;
    }
    public static SFO_Dynamic_Fields__c createSFODynamicFields(String SFOFieldId, String sfoId)
    {
        SFO_Dynamic_Fields__c field = new SFO_Dynamic_Fields__c();
        field.SFO_Field__c=SFOFieldId;
        field.SFO__c = sfoId;
        
        return field;
    }
    
    public static FPA_Link__c CreatesfpaLink(String fpaId)
    {
        FPA_Link__c fpaLink = new FPA_Link__c();
        fpaLink.Quantity__c = 12;
        fpaLink.Unit_Tag__c = 'MAY 1';
        fpaLink.Lead_Time__c = 16;
        fpaLink.FPA__c = fpaId;
        
        return fpaLink ;
    }
    
     public static Product__c createProductFormat(){
        Product__c p = new Product__c();
        p.Name='TestProduct';
        p.PCL__c='0001';
        p.Description__c='NewBrand';
        p.IsActive__c=true;
        return p;
}
    
    public static Approval_Criteria__c ApprovalCriteria(String ApprovelLevel,id Productid,String dh,String Eh,String Mh,
                                                        String Mqali,String MTDH,
                                                        String MTEH,String MTMH,String MTMC,String QLIS){
        Approval_Criteria__c Appcriteria = new Approval_Criteria__c();
        Appcriteria.Approval_Level__c=ApprovelLevel;
        Appcriteria.Format__c=Productid;
        Appcriteria.FPA_Total_Drafting_Hours__c=dh;
        Appcriteria.FPA_Total_Engineering_Hours__c=Eh;
        Appcriteria.FPA_Total_Manufacturing_Hours__c=Mh;
        Appcriteria.Max_QTY_of_Units_On_Single_Line_Item__c=Mqali;
        Appcriteria.Max_Total_Drafting_Hours_per_Single_l__c=MTDH;
        Appcriteria.Max_Total_Engineering_Hours_for_Single__c=MTEH;
        Appcriteria.Max_Total_Manufacturing_Hours_for_Single__c=MTMH;
        Appcriteria.Max_Total_Material_Cost_for_Single_Line__c=MTMC;
        Appcriteria.QTY_of_line_Item_with_Specials__c=QLIS;
        return Appcriteria;
    }
    public static FPA_Link__c CreatesfpaLink(id FPAObj,Integer MaxQuantitySingleLineItem,Integer FpaTotalEngHours,Integer FpaTotalMagHours,
                                                                  Integer MaxMaterialCost,Integer QLineItemSpecial,Integer FpaTotalDrfHours){
        FPA_Link__c UnitDetailObj =TestUtility.CreatesfpaLink(FPAObj);
        
        UnitDetailObj.Max_QTY_of_Units_On_Single_Line_Item__c=MaxQuantitySingleLineItem;
        UnitDetailObj.FPA_Total_Engineering_Hours__c=FpaTotalEngHours;
        UnitDetailObj.FPA_Total_Manufacturing_Hours__c=FpaTotalMagHours;
        UnitDetailObj.Max_Total_Material_Cost_for_Single_Line__c=MaxMaterialCost;
        UnitDetailObj.QTY_of_line_Item_with_Specials__c=QLineItemSpecial;
        UnitDetailObj.FPA_Total_Drafting_Hours__c=FpaTotalDrfHours;
        return  UnitDetailObj;                                                             
    } 
public static FPA_Approval__c CreateFpaApprover(String fpaId,String Status)
{
    FPA_Approval__c FpaApprover = new FPA_Approval__c();
    FpaApprover.FPA__c=fpaId;
    FpaApprover.Status__c=Status;
    return FpaApprover;
}
    public static FPA_Approval__c CreateFormatApprover(String formatId,String Status,boolean a, boolean b, boolean c, boolean d)
{
    FPA_Approval__c FormatApprover = new FPA_Approval__c();
    FormatApprover.Format__c=formatId;
    FormatApprover.A__c=a;
    FormatApprover.B__c=b;
    FormatApprover.C__c=c;
    FormatApprover.D__c=d;
    return FormatApprover;
}
}