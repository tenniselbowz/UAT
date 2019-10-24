public class OptionsAttachmentsRelatedToSF {
    // public List<Attachment> SFAttachment {get;set;}
    public List<wrapSfoOption> wrapSfoOptionList{get;set;}
    public List<ContentDocumentLink> OptionFilesList {get;set;}
    public Special_Feature_Option__c CurrentPage{set;get;}
    public Id currenpageId {set;get;}
    public OptionsAttachmentsRelatedToSF(ApexPages.StandardController stdController) {
        this.CurrentPage = (Special_Feature_Option__c)stdController.getRecord();
        id currenpageId = CurrentPage.Id;
        System.debug('CurrentPage ::'+CurrentPage.id);
        Id devOptRecordTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName().get('Option').getRecordTypeId();
        if(CurrentPage.RecordTypeId==devOptRecordTypeId){
            Special_Feature_Option__c OptionRecord =[SELECT Id,RecordTypeId,Option_Parent__c FROM Special_Feature_Option__c where id= :CurrentPage.id];
            SFOMethod(OptionRecord.Option_Parent__c);
        }
        else{
            SFOMethod(currenpageId);
        }
    }
    public void SFOMethod(id currenpageId){
        Map<id,String> SFOptionidsNames = new  Map<id,String>();
        OptionFilesList =new List<ContentDocumentLink>();
        wrapSfoOptionList= new List<wrapSfoOption>();
        List<Attachment> SFOptionAttachments = new List<Attachment>();
        //id currenpageId = ApexPages.currentPage().getParameters().get('id');
        if( currenpageId != null) {
            Id devRecordTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName().get('Special_Feature_Option').getRecordTypeId();
            System.debug(devRecordTypeId);
            Special_Feature_Option__c SFRecord = [SELECT Id, Name,Name__c, RecordTypeId, Parent_SFO__c, Option_Parent__c, Special_Feature_Parent__c FROM Special_Feature_Option__c where id =:currenpageId And RecordTypeId= :devRecordTypeId];
            SFOptionidsNames.put(SFRecord.id,SFRecord.Name__c);
            List<Special_Feature_Option__c> OptionRecords =[SELECT Id, Name,Name__c, RecordTypeId, Parent_SFO__c, Option_Parent__c, Special_Feature_Parent__c FROM Special_Feature_Option__c where Option_Parent__c=:SFRecord.id];
            for(Special_Feature_Option__c optionid: OptionRecords){
                SFOptionidsNames.put(optionid.id,optionid.Name__c);
            }     
            /*SFAttachment = [SELECT Id, ParentId, Name FROM Attachment where ParentId In :SFOptionids];
System.debug('SFAttachment ::'+SFAttachment);
System.debug('SFAttachment Size::'+SFAttachment.size());*/
            List<ContentDocumentLink> OptionFiles = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                                                     ContentDocument.Title From ContentDocumentLink where LinkedEntityId IN : SFOptionidsNames.keySet()];
            String yourFiles = 'Lets assume this is your binary string of the files';
            
            for(ContentDocumentLink c: OptionFiles){
                System.debug('OptionFiles ::'+c.ContentDocument.title);
                wrapSfoOption w = new wrapSfoOption(c,SFOptionidsNames.get(c.LinkedEntityId));
                wrapSfoOptionList.add(w);
            }
            System.debug('OptionFiles ::'+OptionFiles);
            System.debug('OptionFiles.size ::'+OptionFiles.size());
        }
    }
    public class wrapSfoOption{
        public ContentDocumentLink ConLinkDoc {get; set;}
        public String Name {get; set;}
        // public Integer Numberr {get; set;}
        public wrapSfoOption(ContentDocumentLink c,String n) {
            ConLinkDoc = c;
            Name = n;
            //Numberr=num;
        }
    }
}