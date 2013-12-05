public class categoryTriggerTest 
{
    static testMethod void testCategoryTrigger() 
    {
        string contactID = '00320000004Va4ZAAS';
        string brandID = '00120000006s2o7AAA';

        Brands_of_interest__c b = new Brands_of_interest__c();
        b.accounts_brands__c = brandID;
        b.contact__c = contactID;

        insert(b); 
    }
}