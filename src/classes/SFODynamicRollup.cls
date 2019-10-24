public class SFODynamicRollup {
    public static boolean hasRollUp = true;
    public static void summarizeTotalCost(list<Special_Feature_Option__c> options){
        set<String> parentIds = new set<String>();
        for(Special_Feature_Option__c option :options){
        	parentIds.add(option.Option_Parent__c);    
        }
        List<Special_Feature_Option__c> parentSFOs = new  List<Special_Feature_Option__c>(
        [select id,Total_Cost1__c from Special_Feature_Option__c where id IN : parentIds]);
        Map<String, decimal> sfoParentToOptions 
            = new Map<String, decimal>();
        for(Special_Feature_Option__c optionRec : [SELECT Id, Total_Cost_value__c,Option_Parent__c FROM Special_Feature_Option__c
                                                  WHERE Option_Parent__c IN :parentIds]){
            decimal totalCost = (optionRec.Total_Cost_value__c == null)?0:optionRec.Total_Cost_value__c;
            if(sfoParentToOptions.containsKey(optionRec.Option_Parent__c)){
                decimal totCost = sfoParentToOptions.get(optionRec.Option_Parent__c)+totalCost;
                sfoParentToOptions.put(optionRec.Option_Parent__c, totCost);  
            }else{
                sfoParentToOptions.put(optionRec.Option_Parent__c, totalCost);   
            }          
        }
        for(Special_Feature_Option__c parentSFO :parentSFOs){
            
            if(sfoParentToOptions.containsKey(parentSFO.Id)){ parentSFO.Total_Cost1__c =  sfoParentToOptions.get(parentSFO.Id);
            }
        }
        
        if(parentSFOs.size() > 0){
            hasRollUp = false; update parentSFOs;    
        }
    }
}