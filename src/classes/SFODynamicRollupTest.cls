@isTest
public class SFODynamicRollupTest {
    
    @isTest static void samplemethod() {
        list<Special_Feature_Option__c> slist = new  list<Special_Feature_Option__c>();
        
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
        Special_Feature_Option__c SFO_Obj3 = new Special_Feature_Option__c();
        SFO_Obj3.RecordTypeId = RecordTypeIdSFO2;
        SFO_Obj3.Special_Feature_Parent__c = SFO_Obj2.id;
        insert SFO_Obj3;
        slist.add(SFO_Obj3);
        
        //get record type of Option
        Id RecordTypeIdSFO3 = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByName().get('Level 4-Special Feature').getRecordTypeId();    
        
        //Create SFO(Option) record
        Special_Feature_Option__c SFO_Obj4 = new Special_Feature_Option__c();
        SFO_Obj4.RecordTypeId = RecordTypeIdSFO3;
        SFO_Obj4.Special_Feature_Parent__c = SFO_Obj2.id;
        insert SFO_Obj4;
        slist.add(SFO_Obj4);
        
        SFODynamicRollup.summarizeTotalCost(slist);
        //Sfod.hasRollUp;
    }
}