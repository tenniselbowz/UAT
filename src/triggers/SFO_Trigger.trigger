trigger SFO_Trigger on Special_Feature_Option__c (before insert, before update, 
                                                  after insert, after update) 
{
    System.debug('Inside Trigger');
    Id optionRecordTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName().get('Option').getRecordTypeId();
    Id specialFeatureRecordTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName().get('Special_Feature_Option').getRecordTypeId();
    if(trigger.isBefore)
    {
        List<Special_Feature_Option__c> SFO_List = new List<Special_Feature_Option__c>();
        if(trigger.isUpdate)
        {
            for(Special_Feature_Option__c sfo_rec :trigger.new)
            {
                if(sfo_rec.Unit_Tags__c != trigger.oldMap.get(sfo_rec.Id).Unit_Tags__c)
                {
                    SFO_List.add(sfo_rec);    
                }  
            }
        }
        if(SFO_List.size() > 0)
        {
            if(Test.isRunningTest()){
            // SFO_Trigger_Handler.updateUnitTags(SFO_List); 
                }  
        }
        if(trigger.isInsert)
        {
            SFO_List = new List<Special_Feature_Option__c>();
            for(Special_Feature_Option__c sfo_rec :trigger.new)
            {
                if(sfo_rec.RecordTypeId == optionRecordTypeId)
                {
                    SFO_List.add(sfo_rec);    
                }  
                
            }
            // AND SFO_Custom_Edit_Page_Controller.isclone = False
            //  SFO_Custom_Edit_Page_Controller sfo = new SFO_Custom_Edit_Page_Controller();
            //  boolean isclone = sfo.isclone;
            
            if(SFO_List.size() > 0)
            {
                
                SFO_Trigger_Handler.updateRevisionInfo(SFO_List);   
            }
        }
    }
    if(trigger.isAfter)
    {
        List<Special_Feature_Option__c> SFO_List = new List<Special_Feature_Option__c>();
        List<Special_Feature_Option__c> specialFeatureList = new List<Special_Feature_Option__c>();
        if(trigger.isInsert)
        {
            for(Special_Feature_Option__c sfo_rec :trigger.new)
            {
                if(sfo_rec.Option_Parent__c != null)
                {
                    SFO_List.add(sfo_rec);    
                }
                if(sfo_rec.RecordTypeId == specialFeatureRecordTypeId)
                {
                    specialFeatureList.add(sfo_rec);    
                }
            }  
            system.debug('clone::'+SFO_Custom_Edit_Page_Controller.isclone);
            if(SFO_List.size() > 0  && !SFO_Custom_Edit_Page_Controller.isclone)
            {
                SFO_Trigger_Handler.Insert_ChildRec_for_SFOs(SFO_List);    
            }
            if(specialFeatureList.size() > 0 )
            {
                SFO_Trigger_Handler.createDynamicFields(specialFeatureList);    
            }
        }
        
        if(trigger.isUpdate){
            if(SFODynamicRollup.hasRollUp){
                Id OptrecTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName().get('Option').getRecordTypeId();
                list<Special_Feature_Option__c> options = new list<Special_Feature_Option__c>();
                for(Special_Feature_Option__c sfo : trigger.new ){
                    if(sfo.recordTypeId == OptrecTypeId
                       && sfo.Total_Cost_value__c != trigger.oldMap.get(sfo.id).Total_Cost_value__c){
                           options.add(sfo); 
                       }
                }
                if(options.size() > 0 ){
                    SFODynamicRollup.summarizeTotalCost(options);
                } 
            }
            
        }
    }
    
    if(Trigger.isAfter){
        System.debug('isAfter');
        if(Trigger.isUpdate){
            System.debug('isUpdate');
            Map<id,String> sfoIdStatus = new Map<id,String>();
            Map<id,id> unitDetailWithFpaId = new Map<id,id>();
            set<id> newSfoids = new set<id>();
            Map<id,id> UnitDetailidsWithSfoIds = new Map<id,id>();
            for(Special_Feature_Option__c s: Trigger.New){ 
                if(s.Status__c == 'Draft' || s.Status__c=='Rejected'){}
                sfoIdStatus.put(s.id,s.Status__c);
                newSfoids.add(s.id);
                System.debug('New Related SFO'+s.Status__c);
            }
            System.debug('sfoIdStatus ::'+sfoIdStatus);
            List<Related_SFO__c> ToDeleteListOfRelatedSFOs =[SELECT Name, Id, Unit_Detail__c, SFO__c FROM Related_SFO__c where SFO__c IN :newSfoids];
            System.debug('ToDeleteListOfRelatedSFOs'+ToDeleteListOfRelatedSFOs);
            for(Related_SFO__c r: ToDeleteListOfRelatedSFOs){
                UnitDetailidsWithSfoIds.put(r.Unit_Detail__c,r.SFO__c);
            }
            List<FPA_Link__c>  listOfUnitDetailsRelatedToSFO = [SELECT Id, Name, SFO__c, FPA__c FROM FPA_Link__c where id  IN :UnitDetailidsWithSfoIds.keySet()];
            System.debug('listOfUnitDetailsRelatedToSFO'+listOfUnitDetailsRelatedToSFO);
            for(FPA_Link__c unitdetail :listOfUnitDetailsRelatedToSFO){
                unitDetailWithFpaid.put(unitdetail.FPA__c,unitdetail.id);
            }
            List<Factory_Pricing_Authorization__c> FPAListRelatedToUnitDetail = [SELECT Id, Status__c FROM Factory_Pricing_Authorization__c where id IN: unitDetailWithFpaid.keySet()];
            for(Factory_Pricing_Authorization__c f: FPAListRelatedToUnitDetail){
                System.debug('f.Status__c :: Before Assign'+f.Status__c);
                f.Status__c = sfoIdStatus.get(UnitDetailidsWithSfoIds.get(unitDetailWithFpaId.get(f.id)));
                System.debug('f.Status__c :: '+f.Status__c);
            }
            removeDraftRejectedSFO.removesfo(trigger.oldmap, trigger.newmap);
            Database.SaveResult [] updateResult = Database.update(FPAListRelatedToUnitDetail, false);
            //Database.delete(listOfUnitDetailsRelatedToSFO, false);
            System.debug('Completed');
            for (Database.SaveResult sr : updateResult) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
}