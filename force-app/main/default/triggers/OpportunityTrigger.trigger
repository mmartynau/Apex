trigger OpportunityTrigger on Opportunity (before insert, before update, after insert) {
    if (Trigger.IsBefore) {
        if (Trigger.isInsert){
        	OpportunityTriggerHandler.moreThanXOppError(Trigger.New);
        }
        if (Trigger.isUpdate){
            OpportunityTriggerHandler.moreThanXOppError(Trigger.New);
 			OpportunityTriggerHandler.updateAccountName(Trigger.New, Trigger.OldMap);
        }
    }
    if (Trigger.isAfter){
        OpportunityTriggerHandler.scheduleCreateFullSetList(Trigger.New);
    }
}