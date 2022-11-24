public class OpportunityTriggerHandler {
    public static void moreThanXOppError(List<Opportunity> oppList){
    	Map<Id,Opportunity> accIdsMap = new Map<Id,Opportunity>();
        for (Opportunity opp : oppList){
            accIdsMap.put(opp.AccountId,opp);
        }
        List<Account> accList = [SELECT Id,(SELECT Id FROM Opportunities WHERE Id NOT IN :oppList) FROM Account WHERE Id IN :accIdsMap.keySet()];
        for (Account acc : accList){
            if (acc.Opportunities.size() > 0){
               accIdsMap.get(acc.Id).addError(System.Label.Nice_Error);
            }
        }
    }
    public static void updateAccountName(List<Opportunity> listOpp, Map<Id,Opportunity> mapOppOld){
        List<Account> accForUpdate = new List<Account>();
        Set<Id> accIds = new Set<Id>();
        for (Opportunity opp : listOpp){
            accIds.add(opp.AccountId);
        }
        Map<Id,Account> accMap =  new Map<Id,Account>([SELECT Id,RecordType.Name,(SELECT Id FROM Opportunities) FROM Account WHERE Id IN :accIds]);

        for(Opportunity opp : listOpp){
            if (mapOppOld.get(opp.Id).Name != opp.Name){
                Account accItem = accMap.get(opp.AccountId);
                accItem.Name = accItem.RecordType.Name + ' | ' + opp.Name;
                accForUpdate.add(accItem);
            }
        }
        if (accForUpdate.size() > 0){
            update accForUpdate;
        }
    }

    public static void scheduleCreateFullSetList(List<Opportunity> listOpp){
        DateTime myDateTime = DateTime.now().addMinutes(2);
        String sDay = String.valueof(myDateTime.day());
        String sHour = String.valueof(myDateTime.hour());
        String sMinute = String.valueof(myDateTime.minute());
        String sSecond = String.valueof(myDateTime.second());
        String sMonth = String.valueof(myDateTime.month());
        String sYear = String.valueof(myDateTime.year());
        String CRON_EXP = sSecond + ' ' + sMinute + ' ' + sHour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        String jobID = System.schedule('Create FullSetList', CRON_EXP, new CreateFullSetListSchedule(listOpp));
    }
}