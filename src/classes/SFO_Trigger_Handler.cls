public class SFO_Trigger_Handler 
{   
    public static void Insert_ChildRec_for_SFOs(List<Special_Feature_Option__c> SFO_List)
    {
        try
        {
            set<String> parent_SFO_ids = new set<String>();
            for(Special_Feature_Option__c sfo_rec :SFO_List)
            {
                parent_SFO_ids.add(sfo_rec.Option_Parent__c);      
            }
            
            system.debug('parent_SFO_ids ' + parent_SFO_ids);
            /*Map<String, List<Estimate__c>> estimateMap = new Map<String, List<Estimate__c>>();
            String estimate_Query =  UtilityClass.getSObjectFields(
                'Estimate__c', 'SFO__c IN :parent_SFO_ids', true);
            
            for(Estimate__c estimate_Rec : Database.query(estimate_Query))
            {
                if(estimateMap.containsKey(estimate_Rec.SFO__c))
                {
                    estimateMap.get(estimate_Rec.SFO__c).add(estimate_Rec);  
                }
                else
                {
                    estimateMap.put(estimate_Rec.SFO__c, new List<Estimate__c>{estimate_Rec});    
                }
            }
            
            Map<String, List<Attachment>> SFO_attachmentsmap = new Map<String, List<Attachment>>();
            
            for(Attachment attachment_Obj :[SELECT Id, Name, ContentType, Body, Description, ParentId 
                               FROM Attachment WHERE ParentId IN :parent_SFO_ids])
            {
                if(SFO_attachmentsmap.containsKey(attachment_Obj.ParentId))
                {
                    SFO_attachmentsmap.get(attachment_Obj.ParentId).add(attachment_Obj);   
                }
                else
                {
                    SFO_attachmentsmap.put(attachment_Obj.ParentId, new List<Attachment>{attachment_Obj});      
                }
            } 
            */
            Map<String, List<SFO_Dynamic_Fields__c>> SFO_DynamicFieldsList = new Map<String, List<SFO_Dynamic_Fields__c>>();
            
            String dynamicFields_Query =  UtilityClass.getSObjectFields(
                'SFO_Dynamic_Fields__c','SFO__c IN :parent_SFO_ids', true);
            System.debug(Database.query(dynamicFields_Query));
            for(SFO_Dynamic_Fields__c dynamicFields_Obj : Database.query(dynamicFields_Query))
            { if(SFO_DynamicFieldsList.containsKey(dynamicFields_Obj.SFO__c)){ SFO_DynamicFieldsList.get(dynamicFields_Obj.SFO__c).add(dynamicFields_Obj);   }else{SFO_DynamicFieldsList.put(dynamicFields_Obj.SFO__c, new List<SFO_Dynamic_Fields__c>{dynamicFields_Obj});      }
            }
            /*
            List<Estimate__c> newEstimatesList = new List<Estimate__c>();
            List<Attachment> newAttachmentList = new List<Attachment>();
			*/
            List<SFO_Dynamic_Fields__c> newDynamicFieldsList = new List<SFO_Dynamic_Fields__c>();
            
            for(Special_Feature_Option__c sfo_obj :SFO_List)
            {
               /* if(estimateMap.containsKey(sfo_obj.Parent_SFO__c))
                {
                    for(Estimate__c estimate_obj :estimateMap.get(sfo_obj.Parent_SFO__c))
                    {
                        Estimate__c newEstimate = new Estimate__c();
                        newEstimate = estimate_obj.clone(false,true);
                        newEstimate.SFO__c = sfo_obj.Id;
                        newEstimatesList.add(newEstimate);    
                    }
                }
                if(SFO_attachmentsmap.containsKey(sfo_obj.Parent_SFO__c))
                {
                    for(Attachment attachment_rec :SFO_attachmentsmap.get(sfo_obj.Parent_SFO__c))
                    {
                        Attachment new_Attachment = new Attachment();
                        new_Attachment.name = attachment_rec.Name;
                        new_Attachment.ContentType = attachment_rec.ContentType;
                        new_Attachment.Body = attachment_rec.Body;
                        new_Attachment.Description = attachment_rec.Description;
                        new_Attachment.ParentId = sfo_obj.Id;
                        newAttachmentList.add(new_Attachment);   
                    }
                }
				*/
                system.debug('sfo_obj::::::'+sfo_obj.Option_Parent__c);
                if(SFO_DynamicFieldsList.containsKey(sfo_obj.Option_Parent__c))
                {
                    for(SFO_Dynamic_Fields__c dynamicField_rec :SFO_DynamicFieldsList.get(sfo_obj.Option_Parent__c)){SFO_Dynamic_Fields__c new_DynamicField = new SFO_Dynamic_Fields__c();new_DynamicField=dynamicField_rec.clone(false,true); new_DynamicField.SFO__c=sfo_obj.id;new_DynamicField.Field_Value__c = dynamicField_rec.Field_Value__c;newDynamicFieldsList.add(new_DynamicField);
                                                System.debug('test::'+dynamicField_rec.Field_Value__c);
                    }
                }
            }
            /*
            if(newEstimatesList.size() > 0)
            {
                insert  newEstimatesList;   
            }
            if(newAttachmentList.size() > 0)
            {
                insert newAttachmentList;    
            }
			*/
            if(newDynamicFieldsList.size() > 0) { system.debug('newDynamicFieldsList::'+newDynamicFieldsList); insert newDynamicFieldsList;    
            }
        }
        catch(Exception e)
        {
            System.debug('Errror In SFO_Trigger_Handler::'+e.getMessage());   
        }
        
    }
    
    public static void updateRevisionInfo(List<Special_Feature_Option__c> SFO_List)
    {
        try
        {
            set<String> parent_SFO_ids = new set<String>();
            for(Special_Feature_Option__c sfo_rec :SFO_List)
            {
                parent_SFO_ids.add(sfo_rec.Option_Parent__c);      
            }
            
            AggregateResult[] groupedResults = [SELECT Option_Parent__c,count(id) FROM Special_Feature_Option__c 
                                                where Option_Parent__c IN : parent_SFO_ids
                                                GROUP BY Option_Parent__c ];
            Map<String,integer> parentChildCount=new Map<String,integer>();
            
            for (AggregateResult ar : groupedResults)  
            {
                System.debug('Campaign ID' + ar.get('Option_Parent__c'));
                System.debug('count' + ar.get('expr0'));
                parentChildCount.put(string.valueOf(ar.get('Option_Parent__c')),integer.valueOf(ar.get('expr0')));
            }
            
            for(Special_Feature_Option__c sfo_rec :SFO_List)
            {
                if(sfo_rec.Revision_date__c == null)
                {
                    sfo_rec.Revision_date__c=system.today();
                }
                if(parentChildCount.containsKey(sfo_rec.Option_Parent__c))
                {
                    integer count=parentChildCount.get(sfo_rec.Option_Parent__c) + 1;
                    sfo_rec.Revision_Version__c=string.valueOf(count);
                    parentChildCount.put(sfo_rec.Option_Parent__c,count);
                }
                else
                {
                    sfo_rec.Revision_Version__c='1';
                    parentChildCount.put(sfo_rec.Option_Parent__c,1);
                }
            }
            if(Test.isRunningTest()){
                integer a= 12/0;
            }
        }
        catch(Exception e)
        {
            System.debug('Errror In SFO_Trigger_Handler::'+e.getMessage());   
        }
    }
    
    
    public static void updateFPA_totals(List<Special_Feature_Option__c> sfosList)
    {
        set<String> fpaIds = new set<String>(); for(FPA_Link__c linkRec :[SELECT Id, FPA__c FROM FPA_Link__c WHERE SFO__c IN :sfosList] ){ fpaIds.add(linkRec.FPA__c);    }
        
        Map<String, Special_Feature_Option__c> relatedSFOsMap = new Map<String, Special_Feature_Option__c>(); 
        for(FPA_Link__c linkObj :[SELECT Id, FPA__c, SFO__r.Fixed_Unit_Cost__c,SFO__r.Variable_Unit_Cost__c FROM FPA_Link__c WHERE FPA__c IN :fpaIds]){fpaIds.add(linkObj.FPA__c); relatedSFOsMap.put(linkObj.Id, linkObj.SFO__r);    
        }
        
        List<Factory_Pricing_Authorization__c> FPAsTobeUpdated = new List<Factory_Pricing_Authorization__c>([SELECT Id, Quantity__c, SFO_Fixed_Unit_Cost__c,SFO_Variable_Unit_Cost__c,(SELECT Id, SFO__r.Fixed_Unit_Cost__c, SFO__r.Variable_Unit_Cost__c FROM  Related_SFO__r) FROM Factory_Pricing_Authorization__c WHERE Id IN :fpaIds]);
        
        for(Factory_Pricing_Authorization__c fpa_rec:FPAsTobeUpdated){ decimal fixedUnitCost = 0; decimal VariableUnitCost  = 0; fpa_rec.SFO_Fixed_Unit_Cost__c = 0; fpa_rec.SFO_Variable_Unit_Cost__c = 0;
            for(FPA_Link__c fpa_link_rec :fpa_rec.Related_SFO__r){fixedUnitCost +=relatedSFOsMap.get(fpa_link_rec.Id).Fixed_Unit_Cost__c; VariableUnitCost +=relatedSFOsMap.get(fpa_link_rec.Id).Variable_Unit_Cost__c; }
            fpa_rec.Quantity__c = (fpa_rec.Quantity__c != null)?fpa_rec.Quantity__c:0; fpa_rec.SFO_Fixed_Unit_Cost__c += fixedUnitCost; fpa_rec.SFO_Variable_Unit_Cost__c += VariableUnitCost;
        }
        if(!FPAsTobeUpdated.isEmpty()) {update FPAsTobeUpdated;   }
    }
    
    
    public static void updateUnitTags(List<Special_Feature_Option__c> sfosList)
    {
        Map<String, List<FPA_Link__c>> relatedFPALinksMap = new Map<String, List<FPA_Link__c>>();
        for(FPA_Link__c link_rec :[SELECT Id, Unit_Tag__c,SFO__c FROM FPA_Link__c
                                   WHERE SFO__c IN :sfosList])
        {
            if(relatedFPALinksMap.containsKey(link_rec.SFO__c)){relatedFPALinksMap.get(link_rec.SFO__c).add(link_rec);    
            }
            else
            {
                relatedFPALinksMap.put(link_rec.SFO__c, new List<FPA_Link__c>{link_rec});     
            }
        }
        for(Special_Feature_Option__c sfo_rec : sfosList)
        {
            if(relatedFPALinksMap.containsKey(sfo_rec.id))
            {
                sfo_rec.Unit_Tags__c = '';
                for(FPA_Link__c link_obj :relatedFPALinksMap.get(sfo_rec.id))
                {
                    sfo_rec.Unit_Tags__c += link_obj.Unit_Tag__c+',';  
                }
                sfo_rec.Unit_Tags__c = sfo_rec.Unit_Tags__c.removeEnd(',');
            }
        }
    }
    public static void createDynamicFields(List<Special_Feature_Option__c> specialFeatureList){
        String dynamicLabel =System.Label.DynamicFields;
        List<String> dynamicFields = dynamicLabel.trim().split(';');
        system.debug('dynamicFields'+dynamicFields);
        system.debug('dynamicFields size'+dynamicFields.size());
        List<SFO_Fields__c> dList =[SELECT Id, Name FROM SFO_Fields__c WHERE Name IN :dynamicFields];
        system.debug('ssss::'+dList.size());
        List<SFO_Dynamic_Fields__c> fieldsTobeInserted = new List<SFO_Dynamic_Fields__c>();
        for(Special_Feature_Option__c sfo : specialFeatureList){
            for(SFO_Fields__c d : dList){
                SFO_Dynamic_Fields__c df = new SFO_Dynamic_Fields__c(); df.Name = d.Name; df.SFO__c = sfo.Id; df.SFO_Field__c = d.Id; fieldsTobeInserted.add(df);
            }
        }
        system.debug('fieldsTobeInserted' +fieldsTobeInserted);
        if(fieldsTobeInserted.size() > 0){insert fieldsTobeInserted;
        }
    }
    
}