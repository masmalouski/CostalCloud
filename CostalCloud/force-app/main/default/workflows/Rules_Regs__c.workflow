<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Rules_Regs_Unique_ID</fullName>
        <field>Unique_ID__c</field>
        <formula>Store_Client__r.Store__c  &amp; &quot;-&quot;  &amp; TEXT(Client_Type__c )  &amp; &quot;-&quot;  &amp;  TEXT(Program__c ) &amp; &quot;-&quot;  &amp; TEXT ( Category__c )  &amp; &quot;-&quot;  &amp;  svcCodeType__c  &amp; &quot;-&quot;  &amp;  TEXT( Installation_State__c )</formula>
        <name>Rules/Regs: Unique ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Rules%2FRegs%3A Unique ID</fullName>
        <actions>
            <name>Rules_Regs_Unique_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Rules_Regs__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
