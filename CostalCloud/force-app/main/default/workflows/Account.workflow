<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Account_Set_IntegrationKey</fullName>
        <field>Integration_Key_Account__c</field>
        <formula>&quot;S&quot; &amp; CASESAFEID(Id)</formula>
        <name>Account Set IntegrationKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Set_Onboarding_Date</fullName>
        <field>Onboarding_Date__c</field>
        <formula>TODAY()</formula>
        <name>Account: Set Onboarding Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Acct_Account_Number_to_Integration_Key</fullName>
        <field>Integration_Key_Account__c</field>
        <formula>AccountNumber</formula>
        <name>Acct: Account Number to Integration Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ia_crm__Set_Reseller_Type</fullName>
        <field>ia_crm__Reseller_Type__c</field>
        <formula>$Setup.ia_crm__Reseller_Types__c.ia_crm__Types__c</formula>
        <name>Set Reseller Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Account Set IntegrationKey</fullName>
        <actions>
            <name>Account_Set_IntegrationKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Account%3A Set Onboarding Date</fullName>
        <actions>
            <name>Account_Set_Onboarding_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Onboarding_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Installer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ia_crm__Set Reseller Type</fullName>
        <actions>
            <name>ia_crm__Set_Reseller_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(And(ia_crm__Reseller_Type__c &lt;&gt; $Setup.ia_crm__Reseller_Types__c.ia_crm__Types__c),true,false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
