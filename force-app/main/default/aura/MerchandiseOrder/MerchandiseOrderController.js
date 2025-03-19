({
    init: function(component, event, helper) {
        var recordIds = component.get("v.recordIds");
        console.log('Record IDs in Aura:', recordIds);
        console.log('Record IDs passed from VF:', component.get("v.recordIds"));
    }
})