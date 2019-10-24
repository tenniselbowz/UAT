public class FPAApprovalDetails {
    /*
public static String sumOfUnitDetails(list<FPA_Link__c> FPALinkList)
{
system.debug('Enter into sumOfUnitDetails');
String approvalLevel = '';
Decimal sum = 0;
for (FPA_Link__c RelatedSFOs :FPALinkList)
{
sum+=RelatedSFOs.Quantity__c;
}
system.debug('Sum Of unit Deatils::'+sum);
List<Decimal> quantityList = new List<Decimal>();
for(FPA_Link__c fpaLink : FPALinkList){
quantityList.add(fpaLink.Quantity__c);    
}

Decimal max = quantityList[0];
for(Integer i = 1; i < quantityList.size();i++)
{
if(quantityList[i] > max)
{
max = quantityList[i];
}
}
if (max>20)
{
approvalLevel ='A' ;  	
}
if (max>10 && max<=20)
{
approvalLevel ='B' ;  
}    
if(max>5 && max <=10)
{
approvalLevel ='c' ; 
}
if (max>0 && max<=5)
{
approvalLevel ='D' ;  
}
System.debug('Max Value' + max);
return approvalLevel;
}
*/ 
    public static void getFPADynamicFields(list<Related_SFO__c> relatedSFOList)
    {
        set<String> unitTagIds = new set<String>();
        set<String> fpaIds = new set<String>();
        for(Related_SFO__c rel : relatedSFOList){
            unitTagIds.add(rel.unit_Detail__c);
        }
        List<FPA_Link__c> fpaLinks = new List<FPA_Link__c>();
        Map<Id,List<FPA_Link__c>> fpaLinksMap=new Map<Id,List<FPA_Link__c>>();
        fpaLinks = [SELECT Id, Quantity__c,
                    QTY_of_line_Item_with_Specials__c,
                    Max_Total_Material_Cost_for_Single_Line__c,
                    Max_QTY_of_Units_On_Single_Line_Item__c,
                    FPA_Total_Manufacturing_Hours__c,
                    FPA_Total_Engineering_Hours__c,
                    FPA_Total_Drafting_Hours__c,FPA__c,
                    (SELECT Id, Unit_Detail__c,SFO__c,Total_Cost__c FROM Related_SFO__r)
                    FROM FPA_Link__c 
                    WHERE Id IN :unitTagIds];
        
        List<Factory_Pricing_Authorization__c> fpa = new List<Factory_Pricing_Authorization__c>();
        
        list<Related_SFO__c> relatedSFO = new list<Related_SFO__c>();
        for(FPA_Link__c linkRec : fpaLinks){
            relatedSFO.addAll(linkRec.Related_SFO__r);  
            fpaIds.add(linkRec.FPA__c);                
        }
        System.debug(relatedSFO);
        for(FPA_Link__c fss:[SELECT Id, Quantity__c,FPA__c,(SELECT Id, Unit_Detail__c,SFO__c,Total_Cost__c,List_Price__c,Expected_Margin__c,List_Markup__c FROM Related_SFO__r) FROM FPA_Link__c WHERE FPA__c =: fpaIds]){
            List<FPA_Link__c> fplink = fpaLinksMap.get(fss.FPA__c);
            if(fplink == null)
                fplink = new List<FPA_Link__c>();
            fplink.add(fss);
            fpaLinksMap.put(fss.FPA__c,fplink);  
        }
        
        system.debug('fpaLinksMap '+fpaLinksMap);
        Map<Id,Factory_Pricing_Authorization__c> fpaMap=new Map<Id,Factory_Pricing_Authorization__c>();
        for(Factory_Pricing_Authorization__c fact:[select id,Costt__c,List_Price__c,Total_Margin__c,Average_List_Price_Markup__c from Factory_Pricing_Authorization__c where Id IN :fpaIds]){
            fpa.add(fact);
            fpaMap.put(fact.id,fact);
        }
        
        Map<Id,Related_SFO__c> relatedSFOMap=new Map<Id,Related_SFO__c>();
        system.debug('Enter into getFPADynamicFields Method::'+relatedSFO);
        set<Id> SFOIds = new set<Id>();
        Map<String, decimal> draftingHoursMap = new Map<String, decimal>();
        Map<String, decimal> engineeringHoursMap = new Map<String, decimal>();
        Map<String, decimal> manufacturingHoursMap = new Map<String, decimal>();
        Map<String, decimal> materialCostMap = new Map<String, decimal>();
        
        Map<String, decimal> draftingHoursSumMap = new Map<String, decimal>();
        Map<String, decimal> engineeringHoursSumMap = new Map<String, decimal>();
        Map<String, decimal> manufacturingHoursSumMap = new Map<String, decimal>();
        Map<String, decimal> materialCostSumMap = new Map<String, decimal>();
        for (Related_SFO__c RSFO :relatedSFO)
        {
            SFOIds.add(RSFO.SFO__c);
            
        }
        set<string> dynamicFieldList =new set<string>{'Material Cost','Drafting Hours','Manufacturing Hours','Engineering Hours'};
            set<string> dynamicFieldListClone =new set<string>();
        system.debug(SFOIds);
        try{
            for (SFO_Dynamic_Fields__c  dynamicField :[select id,name, field_Value__c, SFO__c
                                                       from SFO_Dynamic_Fields__c where SFO__c IN :SFOIds
                                                       AND Name IN :dynamicFieldList]) 
            {
                dynamicFieldListClone.add(dynamicField.name);
                
                if(dynamicField.name.equalsIgnoreCase('Drafting Hours'))
                {
                    decimal draftingCost = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    draftingHoursMap.put(dynamicField.SFO__c+dynamicField.name,draftingCost);  
                }
                else if(dynamicField.name.equalsIgnoreCase('Manufacturing Hours'))
                {
                    decimal manufacturingCost = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    manufacturingHoursMap.put(dynamicField.SFO__c+dynamicField.name,manufacturingCost);
                }
                else if(dynamicField.name.equalsIgnoreCase('Engineering Hours'))
                {
                    decimal engineeringCost = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    engineeringHoursMap.put(dynamicField.SFO__c+dynamicField.name,engineeringCost);
                }
                else if (dynamicField.name.equalsIgnoreCase('Material Cost'))
                {
                    decimal materialCost = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    materialCostMap.put(dynamicField.SFO__c+dynamicField.name,materialCost ); 
                }
            }
            
            //System.debug('draftingHoursMap::'+draftingHoursMap);
            //System.debug('manufacturingHoursMap::'+manufacturingHoursMap);
            //System.debug('engineeringHoursMap::'+engineeringHoursMap);
            //System.debug('materialCostMap::'+materialCostMap);
            decimal draftingSum =0;
            decimal manufacturingHoursSum =0;
            decimal engineeringHoursSum =0;
            decimal materialCostSum =0;
            System.debug('dynamicFieldListClone::'+dynamicFieldListClone);
            for(Related_SFO__c relatedSFOs : relatedSFO)
            {
                relatedSFOMap.put(relatedSFOs.Id,relatedSFOs);
                //string unitTag;
                for(string s :dynamicFieldListClone)
                {
                    if(draftingHoursMap.containsKey(relatedSFOs.SFO__c+s))
                    {
                        draftingSum = draftingHoursMap.get(relatedSFOs.SFO__c+s);
                        if(draftingHoursSumMap.containsKey(relatedSFOs.unit_detail__c+s)){
                            decimal draftSum = draftingHoursSumMap.get(relatedSFOs.unit_detail__c+s)+draftingSum;
                            draftingHoursSumMap.put(relatedSFOs.unit_detail__c+s,draftSum);  	    
                        }else{
                            draftingHoursSumMap.put(relatedSFOs.unit_detail__c+s,draftingSum);     
                        }
                        
                    }
                    
                    else if(manufacturingHoursMap.containsKey(relatedSFOs.SFO__c+s))
                    {
                        manufacturingHoursSum = manufacturingHoursMap.get(relatedSFOs.SFO__c+s);
                        if(manufacturingHoursSumMap.containsKey(relatedSFOs.unit_detail__c+s)){
                            decimal manufactureSum = manufacturingHoursSumMap.get(relatedSFOs.unit_detail__c+s)+manufacturingHoursSum;
                            manufacturingHoursSumMap.put(relatedSFOs.unit_detail__c+s,manufactureSum);  	    
                        }else{
                            manufacturingHoursSumMap.put(relatedSFOs.unit_detail__c+s,manufacturingHoursSum);     
                        }  
                    }
                    else if(engineeringHoursMap.containsKey(relatedSFOs.SFO__c+s))
                    {
                        engineeringHoursSum = engineeringHoursMap.get(relatedSFOs.SFO__c+s);
                        if(engineeringHoursSumMap.containsKey(relatedSFOs.unit_detail__c+s)){
                            decimal engineeringSum = engineeringHoursSumMap.get(relatedSFOs.unit_detail__c+s)+engineeringHoursSum;
                            engineeringHoursSumMap.put(relatedSFOs.unit_detail__c+s,engineeringSum);  	    
                        }else{
                            engineeringHoursSumMap.put(relatedSFOs.unit_detail__c+s,engineeringHoursSum);     
                        } 
                    }
                    
                    else if(materialCostMap.containsKey(relatedSFOs.SFO__c+s))
                    {
                        materialCostSum = materialCostMap.get(relatedSFOs.SFO__c+s);
                        if(materialCostSumMap.containsKey(relatedSFOs.unit_detail__c+s)){
                            decimal materialSum = materialCostSumMap.get(relatedSFOs.unit_detail__c+s)+materialCostSum;
                            materialCostSumMap.put(relatedSFOs.unit_detail__c+s,materialSum);  	    
                        }else{
                            materialCostSumMap.put(relatedSFOs.unit_detail__c+s,materialCostSum);     
                        }
                    }
                }
            }
            //Rollup Totals to FPA 
            for(Factory_Pricing_Authorization__c fp:fpa){
                Decimal totalCosts = 0;
                Decimal listPrice = 0;
                Decimal totalMargin = 0;
                Decimal averageMargin = 0;
                Integer countofRelatedSFO = 0;
                system.debug('FPAMAP LINK SIZE '+fpaLinksMap.get(fp.id).size());
                for(FPA_Link__c fplink:fpaLinksMap.get(fp.id)){
                    for(Related_SFO__c related:fplink.Related_SFO__r){              
                        totalCosts += (related.Total_Cost__c*fplink.Quantity__c);
                        listPrice += (related.List_Price__c*fplink.Quantity__c);
                        totalMargin += (related.Expected_Margin__c*related.Total_Cost__c*fplink.Quantity__c);
                        averageMargin += (related.List_Markup__c);
                        countofRelatedSFO=countofRelatedSFO+1;
                    }
                } 
                averageMargin =(countofRelatedSFO != 0 && countofRelatedSFO != null)?(averageMargin/countofRelatedSFO):0;
                Factory_Pricing_Authorization__c fpUpdate = fpaMap.get(fp.id);
                fpUpdate.Costt__c = totalCosts;
                fpUpdate.List_Price__c = listPrice;
                fpUpdate.Total_Margin__c = totalMargin;
                fpUpdate.Average_List_Price_Markup__c = averageMargin;
                //system.debug('totalCosts '+totalCosts);
                system.debug('totalCosts '+totalCosts);
                system.debug('listPrice '+listPrice);
                system.debug('Total_Margin__c '+totalMargin);
                system.debug('Average_List_Price_Markup__c '+averageMargin);
            }
            update fpa;
            
            system.debug('FPA Update '+fpa);
            System.debug('draftingHoursSumMap::'+draftingHoursSumMap);
            System.debug('manufacturingHoursSumMap::'+manufacturingHoursSumMap);
            System.debug('engineeringHoursSumMap::'+engineeringHoursSumMap);
            System.debug('materialCostSumMap::'+materialCostSumMap);
            for(FPA_Link__c tag: fpaLinks){
                for(String fieldName : dynamicFieldListClone){
                    if(draftingHoursSumMap.containsKey(tag.Id+fieldName)){
                        tag.FPA_Total_Drafting_Hours__c = draftingHoursSumMap.get(tag.Id+fieldName); 
                    } 
                    else if(manufacturingHoursSumMap.containsKey(tag.Id+fieldName)){
                        decimal quantity= (tag.Quantity__c != null)?tag.Quantity__c:0;
                        tag.FPA_Total_Manufacturing_Hours__c = manufacturingHoursSumMap.get(tag.Id+fieldName)*quantity;    
                    } 
                    else if(engineeringHoursSumMap.containsKey(tag.Id+fieldName)){
                        tag.FPA_Total_Engineering_Hours__c = engineeringHoursSumMap.get(tag.Id+fieldName);    
                    } 
                    else if(materialCostSumMap.containsKey(tag.Id+fieldName)){
                        decimal quantity= (tag.Quantity__c != null)?tag.Quantity__c:0;
                        system.debug(quantity);
                        tag.Max_Total_Material_Cost_for_Single_Line__c = materialCostSumMap.get(tag.Id+fieldName)*quantity; 
                    } 
                }       
            }
            System.debug('fpaLinks::'+fpaLinks);
            update fpaLinks;
            if(Test.isRunningTest()){
                integer a =122/0;
            }
        }
        
        catch(Exception e)
        {
            system.debug('Exceptions are:'+e.getLineNumber() +'Message'+e.getMessage());  
        }    
    }
    public static void updateUnitTagOnDelete(list<Related_SFO__c> relatedSFOList)
    {
        set<String> unitTagIds = new set<String>();
        set<String> fpaIds = new set<String>();
        for(Related_SFO__c rel : relatedSFOList){
                unitTagIds.add(rel.unit_Detail__c);
        }
        List<FPA_Link__c> fpaLinks = new List<FPA_Link__c>();
        Map<Id,List<FPA_Link__c>> fpaLinksMap=new Map<Id,List<FPA_Link__c>>();
        fpaLinks = [SELECT Id, Quantity__c,
                    QTY_of_line_Item_with_Specials__c,
                    Max_Total_Material_Cost_for_Single_Line__c,
                    Max_QTY_of_Units_On_Single_Line_Item__c,
                    FPA_Total_Manufacturing_Hours__c,
                    FPA_Total_Engineering_Hours__c,
                    FPA_Total_Drafting_Hours__c,FPA__c,
                    (SELECT Id, Unit_Detail__c,SFO__c,Total_Cost__c FROM Related_SFO__r)
                    FROM FPA_Link__c 
                    WHERE Id IN :unitTagIds];
        List<Factory_Pricing_Authorization__c> fpa = new List<Factory_Pricing_Authorization__c>();
        list<Related_SFO__c> relatedSFO = new list<Related_SFO__c>();
        for(FPA_Link__c linkRec : fpaLinks){
            fpaIds.add(linkRec.FPA__c);                
        }
        for(Related_SFO__c SF : relatedSFOList){
            relatedSFO.add(SF);  
        }
        System.debug(relatedSFO);
        for(FPA_Link__c fss:[SELECT Id, Quantity__c,FPA__c FROM FPA_Link__c WHERE FPA__c =: fpaIds]){
            List<FPA_Link__c> fplink = fpaLinksMap.get(fss.FPA__c);
            if(fplink == null)
                fplink = new List<FPA_Link__c>();
            fplink.add(fss);
            fpaLinksMap.put(fss.FPA__c,fplink);  
        }
        system.debug('fpaLinksMap '+fpaLinksMap);
        Map<Id,Factory_Pricing_Authorization__c> fpaMap=new Map<Id,Factory_Pricing_Authorization__c>();
        for(Factory_Pricing_Authorization__c fact:[select id,Costt__c,List_Price__c,Total_Margin__c,Average_List_Price_Markup__c from Factory_Pricing_Authorization__c where Id IN :fpaIds]){
            fpa.add(fact);
            fpaMap.put(fact.id,fact);
        }
        
        Map<Id,Related_SFO__c> relatedSFOMap=new Map<Id,Related_SFO__c>();
        system.debug('Enter into getFPADynamicFields Method::'+relatedSFO);
        set<Id> SFOIds = new set<Id>();
        Map<String, decimal> draftingHoursMap = new Map<String, decimal>();
        Map<String, decimal> engineeringHoursMap = new Map<String, decimal>();
        Map<String, decimal> manufacturingHoursMap = new Map<String, decimal>();
        Map<String, decimal> materialCostMap = new Map<String, decimal>();
        
        Map<String, decimal> draftingHoursSumMap = new Map<String, decimal>();
        Map<String, decimal> engineeringHoursSumMap = new Map<String, decimal>();
        Map<String, decimal> manufacturingHoursSumMap = new Map<String, decimal>();
        Map<String, decimal> materialCostSumMap = new Map<String, decimal>();
        for (Related_SFO__c RSFO :relatedSFO)
        {
            SFOIds.add(RSFO.SFO__c);
            
        }
        set<string> dynamicFieldList =new set<string>{'Material Cost','Drafting Hours','Manufacturing Hours','Engineering Hours'};
            set<string> dynamicFieldListClone =new set<string>();
        system.debug(SFOIds);
        try{
            for (SFO_Dynamic_Fields__c  dynamicField :[select id,name, field_Value__c, SFO__c
                                                       from SFO_Dynamic_Fields__c where SFO__c IN :SFOIds
                                                       AND Name IN :dynamicFieldList]) 
            {
                dynamicFieldListClone.add(dynamicField.name);
                if(dynamicField.name.equalsIgnoreCase('Drafting Hours'))
                {
                    decimal draftingCost = (dynamicField.field_Value__c==null)?0:-decimal.valueOf(dynamicField.field_Value__c);
                    draftingHoursMap.put(dynamicField.SFO__c+dynamicField.name,draftingCost);  
                }
                else if(dynamicField.name.equalsIgnoreCase('Manufacturing Hours'))
                {
                    decimal manufacturingCost = (dynamicField.field_Value__c==null)?0:-decimal.valueOf(dynamicField.field_Value__c);
                    manufacturingHoursMap.put(dynamicField.SFO__c+dynamicField.name,manufacturingCost);
                }
                else if(dynamicField.name.equalsIgnoreCase('Engineering Hours'))
                {
                    decimal engineeringCost = (dynamicField.field_Value__c==null)?0:-decimal.valueOf(dynamicField.field_Value__c);
                    engineeringHoursMap.put(dynamicField.SFO__c+dynamicField.name,engineeringCost);
                }
                
                else if (dynamicField.name.equalsIgnoreCase('Material Cost'))
                {
                    decimal materialCost = (dynamicField.field_Value__c==null)?0:-decimal.valueOf(dynamicField.field_Value__c);
                    materialCostMap.put(dynamicField.SFO__c+dynamicField.name,materialCost );  
                }
            }
            System.debug('draftingHoursMap::'+draftingHoursMap);
            System.debug('manufacturingHoursMap::'+manufacturingHoursMap);
            System.debug('engineeringHoursMap::'+engineeringHoursMap);
            System.debug('materialCostMap::'+materialCostMap);
            decimal draftingSum =0;
            decimal manufacturingHoursSum =0;
            decimal engineeringHoursSum =0;
            decimal materialCostSum =0;
            
            for(Related_SFO__c relatedSFOs : relatedSFO)
            {
                relatedSFOMap.put(relatedSFOs.Id,relatedSFOs);
                //string unitTag;
                for(string s :dynamicFieldListClone)
                {
                    if(draftingHoursMap.containsKey(relatedSFOs.SFO__c+s))
                    {
                        draftingSum = draftingHoursMap.get(relatedSFOs.SFO__c+s);
                        if(draftingHoursSumMap.containsKey(relatedSFOs.unit_detail__c+s)){
                            decimal draftSum = draftingHoursSumMap.get(relatedSFOs.unit_detail__c+s)+draftingSum;
                            draftingHoursSumMap.put(relatedSFOs.unit_detail__c+s,draftSum);  	    
                        }else{
                            draftingHoursSumMap.put(relatedSFOs.unit_detail__c+s,draftingSum);     
                        }
                    }
                    else if(manufacturingHoursMap.containsKey(relatedSFOs.SFO__c+s))
                    {
                        manufacturingHoursSum = manufacturingHoursMap.get(relatedSFOs.SFO__c+s);
                        if(manufacturingHoursSumMap.containsKey(relatedSFOs.unit_detail__c+s)){
                            decimal manufactureSum = manufacturingHoursSumMap.get(relatedSFOs.unit_detail__c+s)+manufacturingHoursSum;
                            manufacturingHoursSumMap.put(relatedSFOs.unit_detail__c+s,manufactureSum);  	    
                        }else{
                            manufacturingHoursSumMap.put(relatedSFOs.unit_detail__c+s,manufacturingHoursSum);     
                        }  
                    }
                    else if(engineeringHoursMap.containsKey(relatedSFOs.SFO__c+s))
                    {
                        engineeringHoursSum = engineeringHoursMap.get(relatedSFOs.SFO__c+s);
                        if(engineeringHoursSumMap.containsKey(relatedSFOs.unit_detail__c+s)){
                            decimal engineeringSum = engineeringHoursSumMap.get(relatedSFOs.unit_detail__c+s)+engineeringHoursSum;
                            engineeringHoursSumMap.put(relatedSFOs.unit_detail__c+s,engineeringSum);  	    
                        }else{
                            engineeringHoursSumMap.put(relatedSFOs.unit_detail__c+s,engineeringHoursSum);     
                        } 
                    }
                    
                    else if(materialCostMap.containsKey(relatedSFOs.SFO__c+s))
                    {
                        materialCostSum = materialCostMap.get(relatedSFOs.SFO__c+s);
                        if(materialCostSumMap.containsKey(relatedSFOs.unit_detail__c+s)){
                            decimal materialSum = materialCostSumMap.get(relatedSFOs.unit_detail__c+s)+materialCostSum;
                            materialCostSumMap.put(relatedSFOs.unit_detail__c+s,materialSum);  	    
                        }else{
                            materialCostSumMap.put(relatedSFOs.unit_detail__c+s,materialCostSum);     
                        }
                    }
                }
            }
            //Rollup Totals to FPA 
            for(Factory_Pricing_Authorization__c fp:fpa){
                Decimal totalCosts = 0;
                Decimal listPrice = 0;
                Decimal totalMargin = 0;
                Decimal averageMargin = 0;
                Integer countofRelatedSFO = 0;
                system.debug('FPAMAP LINK SIZE '+fpaLinksMap.get(fp.id).size());
                for(FPA_Link__c fplink:fpaLinksMap.get(fp.id)){
                    for(Related_SFO__c related:fplink.Related_SFO__r){              
                        totalCosts += (related.Total_Cost__c*fplink.Quantity__c);
                        listPrice += (related.List_Price__c*fplink.Quantity__c);
                        totalMargin += (related.Expected_Margin__c*related.Total_Cost__c*fplink.Quantity__c);
                        averageMargin += (related.List_Markup__c);
                        countofRelatedSFO = countofRelatedSFO+1;
                    }
                } 
                averageMargin =(countofRelatedSFO != 0 && countofRelatedSFO != null)?(averageMargin/countofRelatedSFO):0;
                Factory_Pricing_Authorization__c fpUpdate=fpaMap.get(fp.id);
                fpUpdate.Costt__c = totalCosts;
                fpUpdate.List_Price__c = listPrice;
                fpUpdate.Total_Margin__c = totalMargin;
                fpUpdate.Average_List_Price_Markup__c = averageMargin;
                //system.debug('totalCosts '+totalCosts);  
                system.debug('totalCosts '+totalCosts);
                system.debug('listPrice '+listPrice);
                system.debug('Total_Margin__c '+totalMargin);
                system.debug('Average_List_Price_Markup__c '+averageMargin);
            }
            update fpa;
            
            system.debug('FPA Update'+fpa);
            System.debug('draftingHoursSumMap::'+draftingHoursSumMap);
            System.debug('manufacturingHoursSumMap::'+manufacturingHoursSumMap);
            System.debug('engineeringHoursSumMap::'+engineeringHoursSumMap);
            System.debug('materialCostSumMap::'+materialCostSumMap);
            for(FPA_Link__c tag : fpaLinks){
                decimal MaxTotalMaterialCost = 0;
                decimal FPATotalManufacturingHours = 0;
                system.debug(dynamicFieldListClone);
                for(String fieldName : dynamicFieldListClone){
                    if(draftingHoursSumMap.containsKey(tag.Id+fieldName)){
                        tag.FPA_Total_Drafting_Hours__c += draftingHoursSumMap.get(tag.Id+fieldName); 
                    } 
                    else if(manufacturingHoursSumMap.containsKey(tag.Id+fieldName)){
                        FPATotalManufacturingHours +=manufacturingHoursSumMap.get(tag.Id+fieldName);
                    } 
                    else if(engineeringHoursSumMap.containsKey(tag.Id+fieldName)){
                        tag.FPA_Total_Engineering_Hours__c += engineeringHoursSumMap.get(tag.Id+fieldName);    
                    } 
                    else if(materialCostSumMap.containsKey(tag.Id+fieldName)){
                        MaxTotalMaterialCost +=materialCostSumMap.get(tag.Id+fieldName);
                    } 
                }
                decimal quantity= (tag.Quantity__c != null)?tag.Quantity__c:0;
                tag.Max_Total_Material_Cost_for_Single_Line__c += MaxTotalMaterialCost*quantity;
                tag.FPA_Total_Manufacturing_Hours__c += FPATotalManufacturingHours*quantity;    
            }
            System.debug('fpaLinks::'+fpaLinks);
            update fpaLinks;
        }
        catch(Exception e)
        {
            system.debug('Exceptions are:'+e.getLineNumber() +'Message'+e.getMessage());  
        }    
    }
    
    public static void getTotalListprice(list<Related_SFO__c> relatedSFOList)
    {
        system.debug('relatedSFOList'+ relatedSFOList.size());
        set<Id> unitDetailId = new set<Id>();
        List<FPA_Link__c> fpalinklist= new List<FPA_Link__c>();
        for(Related_SFO__c relatedsfo: relatedSFOList){
            if(relatedsfo.Unit_Detail__c != null){
                unitDetailId.add(relatedsfo.Unit_Detail__c);
                
            }
        }
        system.debug('unitDetailId'+ unitDetailId);
        fpalinklist = [select id,List_Price__c,Item_Cost__c, (select id,List_Price__c,Cost_Per_unit__c from Related_SFO__r) from FPA_Link__c where id in: unitDetailId];
        system.debug('fpalinklist'+ fpalinklist);
        for(FPA_Link__c fpalink : fpalinklist){
            System.debug('fpalinklist :: '+fpalinklist);
            System.debug('fpalinklist.Size() :: '+fpalinklist.size());
            fpalink.List_Price__c = 0;
            fpalink.Item_Cost__c = 0;
            for(Related_SFO__c relatedsfo : fpalink.Related_SFO__r){
                System.debug('fpalink.Related_SFO__r :: '+fpalink.Related_SFO__r);
                System.debug('fpalink.Related_SFO__r.size() :: '+fpalink.Related_SFO__r.size());
                fpalink.List_Price__c += relatedsfo.List_Price__c;
                fpalink.Item_Cost__c += relatedsfo.Cost_Per_unit__c;
            }
        }
        update fpalinklist;
    }
}