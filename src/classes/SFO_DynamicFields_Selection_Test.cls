@isTest
public class SFO_DynamicFields_Selection_Test {
    @isTest static void SFO_DynamicFields_Selection_Method () {
        List<SFO_Fields__c> selectedFeldsList = new List<SFO_Fields__c>();
        for(Integer i=0;i<5;i++){
        SFO_Fields__c Sfo = new SFO_Fields__c();
        Sfo.IsActive__c =true;
        Sfo.Field_Data_Type__c = 'Text';
        Sfo.Field_Length__c = 10;
        Sfo.Formula_Editor__c ='Abcd';
        Sfo.Picklist_Entries__c = 'Efgh';
        Sfo.Required__c = true;
           
            selectedFeldsList.add(Sfo);
        }
        Insert selectedFeldsList;
        
        
        Test.startTest();
        Special_Feature_Option__c Spfo = new Special_Feature_Option__c();
        SFO_DynamicFields_Selection sfc = new SFO_DynamicFields_Selection(new ApexPages.StandardController(Spfo));
        sfc.getDynamicFields();
        sfc.gotoNext();
        sfc.gotoPrevious();
        sfc.saveFields();
        sfc.Beginning();
        sfc.Previous();
        sfc.Next();
        sfc.End();
        sfc.getDisablePrevious();
        sfc.getDisableNext();
        sfc.closePopup();
        Sfc.saveSFOField();
        sfc.showPopup();
        
       /* List<Special_Feature_Option__c> SFOList = new List<Special_Feature_Option__c>();
        SFOList.add(Spfo);
        SFO_Trigger_Handler str = new SFO_Trigger_Handler();
        SFO_Trigger_Handler.Insert_ChildRec_for_SFOs(SFOList);*/
        Test.stopTest();
    }
    
}