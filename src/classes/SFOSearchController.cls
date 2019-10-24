public class SFOSearchController 
{   
    public boolean noresult {set;get;}		
    public List<Special_Feature_Option__c> sfoList;		
    public integer totalpages{get;set;}		
    public integer pageno{get;set;}
    public String searchsfoVal{get;set;}
    public String searchVal{get;set;}
    public boolean autoSearch{set;get;}
    public boolean isSearched{set;get;}
    public String individualIdentifier{set;get;}
    public String groupIdentifier{set;get;}
    public Id relatedSFOID{get;set;}
    public Factory_Pricing_Authorization__c FPARecord{set;get;}
    public List<SFOWrapper> sfoWrapperList{get;set;}
    public List<SFOWrapper> tempsfoWrapper;
    public String FPALinkId{get;set;} //store FPALink Id to be deleted
    public String selectedTag{get;set;}
    private set<String> fpalinkIds;//stores the existing  FPA Link Ids
    public integer total_size{get;set;}
    private integer counter = 0;
    private integer list_size = 6;
    public boolean displayPopup {get; set;}
    public boolean goBack{get;set;}
    public String parentSFOId{get;set;}
    public Decimal markup{set;get;}
    //public List<unitTagWrapper> selectedFpaLinks{get;set;}
    public String returnURL{get;set;}
    public Map<String,List<Related_SFO__c>> unitDetailsToSFOsMap{get;set;}
    public Map<String,FPA_Link__c> FPALinksMap{get;set;}
    public map<string,Boolean> hasRelatedSFO {get;set;}
    public list <Special_Feature_Option__c> selectedRelatedSFO {get;set;}
    private map<string,set<string>> unitToSFOIds;
    public Map<String, SFOWrapper> SFOWrapperMap;
    
    public SFOSearchController(ApexPages.StandardController controller)
    {
        FPARecord=new Factory_Pricing_Authorization__c();
        autoSearch=true;
        String fpaId = apexpages.currentpage().getparameters().get('id');
        returnURL = apexpages.currentpage().getparameters().get('retURL');
        String fpa_record_query =  UtilityClass.getSObjectFields('Factory_Pricing_Authorization__c', 'Id =:fpaId', true);
        FPARecord = database.query(fpa_record_query);        
        total_size = 0;
        goBack = false;
        // selectedFpaLinks = new List<UnitTagWrapper>();
        selectedRelatedSFO = new list<Special_Feature_Option__c>();
        unitToSFOIds = new map<string,set<string>>();
        sfoWrapperList = new List<SFOWrapper>();
        tempsfoWrapper = new List<SFOWrapper>();
        SFOWrapperMap = new Map<String, SFOWrapper>(); 
        getUnitDetails();
    }
    
    public void getUnitDetails()
    {
        hasRelatedSFO =new map<string,Boolean> ();
        String fpaId  = FPARecord.Id;
        List<FPA_Link__c> existingFPALinks = new List<FPA_Link__c>();
        FPALinksMap = new Map<String,FPA_Link__c>();
        unitDetailsToSFOsMap = new Map<String,List<Related_SFO__c>>();
        
        String fpaLink_query = UtilityClass.getSObjectRelatedFields('FPA_Link__c',
                                                                    'SFO__r.Name, SFO__r.Notes__c, SFO__r.Parent_name__c,'+
                                                                    'SFO__r.Name__c, SFO__r.Parent_SFO__c,'+
                                                                    '(select Id, Name,Total_Cost__c,SFO_Margin_Line_Item__c,Parent_Name__c,'+
                                                                    'List_Price__c,List_Markup__c,Expected_Margin__c,'+
                                                                    'SFO__r.Name, SFO__c,SFO__r.Name__c,SFO__r.Option_Parent__c,SFO__r.Option_Parent__r.Name__c,'+
                                                                    'Assumed_Multiplier__c,Margin_per_unit_dlr__c, Net_Price_Per_Unit__c, Margin_Line_Item__c, SFO__r.Option_No__c,'+
                                                                    'Notes__c, Margin_per_unit__c '+
                                                                    'FROM Related_SFO__r)', 
                                                                    'FPA__c = :fpaId', true);
        
        System.debug('Dtat ::'+fpaLink_query);
        
        fpalinkIds = new Set<String>();
        existingFPALinks = Database.query(fpaLink_query);
        for (FPA_Link__c fpalink :existingFPALinks)
        {
            for(Related_SFO__c r :fpalink.Related_SFO__r){
                if(unitToSFOIds.containsKey(fpalink.Id)){
                    unitToSFOIds.get(fpalink.Id).add(r.SFO__c);
                }else{
                    unitToSFOIds.put(fpalink.Id, new set<string>{r.SFO__c});
                }
                
            }
            fpalinkIds.add(fpalink.SFO__c);
            unitDetailsToSFOsMap.put(fpalink.Id, fpalink.Related_SFO__r);
            FPALinksMap.put(fpalink.Id, fpalink);
        }
        system.debug('unitDetailsToSFOsMap::'+unitDetailsToSFOsMap.size());
        
        for(string linkId :unitDetailsToSFOsMap.keySet())
        {
            if(unitDetailsToSFOsMap.get(linkId).size()>0)
            {
                hasRelatedSFO.put(linkId,true);
            }
            else
            {
                hasRelatedSFO.put(linkId,false);
            }
        }
    }
    public String getFields(String objectName) 
    {
        Map<String, Schema.SObjectField> fieldsMap 
            = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        String field = '';
        for (Schema.SObjectField ft : fieldsMap.values())
        { // loop through all field tokens (ft)
            Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
            field += fd.getName()+',';
            
        }
        field = field.removeStart(',').removeEnd(',');
        System.debug('field::'+field);
        return field;
    }
    public void doSearch()
    {
        counter = 0;
        sfoList = new List<Special_Feature_Option__c>();
        sfoWrapperList = new List<SFOWrapper>();
        tempsfoWrapper = new List<SFOWrapper>();
        // tempsfoWrapper.clear();
        // sfoWrapperList.clear();
        set<String> existingSFOIds = new set<String>();
        if(unitToSFOIds.containsKey(selectedTag)){
            if(unitToSFOIds.get(selectedTag) != null){
                existingSFOIds = unitToSFOIds.get(selectedTag);  
            }
        }
        
        Id readOnlyRecordTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName()
            .get('Read_Only').getRecordTypeId();
        Id sfoRecordTypeId = Schema.SObjectType.Special_Feature_Option__c.getRecordTypeInfosByDeveloperName()
            .get('Special_Feature_Option').getRecordTypeId();
        System.debug('searchval ::'+searchVal);
        System.debug('searchsfoVal ::'+searchsfoVal);
        if(searchVal != '' && searchsfoVal != ''){
            string sval = '%'+searchVal+'%';
            string sfoval = '%'+searchsfoVal+'%';
            sfoList = [select Id,Option_Parent__c,Option_Parent__r.name,Option_Parent__r.name__c,status__c,RecordTypeId,Name,Name__c from 
                       Special_Feature_Option__c  WHERE Id NOT IN :existingSFOIds AND RecordTypeId = :readOnlyRecordTypeId AND status__c = 'Approved' 
                       AND (Name LIKE :sval OR Name__c LIKE :sval) AND (Option_Parent__r.name LIKE :sfoval OR Option_Parent__r.name__c LIKE :sfoval)];
        }
        else {
            String localsearchval;
            if(searchVal != '' && searchsfoVal == ''){
                localsearchval = searchVal;
            }
            else if(searchsfoVal != '' && searchVal == ''){
                localsearchval = searchsfoVal;
            }
            System.debug('localsearchval ::'+localsearchval);
            
            
            string st;
            List<Integer> rb = new List<Integer>(); 
            if(localsearchval != '' || localsearchval != null){
                st=localsearchval;
            }
            /* for(integer i = 0; i<localsearchval.length(); i++)
{
rb.clear();
rb.add(localsearchval.charAt(i));
if(st == null)
{
st = String.fromCharArray(rb)+'*';    
}
else if(String.fromCharArray(rb) != 'h')
{
st += String.fromCharArray(rb)+'*';    
}
}*/
            
            system.debug('st:'+st);
            
            String fields = getFields('Special_Feature_Option__c');
            system.debug('existingSFOIds'+existingSFOIds);
            
            String sfo_sosl_query ='FIND '+'\''+st+'\' IN ALL FIELDS'+'  RETURNING'
                +' Special_Feature_Option__c('+fields+' ,option_parent__r.name,Base_Unit_to_be_Modified__r.Name ';
            if(searchVal != ''){
                sfo_sosl_query += 'WHERE  (Id NOT IN :existingSFOIds AND RecordTypeId = :readOnlyRecordTypeId AND status__c = \'Approved\'))';
            }
            else if(searchsfoVal != ''){
                sfo_sosl_query += 'WHERE  ( RecordTypeId = :sfoRecordTypeId ))';
            }
            system.debug('readOnlyRecordTypeId ' + readOnlyRecordTypeId);
            System.debug('sFO_sosl_query:'+sFO_sosl_query);
            List<List<SObject>> searchList = search.query(sFO_sosl_query);
            system.debug('searchList::'+searchList.size());
            system.debug('searchList::'+searchList);
            
            if(searchsfoVal != ''){
                set<Id> sfoids = new set<Id>();
                for(Special_Feature_Option__c s : (List<Special_Feature_Option__c>) searchList[0]){
                    sfoids.add(s.Id);
                    system.debug('s.Id '+s.Id);
                }
                system.debug('sfoids:'+sfoids);
                string query = 'select Id,Option_Parent__c,Option_Parent__r.name,status__c,RecordTypeId,Name,Name__c from Special_Feature_Option__c WHERE Id NOT IN :existingSFOIds AND Option_Parent__c IN :sfoids AND RecordTypeId = :readOnlyRecordTypeId AND status__c = \'Approved\'';
                system.debug(query);
                sfoList = Database.query(query);
                //ystem.debug('sfoList:'+sfoList.size());
                system.debug('sfoList:'+sfoList);
            }
            if(searchVal != ''){
                sfoList = (List<Special_Feature_Option__c>) searchList[0];
            }
            System.debug('sfoList:'+sfoList.size());
        }
        noresult = false;
        if(sfoList.size() == 0){
            noresult = true;
        }
        for(Special_Feature_Option__c sfo :sfoList)
        {
            system.debug('sfo'+sfo.Id +'Record Type ID'+sfo.RecordTypeId);
            if(sfo.status__c == 'Approved' && sfo.RecordTypeId == readOnlyRecordTypeId)
            {
                system.debug('sfo'+sfo);
                // sfoWrapperList.add(new SFOWrapper(sfo)); 
                tempsfoWrapper.add(new SFOWrapper(sfo)); 
            }
            System.debug('tempsfoWrapper ::'+tempsfoWrapper);
        }
        total_size =tempsfoWrapper.size();
        doPagination(tempsfoWrapper, list_size, counter);
        searchVal = '';
        searchsfoVal = '';
        System.debug('searchval ::'+searchVal);
        System.debug('searchsfoVal ::'+searchsfoVal);
    }
    
    
    public pagereference doPagination(List<SFOWrapper> tempWrapper, integer listsize, integer counterVar)
    {
        sfoWrapperList = new List<SFOWrapper>();
        System.debug('tempWrapper Size ::'+tempWrapper.size());
        System.debug(counterVar+'::'+listsize);
        integer totalSize = ((listsize+counterVar) < total_size)?(listsize+counterVar):total_size;
        for(Integer i = counterVar; i< totalSize ; i++)
        {
            sfoWrapperList.add(tempWrapper[i]);    
        }
        totalpages = (sfoList.size() +5) / listsize;
        pageno = (counter + list_size)/listsize;
        return null;
    }
    
    public PageReference Beginning() { 
        //restoreCheckboxes(sfoFieldWrapperList);
        counter = 0;
        doPagination(tempsfoWrapper, list_size, counter);
        return null;
    }
    //Takes from current page to its previous page in pagination
    public PageReference Previous() {
        //restoreCheckboxes(sfoFieldWrapperList);
        counter -= list_size;
        doPagination(tempsfoWrapper, list_size, counter);
        return null;
    }
    //Takes from current page to its next page in pagination    
    public PageReference Next() { 
        //restoreCheckboxes(sfoFieldWrapperList);
        counter += list_size;
        doPagination(tempsfoWrapper, list_size, counter);
        return null;
    }
    //Takes to last page in pagination
    public PageReference End() {
        //restoreCheckboxes(sfoFieldWrapperList);
        //math.mod(total_size, list_size);
        counter = total_size - list_size;
        system.debug('counter:'+counter);
        doPagination(tempsfoWrapper, list_size, counter);
        return null;
    }
    //Disables previous button if there are no records in next page
    public Boolean getDisablePrevious() { 
        
        if (counter>0) {
            return false;    
        }else{
            return true;    
        }
    }
    //Disables previous button if there are no records in previous page
    public Boolean getDisableNext() { 
        if (counter + list_size < total_size){
            return false;
        }else{
            return true;    
        } 
    }
    public pageReference associateSFO()
    {
        list<Related_SFO__c> relatedSfos = new List<Related_SFO__c>();
        System.debug('sfoWrapperList in associateSFO:'+sfoWrapperList);
        
        for(SFOWrapper wrapper :tempsfoWrapper)
        {
            System.debug('tempsfoWrapper ::'+tempsfoWrapper);
            if(wrapper.isSelected==true){
                System.debug('wrapper ::'+wrapper);
            }
            if(wrapper.isSelected){
                wrapper.relatedSFO.Unit_Detail__c = selectedTag;
                relatedSfos.add(wrapper.relatedSFO);	
            }
            wrapper.isSelected = false;
        }
        if(relatedSfos.size() > 0){
            closePopup();
            insert relatedSfos;
            // decimal engHours=0;
            //decimal draftingHours=0;
            //decimal manufacturingHours=0;
            //
            if(relatedSfos.size()>0)
            {
                /*Decimal totalMaterialCost = FPAApprovalDetails.getFPADynamicFields(relatedSfos, 'Material cost');
Decimal totalDraftingHours = FPAApprovalDetails.getFPADynamicFields(relatedSfos, 'Drafting Hours');
Decimal totalManufacturingHours = FPAApprovalDetails.getFPADynamicFields(relatedSfos, 'Manufacturing Hours');
Decimal totalEngineeringHours = FPAApprovalDetails.getFPADynamicFields(relatedSfos, ' ');*/
                
            }
            system.debug('SFOSearch Controller::'+FPARecord.Approval_Level__c);
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Select atleast one SFO.'));    
        }
        system.debug(' Inserted relatedSfos ::'+relatedSfos);
        getUnitDetails();
        
        return null;
    }
    public void closePopup() { 
        sfoWrapperList.clear();
        tempsfoWrapper.clear();
        searchVal ='';
        searchsfoVal = '';
        displayPopup = false;
    }     
    public void showPopup() {   
        System.debug('parentSFOId::'+parentSFOId);
        sfoWrapperList = new List<SFOWrapper>();
        displayPopup = true;    
    }
    public pageReference createSFO()
    {
        System.debug('create SFO');
        return new pageReference('/apex/SFO_Custom_Edit_Page_Test');
    }
    public pagereference backToFPA()
    {
        return new pagereference('/'+FPARecord.Id);
    } 
    public class SFOWrapper
    {
        public boolean isSelected{get;set;}
        public Special_Feature_Option__c sfoObj{get;set;}
        public Related_SFO__c relatedSFO{get;set;}
        public SFOWrapper(Special_Feature_Option__c sfo)
        {
            sfoObj = new Special_Feature_Option__c();
            sfoObj = sfo;
            relatedSFO = new Related_SFO__c();
            relatedSFO.SFO__c = sfo.Id;
            relatedSFO.Assumed_Multiplier__c=0.30;
            relatedSFO.List_Markup__c=5.0;
            isSelected=false;
        }
    }
    public class UnitTagWrapper{
        public Special_Feature_Option__c sfoObj{get;set;}
        public FPA_Link__c fpa_link{get;set;}
        public UnitTagWrapper(Special_Feature_Option__c sfo, FPA_Link__c fpaLink)
        {
            sfoObj = sfo; 
            fpa_link  = fpaLink;
        }
    }
    public void deleteRow(){
        system.debug('relatedSFOID'+relatedSFOID);        
        Related_SFO__c deleteSFO = [select id,name,Unit_Detail__c from Related_SFO__c where id =:relatedSFOID];
        system.debug(deleteSFO);
        List<Related_SFO__c> related=unitDetailsToSFOsMap.get(deleteSFO.Unit_Detail__c);
        system.debug('Before unitDetailsToSFOsMap '+unitDetailsToSFOsMap.values().size());
        unitDetailsToSFOsMap.remove(deleteSFO.Unit_Detail__c);
        system.debug('after'+unitDetailsToSFOsMap.values().size());
        for(Related_SFO__c rel:related){
            if(rel.id != deleteSFO.id){
                if(unitDetailsToSFOsMap.containsKey(deleteSFO.Unit_Detail__c)) {   
                    unitDetailsToSFOsMap.get(deleteSFO.Unit_Detail__c).add(rel);
                }
                else {
                    unitDetailsToSFOsMap.put(deleteSFO.Unit_Detail__c,new List<Related_SFO__c>{rel}); 
                }
            }
        }
        if(!unitDetailsToSFOsMap.containsKey(deleteSFO.Unit_Detail__c)){
        	unitDetailsToSFOsMap.put(deleteSFO.Unit_Detail__c,new List<Related_SFO__c>());
            hasRelatedSFO.put(deleteSFO.Unit_Detail__c, false);
        }
        system.debug('after unitDetailsToSFOsMap '+unitDetailsToSFOsMap.values().size());
        delete deleteSFO;
        //FPA_Link__c linkObj =unitDetailsToSFOsMap.get(rowNumber);
    }   
}