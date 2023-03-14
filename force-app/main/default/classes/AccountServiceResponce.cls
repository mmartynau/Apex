public class AccountServiceResponce {
    public List<Id> contIds = new List<Id>();
    public Id accId;
    public AccountServiceResponce(Account acc, List<Contact> contList) {
        this.accId = acc.Id;
        for(Contact c : contList){
            this.contIds.add(c.Id);
        }
    }
}