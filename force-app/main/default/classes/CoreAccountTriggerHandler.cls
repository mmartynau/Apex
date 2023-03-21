public with sharing class CoreAccountTriggerHandler {
    public static final String LEAD_STATUS = 'Disqualified';
    public static void createLeads(List<Core_Account__c> coreAccList) {
        Map<Core_Account__c,Lead> leadMap = new Map<Core_Account__c,Lead>();
        List<Lead> convertedLeadList = new List<Lead>();
        for (Core_Account__c coreAcc : coreAccList){
            if (isAllFieldsIsNotNull(coreAcc)){
                    Lead l = New Lead(
                        Company = coreAcc.Sign_up_Company_Name__c,
                        FirstName = coreAcc.Sign_up_First_Name__c,
                        LastName = coreAcc.Sign_up_Last_Name__c,
                        Website = coreAcc.Sign_up_Company_Website__c,
                        Email = coreAcc.Sign_Up_Personal_Email__c
                    );
                    leadMap.put(coreAcc, l);
                    convertedLeadList.add(l);
            } else if (!String.isBlank(coreAcc.Sign_up_Last_Name__c)) {
                    leadMap.put(coreAcc, New Lead(
                        Company = coreAcc.Sign_up_Company_Name__c,
                        FirstName = coreAcc.Sign_up_First_Name__c,
                        LastName = coreAcc.Sign_up_Last_Name__c,
                        Website = coreAcc.Sign_up_Company_Website__c,
                        Email = coreAcc.Sign_Up_Personal_Email__c,
                        Status = LEAD_STATUS
                ));
            }
        }
        if (!leadMap.isEmpty()) {
            insert leadMap.values();
            //fill core_acc lead Id
            for (Core_Account__c coreAcc : leadMap.keySet()){
                coreAcc.Lead__c = leadMap.get(coreAcc).Id;
            }
        }
        //map for adding accountId in coreAcc
        Map<Id,Core_Account__c> idCoreAccMap = new Map<Id,Core_Account__c>();
        for(Core_Account__c coreAcc : leadMap.keySet()){
            idCoreAccMap.put(coreAcc.Lead__c,coreAcc);
        }
        if(!convertedLeadList.isEmpty()) {
            List<Database.LeadConvert> massLeadConvert = new List<Database.LeadConvert>();
            for (Lead l : convertedLeadList){
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(l.id);
                lc.setDoNotCreateOpportunity(true);
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                massLeadConvert.add(lc);
            }
            List<Database.LeadConvertResult> lcr = Database.convertLead(massLeadConvert);
            //put AccountId in CoreAccount
            for(Database.LeadConvertResult lr : lcr){
                idCoreAccMap.get(lr.getLeadId()).Account__c = lr.getAccountId();
            }
        }
    }
    private static Boolean isAllFieldsIsNotNull(Core_Account__c coreAcc){
        return (!String.isBlank(coreAcc.Sign_up_Company_Name__c) && 
        !String.isBlank(coreAcc.Sign_up_First_Name__c) && 
        !String.isBlank(coreAcc.Sign_up_Last_Name__c) && 
        coreAcc.Sign_up_Company_Website__c != null && 
        coreAcc.Sign_Up_Personal_Email__c != null);
    }
}