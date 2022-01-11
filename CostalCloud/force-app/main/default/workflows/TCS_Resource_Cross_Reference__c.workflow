<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TCS_Cross_Reference_Unique_ID</fullName>
        <field>Unique_Name__c</field>
        <formula>Name</formula>
        <name>TCS Cross Reference Unique ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>TCS Cross Reference Unique ID</fullName>
        <actions>
            <name>TCS_Cross_Reference_Unique_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW()  ||  ISCHANGED( Name )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
