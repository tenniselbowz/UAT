/*
* @Company      : Solunus Inc
* @Author       : BALAJI
* @Date         : Dec 13th 2018
* @Description  : FPA_CreationController used for controlling FPACreationPage and do certain field populates and calculations.
*/

Public class FPA_CreationController 
{
    public Factory_Pricing_Authorization__c FPAObj{get;set;}
    public String pageType{set;get;}
    public String returnUrl{set;get;}
    string FPAID;
    string query;
    public String vfTitle{set;get;}
    public boolean showInVersion{set;get;}
    public boolean showInCloneOrCreation{set;get;}
    public list<FPA_Link__c> FPALinkList{get;set;}
    public String fpaQuantityString{get;set;}
    public Integer fpaQuantity;
    Id FPARecordId = Schema.SObjectType.Factory_Pricing_Authorization__c.getRecordTypeInfosByDeveloperName().get('Factory_Price_Authorization').getRecordTypeId();
    public Map<Integer,FPA_Link__c> FPALinkMap{set;get;}
    public Integer rowNumber{get;set;}
    public Integer key;
    public boolean showInEditPage{set;get;}
     public List<FPA_Link__c> deleteList;
    
  
    public FPA_CreationController(ApexPages.StandardController controller) 
    {   
        key =0;
        rowNumber = 0;
        fpaQuantity = 0;
        showInVersion = false;
        showInCloneOrCreation = false;
        pageType = 'Creation';
        pageType = ApexPages.currentPage().getParameters().get('pageType');
        FPAID = ApexPages.currentPage().getParameters().get('id');
        system.debug('pageType--'+pageType);
        system.debug('FPAID--'+FPAID);
        returnUrl = ApexPages.currentPage().getParameters().get('retUrl');
        system.debug('returnUrl --' + returnUrl+'--');
        FPALinkList =new list<FPA_Link__c>([select id,name,FPA__c,Quantity__c,Lead_Time__c from FPA_Link__c where FPA__c =:FPAID]);
        System.debug('FPALinkList::'+FPALinkList);
        deleteList = new List<FPA_Link__c>();
        FPALinkMap = new map <integer,FPA_Link__c>();
        if(FPALinkList.size()>0){
            for(FPA_Link__c fpalink: FPALinkList){
                FPALinkMap.put(key,fpalink);
                key+=1;
            }
            
        }
        // deleteList=new List<FPA_Link__c>();
        if(FPAID != null && returnUrl == null)
        {
            returnUrl='/'+FPAID;
        }
        try
        {
            System.debug('FPAID'+FPAID);
            query = UtilityClass.getSObjectFields('Factory_Pricing_Authorization__c', 'Id=:FPAID limit 1', true);
            FPAObj = Database.query(query);
            
            FPAObj.Status__c='Draft';
            FPAObj.RecordTypeId = FPARecordId;
            if(pageType == 'Clone')
            {   
                System.debug('clone');
                vfTitle = 'FPA Clone Page';
                showInEditPage = false;
                FPAObj.Id=Null;
                showInCloneOrCreation = True;
                FPAObj.Comments__c=null;
                FPAObj.Version__c=null;
               // FPAObj.SFO_Fixed_Unit_Cost__c = null;
                FPAObj.SFO_Variable_Unit_Cost__c = null;
                FPAObj.FPA_Number__c=Null;
                FPAObj.Submitted__c = system.today();
                //FPAObj.Complete__c = Null;
                //FPAObj.Revenue__c = Null;
                FPAObj.SO_Number__c = Null;
                FPAObj.Parent_FPA__c = Null;
            }
            else if(pageType == 'Version')
            {
                System.debug('version');
                vfTitle = 'FPA Versioning Page';
                FPAObj.Id=Null;
                showInVersion = True;
                showInEditPage = false;
                Integer version_Count = 0;
                version_Count = [SELECT count() FROM Factory_Pricing_Authorization__c
                                 WHERE Parent_FPA__c = :FPAID ];
                FPAObj.version__c = String.valueOf(version_Count+1);
                FPAObj.Comments__c=null;
            }
            else
            {
                
                if(FPAObj.id!=null)
                {
                    vfTitle = 'FPA Edit Page'; 
                    showInEditPage = true;
                    system.debug('entered edit: '+showInEditPage);
                }
                else
                {
                    vfTitle = 'FPA Creation Page';  
                    showInEditPage = false;
                    system.debug('entered new in else:'+showInEditPage);
                    
                }
                showInCloneOrCreation = True;
            }
        }
        catch(Exception e)
        {
            FPAObj = new Factory_Pricing_Authorization__c();
            FPAObj.Quantity__c = 0;
            FPAObj.Submitted__c = system.today();
            FPAObj.OwnerId = Userinfo.getUserId();
            FPAObj.Application_Engineer__c = UserInfo.getUserId();
            vfTitle = 'FPA Creation Page';
            showInCloneOrCreation = True;
            System.debug(e.getLineNumber()+'test'+e.getMessage());

        }
        system.debug('FPAObj--'+FPAObj);
    }
    
    /* 
* @Description  : Used  to save FPA and generate FPA Number
* @Author       : BALAJI
*/
    public PageReference saveFPA()
    {
        date today = system.today();
        String pcl;
        string Revenue;
        if(pageType == 'Version')
        {
            Integer version_Count = 0;
            if(FPAObj.Parent_FPA__c == Null)
            {
                version_Count = 1;
                FPAObj.Parent_FPA__c = FPAID;
            }
            else
            {
                version_Count = [SELECT count() FROM Factory_Pricing_Authorization__c WHERE Parent_FPA__c = :FPAObj.Parent_FPA__c];
                FPAObj.version__c = String.valueOf(version_Count+1);
            }
        }
        else
        {
            try
            {
                Product__c prod = [Select id, Name, PCL__c from Product__c where id =:FPAObj.Base_Unit_to_be_Modified__c ];
                
                FPAObj.PCL__c = string.valueOf(prod.Name);
                
            }
            catch(Exception e)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Issue with Product (PCL or Revenue). Please contact System Administrator');
                ApexPages.addMessage(msg);
                return Null;
            }
            
            string fpaname =  FPAObj.PCL__c + (string.valueof(FPAObj.Submitted__c.year())).removeStart('20');// + string.valueof(today.month()) + string.valueof(today.day());
            if(string.valueof(FPAObj.Submitted__c.month()).length()==1)
                fpaname = fpaname+'0'+string.valueof(FPAObj.Submitted__c.month());
            else
                fpaname = fpaname+string.valueof(FPAObj.Submitted__c.month());
            if(string.valueof(FPAObj.Submitted__c.day()).length()==1){
                System.debug('Today::'+FPAObj.Submitted__c);
                System.debug('day::'+FPAObj.Submitted__c.day());
                fpaname = fpaname+'0'+string.valueof(FPAObj.Submitted__c.day());
            }
            else{
                System.debug('Today::'+FPAObj.Submitted__c);
                System.debug('day::'+FPAObj.Submitted__c.day());
                fpaname = fpaname+string.valueof(FPAObj.Submitted__c.day());    
            }
                
                
            
            if(FPAID == null)
            {
                List<AggregateResult> fparec = [select count(id) from Factory_Pricing_Authorization__c where Base_Unit_to_be_Modified__c=:FPAObj.Base_Unit_to_be_Modified__c AND Created_Date__c =: FPAObj.Submitted__c];
                integer fpasCount = ((decimal)fparec[0].get('expr0')).intValue();
                system.debug('fpas Count with SubmittedDate--'+fpasCount);
                
                if(fpasCount==0){
                    fpaname += 'A';
                }
                else
                {
                    String key = 'BCDEFGHIJKLMNOPQRSTUVWXYZ';
                    fpaname +=(key.left(fpasCount)).right(1);
                }
                system.debug('FPA_Number--'+fpaname); 
                FPAObj.FPA_Number__c = fpaname;
            }
            
        }
        
        try
        {
            System.debug(FPAObj.Quantity__c);
            upsert FPAObj;
           
             for(FPA_Link__c linkRec : FPALinkMap.values())
            {
                if(linkRec.fpa__c == null){
                    linkRec.fpa__c =FPAObj.id;
                }
            }
            upsert FPALinkMap.values();
            if(deleteList.size() > 0)
            {
                delete deleteList;
            } 
            
            if(FPAObj.Parent_FPA__c != null)
            {
                FPA_Version_Controller.createFPA_ChildRecords(FPAObj.Id);    
            }
           
        }
        catch(Exception ex)
        {
            System.debug('**Class Name** -- Exception Message- '+ex.getMessage()+' -- Line Number:' +ex.getLineNumber());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,' Exception Message- '+ex.getMessage()+' -- Line Number:' +ex.getLineNumber()+'Please contact System Administrator');
            //ApexPages.addMessage(msg);
            return null;
        }
        PageReference pageRef = new PageReference('/'+FPAObj.id);
        return pageRef;
        
    }
    public pagereference backtofpasearch()
    {
        if(FPAID != null)
            return new pagereference('/'+FPAID);
        else
            return new pagereference(returnUrl);
    }
    
    public void generateUnitDetails()
    {
        System.debug('fpaQuantityString::'+fpaQuantityString);
        if(!fpaQuantityString.isNumeric())
        {
            return;
        }
        fpaQuantity = Integer.valueOf(fpaQuantityString);
        system.debug(FPAObj.Quantity__c+'Quantity::'+fpaQuantity);
        FPAObj.Quantity__c = fpaQuantity;
        showInEditPage = true;
        
        for (integer i=0;i<fpaQuantity;i++)
        {
            FPA_Link__c linkObj =new FPA_Link__c();
            FPALinkList.add(linkObj); 
            FPALinkMap.put(key,linkObj);
            key +=1;
        }
        System.debug('FPALinkList::'+FPALinkList);
        System.debug('FPALinkList size::'+FPALinkList.size());
        system.debug('FPALinkMap::'+FPALinkMap);
        
    }
     public void addRow()
    {
        FPA_Link__c linkObj =new FPA_Link__c();
        FPALinkMap.put(key,linkObj);
        system.debug('FPALinkMap:::'+FPALinkMap);
        fpaQuantity =  FPALinkMap.keySet().size();
        FPAObj.Quantity__c = fpaQuantity;
        key +=1;
                
    }    
    public void delRow()
    {
        System.debug('rowNumber'+rowNumber);
        FPA_Link__c linkObj =FPALinkMap.get(rowNumber);
        System.debug('linkObj'+linkObj);
        FPALinkMap.remove(rowNumber);
        
        if(linkObj !=null && linkObj.Id !=NULL)
        {
             System.debug('delete');
            deleteList.add(linkObj);
        }
        fpaQuantity =  FPALinkMap.keySet().size();
        FPAObj.Quantity__c = fpaQuantity;
    }
    
}