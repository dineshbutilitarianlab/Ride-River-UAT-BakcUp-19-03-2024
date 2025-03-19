({
    doInit: function (component, event, helper) {
        let recordId = component.get("v.recordId");
        console.log("Initial Record ID:", recordId);

        if (!recordId) {
            console.error("Record ID is undefined, setting a fallback.");
            recordId = "<FallbackRecordId>"; // Replace with a valid ID for testing
            component.set("v.recordId", recordId);
        }

        component.set("v.parentId", recordId);
    },

    doSave: function (component, event, helper) {
        if (component.find("fileId").get("v.files") === null) {
            alert("Please Select a File");
        } else if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        }
    },

    handleFilesChange: function (component, event) {
        var customFileName = "No File Selected..";
        if (event.getSource().get("v.files").length > 0) {
            customFileName = event.getSource().get("v.files")[0].name;
        }
        component.set("v.fileName", customFileName);
    },

    closeModel: function (component) {
        component.set("v.showFileUpload", false);
    }
});