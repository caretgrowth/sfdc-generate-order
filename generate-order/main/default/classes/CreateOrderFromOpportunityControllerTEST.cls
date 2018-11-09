@IsTest
public with sharing class CreateOrderFromOpportunityControllerTEST {

    private static void generateData() {
        // Generate data for testing
        Product2 p1 = new Product2(Name = 'Service 1', 
                                    Family = 'Professional Services');
        insert p1;

        Product2 p2 = new Product2(Name = 'Service 2', 
                            Family = 'Professional Services');
        insert p2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = p1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = p2.Id,
            UnitPrice = 15000, IsActive = true);
        insert standardPrice2;

        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice1 = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = p1.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice1;

        PricebookEntry customPrice2 = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = p2.Id,
            UnitPrice = 14000, IsActive = true);
        insert customPrice2;

        Account a = new Account(name='Test 1');
        insert a;

        Contact c = new Contact();
        c.AccountId = a.id;
        c.LastName = 'Test';
        c.LeadSource = 'Advertisement';
        insert c;
        
        Opportunity o = new Opportunity(name='Test 1 Oppty'
                                       , accountid = a.id
                                       , Pricebook2Id = customPB.id
                                       , StageName = 'Prospecting'
                                       , CloseDate=date.TODAY());
        insert o;

        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityID=o.id, Product2Id = customPrice1.id, quantity = 1, UnitPrice = 12000);
        insert oli1;

        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityID=o.id, Product2Id = customPrice2.id, quantity = 1, UnitPrice = 14000);
        insert oli2;
    }

    static testmethod void testOrderCreation() {
        generateData();
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        Order ord = CreateOrderFromOpportunityController.createOrder(oppty.id);
        List<OrderItem> ordItems = [SELECT Id FROM OrderItem WHERE OrderId = :ord.Id];
        system.assertEquals(ordItems.size(),2);
    }
}
