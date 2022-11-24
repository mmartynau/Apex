public with sharing class CreateFullSetList implements Queueable{
    private List<Opportunity> oppList;
    public CreateFullSetList(List<Opportunity> oppList){
        this.oppList = oppList;
    }
    public void execute(QueueableContext context){
        List<FullSetList__c> fsList = new List<FullSetList__c>();
        List<FullSetListTemplate__c> flList = [SELECT Description__c, DueDate__c, Order__c FROM FullSetListTemplate__c];
        for(Opportunity opp : oppList){
            for(FullSetListTemplate__c fslt : flList){
                fsList.add(new FullSetList__c(
                    Description__c = fslt.Description__c,
                    DueDate__c = Date.today(),
                    Order__c = fslt.Order__c,
                    Opportunity__c = opp.Id)
                );
            }
        }
        insert fsList;
    }
}
