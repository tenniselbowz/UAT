@isTest
public class ApprovalCriteriaTriggerTest 
{
    
    @testSetup static void setup() {
        Product__c prod =new Product__c();
        prod.Name='Test Format'; 
        insert prod;
    }
    
    static testMethod void testApprovalLevelDupPreventer()
    {
        
        Product__c formatObj=[Select id from Product__c limit 1];
        
        list<Approval_Criteria__c> appList =new list<Approval_Criteria__c> (); 
        Approval_Criteria__c   appCriteriaRecord = new Approval_Criteria__c();
        {
            appCriteriaRecord.Approval_Level__c='A';
            appCriteriaRecord.Format__c =formatObj.id;
            appCriteriaRecord.FPA_Total_Drafting_Hours__c='10';
            appCriteriaRecord.FPA_Total_Engineering_Hours__c='30';
            appCriteriaRecord.FPA_Total_Manufacturing_Hours__c='20';
            appCriteriaRecord.Max_QTY_of_Units_On_Single_Line_Item__c='10';
            appCriteriaRecord.Max_Total_Drafting_Hours_per_Single_l__c='15';
            appCriteriaRecord.Max_Total_Engineering_Hours_for_Single__c='20';
            appCriteriaRecord.Max_Total_Material_Cost_for_Single_Line__c='30';
            appCriteriaRecord.Max_Total_Manufacturing_Hours_for_Single__c='20';
            appList.add(appCriteriaRecord);
        }
        insert appList;
        
        Approval_Criteria__c ac =[select id,name,Approval_Level__c from Approval_Criteria__c limit 1];
        system.assertEquals(ac.Approval_Level__c,'A');
    }
    
     static testMethod void testApprovalLevelDupUpdate()
    {
        Product__c formatObj=[Select id from Product__c limit 1];
        Approval_Criteria__c  appCriteriaRecordDup = new  Approval_Criteria__c();
        {
            appCriteriaRecordDup.Approval_Level__c='A';
            appCriteriaRecordDup.Format__c =formatObj.id;
            appCriteriaRecordDup.FPA_Total_Drafting_Hours__c='10';
            insert appCriteriaRecordDup;
            appCriteriaRecordDup.FPA_Total_Drafting_Hours__c='20';
            update appCriteriaRecordDup;
        }
        
    }
    
}