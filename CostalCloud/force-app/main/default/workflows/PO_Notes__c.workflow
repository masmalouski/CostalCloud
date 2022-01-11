<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PO_Notes_Send_to_Mobile</fullName>
        <field>Copy_to_Mobile_App__c</field>
        <literalValue>1</literalValue>
        <name>PO Notes: Send to Mobile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PO Notes%3A Send to Mobile</fullName>
        <actions>
            <name>PO_Notes_Send_to_Mobile</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PO_Notes__c.Copy_to_Mobile_App__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Special_Instructions_Text__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
