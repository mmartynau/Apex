@isTest
public with sharing class CountOpportunityBatchTest {
    @TestSetup
    static void makeData(){
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            accList.add(new Account(Name = 'acc Name ' + (i + 1)));
        }
        insert accList;
        for(Account acc : accList){
            oppList.add(new Opportunity(Name = 'Opp ' + acc.Name, CloseDate = Date.today(), StageName = 'Qualification', AccountId = acc.Id));
        }
        insert oppList;
    }
    @isTest static void checkCountingWithoutSchedule(){
        List<Account> accList = [SELECT NumOfOpps__c, (SELECT Id FROM Opportunities) FROM Account];
        Test.startTest();
        CountOpportunityBatch countOpp = new CountOpportunityBatch();
        Id batchId = DataBase.executeBatch(countOpp);
        Test.stopTest();
        System.assert([SELECT NumOfOpps__c FROM Account LIMIT 1].NumOfOpps__c == 1, 'Should be 1');
    }
    @isTest static void checkCountingWithSchedule(){
        List<Account> accsList = [SELECT NumOfOpps__c,(SELECT Id FROM Opportunities) FROM Account];
        Id accId = accsList[0].Id;
        insert new Opportunity(Name = 'NewOpp', CloseDate = Date.today(), StageName = 'Qualification', AccountId = accId);
        Test.startTest();
        CountOpportunityBatchSchedule countSch = new CountOpportunityBatchSchedule();
        String sch = '0 0 0 26 11 ? 2022';
        String jobID = System.schedule('Counting Number of opps Test', sch, countSch);
        System.assertEquals(null, [SELECT NumOfOpps__c FROM Account WHERE Id = :accId].NumOfOpps__c, 'should be null');
        Test.stopTest();
        System.assertEquals(2, [SELECT NumOfOpps__c FROM Account WHERE Id = :accId].NumOfOpps__c, 'Opportunity did not be counted');
    }
}
