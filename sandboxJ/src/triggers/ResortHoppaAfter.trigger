/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2011-09-14 14:20:47 
 *	@description:
 *	    Segment 1 movement: on the date of the transfer date, the customer should be moved into Segment 1 on the date of travel.
 *	    – Development is required and when we implement it this will only affect the new records. 
 *	    Create a trigger – Current Segment filed should be update with “1” on Contact object on the date of the 
 *	    transfer date field (“XferDate1” from Shopping Express object). 
 *	    If file was provided on the server later than day of transfer then trigger will update “Current Segment” 
 *	    field with “1” on Contact record with same date when record will be created on SFDC. When “Shopping Express”
 *	    does not create a new record of Contact and transaction will be attached to an existing Contact then also “Current Segment” 
 *	    field should be updated to “1” on Contact record. 
 *	    In other words: if XferDate1 is <= today() then set:
 *	    - Contact.Current_Segment__c = 1
 *	    otherwise setup a time based workflow to trigger on XferDate1
 *	
 *	Version History :   
 *		
 */
trigger ResortHoppaAfter on Resort_Hoppa_Transaction__c (after insert, after update, after delete, after undelete) {

	if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)) {
		ResortHoppaAfterSupport.assignContactCurrentSegment(Trigger.new);
	}

}