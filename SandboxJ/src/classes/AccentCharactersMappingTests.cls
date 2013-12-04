/*

ENG-0711-45

contains a map of accent characters to non-accent counterparts

*/

public class AccentCharactersMappingTests {

    static testMethod void testContact() {
        UnitTestUtils.setApexOffFlag(false);
        String testStr = 'test2Æ';

        Contact contact = new Contact (FirstName = testStr, LastName = testStr);

        insert contact;

        contact = [select FirstName, LastName, FirstNameLocal, LastNameLocal from Contact where id=: contact.id];

        System.assert( contact.LastNameLocal == testStr, contact.LastName + ' LastNameLocal has not been updated ' + contact.LastNameLocal );

        System.assert( contact.FirstNameLocal == testStr, contact.FirstName + ' FirstNameLocal has not been updated ' + contact.FirstNameLocal );



        Account account = new Account (Name = testStr,RecordTypeId=EventBeforeSupport.B2B_ACCOUNT_RT);

        insert account;

        account = [select Name, NameLocal from Account where id=: account.id];

        System.assert( account.NameLocal == testStr, account.Name + ' NameLocal has not been updated ' + account.NameLocal );

        

    }

}