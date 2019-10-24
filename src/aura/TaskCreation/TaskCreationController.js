({
    init : function(component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.taskObj.Sales_Call_Date__c',today);
        var TaskObj = component.get("v.taskObj");
        TaskObj.OwnerId = null ;
        // TaskObj.OwnerId  = $A.get("$SObjectType.CurrentUser.Id");
        var currentUserId =$A.get("$SObjectType.CurrentUser.Id");
        component.set('v.taskObj.OwnerId',currentUserId);
      
    },
    onSave : function(component, event, helper) {
        var task = component.get("v.taskObj");
        var relatedTasks = component.get("v.relatedTasks");
       // alert(relatedTasks);
        console.log(relatedTasks);
        var salesCallDate = component.get("v.today");
        var SalesCallScore = component.get("v.SalesCallScore");
        var comments=component.get('v.taskObj.comment');
        var validBusiness=component.get('v.taskObj.Valid_Business_Reason__c');
        //alert('VBR '+validBusiness);
        if(validBusiness !=''){
        var action = component.get("c.saveTask");
        action.setParams({
            'taskObj': task,
            'relatedTasks' : JSON.stringify(relatedTasks),
            'SalesCallScore' : SalesCallScore,
            'comments': comments
        });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            $A.get('e.force:refreshView').fire();
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse == 'success') {
                    //component.set("v.Message", 'No Records Found...');
                    alert('DSO Task created successfully');
                    window.location.reload();
                } else {
                    alert('ERROR:'+state);
                }
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    
       /* var navEvt = $A.get("e.force:navigateToSObject");
        
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "detail"
        });
        navEvt.fire(); */
    
        }
        else if(validBusiness ==''){
            alert('"Valid Busniess Reason" must be selected ');
        }},
    onChangeVal:function (component, event, helper) {
        
        var task = component.get("v.taskObj");
        var relatedTasks = component.get("v.relatedTasks");
        //alert('In Score Calcualtion '+component.get("v.relatedTasks"));
        console.log(JSON.stringify(JSON.stringify(task)));
        //alert('Selected Account '+JSON.stringify(task));
        var action = component.get("c.calculateSalesScorce");
        
        action.setParams({'taskObj': task,
                          'relatedTasks' : JSON.stringify(relatedTasks)
                         });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 0);
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.SalesCallScore", storeResponse); 
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
})