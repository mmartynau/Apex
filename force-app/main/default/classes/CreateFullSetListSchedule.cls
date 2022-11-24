public class CreateFullSetListSchedule implements Schedulable{
    private List<Opportunity> oppList;

    public CreateFullSetListSchedule(List<Opportunity> oppList) {
        this.oppList = oppList;
    }
    public void execute(SchedulableContext ctx) {
        CreateFullSetList crfl = new CreateFullSetList(oppList);
        ID jobID = System.enqueueJob(crfl);
    }
}
