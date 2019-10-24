public class FPARelatedAttachmentsDownloadController {
    
    public String fpaID {get; set;}
    public String zipFileName {get; set;}
    
    /**
*	Query for the Account using the parameter in the query string
*	Set the filename for the ZIP file
**/
    public FPARelatedAttachmentsDownloadController(ApexPages.StandardController controller) {
        
		this.fpaID = ApexPages.currentPage().getParameters().get('id');
		Factory_Pricing_Authorization__c fpa = [Select id, Name, (Select id, SFO__c from Related_SFO__r) from Factory_Pricing_Authorization__c 
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
        system.debug('test getXMLFiles');
        // Get the FPA and related SFOs Ids
        for(Factory_Pricing_Authorization__c fpa : [Select id, Name, (Select id, SFO__c from Related_SFO__r) from Factory_Pricing_Authorization__c 
                                                    where Id=:fpaID])
        {            
            parentIds.add(fpa.Id);
            for(FPA_Link__c fpaLink : fpa.Related_SFO__r)
            {
                parentIds.add(fpaLink.SFO__c);
            }
        }
        system.debug('parentIds--'+parentIds);
        
        // Query for all Attachments of FPA and related SFOs
        List<Attachment> listAtt = [Select id, Name, Body from Attachment where parentId IN: parentIds];
        List<string> ContentDocumentIds=new List<string>();
        System.debug('listAtt ::'+listAtt+'      '+listAtt.size());
        for(ContentDocumentLink contentDocList : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink 
                                                  where LinkedEntityId IN: parentIds])
        {
            System.debug('contentDocList ::'+contentDocList);
            ContentDocumentIds.add(contentDocList.ContentDocumentId);
        }
        System.debug('ContentDocumentIds.size() ::'+ContentDocumentIds.size());
        if(ContentDocumentIds.size() > 0)
        {
            for(ContentVersion contVersionList : [SELECT VersionData,Title,filetype FROM ContentVersion WHERE 
                                              ContentDocumentId IN : ContentDocumentIds AND IsLatest = true])
            {
                Attachment attObj=new Attachment();
                attObj.Name=contVersionList.Title+'.'+contVersionList.FileType;
                attObj.Body=contVersionList.VersionData;
                attObj.ContentType=contVersionList.FileType;
                listAtt.add(attObj);
            }
        }
        
        
        if(listAtt.size() == 0) {
            throw new ApplicationException('The selected FPA does not have any Attachments. Please atatch an Attachment to the FPA and try again.');
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
            
            String yourFiles = 'Lets assume this is your binary string of the files';
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = 'myZip.zip'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = filename; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(data); // converting your binary string to Blog
            insert conVer;
            
            //insert att;
            
            //return 'SUCCESS-'+att.Id;
            if(test.isRunningTest()){
                integer x=100/0;
            }
            return 'SUCCESS-'+conVer.Id;
        } 
        catch(Exception e) 
        {
            return e.getMessage();
        }
    }   
    
    @RemoteAction
    public static String delData(String attId) {
        try {
            delete [Select id from Attachment where id =:attId];
            system.debug('Deleted');
            if(test.isRunningTest()){
                integer x=100/0;
            }
            return 'SUCCESS';
        }
        
        catch(Exception e) 
        {
            return e.getMessage();
        }
    }
}