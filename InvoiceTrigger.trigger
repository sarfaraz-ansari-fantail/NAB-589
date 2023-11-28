/******************************************************************************************************
 * Author       : Swaraa Banrrjee swaraa.banrrjee@fantailtech.com
 * ***************************************************************************************************/
trigger InvoiceTrigger on Invoice__c (after update,before delete) {
    if(Trigger.isUpdate)
    {
      System.debug('In Invoice Trigger');
        Set<Id> InvoiceId = new Set<Id>();
        List<Invoice__c> InvList = new List<Invoice__c>();
      for(Invoice__c inv:Trigger.New)
      {
           InvoiceId.add(inv.Id);
           InvList.add(inv);
      }
      List<Transaction_Journal__c> transactionJournalList = new List <Transaction_Journal__c>();
      List<Transaction_Journal__c> updatetransactionJournalList = new List <Transaction_Journal__c>();
      List<Transaction_Journal__c> existingTJList = [SELECT Id, Name, Article_Type__c, Article_ID__c,DrCr__c, Date__c, Article_Number__c,Exported__c FROM 
                                                           Transaction_Journal__c where Article_ID__c IN:InvoiceId];
       Map<Id,Transaction_Journal__c> InvTJMap = new Map<Id,Transaction_Journal__c> ();
            for(Transaction_Journal__c tj:existingTJList)
            {
                InvTJMap.put(tj.Article_ID__c,tj);
            }
        
        if(!existingTJList.isEmpty())
            {
                
                for(Invoice__c inv: InvList)
                {
                    Invoice__c oldObj = Trigger.oldMap.get(inv.Id);

                   // Check if the MyField__c has changed
                   if (inv.Total_Paid_Amount__c != oldObj.Total_Paid_Amount__c ||inv.Balance_Amount__c != oldObj.Balance_Amount__c|| inv.Total_Credit_Memo_Amount__c != oldObj.Total_Credit_Memo_Amount__c) {
                        System.debug('Total Paid Amount field has changed');
                     }
                    if(InvTJMap.containsKey(inv.Id) && InvTJMap.get(inv.Id).Exported__c ==false )
                    {
                        System.debug('In Update Invoice'+ InvTJMap.get(inv.Id).Name);
                        InvTJMap.get(inv.Id).Amount__c = inv.Total_Charges__c;
                        InvTJMap.get(inv.Id).Customer_Account__c = inv.Account__c;
                        InvTJMap.get(inv.Id).Date__c = inv.Invoice_Date__c;
                      //  InvTJMap.get(inv.Id).Fin_Acct_Number__c = inv.Show__r.A_R_Acct_Number__c;
                      //  InvTJMap.get(inv.Id).Financial_Account__c = inv.Show__r.A_R_Acct_Name__c;
                        updatetransactionJournalList.add(InvTJMap.get(inv.Id));
                    }
                    if(InvTJMap.containsKey(inv.Id))
                    {
                        if(InvTJMap.get(inv.Id).Exported__c == true && (inv.Total_Paid_Amount__c != oldObj.Total_Paid_Amount__c ||inv.Balance_Amount__c != oldObj.Balance_Amount__c|| inv.Total_Credit_Memo_Amount__c != oldObj.Total_Credit_Memo_Amount__c))
                        {
                            System.debug('In here-->Line 46');
                        }
                        if(InvTJMap.get(inv.Id).Exported__c == true && inv.Total_Paid_Amount__c == oldObj.Total_Paid_Amount__c && inv.Balance_Amount__c == oldObj.Balance_Amount__c && inv.Total_Credit_Memo_Amount__c == oldObj.Total_Credit_Memo_Amount__c) 
                        {
                        System.debug('Line 36');
                        inv.addError('The record cannot be modified as its corresponding Transaction Journal is already exported.');
                        }
                    }
                }
                System.debug('Updating TJ List');
               // update updatetransactionJournalList;
            }
        if(!updatetransactionJournalList.isEmpty())
        {
             update updatetransactionJournalList;
        }
       System.debug('Old Values of Invoice'+trigger.old);
       System.debug('New Value of Invoice'+trigger.new); 
        
    }
    if(Trigger.isDelete)
    {
        List<Id> oldInv = new List<Id>();
        Map<Id,Invoice__c> InvoiceMap = new Map<Id,Invoice__c>();
        for(Invoice__c inv: Trigger.old)
        {
            oldInv.add(inv.Id);
            InvoiceMap.put(inv.Id,inv);
        }
        List<Charge__c> oldChargeList = [SELECT Id, Name, Account__c, Amount__c,Invoice__c FROM Charge__c where Invoice__c IN:oldInv];
        List<Id> ChargeIds = new List <Id>();
        Map<Id,Charge__c> ChargeMap = new Map<Id,Charge__c>();
        for(Charge__c ch:oldChargeList)
        {
            ChargeIds.add(ch.Id);
            ChargeMap.put(ch.Id,ch);
            
        }
         List<Transaction_Journal__c> oldtransactionJournalList = [SELECT Id, Name, Amount__c, Article_Type__c, Financial_Account__c, Article_ID__c, Date__c 
                                                                  FROM Transaction_Journal__c where Article_ID__c IN:ChargeIds and Exported__c= false];
         List<Transaction_Journal__c> existingTJList = [SELECT Id, Name, Article_Type__c, Article_ID__c,DrCr__c, Date__c, Article_Number__c FROM 
                                                           Transaction_Journal__c where Article_ID__c IN:oldInv];
  /*       List<Transaction_Journal__c> oldtransactionJournalListdup = [SELECT Id, Name, Amount__c, Article_Type__c, Financial_Account__c, Article_ID__c, Date__c 
                                                                  FROM Transaction_Journal__c where Article_ID__c IN:ChargeIds and Exported__c= true];*/
         List<Transaction_Journal__c> existingTJListdup = [SELECT Id, Name, Article_Type__c, Article_ID__c,DrCr__c, Date__c, Article_Number__c FROM 
                                                           Transaction_Journal__c where Article_ID__c IN:oldInv and Exported__c= true];
        
     /*   if(!oldtransactionJournalListdup.isEmpty())
        {
            for(Transaction_Journal__c tj:oldtransactionJournalListdup)
            {
                if(ChargeMap.containsKey(tj.Article_ID__c))
                {
                    System.debug('Line 82');
                   // ChargeMap.get(tj.Article_ID__c).addError('The Charge cannot be deleted as its corresponding Transaction Journal is already exported.'); 
                }
            }
        } */
        if(!existingTJListdup.isEmpty())
        {
            for(Transaction_Journal__c tj: existingTJListdup)
            {
                if(InvoiceMap.containsKey(tj.Article_ID__c))
                {
                    System.debug('Line 93');
                    InvoiceMap.get(tj.Article_ID__c).addError('The record cannot be deleted as its corresponding Transaction Journal is already exported.');
                }
            }
        }
        
        if(!existingTJList.isEmpty())
        {
            delete existingTJList;
        }
        if(!oldtransactionJournalList.isEmpty())
        {
            delete oldtransactionJournalList;
        }
        
    }
    

}