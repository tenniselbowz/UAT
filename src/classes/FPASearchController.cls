/* Name			: FPASearchController
 * Created By	: Solunus
 * Created Date	: Dec 24th 2018
 * Description	: This controller helps in retrieving searched records for FPA with given inputs. 
 * 				  It is controller for FPASearchPae
*/
public class FPASearchController {
    
    public List<Factory_Pricing_Authorization__c> FPA_List;
    public Map<String, List<FPAWrapper>> childFPA_map{get;set;}
    public String searchVal{get;set;}
    public boolean isSearched{get;set;}
    public String sortOrder{set ;get;}
    public Map<String,boolean> checkChildMap{get;set;}
    public Factory_Pricing_Authorization__c filterFieldsObj{get;set;} 
    public String fpaId;
    public List<FPAWrapper> FPA_wrapperlist{get;set;}
    public boolean autoSearch{get;set;}
    public String fpa{get;set;}
    private String FPA_recordTypeId;
    public String selectedFpa{get;set;}
    public boolean myFPAs{get;set;}
    public boolean isFPASelected{get;set;}
    public String FPANumber{get;set;}
    public Date entryDate{get;set;}
    public String salesPersonName{get;set;}
    public String officeName{get;set;}
    public String jobName{get;set;}
    public String location{get;set;}
    public FPASearchController(ApexPages.StandardController controller){
        fpaId = apexpages.currentpage().getparameters().get('id');
        autoSearch = true;
        isSearched = false;
        myFPAs = false;
        isFPASelected = true;
        filterFieldsObj = new Factory_Pricing_Authorization__c();
        filterFieldsObj.Status__c = '';
        FPA_recordTypeId =   Schema.SObjectType.Factory_Pricing_Authorization__c.getRecordTypeInfosByDeveloperName()
            .get('Factory_Price_Authorization').getRecordTypeId();
        System.debug('FPA recordtype Id :'+FPA_recordTypeId);
    }
    public pagereference removeValues(){
        
        FPA_List = new List<Factory_Pricing_Authorization__c>();
        filterFieldsObj = new Factory_Pricing_Authorization__c();
        FPA_wrapperlist = new List<FPAWrapper>();
        return null;
    }
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Factory_Pricing_Authorization__c.FieldSets.FPA_Fields.getFields();
    }
    public void resetFilters()
    {
        FPANumber='';
        entryDate=null;
        salesPersonName='';
        officeName='';
        jobName='';
        location ='';  
        doSearch();
    }
    public pagereference doSearch(){
        FPA_List = new  List<Factory_Pricing_Authorization__c>();
        if(searchVal == '' || searchVal == null){
            isSearched = false;
            return null;
        }else{
            isSearched = true;
        }
        string st;
        List<Integer> rb = new List<Integer>(); 
        for(integer i = 0; i<searchVal.length(); i++){
            rb.clear();
            rb.add(searchVal.charAt(i));
            if(st == null){
                st = String.fromCharArray(rb)+'*';    
            }else if(String.fromCharArray(rb) != 'h'){
                st += String.fromCharArray(rb)+'*';    
            }
        }
        String str = st;
        String ApprovedStatus = 'Approved';
        String fields = '';
        for(Schema.FieldSetMember f : this.getFields()) {
            fields += f.getFieldPath() + ', ';
        }
        fields = fields.removeEnd(', ');
      	String fpa_sosl_query ='FIND '+'\''+str+'\' IN ALL FIELDS'+'  RETURNING'
            +' Factory_Pricing_Authorization__c(Base_Unit_to_be_Modified__r.name,Office__r.name,Sales_Person__r.name, '
            +' Parent_FPA__c, '
            +fields+' WHERE Status__c = :ApprovedStatus'; //AND recordTypeId =:FPA_recordTypeId
        if(myFPAs)
        {
            String currentUserId = userInfo.getUserId();
        	fpa_sosl_query +=' AND OwnerId = :currentUserId';    
        }
        if(FPANumber != null && FPANumber != '')
        {
            FPANumber =FPANumber.trim();
         	fpa_sosl_query += ' AND FPA_Number__c = :FPANumber';   
        }
        if(entryDate != null)
        {
        	fpa_sosl_query += ' AND Entry_Date__c = :entryDate';     
        }
        if(salesPersonName != null && salesPersonName != '')
        {
            salesPersonName = salesPersonName.trim();
        	fpa_sosl_query += ' AND Sales_Person_Name__c = :salesPersonName';     
        }
        if(officeName != null && officeName != '')
        {
            officeName = officeName.trim();
        	fpa_sosl_query += ' AND Office_Name__c = :officeName ';     
        }
        if(jobName != null && jobName != '')
        {
            jobName = jobName.trim();
        	fpa_sosl_query += ' AND Name = :jobName';     
        }
        if(location != null && location != '')
        {
            location = location.trim();
        	fpa_sosl_query += ' AND location = :Modifier_location__c';     
        }
        fpa_sosl_query +=' order by Discreet_Identifier__c limit 1000 )';
        System.debug('fpa_sosl_query::'+fpa_sosl_query);
        List<List<SObject>> searchList = search.query(fpa_sosl_query);
        FPA_List = (List<Factory_Pricing_Authorization__c>) searchList[0];
        FPA_wrapperlist = new List<FPAWrapper>();
        for(Factory_Pricing_Authorization__c fpa :FPA_List)
        {
            FPA_wrapperlist.add(new FPAWrapper(fpa));
        }
        return null;
    }
    public pageReference selectWrapper()
    {
        for(FPAWrapper fpwrap: FPA_WrapperList)
        {
            if(fpwrap.fpaObj.Id == selectedFpa)
            {
                fpwrap.isSelected = true;    
            }else
            {
                fpwrap.isSelected = false;     
            }
        }
        
        return null;
    }
    public pagereference filter()
    {
        isSearched = true;
        List<Factory_Pricing_Authorization__c> filteredFPA_List = new List<Factory_Pricing_Authorization__c>();
        
        return null;
    }
        
    public pageReference cloneFPA(){
        if(selectedFpa == null || selectedFpa == ''){
            isFPASelected = false;
        	return null;    
        }
        
        pageReference pr = new pageReference('/apex/FPA_Creation_Test?id='+selectedFpa+'&&pageType=Clone&retUrl=/apex/FPASearchPage');
       //pageReference pr = new pageReference('/'+selectedFpa+'/e?&00N0t000000ncQ0=Clone&clone=1&00N0t000000ncQ0&retURL=/apex/FPASearchPage');
        
        pr.setRedirect(true);
        return pr;
    }
    public pageReference createFPA(){
        pageReference pr = new pageReference('/apex/FPA_Creation_Test?&pageType=Creation&retUrl=/apex/FPASearchPage');
        pr.setRedirect(true);
        return pr;
    }
    public class FPAWrapper{
        public boolean isSelected{get;set;}
        public Factory_Pricing_Authorization__c fpaObj{get;set;}
        public FPAWrapper(Factory_Pricing_Authorization__c fpa){
            fpaObj = new Factory_Pricing_Authorization__c();
            fpaObj = fpa;
            isSelected = false;
        }
    }
}