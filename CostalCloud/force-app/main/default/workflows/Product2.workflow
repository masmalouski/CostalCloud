<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Product_Product_Code_to_Integration_Key</fullName>
        <field>Integration_Key_Product__c</field>
        <formula>ProductCode</formula>
        <name>Product: Product Code to Integration Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Product_SKU_to_populate_Product_Code</fullName>
        <field>ProductCode</field>
        <formula>SKU_Number__c</formula>
        <name>Product SKU to populate Product Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Product%3A Any Update</fullName>
        <actions>
            <name>Product_Product_Code_to_Integration_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Product_SKU_to_populate_Product_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
