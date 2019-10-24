public class unitTagewithRelatedSFO_Controller {
    public string fpa_ID;
    public string pdfcontent{set;get;}
    public Map<id,List<FPA_Link__c>> fpaMap {set;get;}
    public Factory_Pricing_Authorization__c FPA_rec{get;set;}
    public Attachment attch {get;set;}
    public Map<id,List<Related_SFO__c>> unitTagMap {get;set;}
    public Map<id,List<unitTagWrapper>> unitRelatedSFOWrap {set;get;}
    public Map<id,List<unitTagSumWrapper>> unitTagSumWrap {set;get;}
    public Map<id,FPA_Link__c> fpaLinkMap {set;get;}
    public String getFPA_Id(){ return FPA_Id; }
    public void setFPA_Id(String s){
        FPA_Id = s;
        unitTagewithRelatedSFO_Controller();
    }
    
    public void unitTagewithRelatedSFO_Controller(){
        Set<id> fpaLinkIds=new set<id>();
        //Map<id,Related_SFO__c>
        //Map<id,List<>
        system.debug('fpaID '+fpa_ID);
        set<id> sfoIds=new set<id>();
        unitTagMap=new Map<id,List<Related_SFO__c>>();
        fpaMap=new Map<id,List<FPA_Link__c>>();
        fpaLinkMap = new Map<id,FPA_Link__c>();
        FPA_rec = new Factory_Pricing_Authorization__c();
        for(Factory_Pricing_Authorization__c fpa:[select id,QTY_of_line_Item_with_Specials__c,Max_QTY_of_Units_On_Single_Line_Item__c,MaxTotalMaterialCostforSingleLine__c,FPATotalDraftingHours__c,Max_Total_Drafting_Hours_per_Single_line__c,FPATotalEngineeringHours__c,Max_Total_Engineering_Hours_for_Single__c,FPATotalManufacturingHours__c,Max_Total_Manufacturing_Hours_for_Single__c,
                                                  Multiplier__c,Risk__c,Risk_Mitigation_Plan__c,Submitted__c,Total_List_Price__c,Total_Margind__c,Total_Marginp__c,Application_Engineer__r.name,Base_Unit_to_be_Modified__r.Description__c,SO_Number__c,Average_List_Price_Markup__c,
                                                  Total_Margin__c,Description__c,Total_Cost__c,Internal_Notes__c,Costt__c,Cost_unit__c,List_Price__c,name,Job_ID__c, FPA_Number__c, Office__r.Name, Sales_Person__r.Name,Approval_Level__c,(select id,name,Quantity__c,Lead_Time__c from Related_SFO__r) from Factory_Pricing_Authorization__c where Id =:fpa_ID ])
        {FPA_rec=fpa;
         system.debug('fpa '+fpa);
         for(FPA_Link__c fpalink:fpa.Related_SFO__r){
             fpaLinkMap.put(fpalink.Id,fpalink);
             fpaLinkIds.add(fpalink.id);
             if(fpaMap.containsKey(fpa.id)) {   
                 fpaMap.get(fpa.id).add(fpalink);}
             else {fpaMap.put(fpa.id,new list<FPA_Link__c>{fpalink}); }
         }
        }
        attch=new attachment();
        //attch=[select id,name,body,contenttype from attachment where parentid='aEg0t000000CgZ3' and contenttype='Application/PDF' limit 1 ];
        //pdfcontent=EncodingUtil.Base64Encode(attch.body);
        system.debug('fpaLinkIds '+fpaLinkIds);
        Map<id,id> relatedSFOMap=new Map<id,id>();
        List<Related_SFO__c> relatedSFOList=new List<Related_SFO__c>();
        for(Related_SFO__c rfo:[select id,name,Expected_Margin__c,SFO_Margin_Line_Item__c,Total_Cost__c,SFO__c,List_Price__c,SFO__r.Name__c,SFO__r.Option_Parent__r.name,SFO__r.Drafting_hours__c,Unit_Detail__c from Related_SFO__c where Unit_Detail__c =: fpaLinkIds ]){
            sfoIds.add(rfo.SFO__c);
            relatedSFOMap.put(rfo.id, rfo.SFO__c);
            relatedSFOList.add(rfo);
            if(unitTagMap.containsKey(rfo.Unit_Detail__c)) {   
                unitTagMap.get(rfo.Unit_Detail__c).add(rfo);}
            else {unitTagMap.put(rfo.Unit_Detail__c,new list<Related_SFO__c>{rfo}); }
            
        }
        set<string> dynamicFieldList =new set<string>{'Material Cost','Drafting Hours','Manufacturing Hours','Engineering Hours','Modifier Cost'};
            
            //select id,name,(select id,name from SFO_Dynamic_Fields__r) from Special_Feature_Option__c limit 10
            Map<Id,List<SFO_Dynamic_Fields__c>> sfoDynamicMap=new Map<Id,List<SFO_Dynamic_Fields__c>>();
        for(Special_Feature_Option__c sfos:[select id,name,Total_Cost_value__c,(select id,name,Field_Value__c,Field_Value_Number__c from SFO_Dynamic_Fields__r where name =:dynamicFieldList ) from Special_Feature_Option__c where Id =:sfoIds ])
        {
            sfoDynamicMap.put(sfos.id,sfos.SFO_Dynamic_Fields__r);
            /* for(SFO_Dynamic_Fields__c dym:sfos.SFO_Dynamic_Fields__r){
if(sfoDynamicMap.containsKey(sfos.id)) {   
sfoDynamicMap.get(sfos.id).add(dym);}
else {sfoDynamicMap.put(sfos.id,new list<SFO_Dynamic_Fields__c>{dym}); } 
}*/
        }
        unitRelatedSFOWrap=new Map<id,List<unitTagWrapper>>();
        system.debug('relatedSFOList '+relatedSFOList);
        system.debug('sfoDynamicMap '+sfoDynamicMap);
        for(Related_SFO__c rf:relatedSFOList){
            decimal draftingHrs;
            decimal manufacturingHrs;
            decimal engineeringHrs;
            decimal materialCost;
            decimal modifierCost; 
            decimal totalDraftHrs =0;
            decimal totalEngHrs=0;
            decimal totalMfgHrs=0;
            decimal totalMatCost=0;
            decimal totalModiCost=0;
            decimal totalCost=0;
            decimal totalmargin=0;
            
            system.debug('rf '+rf.Name +' DYN '+sfoDynamicMap.get(rf.SFO__c));
            for(SFO_Dynamic_Fields__c dynamicfield:sfoDynamicMap.get(rf.SFO__c) ){
                if(dynamicField.name.equalsIgnoreCase('Drafting Hours')){
                    draftingHrs = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    totalDraftHrs+=draftingHrs;
                }
                else if(dynamicField.name.equalsIgnoreCase('Manufacturing Hours')){
                    manufacturingHrs = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    totalMfgHrs+=manufacturingHrs;
                }
                
                else if(dynamicField.name.equalsIgnoreCase('Engineering Hours')){
                    engineeringHrs = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    totalEngHrs+=engineeringHrs;
                }
                
                else if (dynamicField.name.equalsIgnoreCase('Material Cost')){
                    materialCost = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    totalMatCost+=materialCost;
                }
                
                else if (dynamicField.name.equalsIgnoreCase('Modifier Cost')){
                    modifierCost = (dynamicField.field_Value__c==null)?0:decimal.valueOf(dynamicField.field_Value__c);
                    totalModiCost+=modifierCost;
                } 
            }
            if(unitRelatedSFOWrap.containskey(rf.Unit_Detail__c)){   
                unitRelatedSFOWrap.get(rf.Unit_Detail__c).add(new unitTagWrapper(rf.Name,rf.SFO__r.Name__c,draftingHrs,engineeringHrs,manufacturingHrs,materialCost,modifierCost,rf.Total_Cost__c,rf.SFO_Margin_Line_Item__c));
            }
            else{
                unitRelatedSFOWrap.put(rf.Unit_Detail__c,new list<unitTagWrapper>{new unitTagWrapper(rf.Name,rf.SFO__r.Name__c,draftingHrs,engineeringHrs,manufacturingHrs,materialCost,modifierCost,rf.Total_Cost__c,rf.SFO_Margin_Line_Item__c)}); 
            }
            /*  if(unitTagSumWrap.containsKey(rf.Unit_Detail__c)){
unitTagSumWrap.get(rf.Unit_Detail__c).add(new unitTagSumWrapper(totalDraftHrs,totalEngHrs,totalMfgHrs,totalMatCost,totalModiCost,totalCost,totalmargin));
}
else{
unitTagSumWrap.put(rf.Unit_Detail__c,new list<unitTagSumWrapper>{new unitTagSumWrapper(totalDraftHrs,totalEngHrs,totalMfgHrs,totalMatCost,totalModiCost,totalCost,totalmargin)}); 
}*/
        }
        system.debug('unitRelatedSFOWrap '+unitRelatedSFOWrap);
        
    }
    public class unitTagWrapper{
        public string optionName {set;get;}
        public string specialFeature {set;get;}
        public decimal drafHours {set;get;}
        public decimal engHours {set;get;}
        public decimal mfgHours {set;get;}
        public Decimal matCost {set;get;}
        public Decimal modiCost {set;get;}
        public Decimal totalCost {set;get;}
        public Decimal margin {set;get;}
        
        public unitTagWrapper(string optionNam,string specialFeatur,Decimal drafHour,Decimal engHour,Decimal mfgHour,
                              Decimal matCos,Decimal modiCos,Decimal totalCos,Decimal margi){
                                  optionName=optionNam;
                                  specialFeature=specialFeatur;
                                  drafHours=drafHour;
                                  engHours=engHour;
                                  mfgHours=mfgHour;
                                  matCost=matCos;
                                  modiCost=modiCos;
                                  totalCost=totalCos;
                                  margin=margi;    
                              }
    }
    
    public class unitTagSumWrapper{
        public  decimal totalDraftHrs {set;get;}
        public  decimal totalEngHrs{set;get;}
        public   decimal totalMfgHrs{set;get;}
        public  decimal totalMatCost{set;get;}
        public  decimal totalModiCost{set;get;}
        public decimal totalCost{set;get;}
        public decimal totalmargin{set;get;} 
        public unitTagSumWrapper(decimal totalDraftHr,decimal totalEngHr,decimal totalMfgHr,decimal totalMatCos,decimal totalModiCos,
                                 decimal totalCos,decimal totalmargi){
                                     totalDraftHrs=totalDraftHr;
                                     totalEngHrs=totalEngHr;
                                     totalMfgHrs=totalMfgHr;
                                     totalMatCost=totalMatCos;
                                     totalModiCost=totalModiCos;
                                     totalCost=totalCos;
                                     totalmargin=totalmargi;
                                 }
    }
}