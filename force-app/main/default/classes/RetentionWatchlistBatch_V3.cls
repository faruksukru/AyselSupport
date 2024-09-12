public class RetentionWatchlistBatch_V3 implements Database.Batchable<SObject>, Database.Stateful {

    // Variables to accumulate Accounts with Emails and Thresholds across batches
    Map<String, Object> flowInputs = new Map<String, Object>();
    Map<String, List<Account>> emailToAccountMap = new Map<String, List<Account>>();
    Property_Watchlist_Settings__mdt thresholds = new Property_Watchlist_Settings__mdt();

    // Inner class to group accounts by email
    private class RelateAccountWithEmail { 
        private Map<String, List<Account>> emailToAccountMap;

        // Constructor to initialize the map
        public RelateAccountWithEmail(Map<String, List<Account>> mapAccount) {
            this.emailToAccountMap = mapAccount;
        }

        public void accountsWithEmail(Account acc, String email) {
            if (email != null && email != '') {
                if (!emailToAccountMap.containsKey(email)) {
                    emailToAccountMap.put(email, new List<Account>());
                }
                emailToAccountMap.get(email).add(acc);
            }
        }
    }

    // Batch Start Method
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Get Thresholds from Custom Metadata
         this.thresholds = [
            SELECT Min_Property_Size__c, Executive_Threshold__c, SVP_Threshold__c, VPGM_Threshold__c  
            FROM Property_Watchlist_Settings__mdt 
            LIMIT 1
        ];
        //Get System Admin Profile Id
        Profile systAdmin =[SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //Create String Query
        String query = 'SELECT Id, Name, Latest_Maintenance_Job_Amount__c, Retention_Watchlist_Join_Date__c, Job_Number__c, Watchlist_Reason__c, '+
            			'Owner.Email, Branch__r.Manager__r.Email, Branch__r.SVP__r.Email,Branch__r.VPGM__r.Email FROM Account ' +
                       'WHERE Retention_Watchlist_Join_Date__c = TODAY AND Owner.ProfileId != \'' +systAdmin.Id+'\' AND '+
                       'Latest_Maintenance_Job_Amount__c >'+thresholds.Min_Property_Size__c;
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    // Batch Execute Method
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // Instantiate the inner class with the map
        RelateAccountWithEmail relateEmailHelper = new RelateAccountWithEmail(emailToAccountMap);
		//Calling Inner Class to group accounts with email
        for (Account acc : scope) {
            String email = acc.Owner.Email;
            relateEmailHelper.accountsWithEmail(acc, email);
            email = acc.Branch__r.Manager__r.Email;
            relateEmailHelper.accountsWithEmail(acc, email);
            if (acc.Latest_Maintenance_Job_Amount__c >= this.thresholds.VPGM_Threshold__c){
                email = acc.Branch__r.VPGM__r.Email;
                relateEmailHelper.accountsWithEmail(acc, email);
               }
            if (acc.Latest_Maintenance_Job_Amount__c >= this.thresholds.SVP_Threshold__c){
                email = acc.Branch__r.SVP__r.Email;
                relateEmailHelper.accountsWithEmail(acc, email);
               }
            if (acc.Latest_Maintenance_Job_Amount__c >= thresholds.Executive_Threshold__c) {
                relateEmailHelper.accountsWithEmail(acc, 'ingilizcetranslation@gmail.com');// get executive emails from custom metadata
               }
        }
    }

    // Batch Finish Method to put all Account Lists with Email to a Map, and Ivoke Flow
    public void finish(Database.BatchableContext bc) {
        
        // Debugging output for verification
        for (String email : emailToAccountMap.keySet()) {
            System.debug(email); 
            for (Account acc : emailToAccountMap.get(email)) {
                System.debug(acc);
            }
        }

        // Process each group and pass it to the Flow via an InvocableMethod
        List<PropertyGroup> inputList = new List<PropertyGroup>();

        for (String email : emailToAccountMap.keySet()) {
            PropertyGroup input = new PropertyGroup(email, emailToAccountMap.get(email));
            inputList.add(input);
        }

        // Pass this inputList to the Flow by putting in Map
        flowInputs.put('AccountsGrouped', inputList);
       
       // Call the Flow to send Emails
        //Flow.Interview.Test_Aysel_Email myFlow = new Flow.Interview.Test_Aysel_Email(flowInputs);
        //myFlow.start(); // Start the Flow
    }
}