/*
##Name: Lead2GroupBookingClass
##Created by: Ian Womack
##Date: 12/11/2013
##Purpose: Upon Lead conversion, of a MICE lead, create a Group_Booking_Information__c record
##Used by: LeadTrigger --> Sends in converted leads that require Group_Booking_Information__c records to be created
## The list that comes in has already been filtered by the trigger class which removes all non MICE leads.
*/


public with sharing class Lead2GroupBookingClass{

    Public static void CreateGroupBookings(list<lead> LeadstoAdd)
    {
    //Receives the Leads to convert to GBIs
    system.debug('###Leads passed through###' + LeadstoAdd );
    
    //List to hold all the records to insert
    list<Group_Booking_Information__c> GBIsToInsert = new list<Group_Booking_Information__c>();
    
    //For each Lead that comes in, create a Group_Booking_Information__c record by mapping the data that was captured on the lead.
        FOR (Lead cLead : LeadstoAdd)
        {
            Group_Booking_Information__c  cGBI = new Group_Booking_Information__c();
            cGBI.Name_of_Event__c = cLead.Name_of_Event__c;
            cGBI.Organisation__c = cLead.ConvertedAccountId;
            cGBI.Contact__c = cLead.ConvertedContactId;
            cGBI.Village_of_Visit__c = cLead.Primary_Village_of_Interest__c;
            cGBI.Group_Type__c = cLead.Group_Type__c;
            
            //cGBI.Arrival_Date__c = cLead.Arrival_Date__c; -- This should be on the GBI Only
            cGBI.Expected_Arrival__c = cLead.Expected_Arrival__c;
            cGBI.Expected_Departure__c = cLead.Expected_Departure__c;
            cGBI.Number_of_Visitors__c = cLead.Number_of_Visitors__c;
            cGBI.Visitors_Country_of_Origin__c = cLead.Visitors_Country_of_Origin__c;
            cGBI.Region__c = cLead.Region__c;
            cGBI.Group_Source_lookup__c = cLead.Group_Source_lookup__c;
            cGBI.Transport_Required__c = cLead.Transport_Required__c;
            cGBI.Mode_of_Transport__c = cLead.Mode_of_Transport__c;
            cGBI.Food_Beverage__c = cLead.Food_Beverage__c;
            cGBI.Gift_Card__c = cLead.Gift_Card__c;
            cGBI.Gift__c = cLead.Gift__c;
            cGBI.Notes_and_Additional_Comments__c  = cLead.Notes_and_Additional_Comments__c ;
            cGBI.Coach_Tour_Company_Name__c  = cLead.Coach_Tour_Company_Name__c ;
            cGBI.Inbound_Coach_Operator__c  = cLead.Inbound_Coach_Operator__c ;
            cGBI.Coach_Country_of_Origin__c  = cLead.Coach_Country_of_Origin__c ;
            cGBI.Passengers_Expected__c  = cLead.Passengers_Expected__c ;
            cGBI.Tour_Leader_or_Driver_Name__c  = cLead.Tour_Leader_or_Driver_Name__c ;
            cGBI.Coach_Tour_Contact_Email__c  = cLead.Coach_Tour_Contact_Email__c ;
            cGBI.Coach_Tour_Phone__c  = cLead.Coach_Tour_Phone__c ;
            //Now a calculated field
            //cGBI.Estimated_Spend__c  = cLead.Estimated_Spend__c ;
            cGBI.Group_Booking_Source__c  = cLead.LeadSource ;
           
            
            cGBI.Secondary_MICE_Org_or_Agency_name__c = cLead.Secondary_MICE_Org_or_Agency_name__c;
            cGBI.Secondary_MICE_Contact_Country__c = cLead.Secondary_MICE_Contact_Country__c;
            cGBI.Secondary_MICE_Contact_Title__c = cLead.Secondary_MICE_Contact_Title__c;
            cGBI.Secondary_MICE_Contact_First_Name__c = cLead.Secondary_MICE_Contact_First_Name__c;
            cGBI.Secondary_MICE_Contact_Last_Name__c = cLead.Secondary_MICE_Contact_Last_Name__c;
            cGBI.Secondary_MICE_Contact_Position__c = cLead.Secondary_MICE_Contact_Position__c;
            cGBI.Secondary_MICE_Contact_Address_1__c = cLead.Secondary_MICE_Contact_Address_1__c;
            cGBI.Secondary_MICE_Contact_Address_2__c = cLead.Secondary_MICE_Contact_Address_2__c;
            cGBI.Secondary_MICE_Contact_Address_3__c = cLead.Secondary_MICE_Contact_Address_3__c;
            cGBI.Secondary_MICE_Contact_Town_City__c = cLead.Secondary_MICE_Contact_Town_City__c;
            cGBI.Secondary_MICE_Contact_State__c = cLead.Secondary_MICE_Contact_State__c;
            cGBI.Secondary_MICE_Contact_ZIP_Postcode__c = cLead.Secondary_MICE_Contact_ZIP_Postcode__c;
            cGBI.Secondary_MICE_Contact_Phone__c = cLead.Secondary_MICE_Contact_Phone__c;
            cGBI.Secondary_MICE_Contact_Email__c = cLead.Secondary_MICE_Contact_Email__c;

            
            cGBI.Status__c = 'Proposed';

            //TO-DO - add the additional mappings from Lead to Group_Booking_Information__c
            
                        //Add this GBI to the list to be added
             GBIsToInsert.add(cGBI);
        }
        
        //Add them all
        insert GBIsToInsert;
    
    }
    

}