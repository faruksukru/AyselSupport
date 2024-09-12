@isTest
public class RetentionWatchlistSchedulerTest {
    
    // Test method to verify the scheduling of the job
    @isTest
    static void testScheduler() {
                
        // Schedule the job by invoking the RetentionWatchlistScheduler class
        RetentionWatchlistScheduler scheduler = new RetentionWatchlistScheduler();
        
        // Create a fake cron expression to schedule the job in 1 minute from now
        String cronExp = '0 0 23 * * ?'; // For the sake of testing, this can be any valid cron
        String jobId = System.schedule('Test Retention Watchlist Job', cronExp, scheduler);
        
        // Query the CronTrigger object to verify the job was scheduled
        CronTrigger ct = [SELECT Id, CronJobDetail.Name, State 
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        
        // Assert that the job was successfully scheduled
        System.assertEquals('Test Retention Watchlist Job', ct.CronJobDetail.Name);
        System.assertEquals('WAITING', ct.State); // WAITING means the job is scheduled but hasn't run yet
        
        // Now simulate the execution of the scheduled job
        Test.startTest();
        
        // Execute the batch job directly using Database.executeBatch() in the test context
        RetentionWatchlistBatch_V4 batchJob = new RetentionWatchlistBatch_V4();
        Database.executeBatch(batchJob);
        
        Test.stopTest();
        
       
    }
}