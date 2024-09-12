public class RetentionWatchlistBatch implements Database.Batchable<SObject>, Database.Stateful {
    // Define a map to store PropertyGroups by user email
    private Map<String, PropertyGroup> userPropertyGroups = new Map<String, PropertyGroup>();
    // Define the start method to query records

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Property_Watchlist_Settings__mdt thresholds= [SELECT Min_Property_Size__c,Large_Property_Size__c from Property_Watchlist_Settings__mdt LIMIT 1];
        system.debug(thresholds.Min_Property_Size__c);
        


        // Define a query to get Property accounts with specific criteria
        String query = 'SELECT Id, Name, Latest_Maintenance_Job_Amount__c, Watchlist_Join_Date__c, Contract_Amount__c, Job_Number__c, Watchlist_Reason__c, Owner.Email FROM Account ' +
                       'WHERE '+
                       'Latest_Maintenance_Job_Amount__c >'+thresholds.Min_Property_Size__c;
        system.debug(query);

        return Database.getQueryLocator(query);
    }

    // Define the execute method to process records in batches
    public void execute(Database.BatchableContext BC, List<Account> scope) {
    // Process each property record
    system.debug('Merhaba'+scope);
        for (Account acc : scope) {
            Id ownerId = acc.OwnerId;
            Decimal jobAmount = acc.Latest_Maintenance_Job_Amount__c;
            String ownerEmail = acc.Owner.Email;

            // Initialize PropertyGroup if not already present

            if (!userPropertyGroups.containsKey(ownerEmail)) {
                userPropertyGroups.put(ownerEmail, new PropertyGroup(
                    ownerEmail,
                    new List<Account>(),
                    new List<Account>()
                ));
            }
            //system.debug('Heyyyy'+userPropertyGroups);

           PropertyGroup pg = userPropertyGroups.get(ownerEmail);
            //system.debug('Heyyyy'+pg);

          // Add properties to appropriate lists based on amount
            if (jobAmount >= 100000) {
                pg.largeProperties.add(acc);
            } else if (jobAmount > 25000) {
                pg.smallProperties.add(acc);
            }
        }
 system.debug('Heyyyy'+userPropertyGroups);
    }

     // Define the finish method to handle post-processing
    public void finish(Database.BatchableContext BC) {
        system.debug('Merhabbbbbb'+userPropertyGroups.values());
        // Loop through PropertyGroups and prepare data for the Flow
        for (PropertyGroup pg : userPropertyGroups.values()) {
            // Map of inputs for the Flow
            Map<String, Object> inputs = new Map<String, Object>{
                'propertyGroups' => pg
            };
PropertyGroup prp= (PropertyGroup) inputs.get('propertyGroups');               
//system.debug('Merhabzzza'+inputs.get('propertyGroups').get('smallProperties'));
          system.debug('Merhabzzza'+prp.smallProperties);  
            // Invoke the Flow
           // Flow.Interview.Batch_Apex_Flow_Aysel_Support flowInstance = new Flow.Interview.Batch_Apex_Flow_Aysel_Support(inputs);
           //flowInstance.start();
        }
    }
}