trigger CoreAccountTrigger on Core_Account__c (before insert) {
    CoreAccountTriggerHandler.createLeads(Trigger.New);
}