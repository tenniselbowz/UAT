public class importCasePlanAssetsFromCSVController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Case_Plan_Asset__c> courlist{get;set;}
    public Integer snPosition{get;set;}
    
    private Case_Plan__c cp = null;
    
    public importCasePlanAssetsFromCSVController(ApexPages.StandardController controller){
        this.cp = (Case_Plan__c)controller.getRecord();
        snPosition=0;
    }
    
    public void importCSVFile(){
        csvFileLines = new String[]{};
            if(csvFileBody != null && cp != null){
                if(snPosition==null)
                    snPosition=0;
                
                try{
                    csvAsString = csvFileBody.toString();
                    csvFileLines = csvAsString.split('\n'); 
                    List<String> sns = new List<String>(); 
                    List<String> contactEmails=new List<String>();
                    Map<String,String> snEmailMap=new Map<String,string>();
                    Map<String,String> emailSNMap=new Map<string,string>();
                    Map<String,Id> contactEMailIDMap=new Map<String,ID>();
                    List<Id> ids = new List<Id>();
                    Map<String,id> serialNumAccountMap=new Map<String,Id>();
                    List<Contact> insertContacts=new List<Contact>();
                    for(Integer i=1;i<csvFileLines.size();i++){
                        string row=csvFileLines[i].trim();
                        String[] sn=row.split(',');
                        //system.debug('sn '+sn);
                        sns.add(sn[0].trim()); //Add Serial numbers to list
                        contactEmails.add(sn[1].trim()); //Add emails to list
                        snEmailMap.put(sn[0], sn[1]);
                        emailSNMap.put(sn[1], sn[0]);
                    }
                    if(sns.size()>0){ // Check the size of serial numbers
                        if(cp ==null)
                            cp = [select Id from Case_Plan__c Limit 1];
                        
                        for(Case_Plan_Asset__c cpa :[select Asset__c from Case_Plan_Asset__c where Case_Plan__c =:cp.Id]){
                            ids.add(cpa.Asset__c);//Add ids to list
                        }
                        //Get Assets
                       List<Asset> ass = [select Id, SerialNumber,AccountId from Asset where SerialNumber in:sns and Id not in:ids];                    
                        for(Asset asset:ass){
                            if(asset.SerialNumber !=null &&asset.accountID != null){
                                serialNumAccountMap.put(asset.SerialNumber, asset.accountID);}}
                        system.debug('serialNumAccountMap '+serialNumAccountMap);
                        
                        for(contact con:[select id,name,email from contact where email=:contactEmails order by createddate desc]){//Get existing contacts
                            contactEMailIDMap.put(con.email,con.id);
                        }
                        //Check if Contacts exist in Salesforce with matching emails, if not create a new contact with Email 
                        if(contactEmails.size() != contactEMailIDMap.size()){
                            for(String emails:contactEmails){
                                if(!contactEMailIDMap.containskey(emails)){
                                    contact con=new contact();
                                    String name = emails.substringBefore('@');
                                    con.lastName=name;
                                    con.Email=emails;
                                    if(serialNumAccountMap.containskey(emailSNMap.get(emails)))
                                    con.accountid=serialNumAccountMap.get(emailSNMap.get(emails)); //Map account from Asset Billing
                                    insertContacts.add(con);
                                }
                            }
                            insert insertContacts;
                            system.debug('insertContacts '+insertContacts);
                             for(contact cons:insertContacts)
                            contactEMailIDMap.put(cons.email,cons.id);

                        }
                      
                        if(ass.size()>0){
                            courlist = New List<Case_Plan_Asset__c>(); 
                            for(Asset a :ass){
                                Case_Plan_Asset__c cpa = new Case_Plan_Asset__c();
                                cpa.Asset__c=a.Id;
                                cpa.Case_Plan__c=cp.Id;
                                cpa.Contact__c=contactEMailIDMap.get(snEmailMap.get(a.SerialNumber).tolowercase());
                                courlist.add(cpa);
                                
                            }
                            if(courlist.size()>0){
                                insert courlist;
                                ApexPages.Message successMessage = new ApexPages.Message(ApexPages.severity.CONFIRM,
                                                                                         courlist.size()+' Case Plan Assert(s) Inserted Successfully');
                                ApexPages.addMessage(successMessage);  
                            }
                        }
                    }
                }
                catch (Exception e)    
                {
                    System.debug(e.getCause());
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure input csv file is correct');
                    ApexPages.addMessage(errorMessage);
                }  
            }
        else{
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'No file selected, Please make sure to select a CSV file to import');
            ApexPages.addMessage(errorMessage);
        }
    }
 
}