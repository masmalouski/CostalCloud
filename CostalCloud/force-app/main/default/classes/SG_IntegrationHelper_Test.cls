/**********************************************************************
* Name:   	SG_IntegrationHelper_Test
* Author: 	Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date: 	30-Oct-2019
* ======================================================
* ======================================================
* Purpose: The purpose of this class is to                                                            
* 
* ======================================================
* ======================================================
* History:                                                            
* VERSION	DATE            INITIALS	DESCRIPTION/FEATURES ADDED
* 1.0     	30-Oct-2019     CS			Initial Development           
*   
***********************************************************************/


@IsTest
private class SG_IntegrationHelper_Test
{
    @IsTest
    static void testBehavior()
    {
        Profile p = [SELECT Id, Name FROM profile WHERE name = 'Standard User' LIMIT 1];

        String orgId = (String)Userinfo.getOrganizationId();
        String uniqueEmail = 'test@' + orgId + '.net.test';

        User u = new User(alias = 'standt',
                email=uniqueEmail,
                emailencodingkey='UTF-8',
                lastname='Testing',
                languagelocalekey='en_US',
                localesidkey='en_US',
                profileid = p.Id,
                timezonesidkey='America/Los_Angeles',
                username=uniqueEmail,
                EmployeeNumber=orgId);
        insert u;

        // Create common test accounts
        List<Account> accounts = new List<Account>();
        Account acctMatch = new Account();
        acctMatch.Name = 'Test';
        acctMatch.AccountNumber = orgId;
        accounts.add(acctMatch);

        Account acctNoMatch = new Account();
        acctNoMatch.Name = 'Test';
        acctNoMatch.AccountNumber = 'NonMatching';
        accounts.add(acctNoMatch);

        Account acctNullMatch = new Account();
        acctNullMatch.Name = 'Test';
        acctNullMatch.AccountNumber = null;
        accounts.add(acctNullMatch);

        Test.startTest();
            SG_IntegrationHelper.assignOwnerId_private((List<SObject>)accounts,'EmployeeNumber','AccountNumber');
        Test.stopTest();

        System.assert(acctMatch.OwnerId == u.Id, 'account[0] owner Id did not match');
        System.assert(acctNoMatch.OwnerId != u.Id, 'account[1] owner Id did match');
        System.assert(acctNullMatch.OwnerId != u.Id, 'account[2] owner Id did match');
    }

    @IsTest
    static void testBehavior_NULL()
    {
        Test.startTest();
        SG_IntegrationHelper.assignOwnerId(null);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior_NoFields()
    {
        Profile p = [SELECT Id, Name FROM profile WHERE name = 'Standard User' LIMIT 1];

        String orgId = (String)Userinfo.getOrganizationId();
        String uniqueEmail = 'test@' + orgId + '.net.test';

        User u = new User(alias = 'standt',
                email=uniqueEmail,
                emailencodingkey='UTF-8',
                lastname='Testing',
                languagelocalekey='en_US',
                localesidkey='en_US',
                profileid = p.Id,
                timezonesidkey='America/Los_Angeles',
                username=uniqueEmail,
                EmployeeNumber=orgId);
        insert u;

        // Create common test accounts
        List<Account> accounts = new List<Account>();
        Account acctMatch = new Account();
        acctMatch.Name = 'Test';
        acctMatch.AccountNumber = orgId;
        accounts.add(acctMatch);

        Account acctNoMatch = new Account();
        acctNoMatch.Name = 'Test';
        acctNoMatch.AccountNumber = 'NonMatching';
        accounts.add(acctNoMatch);

        Account acctNullMatch = new Account();
        acctNullMatch.Name = 'Test';
        acctNullMatch.AccountNumber = null;
        accounts.add(acctNullMatch);

        Test.startTest();
            SG_IntegrationHelper.assignOwnerId_private((List<SObject>)accounts, 'EmployeeNumber','EmployeeNumber');
            SG_IntegrationHelper.assignOwnerId_private((List<SObject>)accounts, 'AccountNumber','AccountNumber');
        Test.stopTest();

        System.assert(acctMatch.OwnerId != u.Id, 'account[0] owner Id did match');
        System.assert(acctNoMatch.OwnerId != u.Id, 'account[1] owner Id did match');
        System.assert(acctNullMatch.OwnerId != u.Id, 'account[2] owner Id did match');
    }

}