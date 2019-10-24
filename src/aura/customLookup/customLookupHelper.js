({
    getCurrentUser :function(component, event,helper){
        var sobject = component.get("v.SObjectName");
        var user = $A.get("$SObjectType.CurrentUser");
        component.set("v.selectedRecord", user);
        //console.log(user);
        //console.log(JSON.stringify($A.get("$SObjectType.CurrentUser")));

    },
	searchHelper : function(component,event,getInputkeyWord) {
        var sobject = component.get("v.SObjectName");
	  // call the apex class method 
     var action = component.get("c.fetchAccount");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'sObjectName' : sobject
          });
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", 'Search Result...');
                }
                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    getUserInf : function(component, event, helper)
    {
      var action = component.get("c.getUser");
            // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.SearchKeyWord", storeResponse.Name);
                component.set("v.selectedRecord", storeResponse);
                
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
        
    },
})