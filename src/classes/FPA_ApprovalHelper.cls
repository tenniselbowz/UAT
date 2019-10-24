public class FPA_ApprovalHelper {
    
    public static void updateFPAStatus(Map<String, FPA_Approvers__c> approvals){
        set<String> fpaIds = new set<String>();
        
        for(FPA_Approvers__c app :approvals.values()){
            fpaIds.add(app.FPA__c);   
        }
        List<FPA_Approvers__c> FPA_approvals = new List<FPA_Approvers__c>();
        Map<String, List<FPA_Approvers__c>> fpaToApprovals = new Map<String, List<FPA_Approvers__c>>();
        
        String approval_query = UtilityClass.getSObjectFields('FPA_Approvers__c','FPA__c IN :fpaIds Order by LastModifiedDate asc', true);
        FPA_approvals = Database.query(approval_query);
      
        for(FPA_Approvers__c appRec : FPA_approvals){
            if(fpaToApprovals.containsKey(appRec.FPA__c)){
                fpaToApprovals.get(appRec.FPA__c).add(appRec);  
                
            }
            else
            {
                fpaToApprovals.put(appRec.FPA__c, new List<FPA_Approvers__c>{appRec});  
            }
        }
        
        System.debug('fpaToApprovals ::'+fpaToApprovals);
        Map<String, Map<String, String>> fpaApprvMap = new Map<String, Map<String, String>>();
        for(String fpaId : fpaToApprovals.keySet()){
            Map<String, String> fpaApproverToStatus = new Map<String, String>();
            for(FPA_Approvers__c app : fpaToApprovals.get(fpaId)){
            	fpaApproverToStatus.put(app.Name, app.Status__c);    
            }
            fpaApprvMap.put(fpaId, fpaApproverToStatus);
        }
        System.debug('fpaApprvMap :: '+fpaApprvMap);
        
        Map<String, Factory_Pricing_Authorization__c> fpaMap = new Map<String, Factory_Pricing_Authorization__c>(
            [SELECT Id, Status__c FROM Factory_Pricing_Authorization__c WHERE Id IN :fpaIds]);
        List<Factory_Pricing_Authorization__c> fpaToBeUpdated = new List<Factory_Pricing_Authorization__c>();
        System.debug('For Loop');
        System.debug('fpaApprvMap.keySet() ::'+fpaApprvMap.keySet());
        for(String fpaId : fpaApprvMap.keySet()){
            List<String> Status =  fpaApprvMap.get(fpaId).Values(); 
            system.debug('Status ::'+Status);
            Factory_Pricing_Authorization__c fpa = new Factory_Pricing_Authorization__c();
            if(Status.contains('Rejected')){
                if(fpaMap.containsKey(fpaId)){
                    fpa = fpaMap.get(fpaId);  
                    fpa.status__c = 'Rejected';
                    fpa.Comments__c = 'Rejected';
                    fpaToBeUpdated.add(fpa);
                }	    
            }else if(Status.contains('Sent')){
                //blank 
            }else{
                if(fpaMap.containsKey(fpaId)){
                    fpa = fpaMap.get(fpaId);  
                    fpa.status__c ='Approved';
                    fpa.Comments__c = 'Approved';
                    fpaToBeUpdated.add(fpa);
                }    
            }
        }
        system.debug(fpaToBeUpdated);
        if(fpaToBeUpdated.size() > 0){
            update fpaToBeUpdated;    
        }
        system.debug(fpaToBeUpdated);
    }
    
}