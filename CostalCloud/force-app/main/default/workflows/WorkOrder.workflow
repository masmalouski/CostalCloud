<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>WO_Accounting_Request_Completed_Email</fullName>
        <description>WO Accounting Request Completed Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>mosher@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sg_eva.mooney@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Accounting_Approval_Completed</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Accounting_Approval_Requested</fullName>
        <description>Work Order Accounting Approval Requested</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>mosher@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sg_eva.mooney@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Accounting_Approval_Review</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Electrical_Amount_Approval_Complete</fullName>
        <description>Work Order Electrical Amount Approval Complete</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Electrical_Amount_Review_Completed</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Kitchen_Email_on_Verification</fullName>
        <description>Work Order Kitchen Email on Verification</description>
        <protected>false</protected>
        <recipients>
            <recipient>awalker@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bmccune@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mosher@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sg_eva.mooney@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Kitchen_Verification</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Kitchen_Measure_Email</fullName>
        <description>Work Order Kitchen Measure Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>awalker@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Kitchen_Measure</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Permit_Approval_Review_Completed</fullName>
        <description>Work Order Permit Approval Review Completed</description>
        <protected>false</protected>
        <recipients>
            <field>Permit_Approval_Request_Submitted_By__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Permit_Request_Completed</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_RRP_Request_Completed</fullName>
        <description>Work Order RRP Request Completed</description>
        <protected>false</protected>
        <recipients>
            <field>RRP_Exception_Request_Submitted_By__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_RRP_Exception_Request_Completed</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Store_Designer_Email</fullName>
        <description>Work Order Store Designer Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>awalker@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bmccune@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mosher@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Kitchen_Verification</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Type_Change_Approval_Complete</fullName>
        <description>Work Order Type Change Approval Complete</description>
        <protected>false</protected>
        <recipients>
            <field>Type_change_submitted_by_email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>sg_eva.mooney@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Type_Change_Request_Complete</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Type_Change_Approval_Requested</fullName>
        <description>Work Order Type Change Approval Requested</description>
        <protected>false</protected>
        <recipients>
            <recipient>sg_eva.mooney@rfinstallations.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Regional_Admin__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforce_System_Folder_DO_NOT_TOUCH/Work_Order_Type_Change_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Electrical_Amount_Approved</fullName>
        <field>Electrical_Amount_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Electrical Amount Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Electrical_Amount_Rejected</fullName>
        <field>Electrical_Amount_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Electrical Amount Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Electrical_Amount_Submitted_Recalled</fullName>
        <field>Electrical_Amount_Approval_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Electrical Amount Submitted Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Permit_Approval_Requested_By_Email</fullName>
        <field>Permit_Approval_Request_Submitted_By__c</field>
        <formula>$User.Email</formula>
        <name>Permit Approval Requested By Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Permit_Approval_Status_Approved</fullName>
        <field>Permit_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Permit Approval Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Permit_Approval_Status_Recalled</fullName>
        <field>Permit_Approval_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Permit Approval Status Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Permit_Approval_Status_Rejected</fullName>
        <field>Permit_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Permit Approval Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Permit_Approval_Status_Submitted</fullName>
        <field>Permit_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Permit Approval Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Permit_Attached_Review_Uncheck</fullName>
        <field>Permit_Attached_Review_Request__c</field>
        <literalValue>0</literalValue>
        <name>Permit Attached Review Uncheck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RRP_Exception_Request_Approved</fullName>
        <field>RRP_Exception_Request_Status__c</field>
        <literalValue>Data Entry Approved</literalValue>
        <name>RRP Exception Request Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RRP_Exception_Request_Recalled</fullName>
        <field>RRP_Exception_Request_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>RRP Exception Request Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RRP_Exception_Request_Rejected</fullName>
        <field>RRP_Exception_Request_Status__c</field>
        <literalValue>Data Entry Rejected</literalValue>
        <name>RRP Exception Request Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RRP_Exception_Request_Submitted</fullName>
        <field>RRP_Exception_Request_Status__c</field>
        <literalValue>Submitted to Data Entry</literalValue>
        <name>RRP Exception Request Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RRP_Exception_Request_Submitted_By</fullName>
        <field>RRP_Exception_Request_Submitted_By__c</field>
        <formula>$User.Email</formula>
        <name>RRP Exception Request Submitted By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RRP_Exception_Request_uncheck</fullName>
        <field>RRP_Exception_Request_Review_Request__c</field>
        <literalValue>0</literalValue>
        <name>RRP Exception Request uncheck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RRP_Requires_set_to_No</fullName>
        <field>RRP_Required_Calculated__c</field>
        <literalValue>No</literalValue>
        <name>RRP Requires set to No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Subtract_Material_from_Installer_Amount</fullName>
        <field>Installer_Amount__c</field>
        <formula>Amount__c  -  Materials_Amount__c</formula>
        <name>Subtract Material from Installer Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Approval_Status_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>WO Approval Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Approval_Status_Recalled</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>WO Approval Status Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Approval_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>WO Approval Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Approval_Status_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>WO Approval Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Type_Change_Recalled</fullName>
        <field>Type_Change_Request_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>WO Type Change Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Type_Change_Rejected_Status</fullName>
        <field>Type_Change_Request_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>WO Type Change Rejected Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Type_Change_Request_Status_Submitted</fullName>
        <field>Type_Change_Request_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>WO Type Change Request Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Type_Change_Submitted_Date_Time</fullName>
        <field>Type_Change_Submitted_Date_time__c</field>
        <formula>NOW()</formula>
        <name>WO Type Change Submitted Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Type_change_submitted_by_email</fullName>
        <field>Type_change_submitted_by_email__c</field>
        <formula>$User.Email</formula>
        <name>WO Type change submitted by email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Calc_Installer_Paymt</fullName>
        <field>Installer_Payment__c</field>
        <formula>IF (
	NOT(ISBLANK( Installer_Payment_Override__c) )
	, Installer_Amount__c *  Installer_Payment_Override__c
	, IF (
		NOT(ISBLANK( Installer_Percent__c) )
		,  Installer_Amount__c *  Installer_Percent__c
		, 0 
	)
)</formula>
        <name>Work Order: Calc Installer Paymt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Design_Connect_Email_Sent</fullName>
        <field>Kitchen_Design_Connect_Email_Sent__c</field>
        <formula>TODAY()</formula>
        <name>Work Order Design Connect Email Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Electrical_Amount_Submitted</fullName>
        <field>Electrical_Amount_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Work Order Electrical Amount Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Final_Days_Open</fullName>
        <field>Final_Days_Open__c</field>
        <formula>TODAY()  -  DATEVALUE( CreatedDate )</formula>
        <name>Work Order: Final Days Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Kitchen_Measure_Email_Sent</fullName>
        <field>Kitchen_Measure_Sent__c</field>
        <formula>TODAY()</formula>
        <name>Work Order Kitchen Measure Email Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Kitchen_Verification_Email_Se</fullName>
        <field>Kitchen_Verification_Sent_del__c</field>
        <formula>TODAY()</formula>
        <name>Work Order Kitchen Verification Email Se</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Missing_Documents</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Missing Documents</literalValue>
        <name>Work Order: Missing Documents</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Note_Auto_Gen</fullName>
        <field>PO_Note_Auto_Generated__c</field>
        <literalValue>1</literalValue>
        <name>Work Order: Note Auto Gen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_PO_Note_Auto_Push_FALSE</fullName>
        <field>Auto_Push_Note_AutoCreate__c</field>
        <literalValue>0</literalValue>
        <name>Work Order: PO Note Auto Push FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_PO_Note_Missing_Doc</fullName>
        <field>PO_Note_AutoCreated__c</field>
        <formula>&quot;Missing Required Documents&quot;</formula>
        <name>Work Order: PO Note: Missing Doc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_PO_Note_Subject_Missing_Req</fullName>
        <field>PO_Note_Subject_AutoCreate__c</field>
        <formula>&quot;Missing Documents&quot;</formula>
        <name>Work Order: PO Note Subject Missing Req</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Past_Due</fullName>
        <field>Status</field>
        <literalValue>Past Due</literalValue>
        <name>Work Order: Past Due</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Permit_Required_Change</fullName>
        <field>Permit_Required_calculated__c</field>
        <literalValue>Yes</literalValue>
        <name>Work Order: Permit Required Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Permit_Required_is_No</fullName>
        <field>Permit_Required_calculated__c</field>
        <literalValue>No</literalValue>
        <name>Work Order: Permit Required is No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Private</fullName>
        <field>Private_Note_AutoCreate__c</field>
        <literalValue>1</literalValue>
        <name>Work Order: Private</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Set_Installer_Amount_on_Crea</fullName>
        <field>Installer_Amount__c</field>
        <formula>Amount__c</formula>
        <name>Work Order: Set Installer Amount on Crea</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Set_IntactIntegrationKey</fullName>
        <field>IntacctIntegrationKey__c</field>
        <formula>&quot;S&quot; &amp;  CASESAFEID(Id)</formula>
        <name>Work Order Set IntactIntegrationKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Set_Record_Type_Install</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Installation</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Work Order: Set Record Type Install</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_Store_Designer_Email_Sent</fullName>
        <field>Kitchen_Verification_Sent_del__c</field>
        <formula>TODAY()</formula>
        <name>Work Order Store Designer Email Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_TCS_Amount_to_Amount_Field</fullName>
        <field>Amount__c</field>
        <formula>TCS_Installer_Amount_Total__c</formula>
        <name>Work Order: TCS Amount to Amount Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Order_set_original_amount_on_create</fullName>
        <field>Original_Amount__c</field>
        <formula>Amount__c</formula>
        <name>Work Order set original amount on create</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Type_Approval_Status</fullName>
        <field>Type_Change_Request_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Work Type Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Type_Change_Resolution_Date</fullName>
        <field>Type_Change_Resolution_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Work Type Change Resolution Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Work Order Set Installer Amount on Create</fullName>
        <actions>
            <name>Work_Order_Set_Installer_Amount_on_Crea</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Work Order Set IntactIntegrationKey</fullName>
        <actions>
            <name>Work_Order_Set_IntactIntegrationKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Work Order Set Original Amount on Create</fullName>
        <actions>
            <name>Work_Order_set_original_amount_on_create</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Final Days Open</fullName>
        <actions>
            <name>Work_Order_Final_Days_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Canceled,Completed,Exported</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Final_Days_Open__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Has End Date And No Attachments</fullName>
        <active>true</active>
        <formula>AND (

 NOT( ISBLANK( EndDate ) ),

 OR(
   ISBLANK ( of_Attachment_File_Records__c ),
   of_Attachment_File_Records__c = 0
 )

)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Work_Order_Missing_Documents</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_Note_Auto_Gen</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_PO_Note_Auto_Push_FALSE</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_PO_Note_Missing_Doc</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_PO_Note_Subject_Missing_Req</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_Past_Due</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Work_Order_Private</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.EndDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Work Order%3A Installer Changed</fullName>
        <actions>
            <name>Work_Order_Calc_Installer_Paymt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true != false

/*ISCHANGED( Installer__c )*/</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Kitchen Design Connect Measure</fullName>
        <actions>
            <name>Work_Order_Kitchen_Measure_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Work_Order_Store_Designer_Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Kitchen_Design_Connect_Email_Sent__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Measure Kitchen</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Design_Connect__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Kitchen Design Connect Site Verification</fullName>
        <actions>
            <name>Work_Order_Kitchen_Email_on_Verification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Work_Order_Design_Connect_Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Kitchen_Design_Connect_Email_Sent__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Measure Site Verification/Bid</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Design_Connect__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Kitchen Measure</fullName>
        <actions>
            <name>Work_Order_Kitchen_Measure_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Work_Order_Kitchen_Measure_Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Kitchen_Measure_Sent__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Measure Kitchen</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Kitchen Store Site Verification</fullName>
        <actions>
            <name>Work_Order_Store_Designer_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Work_Order_Store_Designer_Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Kitchen_Verification_Sent_del__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Measure Site Verification/Bid</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Permit Required is No based on Job Type</fullName>
        <actions>
            <name>Work_Order_Permit_Required_is_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>WorkOrder.Permit_Required_calculated__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Job_Type_request_change__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Type_Change_Request_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>When Job Type request change is approved the permit is not required (permit only required for installation)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Permit Required is No based on Record Type</fullName>
        <actions>
            <name>Work_Order_Permit_Required_is_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Measure,Installation Electrical,Installation Plumbing,Installation Product Check-in,ChildWO,Measure Kitchen,Measure Site Verification/Bid,Accounting</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Is_Parent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Permit_Required_calculated__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Permit only required for installation work order record types</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A RRP Required is No based on Record Type</fullName>
        <actions>
            <name>RRP_Requires_set_to_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Installation Electrical,Installation Plumbing,Installation Product Check-in,TCS Work Order,ChildWO,Measure Site Verification/Bid,Accounting</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Is_Parent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RRP_Required_Calculated__c</field>
            <operation>equals</operation>
            <value>Yes,Yes - Year Difference</value>
        </criteriaItems>
        <description>RRP only required for installation work order record types</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A Subtract Material from Installer Amount</fullName>
        <actions>
            <name>Subtract_Material_from_Installer_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Materials_Amount__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Work Order%3A TCS Amount to Amount Field</fullName>
        <actions>
            <name>Work_Order_TCS_Amount_to_Amount_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.TCS_Installer_Amount_Total__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>TCS Work Order</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
