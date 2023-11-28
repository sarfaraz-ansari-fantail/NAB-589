@isTest
private class InvoiceTriggerTest {
    
    static testMethod void testInvoiceTrigger() {
        
        // Create test data
        Account acc = new Account(Name='Test Account');
        insert acc;
        System.assert(acc.Id!=null);
        
        Show_Type__c showtype = new Show_Type__c(Name = 'Test Show Type');
        insert showtype;
        
        Show__c show = new Show__c(Name='Test Show',Show_Start_Date__c = Date.newInstance(2023, 3, 1), Show_End_Date__c = Date.newInstance(2023, 3, 2), Show_Type_Lookup__c = showtype.Id);
        insert show;
        
        
        Invoice__c inv = new Invoice__c(Account__c = acc.Id, Show__c = show.Id, Invoice_Date__c = Date.today());
        insert inv;
        
        Charge__c ch = new Charge__c(Account__c = acc.Id, Amount__c = 50.00, Invoice__c = inv.Id);
        insert ch;
        
        Transaction_Journal__c tj = new Transaction_Journal__c(Article_Type__c='Invoice', Article_ID__c=inv.Id, 
                                                               DrCr__c='DR', Amount__c=100.00, Date__c=Date.today()
                                                              );
        Transaction_Journal__c tj1 = new Transaction_Journal__c(Article_Type__c='Charge', Article_ID__c=ch.Id, 
                                                                DrCr__c='DR', Amount__c=100.00, Date__c=Date.today()
                                                               );
        
        insert tj;
        // Test update trigger
        ch.Amount__c = 500.00;
        update ch;
        update inv;
        tj = [SELECT Amount__c, Customer_Account__c, Date__c, Fin_Acct_Number__c FROM Transaction_Journal__c WHERE Id = :tj.Id];
        System.assertEquals(500.00, tj.Amount__c);
        System.assertEquals(acc.Id, tj.Customer_Account__c);
        System.assertEquals(Date.today(), tj.Date__c);
        
        
        // Test delete trigger
        delete inv;
        
    }
}