public class ProductEstimates 
{
    public Product__c productObj{set;get;}
    public Map<Integer,Estimate__c> estimateMap{set;get;}
    public List<Estimate__c> deleteList;
    public integer rowNumber{set;get;}
    public string rowNumberValue{ get; set;}
    
    public ProductEstimates(ApexPages.StandardController stdController)
    {  
        productObj=new Product__c();
        this.productObj = (Product__c)stdController.getRecord();
        estimateMap=new Map<Integer,Estimate__c>();
        deleteList=new List<Estimate__c>();
        
        rowNumber=0;
        rowNumberValue='';
        if(productObj.Id !=null)
        {
            productObj=[SELECT Id,Name,PCL__c,Family__c,Description__c,
                        (Select ID,Name,Estimate_Lable__c,Hour__c,Type__c from Estimate__r)  
                        FROM Product__c WHERE Id = : productObj.Id];
            
            Integer i=0;
            for(Estimate__c estRec : productObj.Estimate__r)
            {
                estimateMap.put(i,estRec);
                i++;
            }
            
            if(estimateMap.size() < 8)
            {
                for(integer k=estimateMap.size();k<8;k++)
                { 
                    estimateMap.put(k,new Estimate__c(Product__c = productObj.Id,Hour__c =0));
                }
            }
        }
    }
    
    public void delRow()
    {
        system.debug('rowNumber '+ rowNumber);
        system.debug('rowNumberValue '+ rowNumberValue);
        Estimate__c estRec=estimateMap.get(rowNumber);
        estimateMap.remove(rowNumber);
        if(estRec !=null && estRec.Id !=NULL)
        {
            deleteList.add(estRec);
        }
        system.debug(deleteList);
    }
    
    public PageReference submitEstimates()
    {
        PageReference pageRef=new PageReference('/'+ productObj.Id);
        
        List<Estimate__c> estimateList=new List<Estimate__c>();
        set<String> estimateDuplicateset=new set<String>();
        
        for(Estimate__c estimateRec : estimateMap.values())
        {
            estimateRec.Name=estimateRec.Estimate_Lable__c;
            
            if(estimateRec.Estimate_Lable__c != NULL || estimateRec.Type__c != null)
            {
                if(estimateRec.Estimate_Lable__c == NULL && estimateRec.Type__c != null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Label to submit Estimates'));
                    return null;
                }
                /*else if(estimateRec.Estimate_Lable__c != NULL && estimateRec.Type__c == null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Type to submit Estimates'));
                    return null;
                }*/
                else if(estimateDuplicateset.contains(estimateRec.Estimate_Lable__c+estimateRec.Type__c))
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Remove duplicate entries for Estimates'));
                    return null;
                }
                else if(estimateRec.Type__c == 'Hours' && estimateRec.Hour__c <= 0)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Hours required for the type \'Hours\' to submit Estimates'));
                    return null;
                }
                else if(estimateRec.Type__c == 'Dollars' && estimateRec.Hour__c > 0)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Estimate type Dollars doest require hours'));
                    return null;
                }
                else 
                {
                    estimateList.add(estimateRec);
                    estimateDuplicateset.add(estimateRec.Estimate_Lable__c+estimateRec.Type__c);
                } 
            }
        }
        
        if(estimateList.size() > 0)
        {
            upsert estimateList;
        }
        if(deleteList.size() > 0)
        {
            delete deleteList;
        }
        return pageRef;
    }
    
    public void addRow()
    {
        list<integer> keysetList=new list<integer>();
        if(estimateMap.size() != 0)
        {
            keysetList.addALl(estimateMap.keySet());
            system.debug('last key val '+ keysetList[keysetList.size()-1]);
            system.debug('estimateMap.size() '+ estimateMap.size());
            
            estimateMap.put(keysetList[keysetList.size()-1]+1,new Estimate__c(Product__c = productObj.Id,Hour__c= 0.00));
        }
        else
        {
            estimateMap.put(0,new Estimate__c(Product__c = productObj.Id,Hour__c= 0.00));
        }
    }
}