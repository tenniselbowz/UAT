public class SendEmailFPARelatedAttachmentsController {
    
    public String fpaID {get; set;}
    public String zipFileName {get; set;}
    public List<string> ContentDocumentIds {get; set;}
    /**
*	Query for the Account using the parameter in the query string
*	Set the filename for the ZIP file
**/
    public SendEmailFPARelatedAttachmentsController(ApexPages.StandardController controller) {
        
        this.fpaID = ApexPages.currentPage().getParameters().get('id');
        Factory_Pricing_Authorization__c fpa = [Select 
                                                id, 
                                                Name, 
                                                Application_Engineer__c, 
                                                (Select id, 
                                                 SFO__c from Related_SFO__r)
                                                from 
                                                Factory_Pricing_Authorization__c 
                                                where Id=:fpaID];
        // Set the zip's filename to be formatted like "AccountName-2016-3-10.zip"
        this.zipFileName = fpa.Name + '-';
        Date d = Date.today();
        
        this.zipFileName += d.month() + '-' + d.day() +'-'+ d.year() + '.zip';
    }
    
    /**
*	Used for manually throwing errors back to the Visualforce page
*	Usage: throw new ApplicationException('This is the error message');
**/
    public class ApplicationException extends Exception {}
    
    /**
*	Primary function that initiates XML document creation.
*	Data is grouped by Opportunity into individual XML documents,
*	and within each file the Opportunity's data is displayed.
**/
    @RemoteAction
    public static Map<String, String> getXMLFiles(String fpaID) {
        
        List<String> parentIds = new List<String>();
        //List<String> UnitDetailIds = new List<String>();
        
        system.debug('test getXMLFiles');
        // Get the FPA and related SFOs Ids
        
        
        for(Factory_Pricing_Authorization__c fpa : [Select id, 
                                                    Name, 
                                                    (Select id, SFO__c from Related_SFO__r) 
                                                    from
                                                    Factory_Pricing_Authorization__c 
                                                    where Id=:fpaID])
        {            
            parentIds.add(fpa.Id);
            for(FPA_Link__c fpaLink : fpa.Related_SFO__r)
            {
                parentIds.add(fpaLink.SFO__c);
            }
        }
        system.debug('parentIds--'+parentIds);
        
        /*
for(Factory_Pricing_Authorization__c fpa : [Select Id, Name, (Select id, SFO__c from Related_SFO__r) from Factory_Pricing_Authorization__c 
where Id =: fpaID])
{            
parentIds.add(fpa.Id);
for(FPA_Link__c fpaLink : fpa.Related_SFO__r)
{
parentIds.add(fpaLink.SFO__c);
//UnitDetailIds.add(fpaLink.id);

}
//System.debug('UnitDetailIds :: '+UnitDetailIds);
//System.debug('UnitDetailIds Size:: '+UnitDetailIds.size());
/*for(Related_SFO__c	r: [SELECT Id, Name, SFO__c, Unit_Detail__c, Parent_Name__c FROM Related_SFO__c where Unit_Detail__c IN :UnitDetailIds]){
parentIds.add(r.SFO__c);
}
}*/
        system.debug('parentIds--'+parentIds);
        system.debug('parentIds-- size'+parentIds.size());
        
        // Query for all Attachments of FPA and related SFOs
        List<Attachment> listAtt = [Select id, Name, Body from Attachment where parentId IN: parentIds];
        List<String> ContentDocumentIds = new List<String>();
        for(ContentDocumentLink contentDocList : [SELECT Id, 
                                                  LinkedEntityId,
                                                  ContentDocumentId 
                                                  FROM ContentDocumentLink 
                                                  where LinkedEntityId IN: parentIds])
        {
            ContentDocumentIds.add(contentDocList.ContentDocumentId);
        }
        System.debug('ContentDocumentIds ::'+ContentDocumentIds);
        List<ContentVersion> contentList = new List<ContentVersion>();
        if(ContentDocumentIds.size() > 0)
        {
            for(ContentVersion contVersionList : [SELECT VersionData,Title,
                                                  filetype FROM ContentVersion WHERE 
                                                  ContentDocumentId IN : ContentDocumentIds 
                                                  AND IsLatest = true])
            {
                Attachment attObj = new Attachment();
                attObj.Name = contVersionList.Title+'.'+contVersionList.FileType;
                attObj.Body = contVersionList.VersionData;
                attObj.ContentType = contVersionList.FileType;
                listAtt.add(attObj);
                contentList.add(contVersionList);
            }
        }
        
        // Setup map to contain all results from this method. Will contain the generated XML files and a list of Opportunities that were used in the process.
        Map<String, String> resultsData = new Map<String, String>();
        
        // Create the XML body and filename for each Opportunity
        for(Attachment att : listAtt)
        {
            resultsData.put(att.Name, EncodingUtil.base64Encode(att.Body));
        }
        
        return resultsData;
    }
    
    /**
*	Remote Action method to save the ZIP file as an attachment
*	Set the ParentId to connect it to a specific record (the Account in this case)
**/
    @RemoteAction
    public static String saveData(String recordId, String filename, String data) {
        try {
            Attachment att = new Attachment(
                Name = filename,
                Body = EncodingUtil.base64Decode(data),
                ParentId = recordId
            );
            
            System.debug('data :: '+data);
            System.debug('Body :: '+EncodingUtil.base64Decode(data));
            String yourFiles = 'Lets assume this is your binary string of the files';
            
            if(data == null || data == ''){sendEmailMethod(null, recordId); return 'SUCCESS-';
            }
            else{
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                conVer.PathOnClient = 'myZip.zip'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = filename; // Display name of the files
                conVer.VersionData = EncodingUtil.base64Decode(data); // converting your binary string to Blog
                insert conVer;
                
                sendEmailMethod(conVer.Id, recordId);
                
                System.debug('conVer :: '+conVer);
                return 'SUCCESS-'+conVer.Id;
            }
        } 
        catch(Exception e) {return e.getMessage();}
    }
    
    public static void sendEmailMethod(String conId, String fpaID){
        
        User u = [Select Id, Name, CompanyName From User WHERE Id =: UserInfo.getUserId()];
        EmailTemplate template = [Select Id, Name, Body From EmailTemplate WHERE DeveloperName =: 'FPA_External_Summary_Template'];
        Factory_Pricing_Authorization__c targetObjId = [SELECT Name, Id, OwnerId, Sales_Person__r.Email__c, 
                                                        Sales_Person__r.Name FROM Factory_Pricing_Authorization__c WHERE Id =: fpaID];
        List<Factory_Pricing_Authorization__c> fpaRecList = [SELECT Name, Id, Sales_Person__r.Email__c,
                                                             Application_Engineer__r.Email FROM Factory_Pricing_Authorization__c WHERE Id =: fpaID];
        
        List<String> toEmailAddresses = new List<String>();
        for(Factory_Pricing_Authorization__c fpaRec : fpaRecList)
        {
            toEmailAddresses.add(fpaRec.Application_Engineer__r.Email);
            System.debug('fpaRec.Application_Engineer__r.Email ::: '+fpaRec.Application_Engineer__r.Email);
        }
        System.debug('fpaID is :: '+fpaID);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toEmailAddresses);
        mail.setWhatId(targetObjId.Id);
        mail.setTemplateId(template.Id);
        mail.setTargetObjectId(u.Id);
        mail.setSaveAsActivity(false);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (ContentVersion cversion : [SELECT Title, PathOnClient, 
                                        FileType, versiondata 
                                        FROM contentversion 
                                        WHERE Id =: conId]) 
        {
            blob WOCFbody = cversion.versiondata; 
            system.debug('body : '+WOCFbody+'-----------'+cversion.title); 
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(cversion.title+'.'+cversion.FileType);
            efa.setBody(WOCFbody); 
            fileAttachments.add(efa);
            System.debug('fileAttachments :: '+fileAttachments);
            mail.setFileAttachments(fileAttachments);
            System.debug('fileAttachments ::'+fileAttachments);
            System.debug('fileAttachments Size::'+fileAttachments.size());
            
        }
        System.debug('mail :: '+mail);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        Messaging.sendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('Email Result :: '+results);
        
        if(results[0].success == true){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your Mail has been sent successsfully');
            ApexPages.addMessage(myMsg);
            System.debug('myMsg :: '+myMsg);
        }
    } 
    @RemoteAction
    public static String delData(String attId) {
        try {
            delete [Select id from Attachment where id =:attId];
            system.debug('Deleted');
            return 'SUCCESS';
        }
        
        catch(Exception e) {return e.getMessage();}
    }
}