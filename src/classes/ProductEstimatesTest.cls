@istest
public class ProductEstimatesTest 
{
	@isTest static void ProductEstimatesTestMethod() 
    {
        Product2 Product2Obj=TestUtility.createProduct();
        insert product2Obj;
        
        Product__c productObj=TestUtility.createProductFormat();
       // productObj.IsActive__c=true;
        insert productObj;
        
        pageReference pageRef=new pageReference('/apex/ProductEstimatesPage?id='+productObj.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(productObj);
        ProductEstimates ProductEstimatesObj = new ProductEstimates(sc);
        
        ProductEstimatesObj.addRow();
        ProductEstimatesObj.delRow();
        
        Map<Integer,Estimate__c> estWraper=ProductEstimatesObj.estimateMap;
        for(Estimate__c wrap: estWraper.values())
        {
            wrap.Estimate_Lable__c='AGENCY';
            wrap.Type__c='Hours';
            wrap.Hour__c=12;
            break;
        }
        ProductEstimatesObj.submitEstimates();
        
        ProductEstimatesObj = new ProductEstimates(sc);
    }
}