trigger SG_ContentDocumentLink on ContentDocumentLink (after insert)
{
    if( SG_ApexActivator.isDisabled('Disable ContentVersion Triggers') )
    {
        System.debug( 'Trigger disabled by Apex Activation Settings Custom Setting.' );
        return;
    }

    if(Trigger.operationType == TriggerOperation.AFTER_INSERT)
    {
        SG_FileHelper.processFile(Trigger.operationType, Trigger.new);
    }
}