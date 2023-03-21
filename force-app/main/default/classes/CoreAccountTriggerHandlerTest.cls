@isTest
public with sharing class CoreAccountTriggerHandlerTest {
    @isTest static void createCoreAccountWithAllFields(){
        List<Core_Account__c> coreAccList = new List<Core_Account__c>();
        for (Integer i = 0; i < 5; i++) {
            coreAccList.add(new Core_Account__c(Sign_Up_Company_Name__c = 'testName ' + i,
            Sign_Up_Company_Website__c = 'test' + i + '.com',
            Sign_Up_First_Name__c = 'first Name ' + i,
            Sign_Up_Last_Name__c = 'last Name ' + i,
            Sign_Up_Personal_Email__c = 'email' + i + '@mail.com'));
        }
        Test.startTest();
        insert coreAccList;
        Test.stopTest();
        System.assertEquals(5, [SELECT Id FROM Account].size(), 'should be 5');
        System.assertEquals(5, [SELECT Id FROM Contact].size(), 'should be 5');
    }
    @isTest static void createCoreAccountWithLastNameOnly(){
        List<Core_Account__c> coreAccList = new List<Core_Account__c>();
        for (Integer i = 1; i < 5; i++) {
            coreAccList.add(new Core_Account__c(Sign_Up_Company_Name__c = 'testName ' + i,
                                                Sign_Up_Last_Name__c = 'last Name ' + i)
            );
        }
        Test.startTest();
        insert coreAccList;
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Account].size(), 'should be 0');
        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'should be 0');
        System.assertEquals(CoreAccountTriggerHandler.LEAD_STATUS, [SELECT Status FROM Lead LIMIT 1].Status, 'should be ' + CoreAccountTriggerHandler.LEAD_STATUS);
    }
}