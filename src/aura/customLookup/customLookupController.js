({
    init : function(component, event, helper) {
        var sobjectName = component.get('v.SObjectName');
        var task = component.get("v.taskObj");
        var currentUserId =$A.get("$SObjectType.CurrentUser.Id");
        if(sobjectName == 'User'){
            helper.getUserInf(component, event, helper);
        }
        if(sobjectName == 'Account')
        {
            var selectedAccount  = component.get("v.SearchKeyWord");
            component.set("v.selectedRecord",selectedAccount);
        }
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.
        let Field = component.find('field1');
        if( getInputkeyWord.length < 2 )
            {
              Field.set("v.errors", [{message:"Please search with atleast 2 characters"}]); 
            }
        else
        {
          Field.set("v.errors", null);   
        }
                 
        if( getInputkeyWord.length > 1 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        
        var selectedRecord = component.set("v.selectedRecord", null);
        
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
       // alert('Testing Record Selection');
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("accountByEvent");
        
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        component.set("v.accId",selectedAccountGetFromEvent);
       // alert("accid"+JSON.stringify(selectedAccountGetFromEvent.Id));
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
        var compEvents = component.getEvent("componentEvent");// getting the Instance of event
        compEvents.setParams({ "taskObj" : component.get("v.selectedRecord") });// setting the attribute of event
        compEvents.fire();// firing the event.
        
    },
    // automatically call when the component is done waiting for a response to a server request.  
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    onblur: function (component, event, helper) {
        var selectedRecord = component.get('v.selectedRecord');
        //alert('In BLUR '+selectedRecord);
        var selectedId ='';
        if(selectedRecord)
        {
            selectedId = selectedRecord.Id;
            
            var sobjectName = component.get('v.SObjectName');
            var task = component.get("v.taskObj");
            if(sobjectName == 'User'){
                task.OwnerId = selectedId;    
            }else if(sobjectName == 'Account'){
                task.WhatId = selectedId;    
            }
            
        }
        else{
            var sobjectName = component.get('v.SObjectName');
            var task = component.get("v.taskObj");
            if(sobjectName == 'User'){
                task.OwnerId = selectedId;    
            }else if(sobjectName == 'Account'){
                task.WhatId = null;    
            }
        }
           var compEvents = component.getEvent("componentEvent");// getting the Instance of event
            compEvents.setParams({ "taskObj" : selectedRecord });// setting the attribute of event
          compEvents.fire();// firing the event.
    }
    
})