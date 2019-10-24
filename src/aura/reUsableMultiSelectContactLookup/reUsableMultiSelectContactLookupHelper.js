({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var accountRecord = component.get("v.accId");
        if(accountRecord != null)
        {
        var action = component.get("c.fetchLookUpValues");
        var excludeitemsList = component.get("v.lstSelectedRecords");
        var excludedids = [];
        for(var i = 0; i<excludeitemsList.length;i++){
            excludedids.push(excludeitemsList[i].Id);    
        }
        console.log('acc ' + component.get("v.Account"));
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'ExcludeitemsList' : excludedids,
            'AccountName'    : accountRecord.Name
        });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse); 
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        }
        
       
    },
    getRelatedTasks :function(component,event, contactIds){
        var action = component.get("c.getRelatedTasks");
        action.setParams({
            'taskObj': component.get("v.taskObj"),
            'contactIds' : contactIds
        });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.relatedTasks", storeResponse); 
                var relatedTasks=component.get("v.relatedTasks");
                var compEvents = component.getEvent("componentEventFired");// getting the Instance of event
                compEvents.setParams({ "relatedTasks" : relatedTasks });// setting the attribute of event
                compEvents.fire();// firing the event.
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
})