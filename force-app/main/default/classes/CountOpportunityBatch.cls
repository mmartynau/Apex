public with sharing class CountOpportunityBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, DataBase.Statefull  {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, (SELECT Id FROM Opportunities) FROM Account');
    }
    public void execute(Database.BatchableContext bc, List<Account> accounts){
        for(Account acc : accounts){
            acc.NumOfOpps__c = acc.Opportunities.size();
            System.debug(acc.Opportunities.size());
        }
        update accounts;
    }
    public void finish(Database.BatchableContext bc){
        System.debug('finish!');
    }
}
