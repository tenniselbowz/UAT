public class CaseServiceCodesToALLCasesClone {
    private ApexPages.StandardController sctrl;
    public string alertMessage {set;get;}
    public Id cscID {set;get;}
    public boolean evenly {set;get;}
    public Integer recCount{get;set;}
    
    public CaseServiceCodesToALLCasesClone(ApexPages.StandardController controller){
        cscID = apexPages.currentPage().getParameters().get('id');
        evenly = Boolean.valueOf(apexPages.currentPage().getParameters().get('evenly'));
        this.sctrl = controller;
    }
    public void callWarrantyHelper(){
        recCount= 0;
        if(cscID != null && evenly != null){
            //system.debug('cscID '+cscID);
           // system.debug('evenly '+evenly);
           recCount=WarrantyHelper.associateCaseServiceCodes(cscId, evenly);
            system.debug(recCount);
            alertMessage = 'Added to '+recCount+' child case(s)';
           // system.debug('alertMessage '+alertMessage);
        }     
        
    }
    public PageReference redirectPopup()
    {
       // PageReference redirect = sctrl.cancel();
       // return redirect;
    //    System.debug('redirected');
        //Redirect to Record detail page
        PageReference p=new Pagereference('/'+cscID);
        p.setRedirect(true);
        return p;
        
    }
}