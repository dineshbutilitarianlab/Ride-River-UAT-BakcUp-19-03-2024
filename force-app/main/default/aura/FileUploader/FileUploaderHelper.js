({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function (component, event) {
        component.set("v.showLoadingSpinner", true);
        let recordId = component.get("v.recordId");
        console.log("Record ID in uploadHelper:", recordId);
        
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        if (file.size > this.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", "Alert: File size cannot exceed " + this.MAX_FILE_SIZE + " bytes. Selected file size: " + file.size);
            return;
        }
        
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(() => {
            var fileContents = objFileReader.result;
            var base64 = "base64,";
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            this.uploadProcess(component, file, fileContents);
        });
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function (component, file, fileContents) {
        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, "");
    },
    
    uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId) {
        debugger;
        let recordId = component.get("v.recordId");
        var urlParams = new URLSearchParams(window.location.search);
        var recordIdURL = urlParams.get('id');
        // const currentUrl = window.location.href;
        // var recordIdURL;
        // var urldata;
        // if (currentUrl.indexOf('/r/Account/') == -1) {
        //     urldata = currentUrl.split('/r/Account/');
        //    // const parts = currentUrl.split('/r/Account/');
        //     if (urldata.length == 1) {
        //         recordIdURL = urldata[0].split('/')[0];
        //     }
        // }
        component.set("v.recordId", recordIdURL);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: recordIdURL,
            fileName: component.get("v.fileName"),
            base64Data: encodeURIComponent(fileContents.substring(startPosition, endPosition)),
            contentType: file.type,
            fileId: attachId
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, response.getReturnValue());
                } else {
                    component.set("v.showLoadingSpinner", false);
                    component.set("v.showFileUpload", false);
                }
            } else {
                console.error("Error in uploadInChunk:", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    
    navigateToParentRecord : function(component,event,helper)
    {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
            //  "slideDevName": "related"
        });
        navEvt.fire();       
        
    },
    
    showToast : function(component,event,helper)
    {
        
        
    },
    
    
})