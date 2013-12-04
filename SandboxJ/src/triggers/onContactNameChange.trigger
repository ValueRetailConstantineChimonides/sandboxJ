/*
ENG-0711-45
//Auto-update the "Local Name" fields against Contacts (Firstname and Lastname) 
//and Accounts/Brands (Name) with the non-accented (non-localised) spelling of the record.
*/
trigger onContactNameChange on Contact (before insert, before update) {
    if (TriggerUtils.CURRENT_USER.Apex_Off__c)
        return;
    List<Contact> contactsBatch = Trigger.new;
    Integer i=0;
    while (i < contactsBatch.size()) {
        Contact changingContact = contactsBatch.get(i++);
        if (changingContact.LastName == null)
            continue;
        String str = changingContact.LastName;
        {//last name
            String localNameStr = AccentCharactersMapping.replaceAccents(changingContact.LastName);
            if (changingContact.LastNameLocal <> localNameStr) {
                changingContact.LastNameLocal = localNameStr;
                //update changingContact;
                System.debug('updated contact with LastNameLocal=' + changingContact.LastNameLocal);
            }
        }
            
        {//first name
            if (changingContact.FirstName != null) {
                String localNameStr = AccentCharactersMapping.replaceAccents(changingContact.FirstName);
                if (changingContact.FirstNameLocal <> localNameStr) {
                    changingContact.FirstNameLocal = localNameStr;
                    //update changingContact;
                    System.debug('updated contact with FirstNameLocal=' + changingContact.FirstNameLocal);
                }
            }
        }
    }   
}