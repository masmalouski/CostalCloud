<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Invoice_Payment_set_intacct_key</fullName>
        <field>IntactIntegrationKey__c</field>
        <formula>&quot;S&quot; &amp;  CASESAFEID(Id)</formula>
        <name>Invoice/Payment set intacct key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Invoice Payment Set IntacctKey</fullName>
        <actions>
            <name>Invoice_Payment_set_intacct_key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoices_Payments__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
