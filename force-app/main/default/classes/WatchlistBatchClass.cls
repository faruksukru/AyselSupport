public class WatchlistBatchClass implements Database.Batchable<SObject>, Database.Stateful {

    // Variables to accumulate Accounts across batches
    List<Account> highAmountAccounts = new List<Account>();
    List<Account> veryHighAmountAccounts = new List<Account>();
    Map<String, object> flowVariables = new Map<String, object>();
    String emailBodyForVeryHighAmount ='Dear Recipient,\n\n Here is the List for Over 100 K Watchlist Accounts:\n\n';
   // emailBodyForVeryHighAmount+='Here is the List for Over 100 K Watchlist Accounts:\n\n';
    String emailBodyForHighAmount ='Dear Recipient,\n\n Here is the List for Between 25-100 K Watchlist Accounts:\n\n';
    //emailBodyForVeryHighAmount+='Here is the List for Between 25-100 K Watchlist Accounts:\n\n';

    // Query to get the relevant Account records
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Adjust the query according to your field criteria
        return Database.getQueryLocator('SELECT Id, Name, Latest_Maintenance_Job_Amount__c, Watchlist_Join_Date__c, Contract_Amount__c, Job_Number__c, Watchlist_Reason__c FROM Account WHERE Latest_Maintenance_Job_Amount__c > 25000');
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        //system.debug('merhaba');
        // Process each record and categorize
        for (Account acc : scope) {
            if (acc.Latest_Maintenance_Job_Amount__c >= 100000) {
                veryHighAmountAccounts.add(acc);
                emailBodyForVeryHighAmount += acc.Name+ ' - ' + acc.Contract_Amount__c+ ' - ' +acc.Job_Number__c+'\n';
           	} else{
                highAmountAccounts.add(acc);
                emailBodyForHighAmount += acc.Name+ ' - ' + acc.Contract_Amount__c+ ' - ' +acc.Job_Number__c+'\n';
            }
        }
        /*system.debug('veryHighAmountAccounts '+veryHighAmountAccounts);
        system.debug('highAmountAccounts '+highAmountAccounts);
        system.debug('emailBodyForVeryHighAmount '+emailBodyForVeryHighAmount);
        system.debug('emailBodyForHighAmount '+emailBodyForHighAmount);*/
        
        if (!highAmountAccounts.isEmpty() || !veryHighAmountAccounts.isEmpty()) {
           // system.debug('merhaba');
            // Create a Flow variable to hold the data
            flowVariables.put('HighAmountAccounts', highAmountAccounts);
            flowVariables.put('VeryHighAmountAccounts', veryHighAmountAccounts);
            flowVariables.put('emailBodyForVeryHighAmount', emailBodyForVeryHighAmount);
            flowVariables.put('emailBodyForHighAmount', emailBodyForHighAmount);
            // Call the Flow using Flow.Interview
            //Flow.Interview.Batch_Apex_Flow_Aysel_Support myFlow = new Flow.Interview.Batch_Apex_Flow_Aysel_Support(flowVariables);
            //myFlow.start();
        }
        system.debug('Accounts '+flowVariables);
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('heyy'+bc);
        system.debug('gsgsgsg'+flowVariables);
       Flow.Interview.Batch_Apex_Flow_Aysel_Support myFlow = new Flow.Interview.Batch_Apex_Flow_Aysel_Support(flowVariables);
       myFlow.start();
        // Call the Flow with the accumulated lists only if they have records
 		//system.debug('veryHighAmountAccounts_finish '+veryHighAmountAccounts);
        //system.debug('highAmountAccounts_finish '+highAmountAccounts);
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
       // System.debug('Batch job completed.');
    }
}