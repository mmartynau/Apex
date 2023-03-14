@isTest
private class AccountServiceTest {
    @isTest static void testGetAccountById() {
        Id recordId = createTestAccount();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri = 'https://orgfortasks-dev-ed.develop.my.salesforce.com/services/apexrest/AccountService/' + recordId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account thisAccount = AccountService.getAccountMethod();
        // Verify results
        System.assert(thisAccount != null);
        System.assertEquals('Test record', thisAccount.Name);
    }
    @isTest static void testGetWrongId() {
        RestRequest request = new RestRequest();
        request.requestUri = 'https://orgfortasks-dev-ed.develop.my.salesforce.com/services/apexrest/AccountService/' + '123';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        try{
            Account thisAccount = AccountService.getAccountMethod();
        } catch (AccountService.AccountServiceException e){
            System.assertEquals(Label.Incorrect_Account_ID, e.getMessage());
        }
    }
    @isTest static void testPostAccount() {
        // Set up a test request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String json = '{"accName" : "Name Acc","Contacts" : [{"FirstName" : "name 1","LastName" : "lName 1"},{"FirstName" : "name 2","LastName" : "lName 2"}]}';
        req.requestUri = 'https://orgfortasks-dev-ed.develop.my.salesforce.com/services/apexrest/AccountService/';
        req.requestBody = Blob.valueof(json);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        User u = createTestUserWithPermission();
        System.runAs(u) {
            // The following code runs as user 'u'
            // Call the method to test
            AccountService.postMethod();
            // Verify results
            System.assertEquals([SELECT Name FROM Account].Name, 'Name Acc');
          }
    }
    @isTest static void testWrongJson() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String json = '{"accName"}';
        req.requestUri = 'https://orgfortasks-dev-ed.develop.my.salesforce.com/services/apexrest/AccountService/';
        req.requestBody = Blob.valueof(json);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        User u = createTestUserWithPermission();
        System.runAs(u) {
            // The following code runs as user 'u'
            // Call the method to test
            try{
                AccountService.postMethod();
            } catch (AccountService.AccountServiceException e){
                // Verify results
                System.assertEquals(Label.Account_Service_Incorrect_JSON, e.getMessage());
            }
        }
    }
    @isTest static void testWithoutPermissions() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String json = '{"accName" : "Name Acc","Contacts" : [{"FirstName" : "name 1","LastName" : "lName 1"},{"FirstName" : "name 2","LastName" : "lName 2"}]}';
        req.requestUri = 'https://orgfortasks-dev-ed.develop.my.salesforce.com/services/apexrest/AccountService/';
        req.requestBody = Blob.valueof(json);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        try{
            AccountService.postMethod();
        } catch (AccountService.AccountServiceException e){
            // Verify results
            System.assertEquals(Label.Account_Service_Exception_Not_Allowed_to_Create, e.getMessage());
        }
    }
    // Helper method
    static Id createTestAccount() {
        // Create test record
        Account accTest = new Account(Name ='Test record');
        insert accTest;
        return accTest.Id;
    }
    static User createTestUserWithPermission(){
        String uniqueUserName = 'SystemAdministrator' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'admin', Email='SystemAdministrator@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = uniqueUserName);
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CustomPermissionForCreatingAccounts'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
    return u;
    }
}