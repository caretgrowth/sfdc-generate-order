public with sharing class CreateOrderFromOpportunityController {
    
    @AuraEnabled
    public static Opportunity getOpportunity(Id opptyId) {
        return [SELECT ID, ContractId FROM Opportunity WHERE Id = :opptyId];
    }

    @AuraEnabled
    public static Order createOrder(Id opptyId) {
        List<OpportunityLineItem> oppItems = [SELECT id, Product2Id, Quantity, ServiceDate, Description, ListPrice, UnitPrice 
                                            FROM OpportunityLineItem WHERE OpportunityId = :opptyId];
        Opportunity oppty = [SELECT o.id, o.Name, o.ContractId, c.StartDate, c.EndDate, o.AccountId FROM Opportunity o, o.Contract c WHERE Id = :opptyId LIMIT 1];

        // Opportunity oppty = oppInfo[0];

        Order newOrder = new Order();
        newOrder.AccountId = oppty.AccountId;
        newOrder.ContractId = oppty.ContractId != null ? oppty.ContractId : null;
        newOrder.Name = oppty.Name;
        newOrder.EffectiveDate = oppty.Contract.StartDate != null ? oppty.Contract.StartDate : date.today();
        newOrder.EndDate = oppty.Contract.EndDate != null ? oppty.Contract.EndDate : null;
        newOrder.Status = 'Draft';

        insert newOrder;

        List<OrderItem> orderItems = new List<OrderItem>();

        for (OpportunityLineItem oi: oppItems) {
            OrderItem ordItem = new OrderItem();
            ordItem.OrderId = newOrder.Id;
            ordItem.Product2Id = oi.Product2Id;
            ordItem.ServiceDate = oi.ServiceDate;
            ordItem.Description = oi.Description;
            ordItem.UnitPrice = oi.UnitPrice;
            ordItem.Quantity = oi.Quantity;
            
            orderItems.add(ordItem);
        }

        if (orderItems.size() > 0) {
            insert orderItems;
        }

        return newOrder;
    }

}
