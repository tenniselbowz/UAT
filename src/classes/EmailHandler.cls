public class EmailHandler {
    
    public static void sendEmail(Map<String, set<String>> FPA_to_EmailIds, Map<String,String> emailToUserName,
                                 String FPA_Approval_Request_Email_Template, 
                                 Map<String,Factory_Pricing_Authorization__c> FPAMap, String fpaId)
    {
        System.debug('FPA_to_EmailIds'+FPA_to_EmailIds);
        PageReference ref = new pageReference('/apex/FPA_Approval_Email_Page?id='+fpaId);//Page.FPA_Approval_Email_Page;
        Blob b;
        if(Test.isRunningTest()) {
            b = blob.valueOf('Unit Test');
        } else {
            b  = ref.getContentAsPDF();
        }
        
        
        List<EmailTemplate> emailTemplateList = Database.query(
            UtilityClass.getSObjectFields('EmailTemplate', 
                                          'DeveloperName =:FPA_Approval_Request_Email_Template', true));
        String emailBody = '';
        Map<String, Messaging.SingleEmailMessage> messages = new Map<String, Messaging.SingleEmailMessage>();
        if(emailTemplateList.size() > 0)
        {
            for(String parentId :FPA_to_EmailIds.keySet()){
                Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplateList[0].Id, UserInfo.getUserId(), parentId) ;
                messages.put(parentId, message);
            }
        }
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        for(String fpaFileName : FPAMap.keyset()){
            efa.setFileName('Daikin FPA - '+(FPAMap.get(fpaFileName)).FPA_Number__c+' - '+(FPAMap.get(fpaFileName)).Name+' - '+(FPAMap.get(fpaFileName)).Entry_Date__c+'.pdf');
        }
        System.debug('efa.setFileName :: '+efa.FileName);
        //efa.setFileName('attachment.pdf');
        efa.setBody(b);
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        String longRoutingEmail = label.FPA_Long_Routing_Email;
        for(String fpaRecId :FPA_to_EmailIds.keySet())
        {
            
            for(String emailId :FPA_to_EmailIds.get(fpaRecId)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                System.debug('emailId::'+emailId);
                mail.setSubject('FPA Approval request for '+FPAMap.get(fpaRecId).FPA_Number__c);
                mail.setSaveAsActivity(false);
                //mail.setTargetObjectId(FPAMap.get(fpaRecId).OwnerId);
                mail.setWhatId(FPAMap.get(fpaRecId).id);
                mail.setToAddresses(new String[] {emailId});
                emailBody = messages.get(fpaRecId).getHtmlBody();
                System.debug('test::'+emailToUserName.get(emailId));
                emailBody = emailBody.replaceAll('ApproverName', emailToUserName.get(emailId)); 
                mail.setHtmlBody(emailBody);
                mail.setCcAddresses(new List<String>{longRoutingEmail});
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                System.debug('toAddress::'+mail.getToAddresses());
                mailList.add(mail);
            }
            
        }
        try
            
        {
            System.debug('mailList::'+mailList.size());
            List<Messaging.SendEmailResult> 
                results = Messaging.sendEmail(mailList,false);
            System.debug('results:: '+results);
        }
        catch(Exception e)
        {
            System.debug('Email Handler Exception::'+e.getMessage());   
        }
        
    }
    /*public static void sendEmail(Map<String, String> toAddresses, String parentId, String FPA_number, String emailTemplate_devName)
{
List<EmailTemplate> emailTemplateList = Database.query(
UtilityClass.getSObjectFields('EmailTemplate', 
'DeveloperName =:emailTemplate_devName', true));
List<Attachment> attachmentList=new List<Attachment>();
if(emailTemplate_devName.contains('SFO'))
{
for(Attachment attachmentObj : [Select id,Name,Body,contentType from Attachment where parentId =: parentId])
{
system.debug('attachmentObj '+ attachmentObj.ContentType);
attachmentList.add(attachmentObj);
}
List<string> ContentDocumentIds=new List<string>();
for(ContentDocumentLink contentDocList : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink 
where LinkedEntityId =: parentId])
{
ContentDocumentIds.add(contentDocList.ContentDocumentId);
}
if(ContentDocumentIds.size() > 0)
{
for(ContentVersion contVersionList : [SELECT VersionData,Title,filetype FROM ContentVersion WHERE 
ContentDocumentId IN : ContentDocumentIds AND IsLatest = true])
{
Attachment attObj=new Attachment();
attObj.Name=contVersionList.Title+'.'+contVersionList.FileType;
attObj.Body=contVersionList.VersionData;
attObj.ContentType=contVersionList.FileType;
attachmentList.add(attObj);
}
}
}

String emailBody = '';
List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
if(emailTemplateList.size() > 0)
{
//mail.setTemplateId(emailTemplateList[0].Id);  
message = Messaging.renderStoredEmailTemplate(emailTemplateList[0].Id, UserInfo.getUserId(), parentId) ;

}
String longRoutingEmail = label.FPA_Long_Routing_Email;
for(String emailId :toAddresses.keySet())
{
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
emailBody = message.getHtmlBody();
//system.debug('emailBody  ' + emailBody);
emailBody = emailBody.replaceAll(UserInfo.getName(), toAddresses.get(emailId)); 
if(emailTemplate_devName.contains('FPA'))
{
mail.setSubject('FPA Approval request for '+FPA_number);
}
else
{
mail.setSubject('SFO Approval request for '+FPA_number);
}
mail.setToAddresses(new String[] {emailId});
mail.setHtmlBody(emailBody);
mail.setCcAddresses(new List<String>{longRoutingEmail});
if(attachmentList.size() > 0)
{
List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
for (Attachment attachObj : attachmentList)
{
Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
efa.setContentType('application/pdf');
efa.setFileName(attachObj.Name);
efa.setBody(attachObj.Body);
fileAttachments.add(efa);
}
mail.setFileAttachments(fileAttachments);
}
mailList.add(mail);
}

try
{
List<Messaging.SendEmailResult> 
results = Messaging.sendEmail(mailList,false);
System.debug('results:: '+results);
}
catch(Exception e)
{
System.debug('Email Handler Exception::'+e.getMessage());   
}


}*/
    
}