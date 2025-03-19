({
	showMyToast : function(component, event, helper) {
    	
        var messageType = component.get("v.type");
        var message		= component.get("v.message");
        var toastEvent = $A.get("e.force:showToast");
    	  	toastEvent.setParams({
            mode: 'sticky',
            type: messageType,
            message: message,  
    	});
    	toastEvent.fire();
	}
})