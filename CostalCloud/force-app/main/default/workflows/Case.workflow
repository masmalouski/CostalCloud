<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_Status_to_Closed_for_VOC_over_4_5</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Case: Status to Closed for VOC over 4.5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Subject_Line_for_VOC</fullName>
        <field>Subject</field>
        <formula>&quot;VOC Score&quot;  &amp; &quot; &quot;  &amp;  TEXT(iVOC_Installer_VOC__c)  &amp; &quot; &quot;  &amp; &quot;for&quot;  &amp; &quot; &quot;  &amp;  Class_Name__c</formula>
        <name>Case: Subject Line for VOC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_VOC_origin_set_to_HD_Survey</fullName>
        <field>Origin</field>
        <literalValue>HD Survey</literalValue>
        <name>Case: VOC origin set to HD Survey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Case%3A Status to Closed for VOC over 4%2E5</fullName>
        <actions>
            <name>Case_Status_to_Closed_for_VOC_over_4_5</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>VOC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.iVOC_Installer_VOC__c</field>
            <operation>greaterThan</operation>
            <value>4.5</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Subject Line %26 Origin for VOC</fullName>
        <actions>
            <name>Case_Subject_Line_for_VOC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_VOC_origin_set_to_HD_Survey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>VOC</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
