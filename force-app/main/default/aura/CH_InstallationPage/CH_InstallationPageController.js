({   
    initiateFlow : function(component, event, helper) {
         var flow = component.find("flowData");
         flow.startFlow("Install_AAF_Product_Category_Hierarchy_Forecast_Set");
        component.set("v.processCompleted",true);
        
    },
    handleStatusChange  : function (cmp, event,helper) {
         
        if (event.getParam('status') === "FINISHED_SCREEN") {
            cmp.set("v.type","success");
            cmp.set("v.message","Product Category Hierarchy Forecast Set was installed.");
            helper.showMyToast(cmp, event,helper);
        }
         if (event.getParam('status') === "ERROR") {
            cmp.set("v.type","info");
            cmp.set("v.message","The Product Category Hierarchy Forecast Set is already installed. We can’t run the flow again.");
            helper.showMyToast(cmp, event,helper);
        }
        cmp.set("v.isActive",false);
    }
})