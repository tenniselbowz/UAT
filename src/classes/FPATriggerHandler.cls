public class FPATriggerHandler {
    public string fpaId{get;set;}
    public Factory_Pricing_Authorization__c FPAObj;
    public  String missed_approvals{get;set;}
    public Integer approversCount = 0;
    
    public FPATriggerHandler(ApexPages.StandardController stdController)
    { 
       //fpaId = ApexPages.currentPage().getParameters().get('id');
        
        fpaId = stdController.getId();
                  System.debug('FpaID  ::'+fpaId);
        String FPA_Query = UtilityClass.getSObjectFields('Factory_Pricing_Authorization__c', 
                                                         ' Id = : fpaId', true);
        System.debug('Query ....'+FPA_Query);
        FPAObj=database.query(FPA_Query);
        
        missed_approvals = 'Submittted for Approval';
    }
    
    public  void performApprovals()
    {
        
        System.debug('Id'+fpaId);
        Map<String,Factory_Pricing_Authorization__c> FPAMap = new Map<String,Factory_Pricing_Authorization__c>([SELECT Id, Name, OwnerId,FPA_Number__c, Entry_Date__c, Base_Unit_to_be_Modified__c,
                                                                                                                Approval_Level__c, Status__c
                                                                                                                FROM Factory_Pricing_Authorization__c
                                                                                                                where id = :fpaId]);
        
        System.debug('FPAMap :::'+FPAMap);
        set<String> FPA_ApprovalStatus = new set<String>();
        set<String> FPA_formatIds = new set<String>();
        Map<String, set<String>> FormatToApprovalEmails = new Map<String, set<String>>();
        Map<String, set<String>> FPAIdToApprovalEmails = new Map<String, set<String>>();
        Map<String,String> approverEmailToName = new Map<String,String>();
        
        for(Factory_Pricing_Authorization__c fpaRec :FPAMap.values())
        {
            FPA_formatIds.add(fpaRec.Base_Unit_to_be_Modified__c);
            if(fpaRec.Approval_Level__c != null)
            {
                FPA_ApprovalStatus.add(fpaRec.Approval_Level__c);
            }
            else
            {
                missed_approvals = 'Approval level is not defined on FPA. Please define an Aprroval level and resubmit';
            }
        }
        String approver_filter = 'Format__c IN :FPA_formatIds';
        
        system.debug('FPA_ApprovalStatus ' + FPA_ApprovalStatus);
        if(FPA_ApprovalStatus.size() > 0){
            List<String> filters = new List<String>();
            approver_filter += ' AND (';
            if(FPA_ApprovalStatus.contains('A')){
                filters.add(' A__c = true  ');    
            }
            if(FPA_ApprovalStatus.contains('B')){
                filters.add(' B__c = true  ');    
            }
            if(FPA_ApprovalStatus.contains('C')){
                filters.add(' C__c = true  ');    
            }
            if(FPA_ApprovalStatus.contains('D')){
                filters.add(' D__c = true  ');    
            }
            System.debug('filters::'+filters);
            String whereClause = '';
            for(Integer i=0; i<filters.size();i++){
                if(i == 0 ){
                    whereClause += filters[i];    
                }else{
                    whereClause += ' OR '+filters[i];     
                }
                
            }
            
            System.debug('whereClause::'+whereClause);
            approver_filter +=whereClause+' )';
        }
        
        String approvers_Query = UtilityClass.getSObjectFields('FPA_Approval__c',
                                                               approver_filter,
                                                               true);
        System.debug('approvers_Query::'+approvers_Query);
        List<FPA_Approval__c> Format_Approvers = new List<FPA_Approval__c>();
        //Format_Approvers_dupe = new List<FPA_Approval__c>();
        Format_Approvers = Database.query(approvers_Query);
        //Format_Approvers_dupe = Format_Approvers;
        //System.debug('Format_Approvers_dupe :: '+Format_Approvers_dupe);
        //System.debug('Format_Approvers::'+Format_Approvers.size());
        /* if(Format_Approvers.size() == 0){
missed_approvals = 'No Approvers Found.';  
return;
}*/
        if(Format_Approvers.size() == 0){
        	return;    
        }
        else
        {
            approversCount = Format_Approvers.size();
        }
        for (FPA_Approval__c  approvalRec :Format_Approvers)
        {
            approverEmailToName.put(approvalRec.Email__c, approvalRec.Name);
            if(approvalRec.A__c){
                FormatToApprovalEmails = getFormatToApprovalEmails(FormatToApprovalEmails,
                                                                   approvalRec.Format__c+'-A', approvalRec.Email__c);
            }
            if(approvalRec.B__c){
                FormatToApprovalEmails = getFormatToApprovalEmails(FormatToApprovalEmails,
                                                                   approvalRec.Format__c+'-B', approvalRec.Email__c);    
            }
            if(approvalRec.C__c){
                FormatToApprovalEmails = getFormatToApprovalEmails(FormatToApprovalEmails,
                                                                   approvalRec.Format__c+'-C', approvalRec.Email__c);    
            }
            if(approvalRec.D__c){
                FormatToApprovalEmails = getFormatToApprovalEmails(FormatToApprovalEmails,
                                                                   approvalRec.Format__c+'-D', approvalRec.Email__c);    
            }
            
        }
        System.debug('*********'+approverEmailToName);
        for(Factory_Pricing_Authorization__c fpaRec: FPAMap.values()){
            String key = fpaRec.Base_Unit_to_be_Modified__c+'-'+fpaRec.Approval_Level__c;
            if(FormatToApprovalEmails.containsKey(key)){
                for(String emailId :FormatToApprovalEmails.get(key)){
                    if(FPAIdToApprovalEmails.containsKey(fpaRec.Id)){
                        FPAIdToApprovalEmails.get(fpaRec.Id).add(emailId);      
                    }else{
                        FPAIdToApprovalEmails.put(fpaRec.Id, new set<String>{emailId});    
                    }    
                }
                System.debug('FPAIdToApprovalEmails1'+FPAIdToApprovalEmails);
            }    
        }
        /*if(Format_Approvers.size() == 0){
missed_approvals = 'No Approvers Found.';  
return;
}*/
        System.debug('FPAIdToApprovalEmails2::'+FPAIdToApprovalEmails);
        System.debug('approverEmailToName::'+approverEmailToName);
         System.debug('FPAMap::'+FPAMap);
          System.debug('FPAId::'+fpaId);
        
        sendApprovalEmail(FPAIdToApprovalEmails, approverEmailToName, FPAMap,fpaId);
        System.debug('ForMat Approvers::'+Format_Approvers);
        createApprovalRecords(Format_Approvers,fpaId);
        
    }
    public  Map<String, set<String>> getFormatToApprovalEmails(Map<String, set<String>> FormatToApprovalEmails,
                                                               String key, String email)
    {
        if(FormatToApprovalEmails.containsKey(key)){
            FormatToApprovalEmails.get(key).add(email);    
        }else{
            FormatToApprovalEmails.put(key, new set<String>{email});    
        }
        return FormatToApprovalEmails;
    }
    
    
    public  void sendApprovalEmail(Map<String, set<String>> FPA_to_EmailIds, Map<String,String> emailToUserName,
                                   Map<String,Factory_Pricing_Authorization__c> FPAMap, String fpaId){
                                       
                                       EmailHandler.sendEmail(FPA_to_EmailIds, emailToUserName, 'FPA_Approval_Request_Email_Template', FPAMap,fpaId);
                                   }
    
    public void createApprovalRecords(List<FPA_Approval__c> Format_Approvers,String fpaId){
        List<FPA_Approvers__c> FPA_Approvers = new List<FPA_Approvers__c>(); 
        for (FPA_Approval__c  approvalRec :Format_Approvers){
            System.debug('Inside Format Approvers::'+Format_Approvers);
            FPA_Approvers__c rec = new FPA_Approvers__c();
            rec.Name = approvalRec.Name;
            rec.Status__c = 'Sent';
            rec.Approved_Date__c = System.now();
            rec.FPA__c = fpaId;
            rec.Email__c = approvalRec.Email__c;
            FPA_Approvers.add(rec);
        }
        insert FPA_Approvers; 
        
    }
    public  pagereference updateFPA_Approval_Status()
    {
        try
        {
            if(missed_approvals == 'Submittted for Approval')
            {
                Id recordTypeId =
                    Schema.SObjectType.Factory_Pricing_Authorization__c.getRecordTypeInfosByDeveloperName()
                    .get('Read_only').getRecordTypeId();
                if(approversCount == 0){
                    FPAObj.Status__c = 'Approved';    
                }else{
                    FPAObj.Status__c = 'Submitted for Approval';	 
                     
                }
               	FPAObj.RecordTypeId = recordTypeId;    
                update FPAObj;
                system.debug('In Update Approval');
                //FPAObj.Status__c = 'Approved';
            } 
           /* else if(Format_Approvers_dupe.size() == 0){
                FPAObj.Status__c = 'Approved';
            }*/
            
        }
        catch(Exception e)
        {
            System.debug('Exception ::'+e.getMessage());    
        }
        
        return new pagereference('/'+FPAObj.id);
    }
}