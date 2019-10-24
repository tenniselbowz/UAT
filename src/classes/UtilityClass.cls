public class UtilityClass{
    
    
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getSObjectFields(String objectName, String whereClause, boolean allfields)
    {
        String fields = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fieldsMap 
            = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        
        for (Schema.SObjectField ft : fieldsMap.values())
        { // loop through all field tokens (ft)
            Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
            if(allfields)
            {
            	selectFields.add(fd.getName());    
            }
            else if (fd.isCreateable())
            { // field is creatable
            	selectFields.add(fd.getName());     
            }
        }
        if (!selectFields.isEmpty())
        {
            for (string field : selectFields)
            {
                if(field !='TotalPrice')
                {
                    fields += field + ',';    
                }   
            }
        }
        fields = fields.removeEnd(',');
        String query = 'SELECT ' + fields + ' FROM ' + objectName ;
        
        if(whereClause != null &&  whereClause != '')
        {
        	query +=  ' WHERE ' + whereClause ;    
        }
        	
        System.debug('query::'+query);
        return query;      
    }  
    public static string getSObjectRelatedFields(String objectName, String relatedFields, String whereClause, boolean allfields)
    {
        String query = getSObjectFields(objectName, whereClause, allfields);
        String relatedQuery1 = query.substringBefore(' FROM ');
        String relatedQuery2 = query.substringAfter(' FROM ');
        query = relatedQuery1+','+relatedFields+' FROM '+relatedQuery2;
        System.debug('query::'+query);
        return query;      
    }   
}