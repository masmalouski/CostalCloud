/**********************************************************************
* Name:     classes
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
*
* ======================================================
* ======================================================
* Purpose:  
*
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS      	DESCRIPTION/FEATURES ADDED
* 1.0       10/25/21 	    SWM           	Initial Development
*
**********************************************************************/


public without sharing class SG_ContentVersionHelper {

        @TestVisible
        private static final String PRIMARY_INSTALLER_STATUS = 'Primary';
        @TestVisible
        private static final Integer RRP_YEAR = 1978;


        public static void SyncVisibility( Set<Id> ContentVersionSet ) {
            


        }




    /*
        @Future
        public static void createWorkOrdersAtFuture( String JSONWorkOrderList ) {
            system.debug( 'JSONWorkOrderList= ' + JSONWorkOrderList );
            List<WorkOrder> workOrderList = (List<WorkOrder>) JSON.deserialize(
                    JSONWorkOrderList, List<WorkOrder>.class );

            insert workOrderList;
        }
            */

    }