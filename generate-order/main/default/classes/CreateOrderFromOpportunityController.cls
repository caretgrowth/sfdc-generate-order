public with sharing class CreateOrderFromOpportunityController {
    
    @AuraEnabled
    public static Order createOrder(Id opptyId) {
        createOrders(new List<Opportunity>{(Opportunity)Opportunity.SObjectType.newSObject(opptyId)});
        return [SELECT Id, Name FROM Order WHERE OpportunityID = :opptyId ORDER BY CreatedDate DESC LIMIT 1];
    }

    @InvocableMethod(label='Create Order From Opportunity' description='Creates a new order with related products from the related Opportunity.')
    public static void createOrders(List<Opportunity> opptyIds) {
        Set<Id> oppIds = (new Map<Id,Opportunity>(opptyIds)).keySet();

        List<OpportunityLineItem> oppItems = [SELECT OpportunityId, id, Product2Id, Quantity, ServiceDate, Description, ListPrice, UnitPrice, PriceBookEntryId 
                                            FROM OpportunityLineItem WHERE OpportunityId = :oppIds];
        List<Opportunity> opptys = [SELECT o.id, o.Name, o.ContractId, c.StartDate, c.EndDate, o.AccountId, o.PriceBook2Id 
                                FROM Opportunity o, o.Contract c WHERE Id = :oppIds];

        List<Order> orders = new List<Order>();

        for(Opportunity o: opptys) {
            Order ord = new Order();
            ord.AccountId = o.AccountId;
            ord.Pricebook2Id = o.Pricebook2Id;
            ord.OpportunityId = o.id;
            ord.ContractId = o.ContractId != null ? o.ContractId : null;
            ord.Name = o.Name;
            ord.EffectiveDate = o.Contract.StartDate != null ? o.Contract.StartDate : date.today();
            ord.EndDate = o.Contract.EndDate != null ? o.Contract.EndDate : null;
            ord.Status = 'Draft';
            
            orders.add(ord);
        }
        
        insert orders;

        List<OrderItem> orderItems = new List<OrderItem>();

        for(Order ord: orders) {
            for (OpportunityLineItem oi: oppItems) {
                if(ord.OpportunityId == oi.OpportunityId) {
                    OrderItem ordItem = new OrderItem();
                    ordItem.OrderId = ord.Id;
                    ordItem.Product2Id = oi.Product2Id;
                    ordItem.ServiceDate = oi.ServiceDate > date.today() ? oi.ServiceDate : date.today();
                    ordItem.Description = oi.Description;
                    ordItem.UnitPrice = oi.UnitPrice;
                    ordItem.Quantity = oi.Quantity;
                    ordItem.PricebookEntryId = oi.PricebookEntryId;
                    
                    orderItems.add(ordItem);
                }
            }
        }

        if (orderItems.size() > 0) {
            insert orderItems;
        }
    }

}
