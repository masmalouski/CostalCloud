<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>RFI_Reporting_Market_Set_Unique_Name_ID</fullName>
        <field>Market_Name_Unique_ID__c</field>
        <formula>Name &amp;&quot;-&quot;&amp; TEXT(Region__c) &amp;&quot;-&quot;&amp; TEXT( Division__c )</formula>
        <name>RFI Reporting Market Set Unique Name ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>RFI Reporting Market Set Unique Name ID</fullName>
        <actions>
            <name>RFI_Reporting_Market_Set_Unique_Name_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW()  || 
 ISCHANGED( Name  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
