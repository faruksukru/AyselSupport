@isTest
public class RetentionWatchlistBatchV4_Test1 {

    @testSetup
    static void setupTestData() {
        // Insert mock System Administrator Profile for testing
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile dhcProfile = [SELECT Id FROM Profile WHERE Name = 'DHC Admin' LIMIT 1];
        // Create User records for testing
        User manager1 = new User(
            FirstName = 'Test',
            LastName = 'Manager1',
            Email = 'manager1@example.com',
            Username = 'testmanager1@example.com',
            ProfileId = dhcProfile.Id,
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
            ProfileId = dhcProfile.Id,
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
            ProfileId = dhcProfile.Id,
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
        RecordType propertyRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Property' AND SObjectType = 'Account' LIMIT 1];
        RecordType property1RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Property1' AND SObjectType = 'Account' LIMIT 1];
        Account acc1 = new Account(
            Name = 'Test Account 1',
            Latest_Maintenance_Job_Amount__c = 100000,
            RecordTypeId = propertyRecordType.Id,
            Retention_Watchlist_Join_Date__c = Date.today(),
            OwnerId = manager1.Id, // Owner is the manager (User)
            Branch__c = branch.Id  // Reference the Branch__c ID
        );
        insert acc1;
        // Repeat the same for another account
        Account acc2 = new Account(
            Name = 'Test Account 2',
            Latest_Maintenance_Job_Amount__c = 600000,
            Retention_Watchlist_Join_Date__c = Date.today(),
            RecordTypeId = propertyRecordType.Id,
            OwnerId = manager1.Id, // Same manager as Owner
            Branch__c = branch.Id  // Reference the Branch__c ID
        );
        insert acc2;
    }

    @isTest
    static void test_V1() {
        // Query some records to ensure batch has data to process
        List<Account> accounts = [SELECT Id,Latest_Maintenance_Job_Amount__c,Retention_Watchlist_Join_Date__c, RecordType.DeveloperName, Owner.email FROM Account LIMIT 2];
		system.debug('Test accounts: '+accounts);
        //List<User> users=[SELECT Id,name, email FROM user where id in:manager1.Id];
        //system.debug('Test users: '+users);
        Test.startTest();
        // Instantiate the batch
        RetentionWatchlistBatch_V4 batch = new RetentionWatchlistBatch_V4();
        // Execute the batch
        Database.executeBatch(batch);
        Test.stopTest();
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
    
}