public with sharing class CountOpportunityBatchSchedule implements Schedulable{
    public void execute(SchedulableContext ctx){
        CountOpportunityBatch countOpp = new CountOpportunityBatch();
        Id batchId = Database.executeBatch(countOpp);
    }
}
