public with sharing class CampaignMemberResponSysStatusEventsTest {
    private static B2C_Contacts_Management__c b2cContactMgt = null;
    private static String RECORD_TYPE_ID_B2C_CONTACT;
    private static String bicesterAccountID;
    private static  String LAST_SERVICE_USE_WIFI;
    
    
    static testMethod void testCampaignMemberResponSysStatusEvents(){
        Date nowDate = DateTime.newInstance(System.currentTimeMillis()).Date();
        
        //CampaignMemberResponSysStatusEvents.inTesting = true;
        //init();
        
        // Test Contacts    // Test Member
        Integer numberOfXXCont = 8;
        List<CampaignMember> testMembers = setupTestMembers(createContactsForTest(numberOfXXCont));
        
        // create the Campaign
        Campaign  testCamp = new Campaign();
        testCamp.Campaign_Village_s__c = 'Bicester';
        testCamp.Name = 'SFDC Unit Tests';
        testCamp.StartDate = nowDate;
        testCamp.EndDate  = nowDate;
        testCamp.Campaign_Category__c = 'Mono Contact';
        testCamp.type = 'Email';
        testCamp.Incentive__c = '% Value Off (Brand)';
        testCamp.Target_Audience__c = 'Corporate';
        Database.Saveresult insertCampaignResult =  Database.insert(testCamp);
        
         Set<Id> forAggregateTest = new Set<Id>();
        
        if(insertCampaignResult.isSuccess()){
            Integer xx = 0;
            for(CampaignMember aMember : testMembers){
                forAggregateTest.add(insertCampaignResult.getId());
                aMember.CampaignId  = insertCampaignResult.getId();
                aMember.status = 'Sent';
               /*
                 if(xx== 9){
                    aMember.status = 'Viewed Message';
                }else if(xx == 10){
                    aMember.status = 'Clicked Campaign Link';
                }else if(xx == 11){
                    aMember.status = 'Opted Out';
                }else if(xx == 12){
                    aMember.status = 'Soft Bounced';
                }else if(xx == 13){
                    aMember.status = 'Hard Bounced';
                }else{
                    aMember.status = 'Sent';
                }
                xx++;    
               */
            }
        }
        Set<Id> testAcctId = new Set<Id>();
        //testAcctId.add(bicesterAccountID);
        //ID camID = getWiFiCampaignsByAccountID(testAcctId).get(bicesterAccountID);
        //testMember.CampaignId = testCamp.Id;
        
        Test.startTest();
        // Switch it to Test Mode so that it ignores the group
        CampaignMemberResponSysStatusEvents.RUN_IN_TEST_MODE = true;
         Database.SaveResult[] insertCampMembResults = Database.insert(testMembers);
         CampaignMemberResponSysStatusEvents.RUN_IN_TEST_MODE = false;
         
         Boolean membersInsertError = false; 
         List<Id> CampaignMemberIDS = new List<Id>();
        for(Database.SaveResult aResult : insertCampMembResults){
            if(aResult.isSuccess()){
                CampaignMemberIDS.add(aResult.getId());
            }else{
                membersInsertError = true;
            }
         }
         
         System.assertEquals(false,membersInsertError);
         
         
         List<CampaignMember> insertedTestMembers = [SELECT Id, Status From CampaignMember WHERE id IN :CampaignMemberIDS];
         List<CampaignMember> membersToUpdate = new List<CampaignMember>();
         
         CampaignMember testMember_1 = insertedTestMembers[0];
         testMember_1.Status = 'Soft Bounced';
         membersToUpdate.add(testMember_1);
         
         CampaignMember testMember_2 = insertedTestMembers[1];
         testMember_2.Status = 'Hard Bounced';
         membersToUpdate.add(testMember_2);
         
         CampaignMember testMember_3 = insertedTestMembers[2];
         testMember_3.Status = 'Viewed Message';
         membersToUpdate.add(testMember_3);
         
         CampaignMember testMember_4 = insertedTestMembers[3];
         testMember_4.Status = 'Responded';
         membersToUpdate.add(testMember_4);
         
         CampaignMember testMember_5 = insertedTestMembers[4];
         testMember_5.Status = 'Complained of spam';
         membersToUpdate.add(testMember_5);
         
         CampaignMember testMember_6 = insertedTestMembers[5];
         testMember_6.Status = 'Opted Out';
         membersToUpdate.add(testMember_6);
         
         CampaignMember testMember_7 = insertedTestMembers[6];
         testMember_7.Status = 'Clicked Campaign Link';
         membersToUpdate.add(testMember_7);
         
         CampaignMemberResponSysStatusEvents.RUN_IN_TEST_MODE = true;
         Database.update(membersToUpdate);
         CampaignMemberResponSysStatusEvents.RUN_IN_TEST_MODE = false;
         
         CampaignMember testMember_8 = insertedTestMembers[7];
         testMember_8.Status = 'Hard Bounced';
        
        CampaignMemberResponSysStatusEvents.RUN_IN_TEST_MODE = true;
         Database.Saveresult anUpdate_1 = Database.update(testMember_8);
         CampaignMemberResponSysStatusEvents.RUN_IN_TEST_MODE = false;
         
         System.assertEquals(true, anUpdate_1.isSuccess());
         
         
         Test.stopTest();
         
         
         
         //CampaignMemberResponSysStatusEvents.inTesting = false;
    }
    
    private static List<CampaignMember> setupTestMembers(List<Id> testContacts){
        List<CampaignMember> testMembers = new List<CampaignMember>();
        
        for(Id contId : testContacts){
            CampaignMember testMember = new CampaignMember();
            testMember.ContactId = contId;
            
            testMembers.add(testMember);
        }
        
        return testMembers;
        
    }
    
    private static  List<Id> createContactsForTest(Integer numberOfXXCont){
        List<Contact> contactsInsert = new List<Contact>();
        
        // Create the Contact for testing
        for(Integer x =0;x< numberOfXXCont ;x++){
            Contact testContact = new Contact();
        
            testContact.FirstName = 'Testing_'+x;
            testContact.LastName = 'Testing'+DateTime.newInstance(System.currentTimeMillis());
            
            contactsInsert.add(testContact);
        }
        Boolean aFailure = false;
        
        // do Insert
        Database.SaveResult[] results = null;
        try{
            results = Database.insert(contactsInsert);
        }catch(Exception ex){
            //ContactUpsertManager.inTesting = false;
            System.debug('========ex'+ex);
            aFailure = true;
            
        }
        System.assertEquals(false, aFailure);
        System.debug('Attempt to create Contact');
        List<Id> theContactIDs = new List<Id>();
        for(Database.SaveResult aResult : results){
            if(aResult.isSuccess()){
                System.debug('====Succes Creating Contact =========');
                theContactIDs.add(aResult.getId());
            }else{
                System.debug('Failed Create====');
                aFailure = true;
                break;
            }
        }
        System.assertEquals(false, aFailure);
        
        return theContactIDs;
    }
    


}