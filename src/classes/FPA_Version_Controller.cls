public class FPA_Version_Controller {
    public static String FPA_Id;
    public FPA_Version_Controller()
    {
        FPA_Id = ApexPages.currentPage().getParameters().get('id');   
    }
    public static pagereference redirectToFPACreation()
    {
        /*Factory_Pricing_Authorization__c FPA_rec = [SELECT id, Parent_FPA__r.name, Name FROM Factory_Pricing_Authorization__c
        WHERE Id =:FPA_Id];
        String parentFPAName =(FPA_rec.Parent_FPA__r.name != null)?FPA_rec.Parent_FPA__r.name:FPA_rec.Name;
        String parentFPA_componentId = 'CF00N0t000000nRIK';
        return new pagereference('/'+FPA_Id+'/e?clone=1&'+parentFPA_componentId+'='+parentFPAName+'&retURL='+FPA_Id); */
        return new pagereference('/apex/FPA_Creation?Id='+FPA_Id+'&version=1&retUrl=/'+FPA_Id);
        
    }
    public static void createFPA_ChildRecords(String FPA_Id)
    {
        String FPA_Query = UtilityClass.getSObjectFields(
            'Factory_Pricing_Authorization__c', 'Id =:FPA_Id AND Parent_FPA__c != null', true);
        Factory_Pricing_Authorization__c FPA_record = database.query(FPA_Query);
        List<Factory_Pricing_Authorization__c> FPA_List = new List<Factory_Pricing_Authorization__c>();
        FPA_List.add(FPA_record);
        try{
            set<String> parent_FPA_ids = new set<String>();
            for(Factory_Pricing_Authorization__c fpa_rec :FPA_List)
            {
                parent_FPA_ids.add(fpa_rec.Parent_FPA__c);	    
            }
            Map<String, List<Estimate__c>> estimateMap = new Map<String, List<Estimate__c>>();
            String estimate_Query =  UtilityClass.getSObjectFields(
                'Estimate__c', 'FPA__c IN :parent_FPA_ids', true);
            for(Estimate__c estimate_Rec : Database.query(estimate_Query))
            {
                if(estimateMap.containsKey(estimate_Rec.FPA__c))
                {
                    estimateMap.get(estimate_Rec.FPA__c).add(estimate_Rec);  
                }else{
                    estimateMap.put(estimate_Rec.FPA__c, new List<Estimate__c>{estimate_Rec});    
                }
            }
            Map<String, List<Attachment>> FPA_attachmentsmap = new Map<String, List<Attachment>>();
            Map<String, List<ContentDocumentLink>> FPA_contentmap = new Map<String, List<ContentDocumentLink>>();
            
            for(Attachment attachment_Obj :[SELECT Id, Name, ContentType, Body, Description, ParentId 
                                            FROM Attachment WHERE ParentId IN :parent_FPA_ids])
            {
                if(FPA_attachmentsmap.containsKey(attachment_Obj.ParentId))
                {
                    FPA_attachmentsmap.get(attachment_Obj.ParentId).add(attachment_Obj);   
                }
                else
                {
                    FPA_attachmentsmap.put(attachment_Obj.ParentId, new List<Attachment>{attachment_Obj});      
                }
            } 
            
            for(ContentDocumentLink contentDocRec : [SELECT Id,LinkedEntityId,ContentDocumentId,ShareType
                                                         FROM ContentDocumentLink 
                                                          where LinkedEntityId IN :parent_FPA_ids])
            {
                if(FPA_contentmap.containsKey(contentDocRec.LinkedEntityId))
                {
                    FPA_contentmap.get(contentDocRec.LinkedEntityId).add(contentDocRec);   
                }
                else
                {
                    FPA_contentmap.put(contentDocRec.LinkedEntityId, new List<ContentDocumentLink>{contentDocRec});      
                }
            } 
            
            Map<String, List<FPA_Link__c>> fpaLinkMap = new Map<String, List<FPA_Link__c>>();
            String fpalink_Query =  UtilityClass.getSObjectFields(
                'FPA_Link__c', 'FPA__c IN :parent_FPA_ids', true);
            for(FPA_Link__c fpaLink_Rec : Database.query(fpalink_Query))
            {
                if(fpaLinkMap.containsKey(fpaLink_Rec.FPA__c))
                {
                    fpaLinkMap.get(fpaLink_Rec.FPA__c).add(fpaLink_Rec);  
                }else{
                    fpaLinkMap.put(fpaLink_Rec.FPA__c, new List<FPA_Link__c>{fpaLink_Rec});    
                }
            }
            List<Estimate__c> newEstimatesList = new List<Estimate__c>();
            List<Attachment> newAttachmentList = new List<Attachment>();
            List<ContentDocumentLink> contentDocList =new List<ContentDocumentLink>();
            List<FPA_Link__c> newFPAlinkList = new List<FPA_Link__c>();
            
            for(Factory_Pricing_Authorization__c fpa_obj :FPA_List)
            {
                if(estimateMap.containsKey(fpa_obj.Parent_FPA__c))
                {
                    for(Estimate__c estimate_obj :estimateMap.get(fpa_obj.Parent_FPA__c))
                    {
                        Estimate__c newEstimate = new Estimate__c();
                        newEstimate = estimate_obj.clone(false,true);
                        newEstimate.FPA__c = fpa_obj.Id;
                        newEstimatesList.add(newEstimate);    
                    }
                    
                }
                if(FPA_attachmentsmap.containsKey(FPA_obj.Parent_FPA__c))
                {
                    for(Attachment attachment_rec :FPA_attachmentsmap.get(FPA_obj.Parent_FPA__c))
                    {
                        Attachment new_Attachment = new Attachment();
                        new_Attachment.name = attachment_rec.Name;
                        new_Attachment.ContentType = attachment_rec.ContentType;
                        new_Attachment.Body = attachment_rec.Body;
                        new_Attachment.Description = attachment_rec.Description;
                        new_Attachment.ParentId = fpa_obj.Id;
                        newAttachmentList.add(new_Attachment);   
                    }
                    
                }
                if(FPA_contentmap.containsKey(FPA_obj.Parent_FPA__c))
                {
                    for(ContentDocumentLink contentDocRec :FPA_contentmap.get(FPA_obj.Parent_FPA__c))
                    {
                        ContentDocumentLink contentDocumentLinkObj=new ContentDocumentLink();
                        contentDocumentLinkObj.ContentDocumentId=contentDocRec.ContentDocumentId;
                        contentDocumentLinkObj.LinkedEntityId=fpa_obj.Id;
                        contentDocumentLinkObj.ShareType=contentDocRec.ShareType;
                        contentDocList.add(contentDocumentLinkObj);
                    }
                }
                if(fpaLinkMap.containsKey(fpa_obj.Parent_FPA__c))
                {
                    for(FPA_Link__c fpaLink_obj :fpaLinkMap.get(fpa_obj.Parent_FPA__c))
                    {
                        FPA_Link__c newfpaLink = new FPA_Link__c();
                        newfpaLink = fpaLink_obj.clone(false,true);
                        newfpaLink.FPA__c = fpa_obj.Id;
                        newFPAlinkList.add(newfpaLink);    
                    }
                    
                }
                
            }
            if(newEstimatesList.size() > 0)
            {
                insert  newEstimatesList;   
            }
            if(newAttachmentList.size() > 0)
            {
                insert newAttachmentList;    
            }  
            if(contentDocList.size() > 0)
            {
             	insert contentDocList;   
            }
            if(newFPAlinkList.size() >0)
            {
            	insert newFPAlinkList;    
            }
            
        }
        catch(Exception e)
        {
            System.debug('Errror In SFO_Trigger_Handler::'+e.getMessage());   
        }
        
    }
    
}