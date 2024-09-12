Public class RetentionWatchlistScheduler implements Schedulable {
    // This method is executed when the scheduled job is triggered
    Public void execute(SchedulableContext sc) {
        // Call the batch class within the scheduled class
        RetentionWatchlistBatch_V4 batchJob = new RetentionWatchlistBatch_V4();
        Database.executeBatch(batchJob);
    }
    
}