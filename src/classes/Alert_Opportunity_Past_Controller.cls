public class Alert_Opportunity_Past_Controller {

     public Apttus_Proposal__Proposal__c proposalObj;
    public Boolean isNotify {get;set;}
 
    public Alert_Opportunity_Past_Controller(ApexPages.StandardController controller) 
    {
        isNotify = false;
        this.proposalObj = (Apttus_Proposal__Proposal__c)controller.getrecord();
    }
    public void Display()
    {
        try
        {
            Apttus_Proposal__Proposal__c so = [select id,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.CloseDate from Apttus_Proposal__Proposal__c where id=:proposalObj.Id];
            
           if(so.Apttus_Proposal__Opportunity__r.CloseDate < system.today() )
            {
                isNotify = true;
            }
            else
                isNotify = false;
        }
        catch(Exception e)
        {
            system.debug('exception '+e);
        }
        
    }
}