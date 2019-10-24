public class removeDraftRejectedSFO {
    public static void removesfo(map<Id, Special_Feature_Option__c> oldmap, map<Id, Special_Feature_Option__c> newmap){
        list<Special_Feature_Option__c> SFOList = new list<Special_Feature_Option__c>();
        set<Id> sfoids = new set<Id>();
        RecordType readonlyrectype =  [select id, developerName, SObjectType from RecordType where developerName = 'Read_Only' and SObjectType='Special_Feature_Option__c'];
        RecordType optionrectype =  [select id, developerName, SObjectType from RecordType where developerName = 'Option' and SObjectType='Special_Feature_Option__c'];
        for(Id i : oldmap.keyset()){
            if(oldmap.get(i).RecordTypeId == readonlyrectype.Id && oldmap.get(i).Status__c == 'Approved' && 
               (newmap.get(i).Status__c == 'Draft' || newmap.get(i).Status__c == 'Rejected')){
                   Special_Feature_Option__c sfo = newmap.get(i);
                   //sfo.RecordTypeId = optionrectype.Id;
                   SFOList.add(sfo);
                   sfoids.add(i);
               }
        }
        list<Related_SFO__c> relatedSFOList = new list<Related_SFO__c>();
        for(Related_SFO__c r_sfo :[Select Id, Name, SFO__c from Related_SFO__c where SFO__c In :sfoids]){
            system.debug('name:'+r_sfo.Name);
            r_sfo.SFO__c = NULL;
            r_sfo.Unit_Detail__c = NULL;
            relatedSFOList.add(r_sfo);
        }
        database.delete(relatedSFOList);
        //update relatedSFOList;
    }
}