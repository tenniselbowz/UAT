@isTest
public class DSO_Sales_Call_Task_Controller_Test {
    
    @testSetup static void setup(){//Insert Test Data
        Id accountRecordTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Daikin Applied').getRecordTypeId();
        Id warrantyRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();   
        Id warrantyAuthClaimRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Direct Sales Office Standard User'].Id,
            LastName = 'last',
            Email = 'testemails@daikinapplied.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            User_Department__c='DAAL - Equipment Sales'
        );
        insert u;
        
        System.runAs(u) {
            List<account> accountList = new List<account>(); 
        List<contact> contactlist = new List<contact>();
        Account testAccount = APTPS_DaikinTestDataUtility.getAccount('accName');
        testAccount.High_Value__c = true;
        testAccount.Description='DAAL';
        accountList.add(testAccount);
        
        Account testAccount1 = APTPS_DaikinTestDataUtility.getAccount('accName');
        testAccount1.High_Value__c = false;
        testAccount1.Description='DAAL Tracking List';
        accountList.add(testAccount1);
        insert accountList;
        
        Contact testContact1 = APTPS_DaikinTestDataUtility.getContact(testAccount);
        testContact1.High_Value__c = true;
        Contact testContact2 = APTPS_DaikinTestDataUtility.getContact(testAccount);
        testContact2.High_Value__c = true;
        Contact testContact3 = APTPS_DaikinTestDataUtility.getContact(testAccount);
        testContact3.High_Value__c = true;
        Contact testContact4 = APTPS_DaikinTestDataUtility.getContact(testAccount);
        testContact4.High_Value__c = true; 
        Contact testContact5 = APTPS_DaikinTestDataUtility.getContact(testAccount);
        testContact5.High_Value__c = true; 
        contactlist.add(testContact1);
        contactlist.add(testContact2);
        contactlist.add(testContact3);
        contactlist.add(testContact4);
        contactlist.add(testContact5);
        insert contactlist;
        }
    
        
        /*
        system.debug('User '+U);
        // Update Owner on Accounts
        List<Account> accUpdate=new List<Account>();
        for(Account acUpdate:accountList){
            acupdate.owner=u;
            accUpdate.add(acupdate);
        }
        update accUpdate; */
        
    }
    
    @isTest static void fetchLookupValues(){
        List<string> exludeList=new  List<string>();
        List <sObject> sObj = DSO_Sales_Call_Task_Controller.fetchLookUpValues('Test Account NA-1', 'Contact', exludeList,'Test Account NA-1');
        // System.assertEquals(null, result);
    }
    @isTest static void getRelatedTasks(){
        List<String> contactIds=new List<String>();
        List<String> Cont1 = new List<String>();
        List<String> Cont2 = new List<String>();
        List<String> Cont3 = new List<String>();
        List<String> Cont4 = new List<String>();
        List<String> Cont5 = new List<String>();
        
        for(contact c:[select id,name from contact limit 10]){
            contactIds.add(c.id);
            if(Cont1.size()<1){
                Cont1.add(c.id);
            }
            if(Cont2.size()<2){
                Cont2.add(c.id);
            }
            if(Cont3.size()<3){
                Cont3.add(c.id);
            }
            if(Cont4.size()<4){
                Cont4.add(c.id);
            }
            if(Cont5.size()<5){
                Cont5.add(c.id);
            }
            
        }
        System.debug('contactIds'+contactIds);
        Account acc=[select id,name from account where High_Value__c = true limit 1];
        User u=[select id,name from user limit 1];
        acc.OwnerId=u.id;
        update acc;
        Task tsk=new Task();
        tsk.Sales_Call_Date__c=system.Date.today();
        tsk.WhatId=acc.id;
        tsk.Valid_Business_Reason__c='Customer Meal';
        
        case cas=new case();        
        cas.status='Warranty Approved';     
        insert cas;     
        
        Task tsks=new Task();       
        tsks=tsk.clone();       
        tsks.WhatId=cas.id;     
        tsks.Status='Completed';        
        tsks.Subject='Email:DSO';       
        insert tsks;        
        delete tsks;
        
        List<TaskRelation> getRelatedTask=DSO_Sales_Call_Task_Controller.getRelatedTasks(tsk, contactIds);
        String relatedTasks=JSON.serialize(getRelatedTask);
        //Calcualte Sales Score 
        String salesScore=DSO_Sales_Call_Task_Controller.calculateSalesScorce(tsk,relatedTasks);
        
        //Create a Task for selected account and contact
        string result=DSO_Sales_Call_Task_Controller.saveTask(tsk, relatedTasks, '60', 'Test');
        
        //Query custom metadata here
        Valid_Business_Reason_Factor__mdt supportSetting = [ SELECT Valid_Business_Reason__c,Valid_Business_Reason_Factor__c 
                                                            FROM Valid_Business_Reason_Factor__mdt WHERE Valid_Business_Reason__c LIKE '%Customer Meal%'
                                                            limit 1];
        //Get Account records from search Keywork
        List <sObject> fetchAccount=lookUpController.fetchAccount('accName', 'Account');
        //system.assertEquals(2, fetchAccount.size());
        tsk.Valid_Business_Reason__c='Cliffnotes Daikin Education';
        update tsk;
        
        system.assertEquals(UserInfo.getUserId(), lookUpController.getUser().Id);
    }
}