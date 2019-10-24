public class DSO_Sales_Call_Task_Controller {
    
    
    public static string AccountId{get;set;}
    public static List<string> lstExcludeitems = new List<string>();
    public static list<string> contactIds = new list<string>();
    
    public DSO_Sales_Call_Task_Controller(ApexPages.StandardController stdcontroller){
        
    }
    
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, List<string> ExcludeitemsList, String AccountName) {
        system.debug('AccountId'+AccountName);
        List<String> AccountIdList = new List<String>();
        AccountIdList.add(AccountId);
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        //system.debug('ExcludeitemsList::'+ExcludeitemsList);
        
        for(string item : ExcludeitemsList ){lstExcludeitems.add(item); }
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        String sQuery =  'select id, Name, AccountId from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND Account.Name =: AccountName order by createdDate DESC limit 5';
        System.debug('sQuery::'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        System.debug('list of contacts'+lstOfRecords);
        if(lstOfRecords.size()>0){
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }}
        return returnList;
    }
    
    @AuraEnabled
    public static List<TaskRelation> getRelatedTasks(Task taskObj, List<String> contactIds){
        List<TaskRelation> taskRelationList = new List<TaskRelation>();
        for(String contactId : contactIds){
            TaskRelation relatedTask = new TaskRelation();
            relatedTask.TaskId = taskObj.Id;
            relatedTask.RelationId = contactId;
            relatedTask.IsWhat = false;
            taskRelationList.add(relatedTask);
        }
        return taskRelationList;
    }
    
    @AuraEnabled 
    public static String saveTask(Task taskObj, String relatedTasks, string SalesCallScore, string comments){
        
        //get task record type
        Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DSO').getRecordTypeId();
        if(SalesCallScore ==null || SalesCallScore == ''){
            SalesCallScore = '0';    
        }
        System.debug('SalesCallScore::'+SalesCallScore);
        //Task taskObj = (Task)JSON.deserialize(taskString, Task.Class);
        taskObj.Sales_Call_Date__c = taskObj.Sales_Call_Date__c;
        taskObj.Valid_Business_Reason__c = taskObj.Valid_Business_Reason__c;
        taskObj.Type='Meeting';
        taskObj.RecordTypeId = devRecordTypeId;
        taskObj.WhatId = taskObj.WhatId;
        taskObj.Description = comments;
        taskObj.Sales_Call_Score__c = decimal.valueOf(SalesCallScore);
        taskObj.Status = 'In Progress';
        taskObj.Subject = 'DSO Sales Call';
        //taskObj.OwnerId = taskObj.OwnerId;
        insert taskObj;
        System.debug('taskObj::'+taskObj);
        
        if(string.isBlank(relatedTasks)){ 
            return 'success';
        }
        //insert related records (contacts)
        List<TaskRelation> relatedTaskList = new List<TaskRelation>();
        List<TaskRelation> sobjRecordsLst = (List<TaskRelation>)System.JSON.deserialize(relatedTasks, List<TaskRelation>.class); 
        
        if(sobjRecordsLst !=null){
            for (TaskRelation taskRelobj : sobjRecordsLst) {
                TaskRelation m = (TaskRelation)taskRelobj;
                relatedTaskList.add(m);
            }   
        }
        System.debug('relatedTasks::'+relatedTaskList);
        for(TaskRelation relatedTask : relatedTaskList){
            relatedTask.TaskId =  taskObj.Id;   
        }
        if(relatedTaskList.size() > 0){
            insert relatedTaskList;    
        }
        return 'success';
        
    }
    
    @AuraEnabled
    @TestVisible public static String calculateSalesScorce(task taskObj, String relatedTasks)
    {
        system.debug('taskObj'+taskObj);
        string SalesCallScoreValue;
        integer HighContactSize =0;
        decimal validBRFactor =0;
        list<string> contactIds = new list<string>();
        List<TaskRelation> relatedTaskList = new List<TaskRelation>();
        list<Valid_Business_Reason_Factor__mdt> VBRFactor = new list<Valid_Business_Reason_Factor__mdt>();
        
        List<TaskRelation> sobjRecordsLst = (List<TaskRelation>)System.JSON.deserialize(relatedTasks, List<TaskRelation>.class);
        if(sobjRecordsLst !=null){
            for (TaskRelation taskRelobj : sobjRecordsLst) {
                TaskRelation m = (TaskRelation)taskRelobj;
                contactIds.add(m.RelationId);
            } 
        }  
        
        // get Account infromation
        Account accObj =new Account();
        if(taskObj.whatid !=null)
            accObj =[select id,High_Value__c from Account where id=:taskObj.whatid];
        system.debug('Account -- '+accObj);
        
        // get contact information
        list<contact> selectedContacts = new list<contact>();
        if(contactIds.size()>0)
            selectedContacts =[select id,High_Value__c from Contact where id IN :contactIds];
        system.debug('Test check'+selectedContacts);
        
        //get Value Business Reason Factor -based on Account High value and no.of High Contacts
        if(accObj.id !=null){
            system.debug('taskObj.Valid_Business_Reason__c'+taskObj.Valid_Business_Reason__c);
            if(taskObj.Valid_Business_Reason__c !=null && taskObj.Valid_Business_Reason__c!=''){
                for(Valid_Business_Reason_Factor__mdt VBR:[select Account_Value__c,Valid_Business_Reason_Factor__c,Valid_Business_Reason__c,VBR_Factor_1__c,VBR_Factor_2__c,VBR_Factor_3__c,VBR_FActor_4__c from Valid_Business_Reason_Factor__mdt WHERE Valid_Business_Reason__c =:taskObj.Valid_Business_Reason__c AND Account_Value__c=:accObj.High_Value__c]){
                    system.debug('VBR'+VBR);
                    if(accObj.High_Value__c == true ){                  // check wherather Account value is High or low
                        
                        if(selectedContacts.size()>0){                 // get contacts count with high value
                            for(contact c:selectedContacts){       
                                if(c.High_Value__c)
                                    HighContactSize +=1;
                            }
                            if(VBR.Account_Value__c == true){            // if Account value is High ,check High contacts count and assign value from Metadata
                                if(HighContactSize ==0){
                                    validBRFactor = VBR.Valid_Business_Reason_Factor__c;
                                }else if(HighContactSize ==1) {
                                    validBRFactor = VBR.VBR_Factor_1__c;
                                }else if(HighContactSize ==2) {
                                    validBRFactor = VBR.VBR_Factor_2__c;
                                }else if(HighContactSize ==3) {
                                    validBRFactor = VBR.VBR_Factor_3__c;
                                }else if(HighContactSize >=4) {
                                    validBRFactor = VBR.VBR_Factor_4__c;
                                }
                            }   
                        }
                        
                        else{
                             validBRFactor = VBR.Valid_Business_Reason_Factor__c;
                        }
                    }else{                                    // If Account value is low directly assign VBR value from Metadata
                        system.debug('account low');
                        validBRFactor = VBR.Valid_Business_Reason_Factor__c;
                    }
                }
            }
        }else{validBRFactor =0;}
        SalesCallScoreValue = String.valueOf(validBRFactor);           // convert integer into string
        return SalesCallScoreValue;
    }
    
}