public with sharing class BarcodeAppCustomerSearchController {
	public String searchFirstName {get; set;}
	public String searchLastName {get; set;}
	public String searchEmail {get; set;}
	public String searchPostcode {get; set;}
	public String searchMailStreet {get; set;}
	public String searchVRNumber {get; set;}
	public String selectedId {get; set;}
	public String selectedName {get; set;}
	public String selectedVRNumber {get; set;}
	public String selectedCampaignId {get; set;}
	public String selectedCampaignName {get; set;}
	public List<Contact> custSearchResults {get; private set;}
	public List<Campaign> campaignSearchResults {get; private set;}
	public boolean searchExactMatching {get; set;}
	public boolean showAllCampaigns {get; set;}
	public boolean dataPassedIn {get; private set;}
	public boolean contactPassedIn {get; private set;}
	public Integer custSearchNoOfRecords {get; private set;}
	public Integer custSearchPageSize {get; private set;}
	public Integer campSearchNoOfRecords {get; private set;}
	public Integer campSearchPageSize {get; private set;}
	private Integer custSearchMaxRecords;
	private List<Id> userVillageAccountIds;
	
	public BarcodeAppCustomerSearchController() {
        custSearchPageSize = Properties.BARCODE_CUSTOMER_SEARCH_PAGE_SIZE;
        campSearchPageSize = Properties.BARCODE_CAMPAIGN_SEARCH_PAGE_SIZE;
        custSearchMaxRecords = Properties.BARCODE_CUSTOMER_SEARCH_MAX_RECORDS;
        userVillageAccountIds = VillageCrossReferencer.getUserVillageAccountIdList(true);
        selectedId = ApexPages.currentPage().getParameters().get('contactid');
        searchEmail = ApexPages.currentPage().getParameters().get('email');
        String showAll = ApexPages.currentPage().getParameters().get('showall');
        if (showAll == 'true') {
        	showAllCampaigns = true;
        } else {
			showAllCampaigns = false;
        }
        searchExactMatching = true;
		dataPassedIn = false;
		contactPassedIn = false;
		if ((selectedId != null && selectedId.length() > 0) || (searchEmail != null && searchEmail.length() > 0)) {
			dataPassedIn = true;
			custSearch();
			if (selectedId != null && selectedId.length() > 0) {
				contactPassedIn = true;
				getCMData();
				Contact temp = [SELECT Id, Name, User_Login_ID__c FROM Contact WHERE Id = :selectedId];
				selectedName = temp.Name;
				selectedVRNumber = temp.User_Login_ID__c;
			}
		}	
	}
	
	/**
	 * Paginated Customer Search Results
	 */
	public List<Contact> getCustSearchResults2() {
		if (custSearchResults == null) {
			return null;
		}
		List<Contact> cl = new List<Contact>();
		for (Contact c : (List<Contact>)custSearchSetCon.getRecords()) {
			cl.add(c);
		}
		return cl;
	}

	/**
	 * Paginated Campaign Search Results
	 */
	public List<Campaign> getCampaignSearchResults2() {
		if (campaignSearchResults == null) {
			return null;
		}
		List<Campaign> cmpList = new List<Campaign>();
		for (Campaign cm : (List<Campaign>)campSearchSetCon.getRecords()) {
			cmpList.add(cm);
		}
		return cmpList;
	}

	/**
	 * Only render customer search results if results list not empty
	 */
	public boolean getRenderCustSearch() {
		if(custSearchResults != null && custSearchResults.size() > 0) {
			return true;
		}
		return false;
	}
	
	/**
	 * Only render campaign search results if results list not empty
	 */
	public boolean getRenderCMSearch() {
		if(campaignSearchResults != null && campaignSearchResults.size() > 0) {
			return true;
		}
		return false;
	}

	/**
	 * Perform customer search using data entered
	 */
	public void custSearch() {
		String queryString =  'SELECT Id, FirstName, LastName, Name, Account.Name, ';
			   queryString += 'AccountId, User_Login_ID__c, MailingStreet, ';
			   queryString += 'MailingPostalCode, Email FROM Contact WHERE RecordTypeId = \'' + Properties.B2C_CONTACT_RECORD_TYPE + '\'';
		boolean searchCriteriaEntered = false;
		if (selectedId != null && selectedId.length() > 0) {
			searchCriteriaEntered = true;
			queryString += ' AND Id = \'' + selectedId + '\'';
		} else if (searchVRNumber != null && searchVRNumber.length() > 0) {
			searchCriteriaEntered = true;
			queryString += ' AND User_Login_ID__c = \'' + searchVRNumber + '\'';
		} else {
			if (searchLastName != null && searchLastName.length() > 0) {
				if (searchExactMatching) {
					queryString += ' AND LastName = \'' + searchLastName + '\'';
				} else {
					queryString += ' AND LastName LIKE \'%' + searchLastName + '%\'';
				}
				searchCriteriaEntered = true;
			}
			if (searchFirstName != null && searchFirstName.length() > 0) {
				if (searchExactMatching) {
					queryString += ' AND FirstName = \'' + searchFirstName + '\'';
				} else {
					queryString += ' AND FirstName LIKE \'%' + searchFirstName + '%\'';
				}
				searchCriteriaEntered = true;
			}
			if (searchPostcode != null && searchPostcode.length() > 0) {
				if (searchExactMatching) {
					queryString += ' AND MailingPostalCode = \'' + searchPostcode + '\'';
				} else {
					queryString += ' AND MailingPostalCode LIKE \'%' + searchPostcode + '%\'';
				}
				searchCriteriaEntered = true;
			}
			if (searchMailStreet != null && searchMailStreet.length() > 0) {
				if (searchExactMatching) {
					queryString += ' AND MailingStreet = \'' + searchMailStreet + '\'';
				} else {
					queryString += ' AND MailingStreet LIKE \'%' + searchMailStreet + '%\'';
				}
				searchCriteriaEntered = true;
			}
			if (searchEmail != null && searchEmail.length() > 0) {
				queryString += ' AND Email = \'' + searchEmail + '\'';
				searchCriteriaEntered = true;
			}
		}
		if (userVillageAccountIds != null && userVillageAccountIds.size() > 0) {
			queryString += ' AND AccountId IN :userVillageAccountIds';
		}
		//queryString += ' ORDER BY LastName, FirstName';
		queryString += ' LIMIT ' + custSearchMaxRecords;
		system.debug('CONTACT QUERY: ' + queryString);
		if (!searchCriteriaEntered) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You must enter at least one search criteria'));
		} else {
			custSearchSetCon = null;
			try {
				custSearchResults = Database.query(queryString);
				if (custSearchResults.size() < 1) {
					ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'No matching results found'));
				} else if (custSearchResults.size() >= custSearchMaxRecords - 1) {
					ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'Over ' + custSearchMaxRecords + ' records found - please refine your search'));
					custSearchResults.clear();
				} else {
					dataPassedIn = true;
				}
				custSearchNoOfRecords = custSearchResults.size();
				system.debug('CONTACTS SELECTED: ' + custSearchNoOfRecords);
			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Exception thrown: ' + e.getMessage()));
			}
		}
	}
	
	/**
	 * Retrieve campaign search results
	 */
	private void getCMData() {
		Set<Id> campaignIds;
		Date checkDate = system.today();

		String queryString =  'SELECT Id, Name, B2C_Campaign_ID__c, StartDate, EndDate, NumberOfContacts, NumberOfResponses, IsActive';
			   queryString += ' FROM Campaign WHERE IsActive = true';
			   queryString += ' AND StartDate <= :checkDate';
			   queryString += ' AND EndDate >= :checkDate';
			   queryString += ' AND Active_Redemption_Segments__c = true';

		if (!showAllCampaigns) {
			List<CampaignMember> cmList = [SELECT Id, Campaign.Id FROM CampaignMember WHERE Contact.Id = :selectedId];
			campaignIds = new Set<Id>();
			for (CampaignMember cm : cmList) {
				campaignIds.add(cm.Campaign.Id);
			}
			queryString += ' AND Id IN :campaignIds';
		} else {
			String villageString = VillageCrossReferencer.getUserVillageName();
			queryString += ' AND Campaign_Village_s__c = :villageString';
			system.debug('VILLAGE STRING: ' + villageString);
		}
		queryString += ' ORDER BY Name';
		system.debug('CAMPAIGN QUERY: ' + queryString);

		campSearchSetCon = null;
		try {
			campaignSearchResults = Database.query(queryString);
			if (campaignSearchResults.size() < 1) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'No matching campaigns found for ' + selectedName + ' (' + selectedVRNumber + ')'));
			}
			campSearchNoOfRecords = campaignSearchResults.size();
			system.debug('CAMPAIGNS SELECTED: ' + campSearchNoOfRecords);
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Exception thrown: ' + e.getMessage()));
		}
	}
	
	/**
	 * Return to Barcode Scanner screen
	 */
	public PageReference back() {
		return Page.BarcodeAppScan;
	}

	/**
	 * Add a new customer record to Salesforce
	 */
	public PageReference addNew() {
		return Page.BarcodeAppAddContact;
	}

	/**
	 * Select a row from the customer search results table
	 */
	public void selectRow() {
		selectedCampaignId = null;
		selectedCampaignName = null;
		getCMData();
	}
	
	/**
	 * Clear all search fields and return to data entry screen
	 */
	public void clear() {
		searchFirstName = null;
		searchLastName = null;
		searchEmail = null;
		searchPostcode = null;
		searchMailStreet = null;
		searchVRNumber = null;
		custSearchResults = null;
		campaignSearchResults = null;
		showAllCampaigns = false;
		searchExactMatching = true;
		selectedId = null;
		selectedName = null;
		selectedVRNumber = null;
		selectedCampaignId = null;
		selectedCampaignName = null;
		dataPassedIn = false;
		contactPassedIn = false;
	}
	
	/**
	 * Proceed to Process Redemption screen for selected customer and campaign
	 */
	public PageReference processRedemption() {
		List<CampaignMember> testCMList = [SELECT Id, Contact.Id, Campaign.Id FROM CampaignMember WHERE Contact.Id = :selectedId AND Campaign.Id = :selectedCampaignId];
		CampaignMember cm;
		if (testCMList.size() == 0) {
			cm = new CampaignMember(ContactId = selectedId, CampaignId = selectedCampaignId);
			insert cm;
		} else {
			cm = testCMList.get(0);
		}
		PageReference pr = new PageReference('/apex/BarcodeAppRedemption?cmsfid=' + cm.Id);
		return pr;
	}

	public ApexPages.Standardsetcontroller custSearchSetCon {
		get {
			if (custSearchSetCon == null) {
				custSearchSetCon = new ApexPages.Standardsetcontroller(custSearchResults);
				custSearchSetCon.setPageSize(custSearchPageSize);
				custSearchSetCon.setPageNumber(1);
			}
			return custSearchSetCon;
		}
		set;
	}

	public Boolean csHasNext {
		get {
			return custSearchSetCon.getHasNext();
		}
		set;
	}
	
	public Boolean csHasPrevious {
		get {
			return custSearchSetCon.getHasPrevious();
		}
		set;
	}
	
	public Integer csPageNumber {
		get {
			return custSearchSetCon.getPageNumber();
		}
		set;
	}
	
	public void csFirst() {
		custSearchSetCon.first();
	}
	
	public void csLast() {
		custSearchSetCon.last();
	}
	
	public void csPrevious() {
		custSearchSetCon.previous();
	}
	
	public void csNext() {
		custSearchSetCon.next();
	}

	public ApexPages.Standardsetcontroller campSearchSetCon {
		get {
			if (campSearchSetCon == null) {
				campSearchSetCon = new ApexPages.Standardsetcontroller(campaignSearchResults);
				campSearchSetCon.setPageSize(campSearchPageSize);
				campSearchSetCon.setPageNumber(1);
			}
			return campSearchSetCon;
		}
		set;
	}

	public Boolean campHasNext {
		get {
			return campSearchSetCon.getHasNext();
		}
		set;
	}
	
	public Boolean campHasPrevious {
		get {
			return campSearchSetCon.getHasPrevious();
		}
		set;
	}
	
	public Integer campPageNumber {
		get {
			return campSearchSetCon.getPageNumber();
		}
		set;
	}
	
	public void campFirst() {
		campSearchSetCon.first();
	}
	
	public void campLast() {
		campSearchSetCon.last();
	}
	
	public void campPrevious() {
		campSearchSetCon.previous();
	}
	
	public void campNext() {
		campSearchSetCon.next();
	}
}