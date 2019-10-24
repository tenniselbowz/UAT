public class SFODynamicFields 
{
    public Special_Feature_Option__c sfo_Obj{get;set;}
    public List<dynamicWrapper> dynamicWrapperList{get;set;}
    public List<dynamicWrapper> dynamicWrapperList2{get;set;}
    private List<SFO_Dynamic_Fields__c> sfo_dynamic_fields_list = new List<SFO_Dynamic_Fields__c>();
    
    public SFODynamicFields(ApexPages.StandardController controller)
    {
        sfo_Obj = (Special_Feature_Option__c)controller.getRecord();
        if(sfo_Obj.Id != NULL)
        {
            string SFOId=sfo_Obj.Id;
            sfo_Obj = Database.query(UtilityClass.getSObjectFields('Special_Feature_Option__c', 'id=:SFOId', true)); 
            sfo_dynamic_fields_list = Database.query(UtilityClass.getSObjectRelatedFields('SFO_Dynamic_Fields__c',
                             'SFO_Field__r.Field_Data_Type__c,SFO_Field__r.Field_Length__c, SFO_Field__r.Formula_Editor__c,'+
                             'SFO_Field__r.Required__c, SFO_Field__r.Name',
                             'SFO__c = :SFOId',  true)); 
                
        }
        system.debug('sfo_dynamic_fields_list'+sfo_dynamic_fields_list);
        getDynamicFields();
    }
    
    public pagereference saveSFODynamicFields()
    {
        List<SFO_Dynamic_Fields__c> sfo_dynamic_list = new List<SFO_Dynamic_Fields__c>();
        Map<String, String> keyValueMap = new Map<String, String>();
        
        List<dynamicWrapper> cumulativeWrapperList = new List<dynamicWrapper>();
        cumulativeWrapperList.addAll(dynamicWrapperList);
        cumulativeWrapperList.addAll(dynamicWrapperList2);
        System.debug('cumulativeWrapperList::'+cumulativeWrapperList);
        List<Estimate__c> estimateList = new List<Estimate__c>();
        String format = sfo_Obj.Base_Unit_to_be_Modified__c;
        System.debug('format::'+format);
        estimateList = Database.query(UtilityClass.getSObjectFields('Estimate__c', 'Product__c =:format', true));
        for(Estimate__c e :estimateList){
            String key = e.Estimate_Lable__c.toLowerCase(); keyValueMap.put(key, String.valueOf(e.Hour__c));    
            
        } 
        for(dynamicWrapper wrap : cumulativeWrapperList)
        {
            SFO_Dynamic_Fields__c  SFO_Dynamic_Fields_Rec = wrap.sfo_dynamic_field_obj;
            System.debug('sfo_Obj.id '+sfo_Obj.id);
           	sfo_dynamic_list.add(SFO_Dynamic_Fields_Rec); 
            String key = SFO_Dynamic_Fields_Rec.Name.toLowerCase();
            
            if((SFO_Dynamic_Fields_Rec.Field_Value__c == null || SFO_Dynamic_Fields_Rec.Field_Value__c == '')
               && (wrap.sfo_dynamic_field_obj.SFO_Field__r.Field_Data_Type__c == 'Number'))
            {
                SFO_Dynamic_Fields_Rec.Field_Value__c = '0';        
            }
            
            keyValueMap.put(key, SFO_Dynamic_Fields_Rec.Field_Value__c);    
        }
        
        
        for(dynamicWrapper wrapVal : cumulativeWrapperList)
        {
            SFO_Dynamic_Fields__c  SFO_Dynamic_Fields_Rec = wrapVal.sfo_dynamic_field_obj;
            Integer dynamic_field_length = 0;
            System.debug(SFO_Dynamic_Fields_Rec.Name+'::Field Length::'+SFO_Dynamic_Fields_Rec.Field_Value__c);
            if(SFO_Dynamic_Fields_Rec.Field_Value__c != null && SFO_Dynamic_Fields_Rec.Field_Value__c== ''){dynamic_field_length =  SFO_Dynamic_Fields_Rec.Field_Value__c.length();  
            }
            Integer sfo_field_Length = Integer.valueOf(wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Field_Length__c);
            
            if(dynamic_field_length > sfo_field_Length)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Name +' length is exceeded')); return null;
            }
            System.debug('wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Field_data_Type__c ::'+wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Field_data_Type__c);
            if(wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Field_data_Type__c == 'Formula')
            {
                String formula = wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Formula_Editor__c;
                SFO_Dynamic_Fields_Rec.Field_Value__c = 
                    Evaluate_Expression.evaluateExpression(formula, keyValueMap);
                
            }
        }
        if(sfo_dynamic_list.size() > 0)
        {
            upsert sfo_dynamic_list;
            
        }
        
        return new pagereference('/'+sfo_Obj.Id);
    }
    
    public void getDynamicFields()
    {
       
        dynamicWrapperList = new List<dynamicWrapper>();
        dynamicWrapperList2 = new List<dynamicWrapper>();
        
        integer i=0;
        for(SFO_Dynamic_Fields__c sfo_Dynamic_fields_rec :sfo_dynamic_fields_list)
        {
            if(math.mod(i,2) == 0)
            {
                dynamicWrapperList.add(new dynamicWrapper(sfo_Dynamic_fields_rec)); 
            }
            else
            {
                dynamicWrapperList2.add(new dynamicWrapper(sfo_Dynamic_fields_rec));
            }
            if(sfo_Dynamic_fields_rec.SFO_Field__r.Field_Data_Type__c != 'Formula')
            {
               i++; 
            }
        }
        
        System.debug('dynamicWrapperList::'+dynamicWrapperList);
        
        Map<String, SFO_Dynamic_Fields__c> sfo_dynamic_fields_map = new 
            Map<String, SFO_Dynamic_Fields__c>();
        
        if(sfo_Obj.Id != null)
        {
            System.debug('sfo_Obj.Id:: '+sfo_Obj.Id);
            
            for(SFO_Dynamic_Fields__c dynamicField :sfo_dynamic_fields_list)
            {
                sfo_dynamic_fields_map.put(dynamicField.SFO_Field__c, dynamicField);    
            }
        }
        
        for(dynamicWrapper wrap : dynamicWrapperList)
        {
            if(sfo_dynamic_fields_map.containsKey(wrap.sfo_dynamic_field_obj.SFO_Field__c))
            {
                wrap.sfo_dynamic_field_obj =  sfo_dynamic_fields_map.get(wrap.sfo_dynamic_field_obj.SFO_Field__c);
                wrap.fieldValue = sfo_dynamic_fields_map.get(wrap.sfo_dynamic_field_obj.SFO_Field__c).Field_Value__c;
            }
        }
        for(dynamicWrapper wrap : dynamicWrapperList2)
        {
            if(sfo_dynamic_fields_map.containsKey(wrap.sfo_dynamic_field_obj.SFO_Field__c))
            {
                wrap.sfo_dynamic_field_obj =  sfo_dynamic_fields_map.get(wrap.sfo_dynamic_field_obj.SFO_Field__c);
                wrap.fieldValue = sfo_dynamic_fields_map.get(wrap.sfo_dynamic_field_obj.SFO_Field__c).Field_Value__c;
            }
        }
    }
    
    public class dynamicWrapper
    {
        public SFO_Dynamic_Fields__c sfo_dynamic_field_obj{get;set;} 
        public List<String> sfo_pick_list_entries{get;set;}
        public String fieldValue{get;set;}
        public dynamicWrapper(SFO_Dynamic_Fields__c sfo_dynamic_field_rec)
        {
            sfo_pick_list_entries = new List<String>();
            if(sfo_dynamic_field_rec.Picklist_Entries__c != null && sfo_dynamic_field_rec.Picklist_Entries__c != '')
            {
                sfo_pick_list_entries = sfo_dynamic_field_rec.Picklist_Entries__c.split('\n');
                
            }
            sfo_dynamic_field_obj = sfo_dynamic_field_rec;
            
        }
        public List<SelectOption> getdynamiclistEntries() 
        {
            List<SelectOption> options = new List<SelectOption>(); options.add(new SelectOption('','--None--'));
            for(String entry :sfo_pick_list_entries) {entry = entry.trim(); options.add(new SelectOption(entry,entry)); 
            }
            return options;
        }
    }
}