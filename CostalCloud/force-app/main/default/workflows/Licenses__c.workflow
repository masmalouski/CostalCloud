<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>License_Due_to_Expire_Document_Email_Notification</fullName>
        <description>License Due to Expire Document Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>marnett@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/License_Pre_Expiration_Notification</template>
    </alerts>
    <alerts>
        <fullName>License_Expired_Document_Email_Notification</fullName>
        <description>License Expired Document Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>marnett@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/License_Expiration_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>License_set_to_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>License set to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>License_set_to_Expired</fullName>
        <field>Status__c</field>
        <literalValue>Expired</literalValue>
        <name>License set to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>License Expired</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Licenses__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Expired</value>
        </criteriaItems>
        <criteriaItems>
            <field>Licenses__c.Expiration_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>License_set_to_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Licenses__c.Expiration_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>License%3A Active</fullName>
        <actions>
            <name>License_set_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Licenses__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Licenses__c.Expiration_Date__c</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>License%3A Expired</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Licenses__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Expired</value>
        </criteriaItems>
        <criteriaItems>
            <field>Licenses__c.Expiration_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>License_set_to_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Licenses__c.Expiration_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>License%3A Expired Notification</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Licenses__c.Status__c</field>
            <operation>equals</operation>
            <value>Expired,Expired Revoke Access</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>License_Expired_Document_Email_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Licenses__c.Expiration_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>License%3A Expired Notification Email</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Licenses__c.Status__c</field>
            <operation>equals</operation>
            <value>Expired</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>License_Due_to_Expire_Document_Email_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Licenses__c.Expiration_Date__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>License_Expired_Document_Email_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Licenses__c.Expiration_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>License_Expired_Document_Email_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Licenses__c.Expiration_Date__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
