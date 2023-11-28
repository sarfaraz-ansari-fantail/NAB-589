trigger ChargeTrigger on Charge__c (after insert,after update,before delete)
{
 //System.debug('Charge::'+Trigger.New);
 // Map<Id,Charge__c> ChargeMap = new Map <Id,Charge__c>();
 Set <Id> OppProduct = new Set <Id>();  
  
    List<Transaction_Journal__c> transactionJournalList = new List <Transaction_Journal__c>();
    if(Trigger.isInsert){
 /*   for(Charge__c ch:Trigger.New)
    {
        OppProduct.add(ch.Opportunity_Product__c);
    }
        List<Charge__c> ChargeList = [SELECT Id, Name, LastModifiedDate,Opportunity_Product__r.Product2.Income_Acct_Number__c, LastReferencedDate, Account__c, Amount__c, Cancellation_Date__c, Charge_Date__c, Invoice__c, List_Price__c, Opportunity_Product__c, Show__c, Product_Category__c, 
                                      Product_Name__c, Opportunity_Product__r.Product2.Income_Acct_Name__c
                                      FROM Charge__c where Id IN: Trigger.newMap.keySet()];
        
    for(Charge__c ch:ChargeList)
    {
         System.debug('Charge'+ch);
         Transaction_Journal__c tj = new Transaction_Journal__c();
         tj.Amount__c = ch.Amount__c;
         tj.Article_ID__c = ch.Id;
         tj.DrCr__c = 'CR';
         tj.Article_Number__c = ch.Name;
        System.debug('Product details::'+ch.Opportunity_Product__r.Product2);
         tj.Fin_Acct_Number__c = ch.Opportunity_Product__r.Product2.Income_Acct_Number__c;
        System.debug('Line 23'+ch.Opportunity_Product__r.Product2.Income_Acct_Number__c);
        System.debug('TJ field--'+tj.Fin_Acct_Number__c);
         tj.Financial_Account__c =  ch.Opportunity_Product__r.Product2.Income_Acct_Name__c;
         tj.Date__c = ch.Charge_Date__c;
         tj.Article_Type__c = 'Charge';
         tj.Customer_Account__c = ch.Account__c;
         transactionJournalList.add(tj);
    }
     insert transactionJournalList; */
    }
    if(Trigger.isUpdate)
    {
        List<Id> ChargeIds = new List <Id>();
        Map<Id,Transaction_Journal__c> ChargeTJMap = new Map<Id,Transaction_Journal__c>();
        for(Charge__c ch:Trigger.New)
        {
            ChargeIds.add(ch.Id);
            
        }
        List<Transaction_Journal__c> oldtransactionJournalList = [SELECT Id, Name, Amount__c, Article_Type__c, Financial_Account__c, Article_ID__c, Date__c,Exported__c
                                                                  FROM Transaction_Journal__c where Article_ID__c IN:ChargeIds ];
        for(Transaction_Journal__c tj:oldtransactionJournalList)
        {
            ChargeTJMap.put(tj.Article_ID__c,tj);
            System.debug('ChargeTJMap::'+ChargeTJMap);
        }
        if(!oldtransactionJournalList.isEmpty())
        {
            for(Charge__c ch:Trigger.New)
            {
                if(ChargeTJMap.containsKey(ch.Id))
                {
                    if(ChargeTJMap.get(ch.Id).Exported__c == false)
                    {
                    ChargeTJMap.get(ch.Id).Amount__c = ch.Amount__c;
                    ChargeTJMap.get(ch.Id).Date__c = ch.Charge_Date__c;
                    //ChargeTJMap.get(ch.Id).Date__c = ch.Charge_Date__c;
                    // ChargeTJMap.get(ch.Id).Fin_Acct_Number__c = ch.Opportunity_Product__r.Product2.Income_Acct_Number__c;
                     ChargeTJMap.get(ch.Id).Customer_Account__c = ch.Account__c;
                    System.debug('Here');
                    transactionJournalList.add(ChargeTJMap.get(ch.Id));
                    }
                    if(ChargeTJMap.get(ch.Id).Exported__c == true)
                    {
                        System.debug('TJ::'+ChargeTJMap.get(ch.Id));
                        System.debug('Exported Value::'+ChargeTJMap.get(ch.Id).Exported__c);
                        ch.addError('This record cannot be modified as its corresponding Transaction Journal is already exported.');
                    }
                    
                }
            }
        }
        if(!transactionJournalList.isEmpty())
            update transactionJournalList;
    }
    if(Trigger.isDelete)
    {
      List<Id> ChargeIds = new List <Id>();
      Map<Id,Charge__c> ChargeMap = new Map<Id,Charge__c>();
        for(Charge__c ch:Trigger.old)
        {
            ChargeIds.add(ch.Id);
            ChargeMap.put(ch.Id,ch);
            
        }
         List<Transaction_Journal__c> oldtransactionJournalList = [SELECT Id, Name, Amount__c, Article_Type__c, Financial_Account__c, Article_ID__c, Date__c 
                                                                  FROM Transaction_Journal__c where Article_ID__c IN:ChargeIds and Exported__c= false];
         
         List<Transaction_Journal__c> oldtransactionJournalListDup = [SELECT Id, Name, Amount__c, Article_Type__c, Financial_Account__c, Article_ID__c, Date__c 
                                                                  FROM Transaction_Journal__c where Article_ID__c IN:ChargeIds and Exported__c= true];
         
       if(!oldtransactionJournalListDup.isEmpty())
        {
            for(Transaction_Journal__c tj:oldtransactionJournalListDup)
            {
            if(ChargeMap.containsKey(tj.Article_ID__c))
            {
                if(tj.Exported__c =true)
                    {
                        System.debug('In Line 104');
                        ChargeMap.get(tj.Article_ID__c).addError('This record cannot be deleted as its corresponding Transaction Journal is already exported.');
                    }
            }
            }
        } 
        
         
        if(!oldtransactionJournalList.isEmpty())
         {
             System.debug('Deleting TJ records');
             delete oldtransactionJournalList;
         }

    }

}