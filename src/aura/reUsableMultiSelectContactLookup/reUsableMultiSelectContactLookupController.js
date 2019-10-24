({
    onblur : function(component,event,helper){
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        component.set("v.listOfSearchRecords", null );
        component.set("v.SearchKeyWord", '');
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
      //  var getInputkeyWord = '';
       // helper.searchHelper(component,event,getInputkeyWord);
      // alert('In Onblur');
    },
    onfocus : function(component,event,helper){
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        component.set("v.listOfSearchRecords", null ); 
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    
    keyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if(getInputkeyWord.length > 0){
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
        //alert('IN KEYPRESS');
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords"); 
      console.log('before--'+JSON.stringify(AllPillsList)+'--selectedPillId--'+selectedPillId);
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", AllPillsList);
                break;
            }  
        }
        console.log('after--'+JSON.stringify(component.get("v.lstSelectedRecords")));
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null ); 
        var relatedTasks=component.get("v.relatedTasks");
        console.log('Before '+relatedTasks.length);
        for(var i = 0; i< relatedTasks.length; i++){
            console.log('loop '+relatedTasks[i].RelationId+'=='+selectedPillId);
            if(relatedTasks[i].RelationId == selectedPillId){
                relatedTasks.splice(i, 1);
                component.set("v.relatedTasks", relatedTasks);
            }  
        }
        console.log('After '+component.get("v.relatedTasks").length);
         // var a = component.get('c.handleComponentEvent');
       // $A.enqueueAction(a);
        
var compEvents = component.getEvent("componentEventFired");// getting the Instance of event
compEvents.setParams({ "relatedTasks" : relatedTasks });// setting the attribute of event
compEvents.fire();// firing the event.
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        console.log('Handler'+component.get("v.lstSelectedRecords"));
    
        component.set("v.SearchKeyWord",null);
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        listSelectedItems.push(selectedAccountGetFromEvent);
        component.set("v.lstSelectedRecords" , listSelectedItems); 
        //alert(JSON.stringify(listSelectedItems));
        var selectedContactIds = [];
        for(var i = 0; i<listSelectedItems.length; i++){
            
        	selectedContactIds.push(listSelectedItems[i].Id);     
        }
        //alert(listSelectedItems.length+'--'+selectedContactIds.length);
        helper.getRelatedTasks(component,event, selectedContactIds);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
        
        
    },
})