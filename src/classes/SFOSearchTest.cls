@istest
public class SFOSearchTest 
{
    @isTest static void SFOSearchTestMethod() 
    {
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        // Create Feature record
        Product__c productObj= new Product__c();
        productObj.Name = '997';
        productObj.IsActive__c=true;
        productObj.Description__c ='Vision/Skyline';
        productObj.PCL__c='0002';
        insert productObj;
        system.debug('productObj:: '+productObj);
        
        //get record type of Section
        Id RecordTypeIdSFO = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 2-Section').getRecordTypeId();    
        
        //Create SFO(Section) record
        Special_Feature_Option__c SFO_Obj1 = TestUtility.createSFO(productObj.id);
        SFO_Obj1.Name__c = 'test';
        SFO_Obj1.Base_Unit_to_be_Modified__c =productObj.id;
        SFO_Obj1.RecordTypeId = RecordTypeIdSFO;
        insert SFO_Obj1;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        insert FPAPersonRepObj;
        
        //Creating FPA
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,productObj.Id);
        insert FPAObj;
        
        //Creating Unit Detail For FPA
        FPA_Link__c fpaLink = TestUtility.CreatesfpaLink(FPAObj.id);
        insert fpaLink;
        
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
       
        // Creating SFO of Special feature
        List<Special_Feature_Option__c> SFOObjList=new List<Special_Feature_Option__c>();
        Special_Feature_Option__c SFOObj;
        for(integer i=0;i<=20;i++)
        {
            SFOObj=TestUtility.createSFO(productObj.Id);
            SFOObj.Status__c='Draft';
            SFOObj.RecordTypeId = RecordTypeIdSFO2;
            SFOObj.Special_Feature_Parent__c = SFO_Obj2.id;
            SFOObj.Comments__c='test comment'+i;
            SFOObjList.add(SFOObj);
        }
        
        insert SFOObjList;
        
        //get record type of Option
        Id RecordTypeIdSFO3 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 5-Option').getRecordTypeId(); 
        
        //creating SFO With Option Record Type
         Special_Feature_Option__c SFOOption;
        List<Special_Feature_Option__c> OptionSfoList = new List<Special_Feature_Option__c>();
        for(Integer i=0;i<10;i++){
        SFOOption=TestUtility.createSFO(productObj.Id);
        SFOOption.Status__c='Draft';
        SFOOption.RecordTypeId = RecordTypeIdSFO3;
        SFOObj.Option_Parent__c = SFOObjList[0].id;
        SFOOption.Comments__c='test comment'+i;
            OptionSfoList.add(SFOOption);
        }  
        insert OptionSfoList;
        
        for(Special_Feature_Option__c s: OptionSfoList){
        s.Status__c='Approved';
        }
        update OptionSfoList;
        
        
        // Add Option to Unit Detail i.e Related SFO To Unit Detail
        
         fpaLink.SFO__c=OptionSfoList[0].id;
         update fpaLink;
        /*SFOObj=TestUtility.createSFO(productObj.Id);
        SFOObj.Parent_SFO__c = SFO_Obj1.id;
        SFOObj.Status__c='Approved';
        SFOObj.Comments__c='test comment';
        insert SFOObj;*/
        
        string sFO_sosl_query ='FIND \'test commen\' IN ALL FIELDS  RETURNING Special_Feature_Option__c(Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate,Revision_Version__c,Entry_Date__c,Comments__c,Unit_Tags__c,Status__c,Modifier_Location__c,Notes__c,Parent_SFO__c,Base_Unit_to_be_Modified__c,Group_Identifier__c,Individual_Identifier__c,Variable_Unit_Cost__c,Fixed_Unit_Cost__c,Purchased_material_cost__c,Raw_material_cost__c,Drafting_hours__c,Drafting_cost__c,Revision_date__c WHERE  Status__c = \'Approved\' limit 100)';
        List<List<SObject>> searchList = search.query(sFO_sosl_query);
        List<Special_Feature_Option__c> sfoList = (List<Special_Feature_Option__c>) searchList[0];
        System.debug('SFOList size::'+SFOList.size());
        
        pageReference pageRef=new pageReference('/apex/SFOSearchPage?id='+FPAObj.Id);
        Test.setCurrentPage(pageRef);
        
        List<Id> fixedSearchResults= new List<Id>();
        for(Special_Feature_Option__c SFOId : OptionSfoList)
        {
            fixedSearchResults.add(SFOId.Id);
        }
        //fixedSearchResults.add(SFOObjList[0].Id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        /*ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        SFOSearchController SFOApprovalControllerObj = new SFOSearchController(sc);
        SFOApprovalControllerObj.removeValues();
        SFOApprovalControllerObj.getFields('Special_Feature_Option__c');
        SFOApprovalControllerObj.showPopup();
        SFOApprovalControllerObj.createSFO();
        SFOApprovalControllerObj.backToFPA();
        SFOApprovalControllerObj.closePopup();
        SFOApprovalControllerObj.searchVal='Approved';
        SFOApprovalControllerObj.doSearch();
        SFOApprovalControllerObj.NextPage();
        SFOApprovalControllerObj.Previous();
        SFOApprovalControllerObj.Beginning();
        SFOApprovalControllerObj.End();
        SFOApprovalControllerObj.getDisablePrevious();
        SFOApprovalControllerObj.getDisableNext();
        SFOApprovalControllerObj.parentSFOId=SFOObjList[0].Id;
        SFOApprovalControllerObj.refreshPopUp();
        SFOApprovalControllerObj.selectedSFo=SFOObj.Id;
        SFOApprovalControllerObj.selectWrapper();
        SFOApprovalControllerObj.getExistingFPALinks();
        SFOApprovalControllerObj.navigateToFPALinks();
        SFOApprovalControllerObj.backTosearchResults();
        SFOApprovalControllerObj.saveFPALinks();
        
        SFOApprovalControllerObj = new SFOSearchController(sc);
        SFOApprovalControllerObj.getExistingFPALinks();*/
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(FPAObj);
        SFOSearchController SFOApprovalControllerObj = new SFOSearchController(sc);
        SFOApprovalControllerObj = new SFOSearchController(sc);
        SFOSearchController.SFOWrapper sfoWrap = new SFOSearchController.SFOWrapper(OptionSfoList[0]);
        SFOSearchController.UnitTagWrapper sfoUnitTagWrap = new SFOSearchController.UnitTagWrapper(OptionSfoList[0],fpaLink);
        SFOApprovalControllerObj.getUnitDetails();
        SFOApprovalControllerObj.searchVal='Approved';
        SFOApprovalControllerObj.isSearched = true;
        SFOApprovalControllerObj.getFields('Special_Feature_Option__c');
        SFOApprovalControllerObj.doSearch();
        SFOApprovalControllerObj.associateSFO();
        SFOApprovalControllerObj.closePopup();
        SFOApprovalControllerObj.showPopup();
        SFOApprovalControllerObj.createSFO();
        SFOApprovalControllerObj.backToFPA();
        SFOApprovalControllerObj.Beginning();
        //SFOApprovalControllerObj.counter=12;
        SFOApprovalControllerObj.Next();
        SFOApprovalControllerObj.getDisableNext();
        SFOApprovalControllerObj.Previous();
        SFOApprovalControllerObj.getDisablePrevious();
                // SFOApprovalControllerObj.End();
        //SFOApprovalControllerObj.deleteRow();
        Test.stopTest();
        
    }
}