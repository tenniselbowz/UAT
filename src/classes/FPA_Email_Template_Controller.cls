public class FPA_Email_Template_Controller {
    public list<Related_SFO__c> relatedSFO  {get; set;}
    public String FPA_Id;
    public Factory_Pricing_Authorization__c FPA_rec{get; set;}
    //public list<FPA_Link__c> unitDetailsRec {get;set;}
    public String getFPA_Id(){ return FPA_Id; }
    public void setFPA_Id(String s){
        FPA_Id = s;
        FPA_Email_Template_Controller();
    }
    public void FPA_Email_Template_Controller()
    {
        system.debug('FPA_Id'+FPA_Id);
        
        List<FPA_Link__c> FPALink_list = new List<FPA_Link__c>([select id from FPA_Link__c where FPA__c =: FPA_Id]);
        
        relatedSFO = new list<Related_SFO__c> ([select id ,name,Notes__C,list_price__c,Total_Cost__c, SFO__r.Name, SFO__r.Option_Parent__r.Name__c,SFO__r.Option_Parent__r.Notes__c
                                                from Related_SFO__c where unit_detail__c IN : FPALink_list
                                               ]);
        system.debug('FPALink_list'+FPALink_list);
        
        FPA_rec = [SELECT Id, Name, Job_ID__c, Created_Date__c, Application_Engineer__r.Name, FPA_Number__c, Phone__c, Description__c, Base_Unit_to_be_Modified__r.Description__c, Office__r.Name, Sales_Person__r.Name,Approval_Level__c
                   FROM Factory_Pricing_Authorization__c WHERE Id = :FPA_Id];
        system.debug('FPA_rec'+FPA_rec);
    }
}