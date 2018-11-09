({

    createRelatedOrder : function(component, event, helper) {

        var createOrderAction = component.get("c.createOrder");
        createOrderAction.setParams({"opptyId": component.get("v.recordId")});
        createOrderAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.newOrder", response.getReturnValue());

                var resultsToast = $A.get("e.force:showToast");

                resultsToast.setParams({
                    mode: 'dismissible',
                    message: 'New Order Created',
                    messageTemplate: 'Order {0} created!',
                    messageTemplateData: [{
                        url: '/lightning/r/Order/' + component.get("v.newOrder.Id") + '/view',
                        label: component.get("v.newOrder.Name"),
                        }
                    ]
                });
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                $A.get("e.force:refreshView").fire();
            } else {
                console.log('Problem creating the order, response state: ' + state);
            }
        });

        $A.enqueueAction(createOrderAction);
    },

    handleCancel : function() {
        $A.get("e.force:closeQuickAction").fire();
    }
})
