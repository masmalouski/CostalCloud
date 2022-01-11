<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Installers_Available_Unique_Key</fullName>
        <field>Unique_Key__c</field>
        <formula>Store_Name__c  &amp; &quot;-&quot; &amp;  TEXT(Client__c)  &amp; &quot;-&quot;  &amp;  TEXT(Program__c)  &amp; &quot;-&quot;  &amp; TEXT(Category__c)  &amp; &quot;-&quot;  &amp;   Installer_Account__r.Name   &amp; &quot;-&quot;  &amp;  TEXT(Status__c)  &amp; &quot;-&quot;  &amp;  TEXT(SvcTypeCode__c)</formula>
        <name>Installers Available Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Installers Available Unique Key</fullName>
        <actions>
            <name>Installers_Available_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Installers_Available__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
