public class unitTagewithRelatedSFOExt_Controller {
    public string fpa_ID;
    public string pdfcontent{set;get;}
    public Set<Id> RFOId = new Set<Id>();
    public Map<id,List<FPA_Link__c>> fpaMap {set;get;}
    public Factory_Pricing_Authorization__c FPA_rec{get;set;}
    public List<Attachment> attachmnt {get;set;}
    public Map<id,List<Related_SFO__c>> unitTagMap {get;set;}
    public Map<id,List<unitTagWrapper>> unitRelatedSFOWrap {set;get;}
    public Map<id,FPA_Link__c> fpaLinkMap {set;get;}
    public String getFPA_Id(){ return FPA_Id; }
    List<FPA_Link__c> fpaLinkList {get;set;}
    public void setFPA_Id(String s){
        FPA_Id = s;
        unitTagewithRelatedSFOExt_Controller();
    }
    
    public void unitTagewithRelatedSFOExt_Controller(){
        Set<id> fpaLinkIds = new set<id>();
        system.debug('fpaID '+fpa_ID);
        set<id> sfoIds = new set<id>();
        unitTagMap = new Map<id,List<Related_SFO__c>>();
        fpaMap = new Map<id,List<FPA_Link__c>>();
        fpaLinkMap = new Map<id,FPA_Link__c>();
        FPA_rec = new Factory_Pricing_Authorization__c();
        for(Factory_Pricing_Authorization__c fpa : [Select Id, Created_Date__c , Owner.Name, Application_Engineer__r.Name, Phone__c, Multiplier__c, Description__c , Average_List_Price_Markup__c, Total_Margin__c, Costt__c, List_Price__c, Name, Job_ID__c, FPA_Number__c, Office__r.Name, Sales_Person__r.Name, Approval_Level__c, Base_Unit_to_be_Modified__r.Description__c, (Select Id, Name,Quantity__c, Lead_Time__c from Related_SFO__r) from Factory_Pricing_Authorization__c where Id =:fpa_ID ])
        {
            FPA_rec = fpa;
            system.debug('fpa '+fpa);
            for(FPA_Link__c fpalink:fpa.Related_SFO__r){
                
                fpaLinkMap.put(fpalink.Id,fpalink);
                fpaLinkIds.add(fpalink.id);
                if(fpaMap.containsKey(fpa.id)) {   
                    fpaMap.get(fpa.id).add(fpalink);}
                else {
                    fpaMap.put(fpa.id,new list<FPA_Link__c>{fpalink});
                }
            }
        }
        
        system.debug('fpaLinkIds '+fpaLinkIds);
        Map<id,id> relatedSFOMap = new Map<id,id>();
        List<Related_SFO__c> relatedSFOList = new List<Related_SFO__c>();
        
        for(Related_SFO__c rfo : [Select Id, Name, Expected_Margin__c, Total_Cost__c, SFO__c, SFO__r.Option_Parent__r.Notes__c, List_Price__c, SFO__r.name, SFO__r.Option_Parent__r.name, SFO__r.Drafting_hours__c, Unit_Detail__c, SFO__r.Notes__c,SFO__r.Component_Name__c ,SFO__r.Revision_Version__c,SFO__r.Section_Name__c from Related_SFO__c where Unit_Detail__c =: fpaLinkIds ]){
            sfoIds.add(rfo.SFO__c);
            RFOId.add(rfo.Id);
            relatedSFOMap.put(rfo.id, rfo.SFO__c);
            relatedSFOList.add(rfo);
            if(unitTagMap.containsKey(rfo.Unit_Detail__c)) {   
                unitTagMap.get(rfo.Unit_Detail__c).add(rfo);}
            else {unitTagMap.put(rfo.Unit_Detail__c,new list<Related_SFO__c>{rfo}); }
        }
        
        attachmnt = new List<Attachment>();        
        attachmnt = [Select Id, Name, Body, Contenttype, ParentId,Parent.Name From Attachment where parentid IN: RFOId and contenttype='Application/PDF'];
        Map<Id,String> AtUnitTagMap = new Map<Id,String>();
        for(Attachment att : attachmnt){
            pdfcontent = EncodingUtil.Base64Encode(att.Body);
            
        }
        //pdfcontent = EncodingUtil.Base64Encode(attachmnt.Body);
        fpaLinkList = [Select Id, Name,(Select Id, Name From Related_SFO__r where Id IN : RFOId) From FPA_Link__c ];
        for(FPA_Link__c fpaLink : fpaLinkList){
           
            
        }
        set<string> dynamicFieldList = new set<string>{'Material Cost','Drafting Hours','Manufacturing Hours','Engineering Hours','Modifier Cost'};
            
            Map<Id,List<SFO_Dynamic_Fields__c>> sfoDynamicMap = new Map<Id,List<SFO_Dynamic_Fields__c>>();
        for(Special_Feature_Option__c sfos : [Select Id, Name, Total_Cost_value__c, Component_Name__c, Section_Name__c, Revision_Version__c, (Select Id, Name, Field_Value__c, Field_Value_Number__c from SFO_Dynamic_Fields__r where name =:dynamicFieldList ) from Special_Feature_Option__c where Id =:sfoIds ])
        {
            sfoDynamicMap.put(sfos.id,sfos.SFO_Dynamic_Fields__r);
            
        }
        unitRelatedSFOWrap=new Map<id,List<unitTagWrapper>>();
        system.debug('relatedSFOList '+relatedSFOList);
        system.debug('sfoDynamicMap '+sfoDynamicMap);
        for(Related_SFO__c rf:relatedSFOList){
            System.debug('rf notes'+rf.SFO__r.Notes__c);
            string notes = rf.SFO__r.Option_Parent__r.Notes__c;
            String components = rf.SFO__r.Component_Name__c ;
            String sections = rf.SFO__r.Section_Name__c;
            string revisions = rf.SFO__r.Revision_Version__c;
            decimal listPrices = rf.List_Price__c;
            
            system.debug('rf '+rf.Name +' DYN '+sfoDynamicMap.get(rf.SFO__c));
            if(unitRelatedSFOWrap.containskey(rf.Unit_Detail__c)){   
                unitRelatedSFOWrap.get(rf.Unit_Detail__c).add(new unitTagWrapper(rf.SFO__r.Name, rf.SFO__r.Option_Parent__r.name,notes, components, sections, revisions, listPrices));
            }
            else{
                unitRelatedSFOWrap.put(rf.Unit_Detail__c,new list<unitTagWrapper>{new unitTagWrapper(rf.SFO__r.Name, rf.SFO__r.Option_Parent__r.name, notes, components, sections, revisions, listPrices)}); 
            }
        }
        system.debug('unitRelatedSFOWrap '+unitRelatedSFOWrap);
        
    }
    public class unitTagWrapper{
        public string optionName {set;get;}
        public string specialFeature {set;get;}
        public String notes{set;get;}
        public String components{set;get;}
        public String sections{set;get;}
        public String revisions{set;get;}
        public decimal listPrices{set;get;}
        
        public unitTagWrapper(string optionNam,string specialFeatur,String note, String component, String section, String revision, decimal listPrice){
            optionName = optionNam;
            specialFeature = specialFeatur;
            notes = note;
            components = component;
            sections = section;
            revisions = revision;
            listPrices = listPrice;
        }
    }
}