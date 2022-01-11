/***************************************************
* Name:         SG_PONotesHelper_Test
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         Nov 2021
* ==================================================
* ==================================================
* Purpose:      Test methods for SG_PHNOtesHelper
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       Nov 2021        GO          Initial Development
*
****************************************************/
@IsTest
private class SG_PONotesHelper_Test
{

    static testMethod void testBehavior()
    {
        SG_TestDataGenerator td = new SG_TestDataGenerator();
        Account a = td.getAccounts(false)[0];
        insert a;

        // create workorder
        WorkOrder wo = new WorkOrder();
        wo.AccountId = a.Id;
        wo.Status = 'Open';
        insert wo;

        SG_PONotesHelper.processPONOtes_Ran = false;
        // update work order Installer Action
        wo.Installer_Action__c = 'Left Message';
        wo.PO_Note_Autocreated__c = 'Test Message12345678900000000000000000000000000000000000000000000000000000000000555';

        Test.startTest();
        update wo;
        Test.stopTest();

        // confirm PO Note created
        List<PO_Notes__c> notes = [SELECT Id, Name, Work_Order__c FROM PO_Notes__c WHERE Name LIKE 'Test Message%'];
        System.assert(notes.size() == 1);
        System.assertEquals(wo.Id, notes[0].Work_Order__c);
    }
}