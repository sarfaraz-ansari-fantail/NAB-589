/************************************
* Author: Swaraa Banrrjee
* 
* *********************************/
@isTest
public class ChargeTriggerTest {
    
    @isTest
    public static void testChargeTrigger() {
        // Create test data
        Account acc = new Account();
        acc.Name = 'test Acc';
        insert acc;
        System.Assert(acc.Id!=null);
        Product2 prod = new Product2();
        prod.Name = 'Hanging Banner';
        prod.Category__c = 'Display Advertising';
        prod.Start_Date__c = System.today();
        prod.End_Date__c = System.today();
        prod.isActive = true;
        insert prod;
        System.Assert(prod.Id!=null);
        //create standard pricebook entry
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        PriceBookEntry stdPriceBookEntry = new PriceBookEntry();
        stdPriceBookEntry.Product2Id = prod.Id;
        stdPriceBookEntry.Pricebook2Id = stdPriceBookRecId;
        stdPriceBookEntry.UnitPrice = 2000;
        stdPriceBookEntry.IsActive = true;
        insert stdPriceBookEntry;
        
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = 'AACC 23';
        pricebook.IsActive = true;
        insert pricebook;
        System.assert(pricebook.Id!=null, 'Price book exist');
        
        //insert pricebookentry
        PricebookEntry pb = new PricebookEntry();
        pb.Pricebook2Id = pricebook.Id;
        pb.Product2Id = prod.Id;
        pb.UnitPrice = 2000;
        pb.IsActive = true;
        insert pb;
        
        Show_Type__c showtype = new Show_Type__c();
        showtype.Name = 'Test Amplify';
        insert showtype;
        
        Show__c show = new Show__c();
        show.Name = 'Test Show';
        show.Show_Start_Date__c = Date.newInstance(2023, 4, 1);
        show.Show_End_Date__c = Date.newInstance(2023, 4, 2);
        show.Show_Type_Lookup__c = showtype.Id;
        show.Price_Book__c = pricebook.Id;
        insert show;
        System.assert(show.Id != null);
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'test Opp';
        opp.Show__c = show.Id;
        opp.StageName = 'Discovery';
        opp.CloseDate = System.today();
        opp.Amount = 67000;
        opp.Pricebook2Id = pricebook.Id;
        insert opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.Product2Id= prod.Id;
        oli.OpportunityId= opp.Id;	
        oli.Quantity =1;     
        oli.TotalPrice=5678;
        oli.PricebookEntryId=pb.Id;
        insert oli;
        Invoice__c inv = new Invoice__c(Account__c = acc.Id, Show__c = show.Id, Invoice_Date__c = Date.today());
        insert inv;
        
        Charge__c charge = new Charge__c(Account__c = acc.Id, Amount__c = 50.00, Invoice__c = inv.Id,Opportunity_Product__c = oli.Id);
        insert charge;
        
        // Update the Charge record
        Transaction_Journal__c tj = new Transaction_Journal__c(Article_Type__c='Invoice', Article_ID__c=inv.Id, 
                                                               DrCr__c='DR', Amount__c=100.00, Date__c=Date.today()
                                                              );
        Transaction_Journal__c tj1 = new Transaction_Journal__c(Article_Type__c='Charge', Article_ID__c=charge.Id, 
                                                                DrCr__c='DR', Amount__c=100.00, Date__c=Date.today()
                                                               );
        
        insert tj;
        insert tj1;
        charge.Amount__c = 100; // Modify the amount
        update charge;
        delete charge;
        
    }
}