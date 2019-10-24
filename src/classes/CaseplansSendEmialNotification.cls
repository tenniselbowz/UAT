/*****************************************
 Author : Solunus
 Last Modified date : 05/30/19
 Description : To send out Email to Case Plan related Cases
*******************************************/
public class CaseplansSendEmialNotification {
    Public string EmailTemplate{get;set;}
    public String planId;
    public boolean disEMailbutton {set;get;}
    public boolean showresult {set;get;}
    public list<string> emialIDofCasePlans{set;get;}
    public Case_Plan__c plan {get;set;}
    public CaseplansSendEmialNotification(ApexPages.StandardController sc){
        showresult=false; // Disable Pageblock section
        emialIDofCasePlans = new list<string>();
        planId = ApexPages.currentPage().getParameters().get('id');
        plan = [Select Id,Email_Templates__c from Case_Plan__c where id =:planId];
        system.debug('planId '+plan);
        disEMailbutton=false;
        
        if(plan.Email_Templates__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please select an Email template on Case Plan');
            ApexPages.addMessage(myMsg);
            disEMailbutton=true;   
        } 
    }
    
    //Send email alerts to Contacts on Cases related to Case Plan
    public  void emialAlert(){
        disEMailbutton=true; //Disable send email button
       // list<Contact> con = [select Name, Email, (select id from Cases)from Contact];
        list<EmailTemplate> templates = new list<EmailTemplate>();
        
        list<case> caseRecords = new list<case>();
        caseRecords = [Select Id,Contact.Email,ContactEmail,Case_Plan__r.Email_Templates__c from Case where Case_Plan__c  = :planId];
        
        templates = [SELECT id,Name FROM EmailTemplate where name = :plan.Email_Templates__c limit 1];//: plan.Email_Temaplte__c           
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<String> emailIds = new List<String>();
        // list<string> emialIDofCasePlans = new list<string>();
        Map<id,String> casewithEmailMap=new Map<id,String>();
        for(case c : caseRecords){
            emailIds.add(c.Contact.Email);
            casewithEmailMap.put(c.id,c.ContactEmail);
            emialIDofCasePlans.add(c.ContactId);
        }
        system.debug('emialIDofCasePlans::'+emialIDofCasePlans.size());
        try{
            Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[0];
            for(Case cs:caseRecords){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(cs.ContactId);
                mail.setwhatid(cs.Id);
                mail.setTemplateId(templates[0].Id);
                mail.setSaveAsActivity(false);
                messages.add(mail);
            }
            if(messages.size()>0){ //Check if the list has values
                Messaging.SendEmailResult [] trs = Messaging.sendEmail(messages,false); 
                String statusCode;
              /*  for(Messaging.SendEmailResult res:trs){
                    if(!res.IsSuccess()){
                        system.debug('Error encountered '+res.errors);
                    }
                } */
                showresult=true;                                 
            }   
        }
        catch(Exception e){
            System.debug('Errrror'+e.getMessage()+e.getLineNumber()+e.getCause());
        }  
    }
    
    //Get the emails result by querying the bounced emails on contacts
    public void getEmailResult(){
        List<String> unvalidEMails=new List<string>();
        List<String> validEMails=new List<string>();
        for(contact cc:[select id,name,email,isemailbounced from contact where id IN : emialIDofCasePlans]){
            if(cc.isemailbounced){
                unvalidEMails.add(cc.Name);}
            else{validEMails.add(cc.name);} 
        }
        
        if(unvalidEMails.size() >0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.Error,'Unsuccessful - Invalid Email(s) on Contacts '+unvalidEMails);
            ApexPages.addMessage(myMsg);}
        if(validEMails.size() >0){
            system.debug('validEMails '+validEMails);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'Email(s) successfully sent to ' +validEMails.size() +'contact(s)');
            ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference cancel() {
        PageReference redirectSuccess = new ApexPages.StandardController(plan).view();
        return (redirectSuccess);
    }
    
}