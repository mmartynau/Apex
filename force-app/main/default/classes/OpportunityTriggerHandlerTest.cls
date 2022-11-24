@isTest
private class OpportunityTriggerHandlerTest {
    @isTest
    private static void checkErrorOnSecondOppInsert() {
        List<Account> listAcc = new List<Account>{
            new Account(Name = 'Account Office'),
            new Account(Name = 'Account Office 2')
        };
        insert listAcc;
        
        List<Opportunity> listOpp = new List<Opportunity>{
            new Opportunity(Name = 'Office', AccountId = listAcc.get(0).Id, StageName = 'Prospecting', CloseDate = Date.Today()),
            new Opportunity(Name = 'Office 2', AccountId = listAcc.get(1).Id, StageName = 'Prospecting', CloseDate = Date.Today())
        };
        insert listOpp;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp3 = new Opportunity(Name = 'Office 3', AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.Today());
        
        Test.startTest();
        Database.SaveResult res = Database.insert(opp3, false);
        Test.stopTest();

        System.assert(!res.isSuccess(), '2nd Opp should throw an error');
        System.assert(res.getErrors().get(0).getMessage().contains(System.Label.Nice_Error));
    }
    @isTest
    private static void checkCorrectAccountName() {
        List<Account> listAcc = new List<Account>{
            new Account(Name = 'Account Office'),
            new Account(Name = 'Account Office 2')
        };
        insert listAcc;
        
        List<Opportunity> listOpp = new List<Opportunity>{
            new Opportunity(Name = 'Office', AccountId = listAcc.get(0).Id, StageName = 'Prospecting', CloseDate = Date.Today()),
            new Opportunity(Name = 'Office 2', AccountId = listAcc.get(1).Id, StageName = 'Prospecting', CloseDate = Date.Today())
        };
        insert listOpp;
        Opportunity opp = [SELECT Name, AccountId FROM Opportunity LIMIT 1];
        opp.Name = 'Office 3';
 
        Test.startTest();
        Database.SaveResult result = Database.update(opp, false);
        Test.stopTest();
        
        System.assert(result.isSuccess());
        Account resAcc = [SELECT Name, RecordType.Name From Account WHERE Id = :opp.AccountId];
        System.assertEquals(resAcc.Name, resAcc.RecordType.Name + ' | ' + opp.Name);
    }
    @isTest
    private static void checkCreatingFullSetList() {
        List<FullSetListTemplate__c> flstListT = new List<FullSetListTemplate__c>();
        for (Integer i = 0; i < 5; i++) {
            flstListT.add(new FullSetListTemplate__c(Name = 'test ' + i, Description__c = 'Descr ' + i, Order__c = i + 1));
        }
        insert flstListT;
        Test.startTest();
        Opportunity opp1 = new Opportunity(Name = 'testOpp', CloseDate = Date.today(), StageName = 'Prospecting');
        insert opp1;
        System.enqueueJob(new CreateFullSetList(new List<Opportunity>{opp1}));
        Test.stopTest();
        System.debug([SELECT Count() FROM FullSetList__c]);
        System.assertEquals(5, [SELECT Count() FROM FullSetList__c], 'Should be 5');
        for(FullSetList__c fls : [SELECT DueDate__c FROM FullSetList__c]){
            System.assert(fls.DueDate__c == Date.today());
        }
    }
}