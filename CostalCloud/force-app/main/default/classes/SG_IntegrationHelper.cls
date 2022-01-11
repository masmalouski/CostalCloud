/**********************************************************************
* Name:   	SG_IntegrationHelper
* Author: 	Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date: 	29-Oct-2019
* ======================================================
* ======================================================
* Purpose: The purpose of this class is to match Owners of Records to Users given a specific External Id
*
* ======================================================
* ======================================================
* History:
* VERSION	DATE            INITIALS	DESCRIPTION/FEATURES ADDED
* 1.0     	29-Oct-2019     CS			Initial Development
*
***********************************************************************/


public without sharing class SG_IntegrationHelper
{
    /*
      Usage is simple: ONLY USE IN A BEFORE TRIGGER, it can be BEFORE INSERT or BEFORE UPDATE or both
      The code does NOT detect if there is a change in the owner, it will run for every record
      SG_IntegrationHelper.assignOwnerId((List<SObject>)Trigger.new);
     */
    public static void assignOwnerId(List<SObject> sObjects)
    {
        System.debug('BEING assignOwnerId');
        try
        {
            Integration_Settings__c	settings = Integration_Settings__c.getInstance();

            String externalIdFieldName = 'Integration_Key_User__c';
            if(settings != null && settings.API_Field_Name_To_Match__c != null)
            {
                externalIdFieldName = settings.API_Field_Name_To_Match__c;
            }

            System.debug('SG_IntegrationHelper: assignOwnerId: externalIdFieldName = ' + externalIdFieldName);

            assignOwnerId_private(sObjects, externalIdFieldName, externalIdFieldName);
        }
        catch(Exception exp)
        {
            //Do not allow ANY errors, because we do not want to break integration EVER
            System.debug('SG_IntegrationHelper: assignOwnerId: EXCEPTION caught : ' + exp);
        }
        System.debug('END assignOwnerId');
    }

    // create a private method so we can wrap it in a try/catch
    @TestVisible private static void assignOwnerId_private(List<SObject> sObjects, String userExternalIdFieldName, String objectExternalIdFieldName)
    {
        System.debug('BEING assignOwnerId_private');
        if(sObjects == null || sObjects.size() == 0)
        {
            System.debug('SG_IntegrationHelper: assignOwnerId: ABORT: sObjects list was NULL or EMPTY');
            return;
        }

        if(userExternalIdFieldName != null && objectExternalIdFieldName != null)
        {
            //Test that the field exists
            SObject obj = sObjects[0];
            Schema.DescribeSObjectResult describeSObjectResult = obj.getSobjectType().getDescribe();
            String objectName = describeSObjectResult.getName();
            String objectLabel = describeSObjectResult.getLabel();
            Map<String, Schema.SObjectField> objectFieldMap = describeSObjectResult.fields.getMap();

            if( objectFieldMap.containsKey(objectExternalIdFieldName) == false )
            {
                System.debug('SG_IntegrationHelper: assignOwnerId: ABORT: object ' + objectLabel + ' (' + objectName + ') has no field named: ' + objectExternalIdFieldName);
                return;
            }

            Map<String, Schema.SObjectField> userFieldMap = Schema.sObjectType.User.fields.getMap();

            if( userFieldMap.containsKey(userExternalIdFieldName) == false )
            {
                System.debug('SG_IntegrationHelper: assignOwnerId: ABORT: User has no field named: ' + userExternalIdFieldName);
                return;
            }

            //Now the User has the magic field, the object has the magic field, now let's query for users using the value in the magic field
            Set<String> externalIdKeyValues = new Set<String>();

            for(SObject sObj : sObjects)
            {
                String objectFieldValue = (String)sObj.get(objectExternalIdFieldName);
                if(objectFieldValue != null)
                {
                    externalIdKeyValues.add(objectFieldValue);
                }
            }

            System.debug('SG_IntegrationHelper: assignOwnerId_private: externalIdKeyValues = ' + externalIdKeyValues);

            Map<String,Id> userIdsByExternalId = new Map<String,Id>();
            String userQuery = 'SELECT Id,' + userExternalIdFieldName + ' FROM User WHERE ' + userExternalIdFieldName + ' IN :externalIdKeyValues';

            System.debug('SG_IntegrationHelper: assignOwnerId_private: userQuery = ' + userQuery);

            //Test if the user has Audit Field permissions
            if(Schema.sObjectType.Account.fields.CreatedDate.isCreateable() == false)
            {
                //If the create date is NOT editable, then user does not have Audit Field permissions and so the Owner must be an ACTIVE user
                userQuery += ' AND IsActive = TRUE';
            }

            System.debug('SG_IntegrationHelper: assignOwnerId_private: userQuery = ' + userQuery);

            List<User> allUsers = Database.query(userQuery);

            System.debug('SG_IntegrationHelper: assignOwnerId_private: allUsers.size() = ' + allUsers.size());

            for (User u : allUsers)
            {
                SObject userSObject = (SObject) u;
                userIdsByExternalId.put((String) userSObject.get(userExternalIdFieldName), u.Id);
            }

            for(SObject sObj : sObjects)
            {
                String objectFieldValue = (String)sObj.get(objectExternalIdFieldName);
                if(objectFieldValue != null)
                {
                    if(userIdsByExternalId.containsKey(objectFieldValue) == true)
                    {
                        //Set the Owner Id to the User Id matched by the external Id
                        sObj.put('OwnerId',userIdsByExternalId.get(objectFieldValue));
                    }
                    else
                    {
                        System.debug('SG_IntegrationHelper: assignOwnerId: No matching user found for external id value: ' + objectFieldValue + ' on field ' + objectExternalIdFieldName);
                    }
                }
            }
        }
        System.debug('END assignOwnerId_private');
    }

}