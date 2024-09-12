public class RetentionWatchlistBatch_V1 implements Database.Batchable<SObject>, Database.Stateful {
    
    // Variables to accumulate Accounts across batches
    List<Account> over25KProperties = new List<Account>();
    List<Account> over100KProperties = new List<Account>();
    List<Account> over200KProperties = new List<Account>();
    List<Account> over400KProperties = new List<Account>();
    Map<String, object> flowVariables = new Map<String, object>();
    
    // Query to get the relevant Account records
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Property_Watchlist_Settings__mdt thresholds= [SELECT Min_Property_Size__c,Large_Property_Size__c, SVP_Threshold__c,VPGM_Threshold__c  FROM Property_Watchlist_Settings__mdt LIMIT 1];
        Profile systAdmin =[SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        // Adjust the query according to your field criteria
        String query = 'SELECT Id, Latest_Maintenance_Job_Amount__c, Retention_Watchlist_Join_Date__c, Contract_Amount__c, Job_Number__c, Watchlist_Reason__c FROM Account ' +
                       'WHERE Retention_Watchlist_Join_Date__c = TODAY AND Owner.ProfileId = \'' +systAdmin.Id+'\' AND '+
                       'Latest_Maintenance_Job_Amount__c >'+thresholds.Min_Property_Size__c;
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        Property_Watchlist_Settings__mdt thresholds= [SELECT Min_Property_Size__c,Large_Property_Size__c, SVP_Threshold__c,VPGM_Threshold__c  FROM Property_Watchlist_Settings__mdt LIMIT 1];
        system.debug('Merhabaaaa'+scope);
        over25KProperties.addAll(scope);  
        for (Account acc : scope) {
            if (acc.Latest_Maintenance_Job_Amount__c >= thresholds.VPGM_Threshold__c) {
                over400KProperties.add(acc);
               }
            if (acc.Latest_Maintenance_Job_Amount__c >= thresholds.SVP_Threshold__c){
                over200KProperties.add(acc);
               }
            if (acc.Latest_Maintenance_Job_Amount__c >= thresholds.Large_Property_Size__c){
                over100KProperties.add(acc);
               }
        }
                
        if (!over400KProperties.isEmpty() || !over200KProperties.isEmpty() || over100KProperties.isEmpty() || !over25KProperties.isEmpty()) {
            
            // Create a Flow variable to hold the data
            flowVariables.put('over400KProperties', over400KProperties);
            flowVariables.put('over200KProperties', over200KProperties);
            flowVariables.put('over100KProperties', over100KProperties);
            flowVariables.put('over25KProperties', over25KProperties);
            }
   }

    public void finish(Database.BatchableContext bc) {
       system.debug('Accounts '+flowVariables);
       system.debug('over400KProperties '+ '  '+over400KProperties.size());
       system.debug('over200KProperties '+ '  '+over200KProperties.size());
       system.debug('over100KProperties '+ '  '+over100KProperties.size());
       system.debug('over25KProperties '+ '  '+over25KProperties.size()); 
      
        // Call the Flow with the accumulated lists only if they have records
 		   if (!over400KProperties.isEmpty() || !over200KProperties.isEmpty() || over100KProperties.isEmpty() || !over25KProperties.isEmpty()) {
            // Call the Flow using Flow.Interview
            //Flow.Interview.Batch_Apex_Flow_Aysel_Support myFlow = new Flow.Interview.Batch_Apex_Flow_Aysel_Support(flowVariables);
       		//myFlow.start();
        }
 	}
}