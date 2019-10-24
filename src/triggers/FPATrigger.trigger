trigger FPATrigger on Factory_Pricing_Authorization__c (before insert, before Update, After insert,After update) {
    
    Map<String,Factory_Pricing_Authorization__c> FPAMap =new Map<String,Factory_Pricing_Authorization__c>();
    List<Factory_Pricing_Authorization__c> FPAList =new  List<Factory_Pricing_Authorization__c>();
    if(trigger.isBefore){
        if(trigger.isUpdate){
            for (Factory_Pricing_Authorization__c FPA :trigger.new)
            {
                if(FPA.FPATotalDraftingHours__c!= trigger.oldMap.get(FPA.Id).FPATotalDraftingHours__c ||
                   FPA.FPATotalEngineeringHours__c!= trigger.oldMap.get(FPA.Id).FPATotalEngineeringHours__c||
                   FPA.FPATotalManufacturingHours__c!= trigger.oldMap.get(FPA.Id).FPATotalManufacturingHours__c||
                   FPA.Max_QTY_of_Units_On_Single_Line_Item__c!= trigger.oldMap.get(FPA.Id).Max_QTY_of_Units_On_Single_Line_Item__c||
                   FPA.Max_Total_Drafting_Hours_per_Single_line__c!= trigger.oldMap.get(FPA.Id).Max_Total_Drafting_Hours_per_Single_line__c||
                   FPA.Max_Total_Engineering_Hours_for_Single__c!= trigger.oldMap.get(FPA.Id).Max_Total_Engineering_Hours_for_Single__c||
                   FPA.Max_Total_Manufacturing_Hours_for_Single__c!= trigger.oldMap.get(FPA.Id).Max_Total_Manufacturing_Hours_for_Single__c||
                   FPA.MaxTotalMaterialCostforSingleLine__c!= trigger.oldMap.get(FPA.Id).MaxTotalMaterialCostforSingleLine__c||
                   FPA.QTY_of_line_Item_with_Specials__c!= trigger.oldMap.get(FPA.Id).QTY_of_line_Item_with_Specials__c )
                {
                    FPAMap.put(FPA.Id, FPA);
                }else if(FPA.Approval_Level__c != trigger.oldMap.get(FPA.Id).Approval_Level__c){
                    FPA_Approval_Criteria.updateApprovalLevel(FPA); 
                }
            }
            if(FPAMap.keyset().size() > 0 && !FPA_Approval_Criteria.isApprovalLevelUpdated){
            	FPA_Approval_Criteria.performApprovalLevels(FPAMap);    
            }
            if(FPAList.size() > 0){
            	//FPA_Approval_Criteria.updateApprovalLevel(FPAList);    
            }
        }
    }
    
    
}