public class WatchlistBatchClass implements Database.Batchable<SObject> {

    // Variables to accumulate Accounts across batches
    List<Account> highAmountAccounts = new List<Account>();
    List<Account> veryHighAmountAccounts = new List<Account>();
    Map<String, List<Account>> flowVariables = new Map<String, List<Account>>();

    // Query to get the relevant Account records
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Adjust the query according to your field criteria
        return Database.getQueryLocator('SELECT Id, Latest_Maintenance_Job_Amount__c, Watchlist_Join_Date__c, Contract_Amount__c, Job_Number__c, Watchlist_Reason__c FROM Account WHERE Latest_Maintenance_Job_Amount__c > 25000 AND Watchlist_Join_Date__c = TODAY');
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // Process each record and categorize
        for (Account acc : scope) {
            if (acc.Latest_Maintenance_Job_Amount__c > 100000) {
                veryHighAmountAccounts.add(acc);
            } else if (acc.Latest_Maintenance_Job_Amount__c > 25000) {
                highAmountAccounts.add(acc);
            }
        }
        system.debug('veryHighAmountAccounts '+veryHighAmountAccounts);
        system.debug('highAmountAccounts '+highAmountAccounts);
        if (!highAmountAccounts.isEmpty() || !veryHighAmountAccounts.isEmpty()) {
            system.debug('merhaba');
            // Create a Flow variable to hold the data
            flowVariables.put('HighAmountAccounts', highAmountAccounts);
            flowVariables.put('VeryHighAmountAccounts', veryHighAmountAccounts);
            // Call the Flow using Flow.Interview
            Flow.Interview.Batch_Apex_Flow_Aysel_Support myFlow = new Flow.Interview.Batch_Apex_Flow_Aysel_Support(flowVariables);
            myFlow.start();
        }
        system.debug('Accounts '+flowVariables);
    }

    public void finish(Database.BatchableContext bc) {
        // Call the Flow with the accumulated lists only if they have records
 		system.debug('veryHighAmountAccounts_finish '+veryHighAmountAccounts);
        system.debug('highAmountAccounts_finish '+highAmountAccounts);
       /* if (!highAmountAccounts.isEmpty() || !veryHighAmountAccounts.isEmpty()) {
            system.debug('merhaba');
            // Create a Flow variable to hold the data
            flowVariables.put('HighAmountAccounts', highAmountAccounts);
            flowVariables.put('VeryHighAmountAccounts', veryHighAmountAccounts);
            // Call the Flow using Flow.Interview
            //Flow.Interview.MyAutoLaunchFlow myFlow = new Flow.Interview.MyAutoLaunchFlow(flowVariables);
           // myFlow.start();
        }
 		system.debug('Accounts '+flowVariables);*/
        // Optional: Log or perform other finish actions
        System.debug('Batch job completed.');
    }
}