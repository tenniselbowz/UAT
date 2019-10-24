@isTest
public class FPA_ApprovalHelperTest {
    
    public static testmethod void  FPAApprovalHelper(){
        
        Map<String, FPA_Approvers__c> approvals = new Map<String, FPA_Approvers__c>();
        List<FPA_Approvers__c> approverList = new List<FPA_Approvers__c>();
        List<FPA_Approvers__c> updatedapproverList = new List<FPA_Approvers__c>();
        
        Product__c ProductObj=TestUtility.createProductFormat();
        ProductObj.IsActive__c=true;
        insert productObj;
        
        FPA_Persona__c FPAPersonRepObj=TestUtility.createFPAPersona('Rep',null);
        FPAPersonRepObj.User_Id__c='test 1234';
        insert FPAPersonRepObj;
        
        UtilityClass.getSObjectRelatedFields('FPA_Approvers__c','FPA_Person__r.Name','',true);
        Factory_Pricing_Authorization__c FPAObj=TestUtility.createFPA(FPAPersonRepObj.Id,ProductObj.Id);
        insert FPAobj;
        
        FPA_Approvers__c FpaApprover1 = new FPA_Approvers__c();
        FpaApprover1.FPA__c=FPAObj.id;
        FpaApprover1.Status__c='Approved';
        approverList.add(FpaApprover1);
        
        FPA_Approvers__c FpaApprover2 = new FPA_Approvers__c();
        FpaApprover2.FPA__c=FPAObj.id;
        FpaApprover2.Status__c='Rejected';
        approverList.add(FpaApprover2);
        

        FPA_Approvers__c FpaApprover3 = new FPA_Approvers__c();
        FpaApprover3.FPA__c=FPAObj.id;
        FpaApprover3.Status__c='Rejected';
        approverList.add(FpaApprover3);

        FPA_Approvers__c FpaApprover4 = new FPA_Approvers__c();
        FpaApprover3.FPA__c=FPAObj.id;
        FpaApprover3.Status__c='Approved';
        approverList.add(FpaApprover4);
    
        insert approverList; 
        
        for(FPA_Approvers__c a: approverList){
            if(a.Status__c == 'Approved'){
                a.Status__c='Rejected';
            }
            else{
                a.Status__c='Approved';
            }
            updatedapproverList.add(a);
        }
        update updatedapproverList;
        
        for(FPA_Approvers__c aa: updatedapproverList){
            approvals.put(aa.Id,aa);
        }
        
        System.assertEquals('Approved', updatedapproverList[3].Status__c);
         System.assertEquals('Rejected', updatedapproverList[2].Status__c);

    }
}