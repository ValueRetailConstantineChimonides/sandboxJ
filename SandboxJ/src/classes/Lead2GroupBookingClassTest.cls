@isTest
private class Lead2GroupBookingClassTest{
   
   static testMethod void verifyGBIsCreated(){
    // Perform our data preparation.
    List<Lead> leads = new List<Lead>();
    //get the MICE recordtype ID
    Id MiceRecordTypeId = [select Id,name from RecordType where name= 'MICE' and SObjectType='Lead' limit 1].Id;
        
    for(Integer i = 0; i < 5; i++){
        Lead l = new Lead(LastName = 'Test Mice Lead' + i, recordtypeid = MiceRecordTypeId, Company = 'Test Lead Company' + i, Name_of_Event__c = 'TestEventName'+i );
        leads.add(l);
    }
    
   // Get a valid lead conversion status.
    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]; 
   
     // Insert the Lead records 
    insert leads;
    
    
    // Create a list of lead conversions, then create a leadConvert object
    // and add it to the list of lead conversions to be executed.
    List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();
        
    FOR (Lead cLead : leads)
    {
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setConvertedStatus( convertStatus.MasterLabel );
        lc.setLeadId(cLead.id);
        leadConversions.add(lc);
    }
    
   
    // reset the limits
    test.startTest();
     
    // Convert the Lead records that cause the trigger to execute
        Database.convertLead(leadConversions);
       
    // Stop the test, this changes limit context back to test from trigger.
    test.stopTest();
    
    
    //
    
    
    List<Group_booking_information__c> GBIs = [SELECT id, Name_of_Event__c FROM Group_booking_information__c WHERE Name_of_Event__c like 'TestEventName%'];

    //ensure there are 5 Group_booking_information__c records as per test list size
    system.debug('GBIRecords : ' + GBIs);
       system.debug('Number of Group_booking_information records : '+GBIs.size());
       
    System.assertEquals(GBIs.size(),5);
    
    FOR(Integer i = 0; i < 5; i++)
    {
       system.debug('TestEventName: ' + GBIs[i].Name_of_Event__c);
       System.assertEquals(GBIs[i].Name_of_Event__c,'TestEventName'+i);
    }
         
}

   
   
   
   
   
}