({
    handleSelect : function (component, event, helper) {
        var selectedStage = event.getParam("detail").value;
        component.set("v.selectedStage", selectedStage);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Stage Selected",
            "message": "You selected: " + selectedStage,
            "type": "info"
        });
        toastEvent.fire();
    },

    handleSave : function (component, event, helper) {
        var selectedStage = component.get("v.selectedStage");
        var recordId = component.get("v.recordId");

        console.log('Calling updateStatus with:', recordId, selectedStage);

        if (!recordId) {
            alert('Error: recordId is empty');
            return;
        }

        if (!selectedStage) {
            alert('Error: No stage selected');
            return;
        }

        var action = component.get("c.updateStatus");
        action.setParams({
            recordId: recordId,
            newStatus: selectedStage
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Apex response state:', state);

            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Status updated to: " + selectedStage,
                    "type": "success"
                });
                toastEvent.fire();

                component.set("v.selectedStage", "");

                // Recarrega a página se o status for 'Closed'
                if (selectedStage === 'Closed') {
                    $A.get('e.force:refreshView').fire();
                }

            } else {
                var errors = response.getError();
                console.error('Error updating status:', errors);

                var message = (errors && errors[0] && errors[0].message) 
                    ? errors[0].message 
                    : "Unknown error";

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    }
})
