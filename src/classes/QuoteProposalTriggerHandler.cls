public class QuoteProposalTriggerHandler {
   public static boolean flag = true;
   public static map<string,string> RecordIdMap = new map<string,string>();
      
    
    //This class concatenates 8 TK clauses and populates a field on the quote.
    public static void concatenateTKClauses(map<Id, Apttus_Proposal__Proposal__c> quoteList, map<Id, Apttus_Proposal__Proposal__c> oldQuoteMap){
      for(RecordTypes__mdt recordType:[select RecordTypeId__c,MasterLabel from RecordTypes__mdt])
        {
            RecordIdMap.put(recordType.MasterLabel, recordType.RecordTypeId__c);
        }
        
        for(Apttus_Proposal__Proposal__c apLoop: quoteList.values()){
            //Need to add 8 turn key product categories ...... Look at Ancester field and examine how many levels have to check to see if the category is matching. Ancestor is a self relationship field.
            
            if(apLoop.Apttus_QPConfig__ConfigurationFinalizedDate__c !=oldQuoteMap.get(apLoop.id).Apttus_QPConfig__ConfigurationFinalizedDate__c && apLoop.RecordTypeID == RecordIdMap.get('North America RecordType'))
            apLoop.Included_Line_Item_Categories__c = '';
        }   
    
        for (Apttus_Proposal__Proposal_Line_Item__c qLI2: [SELECT Id, Apttus_QPConfig__ClassificationId__r.Apttus_Config2__AncestorId__r.Name, Apttus_QPConfig__ClassificationHierarchy__c, Apttus_Proposal__Product__c, Apttus_Proposal__Product__r.name, Apttus_Proposal__Proposal__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c IN:quoteList.Keyset()]){
            system.debug('in second for loop:'+ qLI2.Apttus_Proposal__Product__r.Name);
            if(qLI2.Apttus_QPConfig__ClassificationHierarchy__c != NULL){
                String[] s = qLI2.Apttus_QPConfig__ClassificationHierarchy__c.split(' \\| ', 4);
                System.debug('s1 is'+ s);
               // System.debug('s2 is '+ s[2]);
                System.debug('Size Of String'+s.size());
                    
                    if(((s.size() > 2 && s[2] !=NULL) && (s[2] == 'AC Scroll' || s[2] == 'AC Screw' || s[2] == 'WC Scroll' || s[2] == 'WC Scroll - Heat Recovery' || s[2] == 'WC Screw' || s[2] == 'WC Mag Bearing Cent' || s[2] == 'WC Cent' || s[2] == 'WC Cent - Heat Recovery' || s[2] == 'WC Recip - Heat Recovery' || s[2] == 'RTU' || s[2] == 'AHU' || s[2] == 'Condensing Unit' || s[2] == 'Split system AH')) || qLI2.Apttus_Proposal__Product__r.Name == 'Boilers' || qLI2.Apttus_Proposal__Product__r.Name == 'Air Handler' || qLI2.Apttus_Proposal__Product__r.Name == 'AC Chiller' || qLI2.Apttus_Proposal__Product__r.Name== 'WC Chiller' || qLI2.Apttus_Proposal__Product__r.Name == 'Pumps' || qLI2.Apttus_Proposal__Product__r.Name == 'Pumps - Boiler Feedwater' || qLI2.Apttus_Proposal__Product__r.Name == 'Pumps - Horizontal Split Case' || qLI2.Apttus_Proposal__Product__r.Name == 'Pumps - Vertical Split Case' || qLI2.Apttus_Proposal__Product__r.Name == 'Pumps End Suction' || qLI2.Apttus_Proposal__Product__r.Name == 'Split Systems' || qLI2.Apttus_Proposal__Product__r.Name == 'Sump Pumps')
                    {
                        Apttus_Proposal__Proposal__c Qt = quoteList.get(qLI2.Apttus_Proposal__Proposal__c);
                        if(Qt.Apttus_QPConfig__ConfigurationFinalizedDate__c !=oldQuoteMap.get(Qt.id).Apttus_QPConfig__ConfigurationFinalizedDate__c && Qt.RecordTypeID == RecordIdMap.get('North America RecordType')){
                          System.debug('Include line item categories::'+Qt);
                            if(Qt.Included_Line_Item_Categories__c =='' || Qt.Included_Line_Item_Categories__c ==null)
                            {
                                if(s.size() > 2 && s[2] !=NULL) {
                                    if(s[2] == 'AC Scroll' || s[2] == 'AC Screw'){
                                        Qt.Included_Line_Item_Categories__c = 'Customer Scope Description AC Chiller'; 
                                    }else if(s[2] == 'WC Scroll' || s[2] == 'WC Scroll - Heat Recovery' || s[2] == 'WC Screw' || s[2] == 'WC Mag Bearing Cent' || s[2] == 'WC Cent' || s[2] == 'WC Cent - Heat Recovery' || s[2] == 'WC Recip - Heat Recovery')
                                        Qt.Included_Line_Item_Categories__c = 'Customer Scope Description WC Chiller';
                                    else if(s[2] == 'RTU')
                                        Qt.Included_Line_Item_Categories__c = 'Customer Scope Description RTU'; 
                                    else if(s[2] == 'AHU' || s[2] == 'Condensing Unit')
                                        Qt.Included_Line_Item_Categories__c = 'Customer Scope Description AHU';
                                    else if(s[2] == 'Split system AH'){
                                        Qt.Included_Line_Item_Categories__c = 'Customer Scope Description Split System';
                                    }
                                }
                                else if(qLI2.Apttus_Proposal__Product__r.Name == 'Boilers'){
                                    Qt.Included_Line_Item_Categories__c = 'Customer Scope Description Boiler';
                                }else if(qLI2.Apttus_Proposal__Product__r.Name == 'Air Handler')
                                    Qt.Included_Line_Item_Categories__c = 'Customer Scope Descriptions AHU'; 
                                else if(qLI2.Apttus_Proposal__Product__r.Name == 'AC Chiller')
                                    Qt.Included_Line_Item_Categories__c = 'Customer Scope Description AC Chiller';
                                else if(qLI2.Apttus_Proposal__Product__r.Name== 'WC Chiller'){
                                    Qt.Included_Line_Item_Categories__c = 'Customer Scope Description WC Chiller';
                                }else if(qLI2.Apttus_Proposal__Product__r.Name == 'Split Systems')
                                    Qt.Included_Line_Item_Categories__c = 'Customer Scope Description Split System';
                                else{
                                    Qt.Included_Line_Item_Categories__c = 'Customer Scope Description Pump Install';
                                }
                            }
                        
                       
            
                            else if(s.size() > 1 && s[2] !=NULL){
                                if(s[2] == 'AC Scroll' || s[2] == 'AC Screw' || qLI2.Apttus_Proposal__Product__r.Name == 'AC Chiller'){
                                    if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description AC Chiller')){Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' +  'Customer Scope Description AC Chiller';}
                            }
                            
                            else if(s[2] == 'WC Scroll' || s[2] == 'WC Scroll - Heat Recovery' || s[2] == 'WC Screw' || s[2] == 'WC Mag Bearing Cent' || s[2] == 'WC Cent' || s[2] == 'WC Cent - Heat Recovery' || s[2] == 'WC Recip - Heat Recovery' ){
                                if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description WC Chiller'))
                                Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' + 'Customer Scope Description WC Chiller';   
                            }
                            else if(s[2] == 'RTU'){
                                if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description RTU'))
                                Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' + 'Customer Scope Description RTU';   
                            }
                            else if(s[2] == 'AHU' || s[2] == 'Condensing Unit'){
                                if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description AHU'))
                                    Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' + 'Customer Scope Description AHU';   
                            }
                            else if(s[2] == 'Split system AH'){
                                if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description Split System'))
                                    Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' + 'Customer Scope Description Split System';   
                            }
                                }
                            
                            else if(qLI2.Apttus_Proposal__Product__r.Name == 'Boilers'){if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description Boiler')){Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' + 'Customer Scope Description Boiler';}} 
                            else if(qLI2.Apttus_Proposal__Product__r.Name== 'WC Chiller'){if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description WC Chiller')){Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' + 'Customer Scope Description WC Chiller';}} 
                            else if(qLI2.Apttus_Proposal__Product__r.Name == 'Split Systems'){if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description Split System')){Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' + 'Customer Scope Description Split System';}
                            }
                            else if(!Qt.Included_Line_Item_Categories__c.contains('Customer Scope Description Pump Install')){Qt.Included_Line_Item_Categories__c = Qt.Included_Line_Item_Categories__c  +', ' + 'Customer Scope Description Pump Install';   }

                        }
                    }
                
            }
        }
    }
    
    //This method sychronizes fields between quote and Opportunity After Isert/Update
   /* public static void syncQuotetoOpportunity(map<Id, Apttus_Proposal__Proposal__c> quoteList, map<Id, Apttus_Proposal__Proposal__c> oldQuoteMap){
        
        List<Opportunity> updateOpps = new List<Opportunity> ();
        //This Query gets field information from Opportunity and related Quote/Proposal through Synced Quote Proposal lookup field on Opportunity
        //Populate the Synced_Quote_Proposal__c in the logic
        //1) Loop through Trigger.newmap Quote pROPOSAL RECORDS AND generate list of Opportunities
        List <Id> opp = new List<Id>();
        for(Apttus_Proposal__Proposal__c q: quoteList.values()){
             
            if(q.Apttus_Proposal__Primary__c == TRUE && q.RecordTypeId== RecordIdMap.get('Latin America Proposal'))
System.debug('RecOrd TYPE ID::'+q.RecordTypeId);
            opp.add(q.Apttus_Proposal__Opportunity__c);
        }
        //List.add(Opp Id from Quote);Here i have to get the Opportunity ID.
        //
        if(opp.size()>0){
        Map<Id,Opportunity> o = new Map<Id, Opportunity> ([SELECT Id, Synced_Quote_Proposal__c, CloseDate,Apttus_GM__c, GM_Percentage__c, Total_Discount__c, Bulk_Exchange_Rate__c, GM_Approval_Status__c, Local_Currency__c, Opportunity_Quote_Status__c, Total_cost__c from Opportunity WHERE Id IN: opp]);
        System.debug('Opportunity values'+o);
            for(Apttus_Proposal__Proposal__c q: quoteList.values()){
            System.debug('quote Primary and recordType::'+q.Apttus_Proposal__Primary__c+q.RecordTypeId);
            if(q.Apttus_Proposal__Primary__c == TRUE  && q.RecordTypeId== RecordIdMap.get('Latin America Proposal')){
                opportunity x = o.get(q.Apttus_Proposal__Opportunity__c);
                if(x!=NULL){
                x.Synced_Quote_Proposal__c = q.id;
                //x.CloseDate = q.Estimated_Close_Date__c;
                x.Apttus_GM__c = q.GM__c;
                x.GM_Percentage__c = q.GM_Percentage__c;
                x.Total_Discount__c = q.Total_Discount__c;
                x.Bulk_Exchange_Rate__c = q.Bulk_Exchange_Rate__c;
                x.GM_Approval_Status__c = q.Margin_Approval_Status__c;
                x.Local_Currency__c = q.Local_Currency__c;
                x.Opportunity_Quote_Status__c = q.Apttus_Proposal__Approval_Stage__c;
                x.Total_cost__c = q.Sum_Total_Cost__c;
                updateOpps.add(x);
            }
            }
    }
    }
                /*for(Opportunity o: [SELECT ID, CloseDate,Apttus_GM__c, GM_Percentage__c, Total_Discount__c, Bulk_Exchange_Rate__c, GM_Approval_Status__c, Local_Currency__c, Opportunity_Quote_Status__c, Total_cost__c, 
                            Synced_Quote_Proposal__c, Synced_Quote_Proposal__r.Estimated_Close_Date__c, Synced_Quote_Proposal__r.GM__c, Synced_Quote_Proposal__r.GM_Percentage__c, Synced_Quote_Proposal__r.Total_Discount__c, Synced_Quote_Proposal__r.Bulk_Exchange_Rate__c, Synced_Quote_Proposal__r.Margin_Approval_Status__c, Synced_Quote_Proposal__r.Local_Currency__c, Synced_Quote_Proposal__r.Apttus_Proposal__Approval_Stage__c, Synced_Quote_Proposal__r.Sum_Total_Cost__c FROM Opportunity WHERE Synced_Quote_Proposal__c IN: quoteList.keyset()]){
            //Assigning the Quote field values to Opportunity field values
            o.CloseDate = o.Synced_Quote_Proposal__r.Estimated_Close_Date__c;
            o.Apttus_GM__c = o.Synced_Quote_Proposal__r.GM__c;
            o.GM_Percentage__c = o.Synced_Quote_Proposal__r.GM_Percentage__c;
            o.Total_Discount__c = o.Synced_Quote_Proposal__r.Total_Discount__c;
            o.Bulk_Exchange_Rate__c = o.Synced_Quote_Proposal__r.Bulk_Exchange_Rate__c;
            o.GM_Approval_Status__c = o.Synced_Quote_Proposal__r.Margin_Approval_Status__c;
            o.Local_Currency__c = o.Synced_Quote_Proposal__r.Local_Currency__c;
            o.Opportunity_Quote_Status__c = o.Synced_Quote_Proposal__r.Apttus_Proposal__Approval_Stage__c;
            o.Total_cost__c = o.Synced_Quote_Proposal__r.Sum_Total_Cost__c;
            
            updateOpps.add(o);
        }*/
/*       if(updateOpps.size()>0)
      update updateOpps;
   }*/
    
    //This method deletes all the synchronized field values when the quote gets deleted.
    /*public static void deleteOppSyncFieldswhenQuoteDeleted(map<Id, Apttus_Proposal__Proposal__c> oldQuoteMap){
        /*for(Apttus_Proposal__Proposal__c qI: quoteList.values()){
            if(qI.Apttus_QPConfig__ConfigurationFinalizedDate__c !=oldQuoteMap.get(qI.id).Apttus_QPConfig__ConfigurationFinalizedDate__c ){
                    
            }
        }*/
        /*List<Opportunity> updateOpps = new List<Opportunity> ();
        for(Opportunity o: [SELECT ID, CloseDate,Apttus_GM__c, GM_Percentage__c, Total_Discount__c, Bulk_Exchange_Rate__c, GM_Approval_Status__c, Local_Currency__c, Opportunity_Quote_Status__c, Total_cost__c 
                            FROM Opportunity WHERE Synced_Quote_Proposal__c IN: oldQuoteMap.keyset()]){
            //o.CloseDate = NULL;
            o.Apttus_GM__c = NULL;
            o.GM_Percentage__c = NULL;
            o.Total_Discount__c = NULL;
            o.Bulk_Exchange_Rate__c = NULL;
            o.GM_Approval_Status__c = '';
            o.Local_Currency__c = NULL;
            o.Opportunity_Quote_Status__c = '';
            o.Total_cost__c = NULL;
            
            updateOpps.add(o);
        }
        update updateOpps;
    }*/
    
     /*public static void deleteOppSyncFieldswhenQuoteDeletedbefore(map<Id, Apttus_Proposal__Proposal__c> quotelist){
                List<Opportunity> updateOpps = new List<Opportunity> ();
        for(Opportunity o: [SELECT ID, CloseDate,Apttus_GM__c, GM_Percentage__c, Total_Discount__c, Bulk_Exchange_Rate__c, GM_Approval_Status__c, Local_Currency__c, Opportunity_Quote_Status__c, Total_cost__c 
                            FROM Opportunity WHERE Synced_Quote_Proposal__c IN: quoteList.keyset()]){
            //o.CloseDate = NULL;
            o.Apttus_GM__c = NULL;
            o.GM_Percentage__c = NULL;
            o.Total_Discount__c = NULL;
                                
            o.Bulk_Exchange_Rate__c = NULL;
            o.GM_Approval_Status__c = '';
            o.Local_Currency__c = NULL;
            o.Opportunity_Quote_Status__c = '';
            o.Total_cost__c = NULL;
            
            updateOpps.add(o);
        }
        update updateOpps;
    }*/
 
 /* *****************************************  
 Method Name:  UpdatingCreditAuthorization
 Created by: Solunus
 Created date:12/12/2018
 Functionality: To update the Credit Authorization# field on Quote/proposal object with the Approval comments from "Service Credit"     
  *****************************************/  
    @future 
    public static void UpdatingCreditAuthorization(String newMapString, String oldMapString)
    {
        map<Id, Apttus_Proposal__Proposal__c> newMap =(map<Id, Apttus_Proposal__Proposal__c>)JSON.deserialize(newMapString, map<Id, Apttus_Proposal__Proposal__c>.class);
        map<Id, Apttus_Proposal__Proposal__c> oldMap =(map<Id, Apttus_Proposal__Proposal__c>)JSON.deserialize(oldMapString, map<Id, Apttus_Proposal__Proposal__c>.class);
        //String North_America_Proposal_RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('North America Proposal').getRecordTypeId(); 
        Map<String, ProcessInstanceStep> approvalHistory  = new Map<String, ProcessInstanceStep>();
        
        List<ProcessInstanceStep> processSteps = [SELECT  Id,ProcessInstanceId,ProcessInstance.TargetObjectId,OriginalActor.Name, Comments, 
                                                  Systemmodstamp FROM
                                                  ProcessInstanceStep where stepStatus ='Approved'
                                                  AND Comments != null AND ProcessInstance.ProcessDefinition.Name = 'Credit Approval Process' AND OriginalActor.Name = 'Service Credit'
                                                  AND ProcessInstance.TargetObjectId IN : newMap.keySet() order by createddate];
        
        system.debug('processSteps::'+processSteps);
        for(ProcessInstanceStep app : processSteps){approvalHistory.put(app.ProcessInstanceId+'-'+app.ProcessInstance.TargetObjectId, app);    
        }
        
       list<Apttus_Proposal__Proposal__c> updateList = new list<Apttus_Proposal__Proposal__c>();
        set<string> ProcessInstanceIds = new set<string>();
        Set<Id> propIds = new Set<Id>();
        for(Apttus_Proposal__Proposal__c  proposal: newMap.values()){propIds.add(proposal.Id);}
        for(Apttus_Proposal__Proposal__c  proposal:[select Id, Credit_Authorization_Number__c from Apttus_Proposal__Proposal__c where Id in :propIds]){
            
            //if(oldMap.get(proposal.id).Aproposalpproval_Status__c != proposal.Approval_Status__c){
            for(ProcessInstanceStep pi :processSteps){
                
                system.debug('pi.ProcessInstanceId::'+pi.ProcessInstanceId);
                system.debug(approvalHistory.keyset()) ;
                if(approvalHistory.containsKey(pi.ProcessInstanceId+'-'+proposal.id)){
                    if(proposal.Credit_Authorization_Number__c != approvalHistory.get(pi.ProcessInstanceId+'-'+proposal.id).Comments){
                        proposal.Credit_Authorization_Number__c = approvalHistory.get(pi.ProcessInstanceId+'-'+proposal.id).Comments;
                    }
                    system.debug('test'+proposal.Credit_Authorization_Number__c);
                }
                if(!ProcessInstanceIds.contains(proposal.id)){updateList.add(proposal);}
                ProcessInstanceIds.add(proposal.id);
            }
        }       
        if(updateList.size()>0){flag = false;
            update updateList;
            
        }
        system.debug('updateList in Future::'+updateList);
        
    }
    
    
 /* *****************************************  
 Method Name:  updateQuoteStatus
 Created by: Solunus
 Created date:16/07/2019
 Functionality: To update the Reject comments on Quote/proposal object with the Approval comments.    
*****************************************/  
   public static void updateQuoteStatus(map<Id,Apttus_Proposal__Proposal__c> newMap, map<Id,Apttus_Proposal__Proposal__c> oldMap, Boolean stopBatch){
        System.debug('Enter into UpdateQuoteStatus');
       
        Map<String, String> ProposalProcessMap  = new Map<String, String>();
        
        Map<String, ProcessInstanceStep> approvalHistory  = new Map<String, ProcessInstanceStep>();
       system.debug('stopBatch::'+stopBatch);
       if(newMap.size()>0)
       {
         UpdateQuoteStatusOnQuoteProposal b = new UpdateQuoteStatusOnQuoteProposal(newMap.keySet(), newMap.values(),stopBatch);
        database.executeBatch(b);  
       }
        
        /*List<ProcessInstanceStep> processSteps = [SELECT  Id,ProcessInstanceId,ProcessInstance.TargetObjectId, Comments, Systemmodstamp FROM ProcessInstanceStep where stepStatus ='Rejected'
                                                  AND Comments != null
                                                  AND ProcessInstance.TargetObjectId IN : newMap.keySet() order by CreatedDate ASC];
       system.debug('processSteps size'+processSteps.size());
       if(processSteps.size() <= 0){
           flag = false;
       }
        system.debug('Approval processSteps::'+processSteps);
        for(ProcessInstanceStep app : processSteps)
        {
            approvalHistory.put(app.ProcessInstanceId+'-'+app.ProcessInstance.TargetObjectId, app);    
        }
        
        for(Apttus_Proposal__Proposal__c p :newMap.values()){
            if(p.RecordTypeId == recordType.RecordTypeId__c){
            p.Reject_Comments__c = '';
            for(ProcessInstanceStep pi :processSteps){
                if(approvalHistory.containsKey(pi.ProcessInstanceId+'-'+p.id)){
                    p.Reject_Comments__c += approvalHistory.get(pi.ProcessInstanceId+'-'+p.id).Comments+'\n';
                }  
                System.debug('p.Reject_Comments__c'+p.Reject_Comments__c);
            }
            p.Reject_Comments__c = p.Reject_Comments__c.removeEnd('-');
            p.Approval_Check__c = true;
            }
        }*/
    }
   }