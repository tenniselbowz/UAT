@isTest
private class TestCaseServiceToAllCasesClone { 
    
    private static testMethod void testClass(){
        
        // Creating Parent case
        case parentcase = new case();
        insert parentcase;
        System.debug('parentcase ::'+parentcase.id);
        
                //Creating Child Case1
        case ChildCase1 = new case();
        ChildCase1.ParentId=parentcase.id;
        insert ChildCase1;
        
        //Creating Child Case
        case ChildCase = new case();
        ChildCase.ParentId=parentcase.id;
        insert ChildCase;
         System.debug('ChildCase ::'+ChildCase.id);
        
        System.assertEquals(ChildCase.ParentId, parentcase.id);
        
        //Creating case_service_code__c For the Child Case
        case_service_code__c csc = new case_service_code__c();
        csc.case__c=ChildCase.id;
        insert csc;
        
        System.assertEquals(csc.case__c, ChildCase.id);
        
        
        Test.startTest();
        pageReference p = page.ApplytoAllCasesClone;       
        Test.setCurrentPage(p);
        p.getParameters().put('id',csc.id);
        p.getParameters().put('evenly','true');
        ApexPages.StandardController sc = new ApexPages.StandardController(csc);
        CaseServiceCodesToALLCasesClone controller = new CaseServiceCodesToALLCasesClone(sc);
        controller.evenly=true;
        controller.callWarrantyHelper();
        controller.redirectPopup();
        test.stopTest();
    }
}