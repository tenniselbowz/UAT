public class FPA_Email_Attachment_controller {
    
    public String FPAId{get;set;}
    
    public FPA_Email_Attachment_controller(ApexPages.StandardController std){
        //FPAId = ApexPages.currentPage().getParameters().get('id');  
        FPAId = std.getId();
    }
    
}