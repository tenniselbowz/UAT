@isTest
public class importCasePlanAssetsFromCSVCntrlTest {
    
    public static  String[] csvFileLines;
    public  static Blob csvFileBody;
    static String str = 'Serial Number,Contact Email \n 1234,test@gmail.com\n 5678,info@gmail.com\n 9632,psevak@apttus.com'; 
    
    @testSetup
    static void testSetUp(){
        
        Case_Plan__c cp =new Case_Plan__c();
        cp.name ='Test Case Plan';
        cp.Type__c='QA Program';
        cp.CurrencyIsoCode='USD';
        cp.Status__c='Completed';
        
        insert cp;
        
        
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        Account testAccount = APTPS_DaikinTestDataUtility.getAccount('accName');
        insert testAccount;
        
        Contact testContact = APTPS_DaikinTestDataUtility.getContact(testAccount);
        insert testContact;
        
        Asset asset = new Asset();
        asset.Name = 'TEST';
        asset.SerialNumber = '1234';
        asset.AccountId = testAccount.Id;

        insert asset;
        
        Case_Plan_Asset__c casePlanAsset =new Case_Plan_Asset__c();
        casePlanAsset.Case_Plan__c=cp.id;
        casePlanAsset.Asset__c=asset.id;
        
        insert casePlanAsset;
        
        Asset asset1 = new Asset();
        asset1.Name = 'TEST1';
        asset1.SerialNumber = '5678';
        asset1.AccountId = testAccount.Id;
        
        insert asset1;
    }
    
    static testMethod void ImportCsvFile()
    {
        
        Test.startTest();     
        Case_Plan__c cp=[select id ,name from Case_Plan__c limit 1];
        list<contact> contacts =[select id ,lastname,Email from contact where Email ='test@gmail.com'];
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        
        //Positive Scenario
        ApexPages.StandardController sd = new ApexPages.StandardController(cp);
        importCasePlanAssetsFromCSVController importData =new importCasePlanAssetsFromCSVController(sd);
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        list<contact> con =[select id ,lastname,Email from contact where Email ='test@gmail.com'];
        
        system.assertNotEquals(contacts.size(), con.size());
        
        //Negative scenario
        Case_Plan__c cp1 =new Case_Plan__c();
        
        ApexPages.StandardController sd1 = new ApexPages.StandardController(cp1);
        importCasePlanAssetsFromCSVController importData1 =new importCasePlanAssetsFromCSVController(sd1);
        importData1.csvFileBody = null;
        importData1.importCSVFile();
        
        
        Test.stopTest();
    }
    
}