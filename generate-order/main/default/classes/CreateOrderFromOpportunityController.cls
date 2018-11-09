public with sharing class CreateOrderFromOpportunityController {
    
    @AuraEnabled
    public static Order createOrder(Id opptyId) {
        List<OpportunityLineItem> oppItems = [SELECT id, Product2Id, Quantity, ServiceDate, Description, ListPrice, UnitPrice, PriceBookEntryId 
                                            FROM OpportunityLineItem WHERE OpportunityId = :opptyId];
        Opportunity oppty = [SELECT o.id, o.Name, o.ContractId, c.StartDate, c.EndDate, o.AccountId, o.PriceBook2Id 
                                FROM Opportunity o, o.Contract c WHERE Id = :opptyId LIMIT 1];

        Order ord = new Order();
        ord.AccountId = oppty.AccountId;
        ord.Pricebook2Id = oppty.Pricebook2Id;
        ord.ContractId = oppty.ContractId != null ? oppty.ContractId : null;
        ord.Name = oppty.Name;
        ord.EffectiveDate = oppty.Contract.StartDate != null ? oppty.Contract.StartDate : date.today();
        ord.EndDate = oppty.Contract.EndDate != null ? oppty.Contract.EndDate : null;
        ord.Status = 'Draft';

        insert ord; 

        List<OrderItem> orderItems = new List<OrderItem>();

        for (OpportunityLineItem oi: oppItems) {
            OrderItem ordItem = new OrderItem();
            ordItem.OrderId = ord.Id;
            ordItem.Product2Id = oi.Product2Id;
            ordItem.ServiceDate = oi.ServiceDate;
            ordItem.Description = oi.Description;
            ordItem.UnitPrice = oi.UnitPrice;
            ordItem.Quantity = oi.Quantity;
            ordItem.PricebookEntryId = oi.PricebookEntryId;
            
            orderItems.add(ordItem);
        }

        if (orderItems.size() > 0) {
            insert orderItems;
        }

        return ord;
    }

}
