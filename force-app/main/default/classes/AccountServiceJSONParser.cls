public class AccountServiceJSONParser {
    public String accName;
    public List<Contacts> contacts;

    public class Contacts {
        public String firstName;
        public String lastName;
    }
    public static AccountServiceJSONParser parseJson(String json) {
        return (AccountServiceJSONParser) System.JSON.deserialize(json, AccountServiceJSONParser.class);
    }
}