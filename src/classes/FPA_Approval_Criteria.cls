public class FPA_Approval_Criteria {
    public static boolean isApprovalLevelUpdated= False;
    public static void updateApprovalLevel(Factory_Pricing_Authorization__c FPARec){
        string FPANumber =FPARec.FPA_Number__c;
        if(FPARec.FPA_Number__c!=null && FPARec.Approval_level__c!=null)
        {
            isApprovalLevelUpdated = true;
            string lastChar =FPANumber.substring(FPANumber.length()- 1);
            string exceptlastChar =FPANumber.substring(0, FPANumber.length()- 1);
            String lastIndex = exceptlastChar.substring(exceptlastChar.length()- 1);
            System.debug('lastIndex::'+lastIndex);
            if(lastIndex.isNumeric()){
                System.debug('exceptlastChar:'+exceptlastChar);
                System.debug('Approval Level:'+FPARec.Approval_level__c);
                System.debug('lastChar:'+lastChar);
            	FPARec.FPA_Number__c= exceptlastChar+FPARec.Approval_level__c+lastChar; 
                
               	System.debug('IF  FPA Number:'+FPARec.FPA_Number__c);
            }else{
                System.debug('Else Before FPA Number:'+FPARec.FPA_Number__c);
           		FPARec.FPA_Number__c= exceptlastChar.replace(lastIndex,FPARec.Approval_level__c)+lastChar; 
                System.debug('Else After FPA Number:'+FPARec.FPA_Number__c);
            }
        }
        //return FPARec.FPA_Number__c;
    }
    public static Approval_Criteria__c defaultValues(Approval_Criteria__c ac)
    {
        if(ac.QTY_of_line_Item_with_Specials__c==null){
            ac.QTY_of_line_Item_with_Specials__c='0';
        }
        if(ac.Max_Total_Material_Cost_for_Single_Line__c==null){
            ac.Max_Total_Material_Cost_for_Single_Line__c='0';
        }
        if(ac.Max_Total_Manufacturing_Hours_for_Single__c==null){
            ac.Max_Total_Manufacturing_Hours_for_Single__c='0';
        }
        if(ac.Max_Total_Engineering_Hours_for_Single__c==null){
            ac.Max_Total_Engineering_Hours_for_Single__c='0';
        }
        if(ac.Max_Total_Drafting_Hours_per_Single_l__c==null){
            ac.Max_Total_Drafting_Hours_per_Single_l__c='0';
        }
        if(ac.Max_QTY_of_Units_On_Single_Line_Item__c==null){
            ac.Max_QTY_of_Units_On_Single_Line_Item__c='0';
        }
        if(ac.FPA_Total_Manufacturing_Hours__c==null){
            ac.FPA_Total_Manufacturing_Hours__c='0';
        }
        if(ac.FPA_Total_Engineering_Hours__c==null){
            ac.FPA_Total_Engineering_Hours__c='0';
        } 
        if(ac.FPA_Total_Drafting_Hours__c==null){
            ac.FPA_Total_Drafting_Hours__c='0';
        } 
        
        return ac;
    }
    
    public static void performApprovalLevels(Map<String,Factory_Pricing_Authorization__c> FPAMap)
    {
        system.debug('Enter into performApprovalLevels method');
        set<String> FPA_formatIds = new set<String>();
        list<Factory_Pricing_Authorization__c> FPAList =new  list<Factory_Pricing_Authorization__c>();
        Map<String,list<wrapperClass>> FormatIdToApprovalCriteriaMap =new Map<String,list<wrapperClass>>();
        Map<string,string> FPAIdtoFormatIdsMap =new Map<string,string>();
        Map<String,list<wrapperClass>> FPAIdToApprovalCriteriaMap =new Map<String,list<wrapperClass>>();
        Map<string,Map<string,wrapperClass>> approvalKeyToWrapper =new Map<string,Map<string,wrapperClass>>();
        
        try
        {
            system.debug('FPAMap::'+FPAMap);
            for(Factory_Pricing_Authorization__c fpaRec :FPAMap.values()){
                FPA_formatIds.add(fpaRec.Base_Unit_to_be_Modified__c);
                
                FPAIdtoFormatIdsMap.put(fpaRec.id,fpaRec.Base_Unit_to_be_Modified__c);
            }
            system.debug('FPAIdtoFormatIdsMap::'+FPAIdtoFormatIdsMap);
            list<Approval_Criteria__c> approvalCriteriaList =[SELECT id,Approval_Level__c,
                                                              FPA_Total_Drafting_Hours__c,
                                                              FPA_Total_Engineering_Hours__c,
                                                              FPA_Total_Manufacturing_Hours__c,
                                                              Max_QTY_of_Units_On_Single_Line_Item__c,
                                                              Max_Total_Drafting_Hours_per_Single_l__c,
                                                              Max_Total_Engineering_Hours_for_Single__c,
                                                              Max_Total_Manufacturing_Hours_for_Single__c,
                                                              Max_Total_Material_Cost_for_Single_Line__c,
                                                              QTY_of_line_Item_with_Specials__c,Format__c
                                                              FROM Approval_Criteria__c 
                                                              WHERE Format__c IN : FPA_formatIds 
                                                              order by  Approval_Level__c desc ];
            system.debug('approvalCriteriaList::'+approvalCriteriaList);
            Map<string,wrapperClass> WrapperMap = new Map<string,wrapperClass>();
            
            for (Approval_Criteria__c appCriteria :approvalCriteriaList)
            { 
                appCriteria=defaultValues(appCriteria);
                if(FormatIdToApprovalCriteriaMap.containsKey(appCriteria.Format__c))
                {
                    FormatIdToApprovalCriteriaMap.get(appCriteria.Format__c).add(new wrapperClass(appCriteria));  
                }
                else{
                    FormatIdToApprovalCriteriaMap.put(appCriteria.Format__c,new list<wrapperClass>{new wrapperClass(appCriteria)});  
                }
            }
            for (string fpaId :FPAIdtoFormatIdsMap.keySet())
            {
                String formatId = FPAIdtoFormatIdsMap.get(fpaId);
                if(FormatIdToApprovalCriteriaMap.containsKey(formatId))  
                {
                    FPAIdToApprovalCriteriaMap.put(fpaId,FormatIdToApprovalCriteriaMap.get(formatId)); 
                }
            }
            
            Map<String, wrapperClass> fpaWithApprovalRanges = new Map<String, wrapperClass>();
            for (String fpaId :FPAIdToApprovalCriteriaMap.keyset())
            {
                for(wrapperClass w :FPAIdToApprovalCriteriaMap.get(fpaId)){
                    system.debug('Test ::'+w.appRec.Approval_Level__c);
                    if(w.appRec.Approval_Level__c == 'D'){
                        fpaWithApprovalRanges.put('D', w);		    
                    }else if(w.appRec.Approval_Level__c == 'C'){
                        if(fpaWithApprovalRanges.containsKey('D')){
                            wrapperClass wr = fpaWithApprovalRanges.get('D');
                            
                            wr.QTY_D_UpperRange = Integer.valueOf(w.appRec.QTY_of_line_Item_with_Specials__c);
                            wr.MaxQTY_D_UpperRange = Integer.valueOf(w.appRec.Max_QTY_of_Units_On_Single_Line_Item__c);
                            wr.MaxTotal_MaterialCost_D_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Material_Cost_for_Single_Line__c);
                            wr.FPATotal_DraftingHours_D_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Drafting_Hours__c);
                            wr.MaxTota_DraftingHours_D_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Drafting_Hours_per_Single_l__c);
                            wr.FPATotal_Enginnering_Hours_D_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Engineering_Hours__c);
                            wr.MaxTotal_Enginnering_Hours_D_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Engineering_Hours_for_Single__c);
                            wr.FPATotal_Manufacturing_Hours_D_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Manufacturing_Hours__c);
                            wr.MaxTotal_Manufacturing_Hours_D_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Manufacturing_Hours_for_Single__c);
                            
                            System.debug('wr.QTY_D_UpperRange::'+wr.QTY_D_UpperRange);
                            fpaWithApprovalRanges.put('C', w);
                        }    
                    }else if(w.appRec.Approval_Level__c == 'B'){
                        if(fpaWithApprovalRanges.containsKey('C')){
                            wrapperClass wr = fpaWithApprovalRanges.get('C'); 
                            
                            wr.QTY_C_UpperRange = Integer.valueOf(w.appRec.QTY_of_line_Item_with_Specials__c);
                            wr.MaxQTY_C_UpperRange = Integer.valueOf(w.appRec.Max_QTY_of_Units_On_Single_Line_Item__c);
                            wr.MaxTotal_MaterialCost_C_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Material_Cost_for_Single_Line__c);
                            wr.FPATotal_DraftingHours_C_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Drafting_Hours__c);
                            wr.MaxTota_DraftingHours_C_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Drafting_Hours_per_Single_l__c);
                            wr.FPATotal_Enginnering_Hours_C_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Engineering_Hours__c);
                            wr.MaxTotal_Enginnering_Hours_C_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Engineering_Hours_for_Single__c);
                            wr.FPATotal_Manufacturing_Hours_C_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Manufacturing_Hours__c);
                            wr.MaxTotal_Manufacturing_Hours_C_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Manufacturing_Hours_for_Single__c);
                            
                            fpaWithApprovalRanges.put('B', w);
                        }    
                    }else if(w.appRec.Approval_Level__c == 'A'){
                        if(fpaWithApprovalRanges.containsKey('B')){
                            wrapperClass wr = fpaWithApprovalRanges.get('B'); 
                            
                            wr.QTY_B_UpperRange = Integer.valueOf(w.appRec.QTY_of_line_Item_with_Specials__c);
                            wr.MaxQTY_B_UpperRange = Integer.valueOf(w.appRec.Max_QTY_of_Units_On_Single_Line_Item__c);
                            wr.MaxTotal_MaterialCost_B_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Material_Cost_for_Single_Line__c);
                            wr.FPATotal_DraftingHours_B_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Drafting_Hours__c);
                            wr.MaxTota_DraftingHours_B_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Drafting_Hours_per_Single_l__c);
                            wr.FPATotal_Enginnering_Hours_B_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Engineering_Hours__c);
                            wr.MaxTotal_Enginnering_Hours_B_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Engineering_Hours_for_Single__c);
                            wr.FPATotal_Manufacturing_Hours_B_UpperRange = Decimal.valueOf(w.appRec.FPA_Total_Manufacturing_Hours__c);
                            wr.MaxTotal_Manufacturing_Hours_B_UpperRange = Decimal.valueOf(w.appRec.Max_Total_Manufacturing_Hours_for_Single__c);
                            
                            fpaWithApprovalRanges.put('A', w);
                        }    
                    }    
                }
                approvalKeyToWrapper.put(fpaId, fpaWithApprovalRanges);
            }
            Map<String, set<String>> fpaApprovalLevels = new Map<String, set<String>>();
            system.debug('approvalKeyToWrapper::'+approvalKeyToWrapper);
            for(String fpaId :approvalKeyToWrapper.keyset()){
                Factory_Pricing_Authorization__c fpa = fpaMap.get(fpaId);
                Map<String, wrapperClass> wrap = approvalKeyToWrapper.get(fpaId);
                for(String approvalLevel :wrap.keySet()){
                    wrapperClass w = wrap.get(approvalLevel);
                    if(approvalLevel == 'D'){
                        System.debug('FPA Quantity::'+fpa.QTY_of_line_Item_with_Specials__c);
                        System.debug('D Upper Range::'+Integer.valueOf(w.QTY_D_UpperRange));
                        if(fpa.QTY_of_line_Item_with_Specials__c >= 0 && 
                           fpa.QTY_of_line_Item_with_Specials__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           }   
                        
                        if(fpa.Max_QTY_of_Units_On_Single_Line_Item__c >= 0 && 
                           fpa.Max_QTY_of_Units_On_Single_Line_Item__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           } 
                        if(fpa.MaxTotalMaterialCostforSingleLine__c >= 0 && 
                           fpa.MaxTotalMaterialCostforSingleLine__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           }
                        
                        if(fpa.FPATotalDraftingHours__c >= 0 && 
                           fpa.FPATotalDraftingHours__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           }
                        if(fpa.Max_Total_Drafting_Hours_per_Single_line__c >= 0 && 
                           fpa.Max_Total_Drafting_Hours_per_Single_line__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           }
                        if(fpa.FPATotalEngineeringHours__c >= 0 && 
                           fpa.FPATotalEngineeringHours__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           }
                        if(fpa.Max_Total_Engineering_Hours_for_Single__c >= 0 && 
                           fpa.Max_Total_Engineering_Hours_for_Single__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           }
                        if(fpa.FPATotalManufacturingHours__c >= 0 && 
                           fpa.FPATotalManufacturingHours__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           }
                        if(fpa.Max_Total_Manufacturing_Hours_for_Single__c >= 0 && 
                           fpa.Max_Total_Manufacturing_Hours_for_Single__c < Integer.valueOf(w.QTY_D_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('D');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'D'});    
                               }	     
                           }
                        
                    }
                    else if(approvalLevel == 'C'){
                        System.debug('C Lower Range::'+w.appRec.QTY_of_line_Item_with_Specials__c);
                        System.debug('C Upper Range::'+Integer.valueOf(w.QTY_C_UpperRange));
                        if(fpa.QTY_of_line_Item_with_Specials__c > Integer.valueOf(w.appRec.QTY_of_line_Item_with_Specials__c)
                           && fpa.QTY_of_line_Item_with_Specials__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                        if(fpa.Max_QTY_of_Units_On_Single_Line_Item__c > Integer.valueOf(w.appRec.Max_QTY_of_Units_On_Single_Line_Item__c)
                           && fpa.Max_QTY_of_Units_On_Single_Line_Item__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                        if(fpa.MaxTotalMaterialCostforSingleLine__c> Decimal.valueOf(w.appRec.Max_Total_Material_Cost_for_Single_Line__c)
                           && fpa.MaxTotalMaterialCostforSingleLine__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                        if(fpa.FPATotalDraftingHours__c> Decimal.valueOf(w.appRec.FPA_Total_Drafting_Hours__c)
                           && fpa.FPATotalDraftingHours__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                        if(fpa.Max_Total_Drafting_Hours_per_Single_line__c > Decimal.valueOf(w.appRec.Max_Total_Drafting_Hours_per_Single_l__c)
                           && fpa.Max_Total_Drafting_Hours_per_Single_line__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                        if(fpa.FPATotalEngineeringHours__c > Decimal.valueOf(w.appRec.FPA_Total_Engineering_Hours__c)
                           && fpa.FPATotalEngineeringHours__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                        if(fpa.Max_Total_Engineering_Hours_for_Single__c > Decimal.valueOf(w.appRec.Max_Total_Engineering_Hours_for_Single__c)
                           && fpa.Max_Total_Engineering_Hours_for_Single__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                        if(fpa.FPATotalManufacturingHours__c > Decimal.valueOf(w.appRec.FPA_Total_Manufacturing_Hours__c)
                           && fpa.FPATotalManufacturingHours__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                        if(fpa.Max_Total_Manufacturing_Hours_for_Single__c > Decimal.valueOf(w.appRec.Max_Total_Manufacturing_Hours_for_Single__c)
                           && fpa.Max_Total_Manufacturing_Hours_for_Single__c <= Integer.valueOf(w.QTY_C_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('C');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'C'});    
                               }	     
                           }
                        
                    }
                    else if(approvalLevel == 'B'){
                        System.debug('B Lower Range::'+w.appRec.QTY_of_line_Item_with_Specials__c);
                        System.debug('B Upper Range::'+Integer.valueOf(w.QTY_B_UpperRange));
                        if(fpa.QTY_of_line_Item_with_Specials__c > Integer.valueOf(w.appRec.QTY_of_line_Item_with_Specials__c)
                           && fpa.QTY_of_line_Item_with_Specials__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                        if(fpa.Max_QTY_of_Units_On_Single_Line_Item__c > Integer.valueOf(w.appRec.Max_QTY_of_Units_On_Single_Line_Item__c)
                           && fpa.Max_QTY_of_Units_On_Single_Line_Item__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                        if(fpa.MaxTotalMaterialCostforSingleLine__c > Decimal.valueOf(w.appRec.Max_Total_Material_Cost_for_Single_Line__c)
                           && fpa.MaxTotalMaterialCostforSingleLine__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                        if(fpa.FPATotalDraftingHours__c > Decimal.valueOf(w.appRec.FPA_Total_Drafting_Hours__c)
                           && fpa.FPATotalDraftingHours__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                        if(fpa.Max_Total_Drafting_Hours_per_Single_line__c > Decimal.valueOf(w.appRec.Max_Total_Drafting_Hours_per_Single_l__c)
                           && fpa.Max_Total_Drafting_Hours_per_Single_line__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                        if(fpa.FPATotalEngineeringHours__c > Decimal.valueOf(w.appRec.FPA_Total_Engineering_Hours__c)
                           && fpa.FPATotalEngineeringHours__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                        if(fpa.Max_Total_Engineering_Hours_for_Single__c > Decimal.valueOf(w.appRec.Max_Total_Engineering_Hours_for_Single__c)
                           && fpa.Max_Total_Engineering_Hours_for_Single__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                        if(fpa.FPATotalManufacturingHours__c > Decimal.valueOf(w.appRec.FPA_Total_Manufacturing_Hours__c)
                           && fpa.FPATotalManufacturingHours__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                        if(fpa.Max_Total_Manufacturing_Hours_for_Single__c > Decimal.valueOf(w.appRec.Max_Total_Manufacturing_Hours_for_Single__c)
                           && fpa.Max_Total_Manufacturing_Hours_for_Single__c <= Integer.valueOf(w.QTY_B_UpperRange)){
                               if(fpaApprovalLevels.containskey(fpaId)){
                                   fpaApprovalLevels.get(fpaId).add('B');    
                               }else{
                                   fpaApprovalLevels.put(fpaId, new set<String>{'B'});    
                               }	     
                           }
                        
                    }else{
                        if(fpa.QTY_of_line_Item_with_Specials__c > Integer.valueOf(w.appRec.QTY_of_line_Item_with_Specials__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        }
                        
                        if(fpa.Max_QTY_of_Units_On_Single_Line_Item__c > Integer.valueOf(w.appRec.Max_QTY_of_Units_On_Single_Line_Item__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        } 
                        
                        if(fpa.MaxTotalMaterialCostforSingleLine__c > Decimal.valueOf(w.appRec.Max_Total_Material_Cost_for_Single_Line__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        } 
                        if(fpa.FPATotalDraftingHours__c > Decimal.valueOf(w.appRec.FPA_Total_Drafting_Hours__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        } 
                        if(fpa.Max_Total_Drafting_Hours_per_Single_line__c > Decimal.valueOf(w.appRec.Max_Total_Drafting_Hours_per_Single_l__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        }
                        if(fpa.FPATotalEngineeringHours__c > Decimal.valueOf(w.appRec.FPA_Total_Engineering_Hours__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        }
                        if(fpa.Max_Total_Engineering_Hours_for_Single__c > Decimal.valueOf(w.appRec.Max_Total_Engineering_Hours_for_Single__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        }
                        if(fpa.FPATotalManufacturingHours__c > Decimal.valueOf(w.appRec.FPA_Total_Manufacturing_Hours__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        }
                        if(fpa.Max_Total_Manufacturing_Hours_for_Single__c > Decimal.valueOf(w.appRec.Max_Total_Manufacturing_Hours_for_Single__c)){
                            if(fpaApprovalLevels.containskey(fpaId)){
                                fpaApprovalLevels.get(fpaId).add('A');    
                            }else{
                                fpaApprovalLevels.put(fpaId, new set<String>{'A'});    
                            }	     
                        }
                    }
                    
                }
                
            }
            System.debug('fpaApprovalLevels::'+fpaApprovalLevels);
            for(String fpaId : fpaMap.keySet()){
                set<String> fpaStatus = new set<String>();
                if(fpaApprovalLevels.containsKey(fpaId)){
                    fpaStatus= fpaApprovalLevels.get(fpaId); 
                    Factory_Pricing_Authorization__c fpa = fpaMap.get(fpaId);
                    if(fpaStatus.contains('A')){
                        fpa = fpaMap.get(fpaId);  
                        fpa.Approval_level__c ='A';
                        
                    }else if(fpaStatus.contains('B')){
                        fpa = fpaMap.get(fpaId);  
                        fpa.Approval_level__c ='B';
                    }else if (fpaStatus.contains('C')){
                        fpa = fpaMap.get(fpaId);  
                        fpa.Approval_level__c ='C';
                    }
                    else
                    {
                        fpa = fpaMap.get(fpaId);  
                        fpa.Approval_level__c ='D';
                    } 
                    if(fpa.FPA_Number__c!=null && fpa.Approval_level__c!=null)
                    {
                        System.debug('Test::'+fpa.FPA_Number__c);
                        isApprovalLevelUpdated = true;
                        updateApprovalLevel(fpa);
                    }
                }
                
            }
        }           
        catch(Exception e)
        {
            system.debug('Exceptions are::'+'Line Number::'+e.getLineNumber()+ ''+ e.getMessage());
        }
    }
    
    public class wrapperClass{
        public Approval_Criteria__c appRec ;
        
        public Integer QTY_D_UpperRange;
        public Integer QTY_C_UpperRange;
        public Integer QTY_B_UpperRange;
        
        public Integer  MaxQTY_D_UpperRange;
        public Integer  MaxQTY_C_UpperRange;
        public Integer  MaxQTY_B_UpperRange;
        
        public Decimal  MaxTotal_MaterialCost_D_UpperRange;
        public Decimal  MaxTotal_MaterialCost_C_UpperRange;
        public Decimal  MaxTotal_MaterialCost_B_UpperRange;
        
        public Decimal FPATotal_DraftingHours_D_UpperRange;
        public Decimal FPATotal_DraftingHours_C_UpperRange;
        public Decimal FPATotal_DraftingHours_B_UpperRange;
        
        public Decimal MaxTota_DraftingHours_D_UpperRange;
        public Decimal MaxTota_DraftingHours_C_UpperRange;
        public Decimal MaxTota_DraftingHours_B_UpperRange;
        
        public Decimal FPATotal_Enginnering_Hours_D_UpperRange;
        public Decimal FPATotal_Enginnering_Hours_C_UpperRange;
        public Decimal FPATotal_Enginnering_Hours_B_UpperRange;
        
        public Decimal MaxTotal_Enginnering_Hours_D_UpperRange;
        public Decimal MaxTotal_Enginnering_Hours_C_UpperRange;
        public Decimal MaxTotal_Enginnering_Hours_B_UpperRange;
        
        public Decimal FPATotal_Manufacturing_Hours_D_UpperRange;
        public Decimal FPATotal_Manufacturing_Hours_C_UpperRange;
        public Decimal FPATotal_Manufacturing_Hours_B_UpperRange;
        
        public Decimal MaxTotal_Manufacturing_Hours_D_UpperRange;
        public Decimal MaxTotal_Manufacturing_Hours_C_UpperRange;
        public Decimal MaxTotal_Manufacturing_Hours_B_UpperRange;
        
        public wrapperClass(Approval_Criteria__c appCriteriaRecord)
        {
            this.appRec = appCriteriaRecord;    
            
        }
    }
}