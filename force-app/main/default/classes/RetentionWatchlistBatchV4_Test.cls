@isTest
public class RetentionWatchlistBatchV4_Test {

    @testSetup
    static void setupTestData() {
        // Insert mock System Administrator Profile for testing
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        // Create User records for testing
        User manager1 = new User(
            FirstName = 'Test',
            LastName = 'Manager1',
            Email = 'manager1@example.com',
            Username = 'testmanager1@example.com',
            ProfileId = sysAdminProfile.Id,
            Alias = 'tmngr1', // Alias is now 8 characters or less
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert manager1;

        User svp1 = new User(
            FirstName = 'Test',
            LastName = 'SVP1',
            Email = 'svp1@example.com',
            Username = 'testsvp1@example.com',
            ProfileId = sysAdminProfile.Id,
            Alias = 'tsvp1', // Alias is now 8 characters or less
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert svp1;

        User vpgm1 = new User(
            FirstName = 'Test',
            LastName = 'VPGM1',
            Email = 'vpgm1@example.com',
            Username = 'testvpgm1@example.com',
            ProfileId = sysAdminProfile.Id,
            Alias = 'tvpgm1', // Alias is now 8 characters or less
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert vpgm1;

        // Insert test Branch__c record
        Branch__c branch = new Branch__c(
            Manager__c = manager1.Id, // Reference the User ID, not Manager__r
            SVP__c = svp1.Id,         // Reference the User ID
            VPGM__c = vpgm1.Id        // Reference the User ID
        );
        insert branch;

        // Insert test Account records and reference the Branch__c record
        Account acc1 = new Account(
            Name = 'Test Account 1',
            Latest_Maintenance_Job_Amount__c = 3000,
            Retention_Watchlist_Join_Date__c = Date.today(),
            OwnerId = manager1.Id, // Owner is the manager (User)
            Branch__c = branch.Id  // Reference the Branch__c ID
        );
        insert acc1;

        // Repeat the same for another account
        Account acc2 = new Account(
            Name = 'Test Account 2',
            Latest_Maintenance_Job_Amount__c = 4000,
            Retention_Watchlist_Join_Date__c = Date.today(),
            OwnerId = manager1.Id, // Same manager as Owner
            Branch__c = branch.Id  // Reference the Branch__c ID
        );
        insert acc2;

        
    }

    @isTest
    static void testBatchExecution() {
        // Mock custom metadata by querying it in the batch class.
        Test.startTest();

        // Instantiate the batch
        RetentionWatchlistBatch_V4 batch = new RetentionWatchlistBatch_V4();

        // Execute the batch
        Database.executeBatch(batch);

        // Stop Test
        Test.stopTest();

        // Query the results to validate execution
        List<Account> accounts = [SELECT Name, Latest_Maintenance_Job_Amount__c, Owner.Email 
                                  FROM Account 
                                  WHERE Name LIKE 'Test Account%'];
        
        // Assert that the accounts were processed
        System.assertEquals(2, accounts.size(), 'Two accounts should have been processed');

        // Optionally add more assertions based on your batch process output
    }

    @isTest
    static void testInnerClassFunctionality() {
        // Initialize a mock map for testing inner class
        Map<String, List<Account>> emailToAccountMap = new Map<String, List<Account>>();

        // Create instance of the inner class
        RetentionWatchlistBatch_V4.RelateAccountWithEmail relateEmailHelper = new RetentionWatchlistBatch_V4.RelateAccountWithEmail(emailToAccountMap);

        // Prepare test data
        Account acc1 = [SELECT Id, Owner.Email FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        Account acc2 = [SELECT Id, Owner.Email FROM Account WHERE Name = 'Test Account 2' LIMIT 1];

        // Simulate adding accounts with emails
        relateEmailHelper.accountsWithEmail(acc1, 'manager1@example.com');
        relateEmailHelper.accountsWithEmail(acc2, 'manager1@example.com');

        // Assert that the accounts were added correctly
        List<Account> accountsForEmail = emailToAccountMap.get('manager1@example.com');
        System.assertNotEquals(null, accountsForEmail, 'Accounts list should not be null');
        System.assertEquals(2, accountsForEmail.size(), 'There should be two accounts for this email');
        System.assert(accountsForEmail.contains(acc1), 'Accounts list should contain acc1');
        System.assert(accountsForEmail.contains(acc2), 'Accounts list should contain acc2');
    }
    // Mock Custom Metadata Class
    @TestVisible
    static Property_Watchlist_Settings__mdt mockCustomMetadata() {
        Property_Watchlist_Settings__mdt settings = new Property_Watchlist_Settings__mdt(
            Min_Property_Size__c = 500,
            Executive_Threshold__c = 2000,
            SVP_Threshold__c = 1500,
            VPGM_Threshold__c = 1000
        );
        return settings;
    }
}