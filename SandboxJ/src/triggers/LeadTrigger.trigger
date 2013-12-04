/*
##Name: LeadTrigger 
##Created by: Ian Womack
##Date: 12/11/2013
##Purpose: Upon Lead conversion, of a MICE lead, create a Group_Booking_Information__c record.
*/

trigger LeadTrigger on Lead (after update) {

//Stores a list of Lead records that will be sent over to the helper class
List<Lead> leadsToCreateBookingInformationRecs = new List<Lead>();
//record type of leads we are interested in
Id RecordTypeId = [select Id,name from RecordType where name= 'MICE' and SObjectType='Lead' limit 1].Id;


//Loop through the leads and only filter out the leads that do not match the criteria

    For (Lead cLead : Trigger.new)
    {
        system.debug('Lead ID: '  +cLead.id);
        system.debug('nowConverted?: '  +cLead.isConverted);
        system.debug('was Converted?: ' + trigger.oldmap.get(cLead.id).isConverted);
        system.debug('Recordtypeid: '   +cLead.recordtypeid );
        system.debug('Should GBI be created?: '   +cLead.Create_Group_Booking__c );
        
        //Criteria: Record Type = MICE && isConverted = true && Create_Group_Booking__c = true
        IF (cLead.isConverted == true && trigger.oldmap.get(cLead.id).isConverted == false && cLead.recordtypeid == RecordTypeId && cLead.Create_Group_Booking__c == true)
        {
        //add the lead to the list to send through for GBI creation
            leadsToCreateBookingInformationRecs.add(cLead);  
            system.debug('Lead added: ' + cLead);
        }
        else
        {
            system.debug('No leads converted');
        }
             
    } //end for loop
    
    
  //display the list of leads for which will be sent for GBI creation
  system.debug('Leads converted: ' + leadsToCreateBookingInformationRecs );
  
  Lead2GroupBookingClass.CreateGroupBookings(leadsToCreateBookingInformationRecs);
  
  
}