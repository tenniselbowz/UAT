public class autoApproveQAFOFCases_Controller {
    public id casePlanId {set;get;}
    public case casePlan;
    public List<SObject> selected { get; private set; }
    public List<case> approvedCases {set;get;}
    //Get the cases of Case Plan related cases and update Status and Approval Status on Cases
    public autoApproveQAFOFCases_Controller(ApexPages.StandardsetController controller){
        casePlanId = ApexPages.currentPage().getParameters().get('id');
        selected = controller.getSelected();
        system.debug('casePlanId '+casePlanId);
    }
    public void updateStatusOnCases(){
        List<case> qaFOFCases=[select Id,Status,casenumber,CreatedDate,Approval_Status__c from Case where id=:selected];
        system.debug('qaFOFCases '+qaFOFCases);
        if(qaFOFCases.size() >0){
            approvedCases = new List<case>();
            for(Case cases:qaFOFCases){
                if(cases.Status !='Warranty Approved' || cases.Approval_Status__c!='Warranty Approved'){
                    cases.Status='Warranty Approved';
                    cases.Approval_Status__c='Warranty Approved';
                    approvedCases.add(cases);
                }}
            if(approvedCases.size() >0){
                try{
                    update approvedCases;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'Below Case(s) are approved successfully');
                    ApexPages.addMessage(myMsg);
                   
                }
            catch (exception e){
                    system.debug('Exception Occured '+e.getCause() +' Msg -'+e.getMessage());
                }
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.info,'The selected case(s) might have already been approved, Please contact your administrator for further assistance');
                ApexPages.addMessage(myMsg);
            }
            
        }
        if(selected.size() ==0 ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.warning,'Please select atlease one case to approve');
            ApexPages.addMessage(myMsg);
        }
        //redirect();
        
    }
    public PageReference goback() {
        //PageReference redirectSuccess = new ApexPages.StandardController(plan).view();
        return new pagereference('/'+casePlanId);
    }
    
}