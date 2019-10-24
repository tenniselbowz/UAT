global class CreateTaskEmail implements Messaging.InboundEmailHandler 
{
    
    global Messaging.InboundEmailResult  handleInboundEmail(Messaging.inboundEmail email, 
                                                            Messaging.InboundEnvelope env)
    {
        System.debug('inside method');
        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
       
        
        String myPlainText= ''; 
        
        // Store the email plain text into the local variable 
        myPlainText = email.plainTextBody;
            System.debug('myPlainText'+myPlainText);
        String subject = email.subject;
            System.debug('subject'+subject);
        String fromAddress = email.fromAddress;
            System.debug('fromAddress'+fromAddress);
        String FPA_number = subject.substringAfter('for').trim();
            System.debug('FPA_number@@@'+FPA_number);
        boolean Approvalstatus;
      //  boolean Approvalstatus = false;
        if(!myPlainText.startsWith('Dear'))
        {
            if(myPlainText.contains('Dear'))
                myPlainText=myPlainText.split('Dear')[0];            
            system.debug('myPlainText ' + myPlainText);
            
            if(myPlainText.containsIgnoreCase('APPROVED') || myPlainText.containsIgnoreCase('APPROVE'))
            {
                Approvalstatus = True;    
            }
            else if(myPlainText.containsIgnoreCase('REJECTED') || myPlainText.containsIgnoreCase('REJECT'))
            { 
                Approvalstatus = False;     
            }
        }
        list<Factory_Pricing_Authorization__c> fpaList = new list<Factory_Pricing_Authorization__c>(
            [select id,FPA_Number__c,Base_Unit_to_be_Modified__c from Factory_Pricing_Authorization__c where FPA_Number__c =: FPA_number]);
        Factory_Pricing_Authorization__c fpa = new Factory_Pricing_Authorization__c();
        system.debug('fpa'+fpaList); 
        if(fpaList.size()>0){
            fpa =  fpaList[0];                 
        }  
        
        list<FPA_Approvers__c> apprList = new list<FPA_Approvers__c>(
            [select id,Email__c,Status__c from FPA_Approvers__c where Email__c =: fromAddress AND  FPA__c =:fpa.id AND Status__c ='Sent']);
        FPA_Approvers__c appr = new FPA_Approvers__c();
        system.debug('appr'+apprList); 
        if(apprList.size()>0){
            appr =  apprList[0];   
            if(Approvalstatus == null){
             	return null;   
            }
			appr.Status__c = (Approvalstatus)?'Approved':'Rejected';
            update appr;
        }
            system.debug(appr);

        return result;
    }
}