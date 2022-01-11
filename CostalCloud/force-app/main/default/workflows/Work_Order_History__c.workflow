<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Work_Order_Auto_Generated_Note</fullName>
        <field>PO_Note_Auto_Generated__c</field>
        <literalValue>1</literalValue>
        <name>Work Order: Auto Generated Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Work_Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Auto_Push</fullName>
        <field>Auto_Push_Note_AutoCreate__c</field>
        <literalValue>0</literalValue>
        <name>Work Order: Auto Push</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Work_Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Note_Follow_Up</fullName>
        <field>PO_Note_AutoCreated__c</field>
        <formula>&quot;Needing Customer Contact Follow Up&quot;</formula>
        <name>Work Order: Note Follow Up</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Work_Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_PO_Note_Follow_Up</fullName>
        <field>PO_Note_AutoCreated__c</field>
        <formula>&quot;Needing Customer Contact Follow Up&quot;</formula>
        <name>Work Order PO Note (Follow Up)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Work_Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Private_Note</fullName>
        <field>Private_Note_AutoCreate__c</field>
        <literalValue>1</literalValue>
        <name>Work Order: Private Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Work_Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Working_Order_Pending_Customer_Contact</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Pending Customer Contact</literalValue>
        <name>Working Order: Pending Customer Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Work_Order__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Work Order Status Tracking%3A Customer Not Ready</fullName>
        <active>true</active>
        <formula>AND (

 ISBLANK( Next_History_Change__c ),

  Sub_Status_Changed_To__c = &quot;Customer Not Ready&quot;

)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Work_Order_Auto_Generated_Note</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_Auto_Push</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_Note_Follow_Up</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_Private_Note</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Working_Order_Pending_Customer_Contact</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Work_Order_History__c.Date_Time_of_Change__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Work Order Status Tracking%3A Pending Customer Response</fullName>
        <active>true</active>
        <formula>AND (

 ISBLANK( Next_History_Change__c ),

  Sub_Status_Changed_To__c = &quot;Pending Customer Response&quot;

)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Work_Order_Auto_Generated_Note</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_Auto_Push</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_PO_Note_Follow_Up</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_Private_Note</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Working_Order_Pending_Customer_Contact</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Work_Order_History__c.Date_Time_of_Change__c</offsetFromField>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
