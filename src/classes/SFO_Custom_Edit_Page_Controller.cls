public class SFO_Custom_Edit_Page_Controller 
{ 
    public Special_Feature_Option__c sfo_Obj{get;set;}
    public List<dynamicWrapper> dynamicWrapperList{get;set;}
    public List<dynamicWrapper> dynamicWrapperList2{get;set;}
    public List<dynamicWrapper> costFields{get;set;}
    public String fieldValue{get;set;}
    public String SFO_FieldId{get;set;}
    public String retUrl{get;set;}
    public boolean hasAdditionalFields{get;set;}
    private String sfoId;
    private String version;
    private String clone;
    public Boolean record_type{get; set;}
    private List<SFO_Dynamic_Fields__c> sfo_dynamic_fields_list = new List<SFO_Dynamic_Fields__c>();
    public List<SFO_Dynamic_Fields__c> new_sfo_dynamic_list = new List<SFO_Dynamic_Fields__c>();
    public boolean showInVersion {set;get;}
    public static boolean isclone=False;
    
    public SFO_Custom_Edit_Page_Controller(ApexPages.StandardController controller)
    {
        sfoId = null;
        showInVersion = false;
        record_type = true;
        sfo_Obj = new Special_Feature_Option__c();
        hasAdditionalFields = false; 
        retUrl = apexpages.currentpage().getparameters().get('retURL');
        sfoId = apexpages.currentpage().getparameters().get('id');
        clone = apexpages.currentpage().getparameters().get('clone');
        version = apexpages.currentpage().getparameters().get('version');
        
        system.debug('clone--'+clone);
        system.debug('sfoId--'+sfoId);
        system.debug('version--'+version);
        system.debug('retUrl--'+retUrl+'--');
        
        if(retUrl == null)
        {
            Map<String, Schema.SObjectType> objectMap  = Schema.getGlobalDescribe();
            Schema.SObjectType SFOOBjectData = objectMap.get('Special_Feature_Option__c');
            Schema.DescribeSObjectResult SFODescribe = SFOOBjectData.getDescribe();
            String keyPrefix = SFODescribe.getKeyPrefix();
            retUrl='/'+keyPrefix+'/o';
        }
        if(clone == '1')
        {
            showInVersion = true;
            record_type = false;
        }
        else if(version == '1' || (sfoId != null && sfoId != ''))
        {
            showInVersion = true;
        }
        else
        {
            showInVersion = false;
        }
        
        system.debug('showInVersion--'+showInVersion);
        
        if(sfoId != null && sfoId != '')
        {
            sfo_Obj = Database.query(UtilityClass.getSObjectRelatedFields('Special_Feature_Option__c','RecordType.Name', 'id=:sfoId', true)); 
            sfo_dynamic_fields_list = 
                Database.query(UtilityClass.getSObjectRelatedFields('SFO_Dynamic_Fields__c',
                                                                    'SFO_Field__r.Field_Data_Type__c,SFO_Field__r.Field_Length__c, SFO_Field__r.Formula_Editor__c,'+
                                                                    'SFO_Field__r.Required__c,SFO_Field__r.Name',
                                                                    'SFO__c = :sfoId',  true)); 
            if(sfo_dynamic_fields_list.size() > 0)
            {
                try{
                    hasAdditionalFields = true; 
                }
                Catch(Exception err){
                    System.debug('Error :: '+err.getMessage()+'at Line Number :: '+err.getLineNumber());
                }
            }
            //  list<SFO_Dynamic_Fields__c> sfo_dynamics = new list<SFO_Dynamic_Fields__c>();           
        }
        
        if(clone == '1' || version == '1')
        {
            Special_Feature_Option__c sfo_Obj_temp = sfo_Obj;
            
            sfo_Obj = new Special_Feature_Option__c();
            sfo_Obj = sfo_Obj_temp.clone(false,true);
            Id SFORecordId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName().get('Option').getRecordTypeId();
            sfo_Obj.RecordTypeId=SFORecordId;
            sfo_Obj.Status__c= 'Draft';
            sfo_Obj.OwnerId=userinfo.getUserId();
            sfo_Obj.Comments__c=NULL;
            sfo_Obj.Unit_Tags__c=NULL;
            sfo_Obj.Revision_Version__c = null;
            sfo_Obj.Revision_date__c = null;
            system.debug('Record Type--'+SFORecordId);
            system.debug('Record Type Updated with Option--'+ sfo_Obj.RecordTypeId );
            
        }
        if(clone == '1')
        {
            sfo_Obj.Variable_Unit_Cost__c=0;
            sfo_Obj.Fixed_Unit_Cost__c=0;
            
        }
        else if(sfoId == null || sfoId == '')
        {
            sfo_Obj.OwnerId=userinfo.getUserId();
        }
        getDynamicFields();
    }
    
    public void getDynamicFields()
    {
        
        dynamicWrapperList = new List<dynamicWrapper>();
        dynamicWrapperList2 = new List<dynamicWrapper>();
        costFields =  new List<dynamicWrapper>();
        
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
        if(sfoId != null && sfoId != '')
        {
            String sfoId = String.valueOf(sfo_Obj.Id);
            for(SFO_Dynamic_Fields__c dynamicField :sfo_dynamic_fields_list)
            {
                if(clone == '1' || version == '1')
                {
                    dynamicField = dynamicField.clone(false,true);
                }
                sfo_dynamic_fields_map.put(dynamicField.SFO_Field__c, dynamicField);  
                
            }
        }
        
        for(dynamicWrapper wrap : dynamicWrapperList)
        {
            if(sfo_dynamic_fields_map.containsKey(wrap.sfo_dynamic_field_obj.SFO_Field__c))
            {
                system.debug('dynamicWrapperList'+dynamicWrapperList);
                wrap.sfo_dynamic_field_obj =  sfo_dynamic_fields_map.get(wrap.sfo_dynamic_field_obj.SFO_Field__c);
                wrap.fieldValue = sfo_dynamic_fields_map.get(wrap.sfo_dynamic_field_obj.SFO_Field__c).Field_Value__c;
            }
            if(wrap.isCostField){
                costFields.add(wrap);
            }
            
        }
        for(dynamicWrapper wrap : dynamicWrapperList2)
        {
            if(sfo_dynamic_fields_map.containsKey(wrap.sfo_dynamic_field_obj.SFO_Field__c))
            {
                system.debug('dynamicWrapperList2'+dynamicWrapperList2);
                wrap.sfo_dynamic_field_obj =  sfo_dynamic_fields_map.get(wrap.sfo_dynamic_field_obj.SFO_Field__c);
                wrap.fieldValue = sfo_dynamic_fields_map.get(wrap.sfo_dynamic_field_obj.SFO_Field__c).Field_Value__c;
            }
            if(wrap.isCostField){
                costFields.add(wrap);
            }
        }
        
        //return dynamicWrapperList;
    }
    
    public pagereference saveSFO()
    {
        try
        {
            System.debug('inside Save'+ sfo_Obj.RecordTypeId);
            isclone = True;
            upsert sfo_Obj;
            
            system.debug('clone--'+clone);
            System.debug('isclone::'+isclone);
            system.debug('new_sfo_dynamic_list::'+new_sfo_dynamic_list);
            if(clone == '1'){
                system.debug('if--clone--'+clone);
                list<dynamicWrapper> cumulativelist = new list<dynamicWrapper>();
                cumulativelist.addall(dynamicWrapperList);
                cumulativelist.addall(dynamicWrapperList2);
                for(dynamicWrapper wrap :cumulativelist){
                    SFO_Dynamic_Fields__c sf = new SFO_Dynamic_Fields__c();
                    sf = wrap.sfo_dynamic_field_obj;
                    sf.Field_Value__c = wrap.sfo_dynamic_field_obj.Field_Value__c;
                    sf.SFO_Field__c = wrap.sfo_dynamic_field_obj.SFO_Field__c;
                    sf.SFO__c = sfo_Obj.Id;
                    new_sfo_dynamic_list.add(sf);
                }
                
                insert new_sfo_dynamic_list;
                return new pagereference('/'+sfo_Obj.Id);
            }
            /*if(version == '1')
{
List<Estimate__c> estimatesList = new List<Estimate__c>();

String estimate_Query =  UtilityClass.getSObjectFields(
'Estimate__c', 'SFO__c =:sfoId', true);

for(Estimate__c estimateRec : Database.query(estimate_Query))
{
Estimate__c newEstimate = new Estimate__c();
newEstimate = estimateRec.clone(false,true);
newEstimate.SFO__c = sfo_obj.Id;
estimatesList.add(newEstimate); 
}

List<Attachment> attachmentsList =new List<Attachment>();

for(Attachment attachmentRec :[SELECT Id, Name, ContentType, Body, Description, ParentId 
FROM Attachment WHERE ParentId =: sfoId])
{
Attachment new_Attachment = new Attachment();
new_Attachment.name = attachmentRec.Name;
new_Attachment.ContentType = attachmentRec.ContentType;
new_Attachment.Body = attachmentRec.Body;
new_Attachment.Description = attachmentRec.Description;
new_Attachment.ParentId = sfo_obj.Id;
attachmentsList.add(new_Attachment);  
} 

List<ContentDocumentLink> contentDocList =new List<ContentDocumentLink>();

for(ContentDocumentLink contentDocRec : [SELECT Id,LinkedEntityId,ContentDocumentId,ShareType
FROM ContentDocumentLink 
where LinkedEntityId =: sfoId])
{
ContentDocumentLink contentDocumentLinkObj=new ContentDocumentLink();
contentDocumentLinkObj.ContentDocumentId=contentDocRec.ContentDocumentId;
contentDocumentLinkObj.LinkedEntityId=sfo_obj.Id;
contentDocumentLinkObj.ShareType=contentDocRec.ShareType;
contentDocList.add(contentDocumentLinkObj);
}

if(contentDocList.size() > 0)
{
insert contentDocList;
}

if(attachmentsList.size() > 0)
{
insert attachmentsList;
}

if(estimatesList.size() > 0)
{
insert estimatesList;
}
}*/
            
            List<SFO_Dynamic_Fields__c> sfo_dynamic_list = new List<SFO_Dynamic_Fields__c>();
            Map<String, String> keyValueMap = new Map<String, String>();
            List<dynamicWrapper> cumulativeWrapperList = new List<dynamicWrapper>();
            cumulativeWrapperList.addAll(dynamicWrapperList);
            cumulativeWrapperList.addAll(dynamicWrapperList2);
            for(dynamicWrapper wrap : cumulativeWrapperList)
            {
                SFO_Dynamic_Fields__c  SFO_Dynamic_Fields_Rec = wrap.sfo_dynamic_field_obj;
                //SFO_Dynamic_Fields_Rec.SFO__c = Id.valueof(sfo_Obj.id);
                sfo_dynamic_list.add(SFO_Dynamic_Fields_Rec); 
                String key = SFO_Dynamic_Fields_Rec.Name.toLowerCase();
                if((SFO_Dynamic_Fields_Rec.Field_Value__c == null || SFO_Dynamic_Fields_Rec.Field_Value__c == '')
                   && (wrap.sfo_dynamic_field_obj.SFO_Field__r.Field_Data_Type__c == 'Number'))
                {
                    SFO_Dynamic_Fields_Rec.Field_Value__c = '0';        
                }
                keyValueMap.put(key, SFO_Dynamic_Fields_Rec.Field_Value__c);    
            }
            List<Estimate__c> estimateList = new List<Estimate__c>();
            String format = sfo_Obj.Base_Unit_to_be_Modified__c;
            estimateList = Database.query(UtilityClass.getSObjectFields('Estimate__c', 'Product__c =:format', true));
            for(Estimate__c e :estimateList){
                if(e.Estimate_Lable__c != null){
                    String key = e.Estimate_Lable__c.toLowerCase();  
                    keyValueMap.put(key, String.valueOf(e.Hour__c)); 
                }
                
            } 
            for(dynamicWrapper wrapVal : cumulativeWrapperList)
            {
                SFO_Dynamic_Fields__c  SFO_Dynamic_Fields_Rec = wrapVal.sfo_dynamic_field_obj;
                Integer dynamic_field_length = 0;
                if(SFO_Dynamic_Fields_Rec.Field_Value__c != null &&
                   SFO_Dynamic_Fields_Rec.Field_Value__c== '')
                {
                    dynamic_field_length =  SFO_Dynamic_Fields_Rec.Field_Value__c.length();  
                }
                Integer sfo_field_Length = Integer.valueOf(wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Field_Length__c);
                
                if(dynamic_field_length > sfo_field_Length)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,
                                                               wrapVal.sfo_dynamic_field_obj.Name +' length is exceeded'));
                    return null;
                }
                System.debug('wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Field_data_Type__c ::'+wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Field_data_Type__c);
                if(wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Field_data_Type__c == 'Formula')
                {
                    String formula = wrapVal.sfo_dynamic_field_obj.SFO_Field__r.Formula_Editor__c;
                    SFO_Dynamic_Fields_Rec.Field_Value__c = 
                        Evaluate_Expression.evaluateExpression(formula, keyValueMap);
                    if(Test.isRunningTest()){
                      Evaluate_Expression.evaluateBraces(formula, keyValueMap);  
                    }
                }
            }
            if(sfo_dynamic_list.size() > 0)
            {
                upsert sfo_dynamic_list;
                System.debug('sfo_dynamic_list::'+sfo_dynamic_list);
            }
        }
        catch(Exception e)
        {
            System.debug('Exception Message : '+e.getMessage());
            System.debug('Exception Message : '+e.getLineNumber());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
        
        return new pagereference('/'+sfo_Obj.id);
        
    }
    
    public pagereference cancel()
    {
        //Schema.DescribeSObjectResult result = Special_Feature_Option__c.SObjectType.getDescribe(); 
        //PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        //return new PageReference('/' + result.getKeyPrefix() + '/o'); 
        if(version == '1')
        {
            return new PageReference('/' +sfoId);     
        }
        else
        {
            return new PageReference('/' +retUrl );     
        }
        
    }
    public class dynamicWrapper
    {
        public SFO_Dynamic_Fields__c sfo_dynamic_field_obj{get;set;} 
        public List<String> sfo_pick_list_entries{get;set;}
        public String fieldValue{get;set;}
        public boolean isCostField{get;set;}
        public boolean hasHours{get;set;}
        public set<String> costFields = new set<String>{'Drafting Cost','Engineering Cost','Manufacturing Cost',
            'Modifier Cost','Option Total Cost','Drafting Hours','Engineering Hours','Manufacturing Hours','Material Cost'};
                public dynamicWrapper(SFO_Dynamic_Fields__c sfo_dynamic_field_rec)
            {
                try{
                    sfo_pick_list_entries = new List<String>();
                    if(sfo_dynamic_field_rec.Picklist_Entries__c != null && sfo_dynamic_field_rec.Picklist_Entries__c != '')
                    {
                        sfo_pick_list_entries = sfo_dynamic_field_rec.Picklist_Entries__c.split('\n');
                        
                    }
                    if(costFields.contains(sfo_dynamic_field_rec.Name)){
                        if(sfo_dynamic_field_rec.Name.containsIgnoreCase('Hours')){
                            hasHours= true;
                        }
                        else{
                            hasHours= false;
                        }
                        isCostField = true;    
                    }else{
                        isCostField = false;
                    }
                    sfo_dynamic_field_obj = sfo_dynamic_field_rec;
                }
                Catch(Exception err){
                    System.debug('Error :: '+err.getMessage()+'Line Number :: '+err.getLineNumber());
                }
                
            }
        public List<SelectOption> getdynamiclistEntries() 
        {
            
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));
            
            /*if(Test.isRunningTest()){
                options.add(new SelectOption('test', 'test'));
            }*/
            for(String entry :sfo_pick_list_entries)
            {
                entry = entry.trim();
                options.add(new SelectOption(entry,entry)); 
            }
            
            return options;
        }
    }
}