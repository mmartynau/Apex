@RestResource(urlMapping = '/AccountService/*')
global with sharing class AccountService {
    @HttpGet
    global static Account getAccountMethod() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Account accResult;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        String queryString = 'SELECT Id';

        for (Schema.FieldSetMember fld : SObjectType.Account.FieldSets.PastService.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }
        queryString += ' FROM Account WHERE ID = :accountId';
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, Database.query(queryString));
        try{
            accResult = (Account) securityDecision.getRecords()[0];
        } catch (ListException e){
            throw new AccountServiceException(Label.Incorrect_Account_ID);
        }
    return accResult;
    }
    @HttpPost
    global static void postMethod(){
        Savepoint sp = Database.setSavepoint();
        AccountServiceJSONParser result;
        List<Contact> contList = new List<Contact>();
        if (!FeatureManagement.checkPermission('allowCreateAccountsViaRest')){
            throw new AccountServiceException(Label.Account_Service_Exception_Without_Permission);
        }
        String req = RestContext.Request.requestBody.toString();
        try {
            result = AccountServiceJSONParser.parseJson(req);
        } catch (JSONException e){
            throw new AccountServiceException(Label.Account_Service_Incorrect_JSON);
        }
        Account acc = new Account (Name = result.accName);
        if (!Schema.sObjectType.Account.isCreateable() || !Schema.sObjectType.Contact.isCreateable()) {
            throw new AccountServiceException(Label.Account_Service_Exception_Not_Allowed_to_Create);
        }
        try {
            insert acc;
            for(AccountServiceJSONParser.Contacts c : result.contacts) {
                contList.add(new Contact (FirstName = c.firstName, LastName = c.lastName, AccountId = acc.Id));
            }
            insert contList;
        } catch (DMLException e){
            Database.rollback(sp);
            throw new AccountServiceException(String.format(System.Label.Account_Service_Exception_Could_Not_Insert,
            new List<Object>{e.getMessage()}));
        }
        AccountServiceResponce response = new AccountServiceResponce(acc, contList);
        RestResponse res = RestContext.response;
        res = new RestResponse();
        RestContext.response = res;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 200;
    }
    global class AccountServiceException extends Exception{}
}