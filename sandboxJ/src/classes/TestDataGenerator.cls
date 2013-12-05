/**
 * This class contains static methods for creating test data for Unit Tests
 *
 */
@isTest
public class TestDataGenerator {

	/**
	 * Setup Admin User for use in RunAs() method.
	 */
	public static User setupAdminUser(Boolean insertToDatabase){
		system.debug('Setting up Admin User');
		User adminUser = new User(alias='BOSS1',email= 'bossman@valueretail.com', emailencodingkey= 'UTF-8',
	                              lastname= 'bossman', firstname= 'the', languagelocalekey= 'en_US', localesidkey= 'en_GB',
	                              profileid = Properties.SYSTEM_ADMINISTRATOR, timezonesidkey= 'Europe/London',
	                              username= 'objSetUpUser1@valueretail.com', isActive = true );
	    if (insertToDatabase) {
	    	insert adminUser;
	    }
	    return adminUser;
	}
	 
	/**
	 * Setup Single User
	 */
	public static User setupUser(String userName, UserRole userRole, Profile userProfile, Boolean isActive, Boolean insertToDatabase) {
		system.debug('Setting up User: ' + userName);
		String truncUserName;
		if (userName.length() > 5) {
			truncUserName = userName.substring(0, 5);
		} else {
			truncUserName = userName;
		}

		User newUser = new User(LastName = userName,
			Alias = truncUserName.toUpperCase() + '123',
			Email = userName + '@valueretail',
			Username = userName + '@valueretail',
			Communitynickname = userName + 'Nickname',
			userroleId = userRole.Id,
			profileId = userProfile.Id,
			timezonesidkey = 'Europe/London',
			emailencodingkey = 'UTF-8',
			languagelocalekey = 'en_US',
			localesidkey = 'en_GB',
			isActive = isActive);

	    if (insertToDatabase) {
	    	insert newUser;
	    }
		return newUser;
	}

	/**
	 * Setup a Queue
	 */
	public static Group setUpQueue(String queueName, Boolean insertToDatabase){
		system.debug('Setting up Queue: ' + queueName);
    	Group newQueue = new Group(Name = 'ZZ' + queueName, Type = 'Queue');
	    if (insertToDatabase) {
	    	insert newQueue;
	    }
		return newQueue;
	}

	/**
	 * Setup Queue Members
	 */
	public static List<GroupMember> setUpQueueMembers(String queueId, List<User> userList, Boolean insertToDatabase){
		List<GroupMember> memberList = new List<GroupMember>();
		for (User u : userList) {
			GroupMember newQueueMember = new GroupMember(GroupId = queueId, UserOrGroupId = u.Id);
			memberList.add(newQueueMember);
		}
	    if (insertToDatabase) {
			insert memberList;
	    }
		return memberList;
	}

	/**
	 * Setup B2B Account
	 */
    public static Account setupB2BAccount(Integer identifier, Boolean insertToDatabase) {
        Account testAccount = new Account(name = 'Test Account' + identifier,
                                          RecordTypeId = Properties.B2B_ACCOUNT_RECORD_TYPE);
	    if (insertToDatabase) {
			insert testAccount;
	    }
        return testAccount;
    }
    
	/**
	 * Setup B2C Account
	 */
    public static Account setupB2CAccount(Integer identifier, Boolean insertToDatabase) {
        Account testAccount = new Account(name = 'Test Account' + identifier,
                                          RecordTypeId = Properties.B2C_ACCOUNT_RECORD_TYPE);
	    if (insertToDatabase) {
			insert testAccount;
	    }
        return testAccount;
    }

	/**
	 * Setup Contact
	 */
    public static Contact setupContact(Integer identifier, Id testAccountId, Boolean insertToDatabase) {
        Contact testContact = new Contact(AccountId = testAccountId,
                                          LastName = 'Test111' + identifier,
                                          FirstName = 'John',
                                          Salutation = 'Mr',
                                          Email = 'testt2387@sdfh.com',
                                          Mailing_Country_In_English__c = 'UNITED KINGDOM',
                                          High_Spender_Status__c = 'None',
                                          EmailReaderStatus__c = 'Unknown');
	    if (insertToDatabase) {
			insert testContact;
	    }
        return testContact;
    }
    
    /**
     * Setup Campaign
     */
    public static Campaign setupCampaign(Integer identifier, Boolean insertToDatabase) {
    	Date startDate = system.today();
    	startDate = startDate.addDays(-5);
    	Date endDate = system.today();
    	endDate = endDate.addDays(5);
    	Campaign testCampaign = new Campaign(Name = 'TESTCAMPAIGN' + identifier,
    										 RecordTypeId = CampaignAfterSupport.DEFAULT_MEMBERS_B2C_CAMPAIGN_RT, 
                                             Type = CampaignAfterSupport.DEFAULT_MEMBERS_CAMPAIGN_TYPE,
                                             IsActive = true, StartDate = startDate, EndDate = endDate,
                                             Active_Redemption_Segments__c = true,
                                             Campaign_Member_Redemption_Count__c = 2);
	    if (insertToDatabase) {
			insert testCampaign;
	    }
        return testCampaign;
    }

    /**
     * Setup Campaign Member
     */
    public static CampaignMember setupCampaignMember(Id contactId, Id campaignId, Boolean insertToDatabase) {
        CampaignMember testCM = new CampaignMember(ContactId = contactId, CampaignId = campaignId, Status = 'Sent');
	    if (insertToDatabase) {
			insert testCM;
	    }
        return testCM;
    }
}