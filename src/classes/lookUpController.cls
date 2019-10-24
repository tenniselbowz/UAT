public class lookUpController {
    @AuraEnabled
    public static List <Account> fetchAccount(String searchKeyWord, String sObjectName) {
        String searchKey = searchKeyWord +'%';
        system.debug('searchKey::'+searchKey);
       
        List < Account > returnList = new List < Account> ();
        String sQuery =  'select id, Name,Description,Account_Owner_User_Department__c,High_Value__c from ' +sObjectName + ' where Name LIKE: searchKey AND Account_Owner_User_Department__c = \'DAAL - Equipment Sales\' limit 1000';
        system.debug('sQuery::'+sQuery);
        List < Account > lstOfRecords = Database.query(sQuery);
        //system.debug('lstOfRecords '+lstOfRecords);
        list<Account> highValueCheckBoxList = new list<Account>();
        list<Account> dAALTrackingList = new list<Account>(); 
        list<Account> nonDAALTrackingList =new list<Account>();
        list<Account> noDescriptionList =new list<Account>();
        list<Account> resultentList =new list<Account>();
        String descriptionCustomLabel = System.Label.Account_Description;
        for (Account acc :lstOfRecords)
        {
            if (acc.High_Value__c == True)
            {
                system.debug('Enter high value');
                highValueCheckBoxList.add(acc);
            }
             else if(acc.description !=null ){
                 if(acc.description.contains(descriptionCustomLabel)){dAALTrackingList.add(acc);  
                }
                else{nonDAALTrackingList.add(acc);}
            }
            else {noDescriptionList.add(acc);}
        }
        resultentList.addAll(highValueCheckBoxList);
        resultentList.addAll(dAALTrackingList);
        resultentList.addAll(nonDAALTrackingList);
        resultentList.addAll(noDescriptionList);
        return resultentList;
    }
    @AuraEnabled
    public static sObject getUser()
    {
        return [select id,Name from User where Id = : UserInfo.getUserId()];
    }
}