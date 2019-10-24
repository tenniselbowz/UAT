public class TaskUtility {
    
     public static boolean runTaskTriggerOnce=true;
    public static void getCaseTasksCount(List<Task> taskRecords){
        list<Task> caseRelatedTasks = new List<Task>();
        set<Id> caseIds = new set<Id>();
        for(Task t: taskRecords){
            if(t.WhatId != NULL){
                String myIdPrefix = String.valueOf(t.WhatId).substring(0,3);
                if(myIdPrefix == '500'){
                    caseRelatedTasks.add(t);
                    caseIds.add(t.whatId);
                }
                
            }
        }
        List<AggregateResult> groupedResults = [Select  Count(Id), WhatId from task Where WhatId in: caseIds Group By WhatId];
        List<Case> casestobeUpdated = New List<Case>();
        
        for (AggregateResult ar : groupedResults)  {
            Case c = new case();
            c.id =  (id)ar.get('WhatId');
            c.Number_of_Tasks__c = (Integer)ar.get('expr0');
            
            casestobeUpdated.add(c);
            System.debug('Case Id:' + ar.get('WhatId'));
            
            System.debug('Number Of Tasks:' + ar.get('expr0'));
            
        }
        
        for(Case cc: [SELECT Id, Number_of_Tasks__c FROM Case WHERE Id in:caseIds and Id Not in:casestobeUpdated and Number_of_Tasks__c != 0]){
            cc.Number_of_Tasks__c =0;
            casestobeUpdated.add(cc);
        }
        if(casestobeUpdated.size()>0)
            update casestobeUpdated;
        
        
    }
    
    public static void hasAttachment(List<Task> tasks){
        Set<Id> taskIds = new set<Id>();
        Set<Id> taskwithAttachments = new set<Id>();
        List<Task> updateTasks = new List<Task>();
        for(Task t: tasks){
            if(t.Attachment__c == FALSE)
                taskIds.add(t.id);
        }
        for(Attachment a: [SELECT Id, ParentId FROM Attachment Where ParentId in: taskIds]){
            taskwithAttachments.add(a.ParentId);
        }
        
        for(task t: [SELECT Id, Attachment__c FROM Task WHERE Id in: taskwithAttachments AND Attachment__c = FALSE]){
            T.Attachment__c =true;
            updateTasks.add(T);
        }
        if(updateTasks.size()>0)
            update updateTasks;
    }
    
    //This method recalculates the Sales call score when an Account/Contact/Valid Business Reason is chnaged on DSO
    @future
    Public static void updateDSOSalesCallScore(List<Id> taskIDs){
        Set<id> accountIds=new set<id>();
        Set<id> ContactIds=new set<id>();
        List<Task> Taskss=new List<Task>();
        List<Task> tasksToUpdate=new List<Task>();
        List<string> validBReason=new List<string>();
        for(Task t:[SELECT Id, WhoId, WhoCount, Valid_Business_Reason__c,WhatId, WhatCount,(select relationid,relation.id,relation.name from taskrelations) FROM Task where id=:taskIDs]){
            validBReason.add(t.Valid_Business_Reason__c);
            accountIds.add(t.WhatId);
            Taskss.add(t);
            for(taskrelation tsr:t.taskrelations){
             ContactIds.add(tsr.relationid);
            }
            ContactIds.add(t.whoid);
        }

        Map<id,boolean> accountValueMap=new Map<id,boolean>();
        for(account acc:[select id,name,high_value__C from account where id =:accountIds]){
            accountValueMap.put(acc.id, acc.high_value__c);
        }
        List<Contact> contacts=new List<contact>();
        Map<id,boolean> contactValueMap=new Map<id,boolean>();
        for(Contact con:[select id,name,high_value__c from contact where id=:ContactIds]){
            contacts.add(con);
            contactValueMap.put(con.id,con.High_Value__c);
        }

        Map<string,Valid_Business_Reason_Factor__mdt> vbrMap=new Map<String,Valid_Business_Reason_Factor__mdt>();
        //List<Valid_Business_Reason_Factor__mdt> vbr=[select Account_Value__c,Valid_Business_Reason_Factor__c,Valid_Business_Reason__c,VBR_Factor_1__c,VBR_Factor_2__c,VBR_Factor_3__c,VBR_FActor_4__c from Valid_Business_Reason_Factor__mdt WHERE Valid_Business_Reason__c =:validBReason AND Account_Value__c=:accountValueMap.values()];
        for(Valid_Business_Reason_Factor__mdt vbr:[select Account_Value__c,Valid_Business_Reason_Factor__c,Valid_Business_Reason__c,VBR_Factor_1__c,VBR_Factor_2__c,VBR_Factor_3__c,VBR_FActor_4__c from Valid_Business_Reason_Factor__mdt WHERE Valid_Business_Reason__c =:validBReason AND Account_Value__c=:accountValueMap.values()])
        {
            vbrMap.put(vbr.Valid_Business_Reason__c+vbr.Account_Value__c, vbr);
        }
        system.debug('vbrMap '+vbrMap);
      
        for(Task tak:Taskss){
            integer highValueContacts=0;
            boolean accountValue=accountValueMap.get(tak.WhatId);
            List<taskrelation> taskrelations=tak.taskrelations;
            if(accountValue){
                //system.debug('Account Value '+accountValue);
            if(taskrelations.size()>0){
                for(taskrelation ts:taskrelations){
                                   // system.debug('Tasks ts '+ts);
                    if(contactValueMap.get(ts.RelationId)== true){
                        highValueContacts=highValueContacts+1;
                    }
                }
                //system.debug('highValueContacts '+highValueContacts);
                Valid_Business_Reason_Factor__mdt vbrs= vbrMap.get(tak.Valid_Business_Reason__c+accountValue);
                    if(highValueContacts == 0)tak.Sales_Call_Score__c=vbrs.Valid_Business_Reason_Factor__c;
                if(highValueContacts == 1){tak.Sales_Call_Score__c=vbrs.VBR_Factor_1__c; }
                if(highValueContacts == 2){tak.Sales_Call_Score__c=vbrs.VBR_Factor_2__c;}
                if(highValueContacts == 3){tak.Sales_Call_Score__c=vbrs.VBR_Factor_3__c;}
                if(highValueContacts >= 4){tak.Sales_Call_Score__c=vbrs.VBR_FActor_4__c;}
            }
                else {
                    //if(contactValueMap.containskey(tak.WhoId) && contactValueMap.get(tak.WhoId)){
                    tak.Sales_Call_Score__c=vbrMap.get(tak.Valid_Business_Reason__c+accountValue).Valid_Business_Reason_Factor__c;
                    }
            }
            else{
               // system.debug('IN ELSE FINAL LOOP');
                tak.Sales_Call_Score__c=vbrMap.get(tak.Valid_Business_Reason__c+accountValue).Valid_Business_Reason_Factor__c;
            }   
        }
        TaskUtility.runTaskTriggerOnce=false;
        update Taskss;
        
    }
    
    
}