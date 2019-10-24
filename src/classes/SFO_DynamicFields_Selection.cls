public class SFO_DynamicFields_Selection {
    private String sfoId;
    public Special_Feature_Option__c sfo_Obj{get;set;}
    public boolean isNext{get;set;}
    public integer list_size{get;set;}
    private integer counter=0; 
    public integer total_size;  
    public List<SFOFieldsWrapper> sfoFieldWrapperList{get;set;}
    public Map<String, SFOFieldsWrapper> dynamicFieldsWrapperMap;
    public List<SFO_Fields__c> selectedFeldsList{get;set;}
    public Boolean displayPopup {get;set;}
    public SFO_Fields__C newSFOField{get;set;}
    
    
    public SFO_DynamicFields_Selection(ApexPages.StandardController controller){
    	sfoId = (String)controller.getId();
        list_size = 10;
        total_size = [SELECT Count() FROM  SFO_Fields__c];
        sfo_Obj = new Special_Feature_Option__c();
        if(sfoId != null && sfoId != ''){
        	sfo_Obj = [SELECT Id, Name  FROM Special_Feature_Option__c WHERE Id = :sfoId];    
        }
        
        dynamicFieldsWrapperMap = new  Map<String, SFOFieldsWrapper>();
        isNext = false;
        newSFOField = new SFO_Fields__C();
        //getDynamicFields();
    }
    public List<SFOFieldsWrapper> getDynamicFields(){
        sfoFieldWrapperList = new List<SFOFieldsWrapper>();
        set<String> existingSFOIds = new set<String>();
        for(SFO_Dynamic_Fields__c existingDynamicField : [SELECT SFO_Field__c FROM SFO_Dynamic_Fields__c 
                                                          WHERE SFO__c = :sfoId]){
        	existingSFOIds.add(existingDynamicField.SFO_Field__c);    
        }
        String sfo_fields_query = UtilityClass.getSObjectFields('SFO_Fields__c',
                                          ' Id NOT IN :existingSFOIds limit :list_size offset :counter', true);
        List<SFO_Fields__c> sfo_fields_list = new List<SFO_Fields__c>();
        sfo_fields_list = Database.query(sfo_fields_query);
        for(SFO_Fields__c field : sfo_fields_list)
        {
            if(dynamicFieldsWrapperMap.containsKey(field.Id)){
            	sfoFieldWrapperList.add(dynamicFieldsWrapperMap.get(field.Id));    
            }else{
            	sfoFieldWrapperList.add(new SFOFieldsWrapper(field)); 
            } 
        }
        return sfoFieldWrapperList;
    }
    
    public pageReference gotoNext(){

        selectedFeldsList = new List<SFO_Fields__c>();
        for(SFOFieldsWrapper wrap : sfoFieldWrapperList){
        	dynamicFieldsWrapperMap.put(wrap.sfo_field_rec.id, wrap);    
        }
        for(SFOFieldsWrapper wrapper :dynamicFieldsWrapperMap.values()){
            if(wrapper.isSelected){
            	selectedFeldsList.add(wrapper.sfo_field_rec);   
            }
        }
        if(selectedFeldsList.size() == 0){
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Please Select atleast on Field' );
            ApexPages.addmessage(msg);
			return null;
        }else{
        	isNext = true;    
        }
        System.debug('selectedFeldsList size '+selectedFeldsList.size());
        return null;
        
    }
    public pageReference gotoPrevious(){
        isNext = false;
        return null;
    }
    
    public pageReference saveFields(){
        List<SFO_Dynamic_Fields__c> dynamicFieldsToBeInserted = new List<SFO_Dynamic_Fields__c>();
        for(SFO_Fields__c field : selectedFeldsList){
        	SFO_Dynamic_Fields__c dynamicField = new SFO_Dynamic_Fields__c();
            dynamicField.SFO__c = sfoId;
            dynamicField.Name = field.Name;
            dynamicField.Picklist_Entries__c = field.Picklist_Entries__c;
            dynamicField.SFO_Field__c = field.Id;
           // dynamicField.Is_Available_for_RollUp__c = field.Is_Available_for_RollUp__c;
            dynamicFieldsToBeInserted.add(dynamicField);
        }
        if(dynamicFieldsToBeInserted.size() > 0){
        	insert dynamicFieldsToBeInserted;    
        }
        return new pageReference('/'+sfoId);
    }
    public void showPopup()
    {
        displayPopup = true;
    }
    public Map<String, SFOFieldsWrapper> restoreCheckboxes(List<SFOFieldsWrapper> sfoFieldWrapperList){
        for(SFOFieldsWrapper dynamicRec :sfoFieldWrapperList){
            if(!dynamicFieldsWrapperMap.containsKey(dynamicRec.sfo_field_rec.Id)){
            	dynamicFieldsWrapperMap.put(dynamicRec.sfo_field_rec.Id, dynamicRec);    
            }
        	
        }
        return dynamicFieldsWrapperMap;
    }
    public void closePopup() {
        displayPopup = false;
    }
    public void saveSFOField(){
        try{
            insert newSFOField;
            displayPopup = false;
            getDynamicFields();
        }catch(Exception e){
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,''+e.getMessage());
            ApexPages.addmessage(msg);    
        }
    }
    public PageReference Beginning() { 
        restoreCheckboxes(sfoFieldWrapperList);
        counter = 0;
        return null;
    }
    //Takes from current page to its previous page in pagination
    public PageReference Previous() {
        restoreCheckboxes(sfoFieldWrapperList);
        counter -= list_size;
        return null;
    }
	//Takes from current page to its next page in pagination    
    public PageReference Next() { 
        restoreCheckboxes(sfoFieldWrapperList);
        counter += list_size;
        return null;
    }
    //Takes to last page in pagination
    public PageReference End() {
        restoreCheckboxes(sfoFieldWrapperList);
        counter = total_size - math.mod(total_size, list_size);
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
    public class SFOFieldsWrapper{
        public SFO_Fields__c sfo_field_rec{get;set;}
        public boolean isSelected{get;set;}
        public SFOFieldsWrapper(SFO_Fields__c sfo_field){
        	sfo_field_rec = sfo_field;
            isSelected = false;
        }
    }
}