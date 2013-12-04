/**
 * WebService for use with ETL Updates into Salesforce
 */
global class ETLWebService {
	global static Map<String, String> defaultValueMap;
	global static Map<String, String> villageLanguageMap;
	global static Map<String, List<Contact>> duplicateMap;
	global static Map<String, List<Customer_Activity__c>> duplicateActivityMap;
	global static Set<String> validGenderList;
	global static Set<String> validEnglishMailingCountryList;
	global static Set<String> validLanguageList;
	global static Set<String> validNationalityList;
	global static Map<String, Id> campaignIdXref;
	private static Logger logger;
	/**
	 * Testing method
	 */
	webService static String wsTest() {
		return 'Yes it works';
	}
	/**
	 * Create / update contact records from list of ETLContactDTO records.
	 * Also creates Customer_Activity__c records where required.
	 */
	webService static List<ETLContactResultDTO> contactRegistration(List<ETLContactDTO> etlContactDTOList) {
		try {
			logger = LoggerFactory.getLogger('ETLWebService');
			logger.log('CALLING ETLWebService.contactRegistration METHOD');
			system.debug('CALLING ETLWebService.contactRegistration METHOD');
			
			// Build valid value lists and defaults for cleansing
			logger.log('ETLWebService: BUILDING FIELD LISTS');
			system.debug('ETLWebService: BUILDING FIELD LISTS');
			defaultValueMap = new Map<String, String>();
			villageLanguageMap = new Map<String, String>();
			duplicateMap = new Map<String, List<Contact>>();
			duplicateActivityMap = new Map<String, List<Customer_Activity__c>>();
			validGenderList = new Set<String>();
			validEnglishMailingCountryList = new Set<String>();
			validLanguageList = new Set<String>();
			validNationalityList = new Set<String>();

			Schema.DescribeFieldResult genderDFR = Contact.Gender__c.getDescribe();
			buildFieldValuesAndDefault(genderDFR, validGenderList, 'Gender', defaultValueMap);
			Schema.DescribeFieldResult emcDFR = Contact.Mailing_Country_In_English__c.getDescribe();
			buildFieldValuesAndDefault(emcDFR, validEnglishMailingCountryList, 'Country', defaultValueMap);
			Schema.DescribeFieldResult languageDFR = Contact.Preferred_language_of_communication__c.getDescribe();
			buildFieldValuesAndDefault(languageDFR, validLanguageList, 'Language', defaultValueMap);
			Schema.DescribeFieldResult nationalityDFR = Contact.Nationality_Picklist__c.getDescribe();
			buildFieldValuesAndDefault(nationalityDFR, validNationalityList, 'Nationality', defaultValueMap);

			List<Village__c> villList = [SELECT Id, Village_Code__c, Village_Local_Language__c FROM Village__c];
			for (Village__c v : villList) {
				String villageLanguage = v.Village_Local_Language__c;
				if (String.isNotBlank(villageLanguage)) {
					villageLanguageMap.put(v.Village_Code__c, villageLanguage);
				}
			}
			logger.log('ETLWebService: VILLAGE LANGUAGE MAP: ' + villageLanguageMap);
			system.debug('ETLWebService: VILLAGE LANGUAGE MAP: ' + villageLanguageMap);

			campaignIdXref = new Map<String, Id>();
			Set<String> campaignRefs = new Set<String>();
			for (ETLContactDTO etlContactDTO : etlContactDTOList) {
				if (String.isNotBlank(etlContactDTO.CampaignId)) {
					campaignRefs.add(etlContactDTO.CampaignId);
				}
			}
			if (!campaignRefs.isEmpty()) {
				List<Campaign> campList = [SELECT Id, B2C_Campaign_ID__c FROM Campaign WHERE B2C_Campaign_ID__c IN :campaignRefs];
				for (Campaign c : campList) {
					campaignIdXref.put(c.B2C_Campaign_ID__c, c.Id);
				}
			}

			Map<String, ETLWebService_Settings__c> allSettings = ETLWebService_Settings__c.getAll();
 			Map<String, ETLContactResultDTO> resultMap = new Map<String, ETLContactResultDTO>();
			List<ETLContactResultDTO> resultList = new List<ETLContactResultDTO>();
			List<Contact> contactUpsertList = new List<Contact>();
			List<String> tpRefList = new List<String>();
			Map<String, Customer_Activity__c> activityInsertMap = new Map<String, Customer_Activity__c>();
			Map<String, CampaignMember> cmUpdateMap = new Map<String, CampaignMember>();
			
			// Map and deduplicate incoming contacts
			logger.log('ETLWebService: MAPPING AND DEDUPLICATING');
			system.debug('ETLWebService: MAPPING AND DEDUPLICATING');

			// Flag any duplicates in the incoming list
			buildDuplicateMaps(etlContactDTOList, duplicateMap, duplicateActivityMap);

			Integer processCount = 1;
			Integer totalCount = etlContactDTOList.size();
			for (ETLContactDTO etlContactDTO : etlContactDTOList) {
				system.debug('PROCESS COUNT: ' + processCount + ' of ' + totalCount);
				processCount++;
				String touchpointRef = etlContactDTO.TouchpointReference;
				String touchpointType = etlContactDTO.TouchpointType;
				logger.log('ETLWebService: Processing ' + touchpointRef);
				logger.log('ETLWebService: Touchpoint ' + touchpointType);
				logger.log('ETLWebService: Incoming Contact DTO: ' + etlContactDTO);
				system.debug('ETLWebService: Processing ' + touchpointRef);
				system.debug('ETLWebService: Touchpoint ' + touchpointType);
				ETLContactResultDTO thisResult = new ETLContactResultDTO();
				thisResult.TouchpointReference = touchpointRef;
				if (allSettings.containsKey(touchpointType)) {
					ETLWebService_Settings__c touchpointSettings = allSettings.get(touchpointType);
					if (touchpointSettings.Enabled__c) {
						thisResult.Result = 'Processing';

						// Map Contact and cleanse dodgy data
						Contact con = mapNewContactFromETL(etlContactDTO, touchpointSettings, thisResult);
				
						// Duplicate Check
						ContactDataValidator.ValidationResult vr = checkForDuplicates(con, duplicateMap); 

						if (vr.getPassedCheck()) {
							logger.log('ETLWebService: Duplicate check passed ' + touchpointRef);
							system.debug('ETLWebService: Duplicate check passed ' + touchpointRef);
							thisResult.ContactAction = 'New';
							contactUpsertList.add(con);
							tpRefList.add(touchpointRef);
							Customer_Activity__c caRec = mapCustomerActivityFromETL(etlContactDTO, con, touchpointSettings);
							activityInsertMap.put(touchpointRef, caRec);
							if (String.isNotBlank(etlContactDTO.CampaignId)) {
								if (caRec.Campaign__c != null) {
									cmUpdateMap.put(touchpointRef, mapCampaignMemberFromCustomerActivity(caRec));
								} else {
									thisResult.Status = 'Campaign Member Error';
									String message = 'Invalid Campaign ID: ' + etlContactDTO.CampaignId;
									if (String.isBlank(thisResult.Message)) {
										thisResult.Message = message;
									} else {
										thisResult.Message += '; ' + message;
									}
								}
							}
						} else if (vr.getDuplicateList() != null && vr.getDuplicateList().size() == 1){
							Contact dupeCon = vr.getDuplicateList().get(0);
							thisResult.ContactId = dupeCon.Id;
							logger.log('ETLWebService: Duplicate contact ' + dupeCon.Id + ' found for ' + touchpointRef);
							system.debug('ETLWebService: Duplicate contact ' + dupeCon.Id + ' found for ' + touchpointRef);
							if (touchpointSettings.Ignore_Duplicates__c) {
								thisResult.ContactAction = 'Ignore';
								logger.log('ETLWebService: Duplicate ignored ' + touchpointRef);
								system.debug('ETLWebService: Duplicate ignored ' + touchpointRef);
							} else {
								thisResult.ContactAction = 'Update';
								logger.log('ETLWebService: Duplicate updated ' + touchpointRef);
								system.debug('ETLWebService: Duplicate updated ' + touchpointRef);
								mapCommonFieldsToContact(etlContactDTO, dupeCon);
								contactUpsertList.add(dupeCon);
								tpRefList.add(touchpointRef);
							}
							Customer_Activity__c caRec = mapCustomerActivityFromETL(etlContactDTO, dupeCon, touchpointSettings);
							activityInsertMap.put(touchpointRef, caRec);
							if (String.isNotBlank(etlContactDTO.CampaignId)) {
								if (caRec.Campaign__c != null) {
									cmUpdateMap.put(touchpointRef, mapCampaignMemberFromCustomerActivity(caRec));
								} else {
									thisResult.Status = 'Campaign Member Error';
									String message = 'Invalid Campaign ID: ' + etlContactDTO.CampaignId;
									if (String.isBlank(thisResult.Message)) {
										thisResult.Message = message;
									} else {
										thisResult.Message += '; ' + message;
									}
								}
							}
						} else {
							logger.log('ETLWebService: Multiple duplicates for ' + touchpointRef + '. List: ' + vr.getDuplicateList());
							system.debug('ETLWebService: Multiple duplicates for ' + touchpointRef + '. List: ' + vr.getDuplicateList());
							thisResult.Result = 'Failed';
							thisResult.Status = 'Multiple Matches';
							thisResult.ContactAction = 'Update';
							thisResult.Message = 'Multiple duplicates found for email: ' + etlContactDTO.EmailAddress + ' and Village: ' + etlContactDTO.Village;
						}
					} else {
						logger.log('ETLWebService: TouchpointType ' + touchpointType + ' specified on ' + touchpointRef + ' is disabled');
						system.debug('ETLWebService: TouchpointType ' + touchpointType + ' specified on ' + touchpointRef + ' is disabled');
						thisResult.Result = 'Failed';
						thisResult.Status = 'Touchpoint Type Disabled';
						thisResult.ContactAction = 'New';
						thisResult.Message = 'Touchpoint Type ' + touchpointType + ' is disabled';
					}
				} else {
					logger.log('ETLWebService: Invalid TouchpointType specified on ' + touchpointRef + '. Type: ' + touchpointType);
					system.debug('ETLWebService: Invalid TouchpointType specified on ' + touchpointRef + '. Type: ' + touchpointType);
					thisResult.Result = 'Failed';
					thisResult.Status = 'Invalid Touchpoint Type';
					thisResult.ContactAction = 'New';
					thisResult.Message = 'Invalid Touchpoint Type specified: ' + touchpointType;
				}
				resultMap.put(touchpointRef, thisResult);
				resultList.add(thisResult);
			}

			// Upsert any valid contacts
			Integer contactUpsertListSize = contactUpsertList.size();
			logger.log('ETLWebService: UPSERTING CONTACTS - ' + contactUpsertListSize + ' RECORDS');
			system.debug('ETLWebService: UPSERTING CONTACTS - ' + contactUpsertListSize + ' RECORDS');
			Boolean contactUpsertSucceeded = true;
			Boolean allOrNothingContacts = false; // AllOrNone: true - if one fails all fail, false - if one fails keep doing the rest
			if (contactUpsertListSize > 0) {
				try {
					List<Database.UpsertResult> urList = Database.Upsert(contactUpsertList, allOrNothingContacts);
					Integer upsertResultListSize = urList.size();
					logger.log('ETLWebService: UPSERT RESULT LIST - ' + upsertResultListSize + ' RECORDS');
					system.debug('ETLWebService: UPSERT RESULT LIST - ' + upsertResultListSize + ' RECORDS');
					Integer pos = 0;
					for (Database.UpsertResult ur : urList) {
						String tpRef = tpRefList.get(pos);
						ETLContactResultDTO tempRes = resultMap.get(tpRef);
						if (ur.isSuccess()) {
							if (tempRes.Status != 'Cleansed' && tempRes.Status != 'Campaign Member Error') {
								tempRes.Status = 'Success';
							}
							if (ur.isCreated()) {
								tempRes.ContactId = ur.getId();
							} 
						} else {
							List<Database.Error> errList = ur.getErrors();
							tempRes.Result = 'Failed';
							tempRes.Status = 'Validation Error';
							for (Database.Error err : errList) {
								if (String.isBlank(tempRes.Message)) {
									tempRes.Message = 'CONTACT: ' + err.getMessage();
								} else {
									tempRes.Message += '; CONTACT: ' + err.getMessage();
								}
							}
						}
						pos++;
					}
				} catch (DMLException dmlX) {
					contactUpsertSucceeded = false;
					return totalDeathMessage(dmlX);
				} catch (Exception e) {
					contactUpsertSucceeded = false;
					return totalDeathMessage(e);
				}
			}
			logger.log('ETLWebService: UPSERT SUCCEEDED: ' + contactUpsertSucceeded);
			system.debug('ETLWebService: UPSERT SUCCEEDED: ' + contactUpsertSucceeded);
			
			// Insert any Customer Activity records
			if (contactUpsertSucceeded && activityInsertMap.size() > 0) {
				logger.log('ETLWebService: CHECKING CUSTOMER ACTIVITY RECORDS');
				system.debug('ETLWebService: CHECKING CUSTOMER ACTIVITY RECORDS');
				for (Customer_Activity__c act : activityInsertMap.values()) {
					String tpRef = act.Touchpoint_Reference__c;
					ETLContactResultDTO tempRes = resultMap.get(tpRef);
					if (tempRes.ContactId == null) {
						if (tempRes.Result != 'Failed') {
							tempRes.Result = 'Failed';
							tempRes.Status = 'Validation Error';
							String errMsg = 'No contact id available for customer activity record';
							if (String.isBlank(tempRes.Message)) {
								tempRes.Message = errMsg;
							} else {
								tempRes.Message += '; ' + errMsg;
							}
						}
						Customer_Activity__c blat = activityInsertMap.remove(tpRef);
						CampaignMember blat2 = cmUpdateMap.remove(tpRef);
					} else {
						ETLWebService_Settings__c touchpointSettings = allSettings.get(act.Touchpoint_Type__c);
						if (allowCustomerActivityInsert(act, duplicateActivityMap, touchpointSettings)) {
							act.Contact_Name__c = tempRes.ContactId;
							if (cmUpdateMap.containsKey(tpRef)) {
								CampaignMember tempCM = cmUpdateMap.get(tpRef);
								tempCM.ContactId = tempRes.ContactId;
							}
						} else {
							if (tempRes.Result != 'Failed') {
								tempRes.Result = 'Completed';
								tempRes.Status = 'Duplicate Customer Activity Ignored';
							}
							String dupeMsg = 'A Customer Activity record with this Touchpoint Ref, Date and Contact already exists - ignoring duplicate';
							if (String.isBlank(tempRes.Message)) {
								tempRes.Message = dupeMsg;
							} else {
								tempRes.Message += '; ' + dupeMsg;
							}
							Customer_Activity__c blat = activityInsertMap.remove(tpRef);
							CampaignMember blat2 = cmUpdateMap.remove(tpRef);
						}
					}
				}
				
				if (activityInsertMap.size() > 0) {
					List<Customer_Activity__c> caInsertList = activityInsertMap.values();
					Integer activityInsertListSize = caInsertList.size();
					logger.log('ETLWebService: INSERTING CUSTOMER ACTIVITY - ' + activityInsertListSize + ' RECORDS');
					system.debug('ETLWebService: INSERTING CUSTOMER ACTIVITY - ' + activityInsertListSize + ' RECORDS');
					Boolean allOrNothingActivity = false; // AllOrNone: true - if one fails all fail, false - if one fails keep doing the rest
					try {
						List<Database.SaveResult> srList = Database.Insert(caInsertList, allOrNothingActivity);
						Integer insertResultListSize = srList.size();
						logger.log('ETLWebService: INSERT RESULT LIST - ' + insertResultListSize + ' RECORDS');
						system.debug('ETLWebService: INSERT RESULT LIST - ' + insertResultListSize + ' RECORDS');
						Integer pos = 0;
						for (Database.SaveResult sr : srList) {
							String tpRef = caInsertList.get(pos).Touchpoint_Reference__c;
							ETLContactResultDTO tempRes = resultMap.get(tpRef);
							if (sr.isSuccess()) {
								tempRes.Result = 'Completed';
								if (tempRes.Status != 'Cleansed' && tempRes.Status != 'Campaign Member Error') {
									tempRes.Status = 'Success';
								}
							} else {
								List<Database.Error> errList = sr.getErrors();
								tempRes.Result = 'Failed';
								tempRes.Status = 'Validation Error';
								for (Database.Error err : errList) {
									if (String.isBlank(tempRes.Message)) {
										tempRes.Message = 'ACTIVITY: ' + err.getMessage();
									} else {
										tempRes.Message += '; ACTIVITY: ' + err.getMessage();
									}
								}
							}
							pos++;
						}
						logger.log('ETLWebService: ACTIVITY RECORD INSERT SUCCEEDED');
						system.debug('ETLWebService: ACTIVITY RECORD INSERT SUCCEEDED');
					} catch (Exception e) {
						return totalDeathMessage(e);
					}
				}
			}

			// Insert any Campaign Member records
			if (contactUpsertSucceeded && cmUpdateMap.size() > 0) {
				logger.log('ETLWebService: INSERTING CAMPAIGN MEMBER RECORDS');
				system.debug('ETLWebService: INSERTING CAMPAIGN MEMBER RECORDS');
				List<String> cmMapKeys = new List<String>();
				cmMapKeys.addAll(cmUpdateMap.keySet());
				List<CampaignMember> cmInsertList = new List<CampaignMember>();
				for (String s : cmMapKeys) {
					cmInsertList.add(cmUpdateMap.get(s));
				}
				try {
					List<Database.SaveResult> srList = Database.Insert(cmInsertList, false); // AllOrNone = false so only do ones that work
					Integer pos = 0;
					for (Database.SaveResult sr : srList) {
						CampaignMember cmTemp = cmInsertList.get(pos);
						if (sr.isSuccess()) {
							logger.log('CAMPAIGN MEMBER INSERTED: ' + cmTemp);
						} else {
							logger.log('CAMPAIGN MEMBER FAILED: ' + cmTemp);
							List<Database.Error> errList = sr.getErrors();
							String tpRef = cmMapKeys.get(pos);
							ETLContactResultDTO tempRes = resultMap.get(tpRef);
							tempRes.Status = 'Campaign Member Error';
							for (Database.Error err : errList) {
								logger.log('ERROR: ' + err.getMessage());
								if (String.isBlank(tempRes.Message)) {
									tempRes.Message = 'CAMPAIGN MEMBER: ' + err.getMessage();
								} else {
									tempRes.Message += '; CAMPAIGN MEMBER: ' + err.getMessage();
								}
							}
						}
						pos++;
					}
					logger.log('ETLWebService: CAMPAIGN MEMBER RECORD INSERT SUCCEEDED');
					system.debug('ETLWebService: CAMPAIGN MEMBER RECORD INSERT SUCCEEDED');
				} catch (Exception e) {
					return totalDeathMessage(e);
				}
			}

			// Commit log file
			logger.log('ETLWebService: RESULTS RETURNED ' + resultList);
			system.debug('ETLWebService: RESULTS RETURNED ' + resultList);
			logger.commitLog();
			
			// Return result list
			return resultList;

		} catch (Exception ex) {
			return totalDeathMessage(ex);
		}
	}
	
	/**
	 * Additional Contact fields mapped for inserts only
	 */
	private static Contact mapNewContactFromETL(ETLContactDTO etlContactDTO, ETLWebService_Settings__c touchpointSettings, ETLContactResultDTO resultDTO) {
		logger.log('ETLWebService: Mapping ' + etlContactDTO.TouchpointReference);
		system.debug('ETLWebService: Mapping ' + etlContactDTO.TouchpointReference);
		Contact con = new Contact();
		mapCommonFieldsToContact(etlContactDTO, con);
		String villageCode = etlContactDTO.Village;
		con.AccountId = VillageCrossReferencer.getVillageAccountIdByCode(villageCode);
		con.B2C_Password__c = etlContactDTO.Password;
		if (etlContactDTO.RegistrationDate == null) {
			con.Original_Creation_Date__c = system.today();
		} else {
			con.Original_Creation_Date__c = etlContactDTO.RegistrationDate;
		}
		con.Lead_Source_Text__c = etlContactDTO.LeadSourceText;
		con.LeadSource = touchpointSettings.Lead_Source__c;
		con.RecordTypeId = Properties.B2C_CONTACT_RECORD_TYPE;
		con.EmailReaderStatus__c = 'Unknown';
		con.High_Spender_Status__c = 'None';
		con.Validate_Record__c = true;
		cleanContactData(con, villageCode, resultDTO);
		logger.log('ETLWebService: Mapped ' + con);
		system.debug('ETLWebService: Mapped ' + con);
		return con;
	}

	/**
	 * Contact field mapper used for both updates and inserts
	 */
	private static void mapCommonFieldsToContact(ETLContactDTO etlContactDTO, Contact con) {
		logger.log('ETLWebService: Updating Common Fields ' + etlContactDTO.TouchpointReference);
		system.debug('ETLWebService: Updating Common Fields ' + etlContactDTO.TouchpointReference);
		if (String.isNotBlank(etlContactDTO.EmailAddress)) {
			con.Email = etlContactDTO.EmailAddress;
		}
		if (String.isNotBlank(etlContactDTO.FirstName)) {
			con.FirstName = etlContactDTO.FirstName;
		}
		if (String.isNotBlank(etlContactDTO.LastName)) {
			con.LastName = etlContactDTO.LastName;
		}
		if (String.isNotBlank(etlContactDTO.Gender)) {
			con.Gender__c = etlContactDTO.Gender;
		}
		if (etlContactDTO.DateOfBirth != null) {
			con.Birthdate = etlContactDTO.DateOfBirth;
		}
		if (etlContactDTO.Over18YearsOld != null) {
			con.I_am_18_years_old_or_more__c = etlContactDTO.Over18YearsOld;
		}
		if (etlContactDTO.EmailOptOut != null) {
			con.HasOptedOutOfEmail = etlContactDTO.EmailOptOut;
		} else {
			con.HasOptedOutOfEmail = true;
		}
		if (etlContactDTO.MobileOptOut != null) {
			con.Mobile_Opt_Out__c = etlContactDTO.MobileOptOut;
		}
		if (etlContactDTO.PostalOptOut != null) {
			con.Postal_Opt_Out__c = etlContactDTO.PostalOptOut;
		}
		if (etlContactDTO.ThirdPartyOptOut != null) {
			con.Other_Village_Partner_Opt_Out__c = etlContactDTO.ThirdPartyOptOut;
		}
		if (etlContactDTO.ProfilingOptOut != null) {
			con.Profiling_Opt_Out__c = etlContactDTO.ProfilingOptOut;
		}
		if (String.isNotBlank(etlContactDTO.CountryOfResidence)) {
			con.Mailing_Country_In_English__c = etlContactDTO.CountryOfResidence.toUpperCase();
		}
		if (String.isNotBlank(etlContactDTO.PreferredLanguage)) {
			con.Preferred_language_of_communication__c = etlContactDTO.PreferredLanguage;
		}
		if (String.isNotBlank(etlContactDTO.Nationality)) {
			con.Nationality_Picklist__c = etlContactDTO.Nationality;
		}
		if (String.isNotBlank(etlContactDTO.Address_Street)) {
			con.MailingStreet = etlContactDTO.Address_Street;
		}
		if (String.isNotBlank(etlContactDTO.Address_City)) {
			con.MailingCity = etlContactDTO.Address_City;
		}
		if (String.isNotBlank(etlContactDTO.Address_State)) {
			con.MailingState = etlContactDTO.Address_State;
		}
		if (String.isNotBlank(etlContactDTO.Address_Country)) {
			con.MailingCountry = etlContactDTO.Address_Country;
		}
		if (String.isNotBlank(etlContactDTO.Address_PostCode)) {
			con.MailingPostalCode = etlContactDTO.Address_PostCode;
		}
		if (String.isNotBlank(etlContactDTO.Mobile)) {
			con.MobilePhone = etlContactDTO.Mobile;
		}
	}
	
	/**
	 * Check incoming data in picklist fields contain valid values.  If not, change to default
	 */
	private static void cleanContactData(Contact con, String villageCode, ETLContactResultDTO resultDTO) {
		logger.log('CLEANING DATA: ' + con);
		system.debug('CLEANING DATA: ' + con);
		system.debug('GENDER LIST: ' + validGenderList);
		system.debug('COUNTRY LIST: ' + validEnglishMailingCountryList);
		system.debug('LANGUAGE LIST: ' + validLanguageList);
		system.debug('DEFAULTS: ' + defaultValueMap);
		Boolean contactCleansed = false;
		String cleanMessage = 'Contact Data Cleansed:';

		if (con.Gender__c == null || !validGenderList.contains(con.Gender__c)) {
			String defValue = defaultValueMap.get('Gender');
			String cleanMsg = ' GENDER changed from ' + con.Gender__c + ' to ' + defValue + '.';
			logger.log(cleanMsg);
			system.debug(cleanMsg);
			if (con.Gender__c != null) {
				contactCleansed = true;
				cleanMessage += cleanMsg;
			}
			con.Gender__c = defValue;
		}
		if (con.Mailing_Country_In_English__c == null || !validEnglishMailingCountryList.contains(con.Mailing_Country_In_English__c)) {
			String defValue = defaultValueMap.get('Country');
			String cleanMsg = ' MAIL COUNTRY IN ENGLISH changed from ' + con.Mailing_Country_In_English__c + ' to ' + defValue + '.';
			logger.log(cleanMsg);
			system.debug(cleanMsg);
			if (con.Mailing_Country_In_English__c != null) {
				contactCleansed = true;
				cleanMessage += cleanMsg;
			}
			con.Mailing_Country_In_English__c = defValue;
		}
		if (con.Preferred_language_of_communication__c == null || !validLanguageList.contains(con.Preferred_language_of_communication__c)) {
			String newLanguage;
			if (String.isNotBlank(villageCode) && villageLanguageMap.containsKey(villageCode)) {
				newLanguage = villageLanguageMap.get(villageCode);
			} else {
				newLanguage = defaultValueMap.get('Language');
			}
			String cleanMsg = ' PREFERRED LANGUAGE changed from ' + con.Preferred_language_of_communication__c + ' to ' + newLanguage + '.';
			logger.log(cleanMsg);
			system.debug(cleanMsg);
			if (con.Preferred_language_of_communication__c != null) {
				contactCleansed = true;
				cleanMessage += cleanMsg;
			}
			con.Preferred_language_of_communication__c = newLanguage;
		}
		if (con.Nationality_Picklist__c == null || !validNationalityList.contains(con.Nationality_Picklist__c)) {
			String defValue = defaultValueMap.get('Nationality');
			String cleanMsg = ' NATIONALITY changed from ' + con.Nationality_Picklist__c + ' to ' + defValue + '.';
			logger.log(cleanMsg);
			system.debug(cleanMsg);
			if (con.Nationality_Picklist__c != null) {
				contactCleansed = true;
				cleanMessage += cleanMsg;
			}
			con.Nationality_Picklist__c = defValue;
		}

		logger.log('DATA CLEANSED: ' + contactCleansed);
		system.debug('DATA CLEANSED: ' + contactCleansed);

		if (contactCleansed) {
			resultDTO.Status = 'Cleansed';
			if (String.isBlank(resultDTO.Message)) {
				resultDTO.Message = cleanMessage;
			} else {
				resultDTO.Message += '; ' + cleanMessage;
			}
		}
	}
	
	/**
	 * Create Customer Activity object from incoming fields and add ref to Contact record
	 */
	private static Customer_Activity__c mapCustomerActivityFromETL(ETLContactDTO etlContactDTO, Contact con, ETLWebService_Settings__c touchpointSettings) {
		logger.log('ETLWebService: Mapping Customer Activity ' + etlContactDTO.TouchpointReference);
		system.debug('ETLWebService: Mapping Customer Activity ' + etlContactDTO.TouchpointReference);
		Customer_Activity__c custAct = new Customer_Activity__c();
		custAct.Activity_Date__c = etlContactDTO.Activity_Date;
		if (etlContactDTO.Activity_Qty != null) {
			custAct.Activity_Quantity__c = etlContactDTO.Activity_Qty;
		}
		custAct.Activity_Text__c = etlContactDTO.Activity_Text;
		custAct.Activity_Type__c = touchpointSettings.Activity_Type__c;
		if (etlContactDTO.Activity_Value != null) {
			custAct.Activity_Value__c = etlContactDTO.Activity_Value;
		}
		custAct.Touchpoint_Reference__c = etlContactDTO.TouchpointReference;
		custAct.Touchpoint_Source__c = etlContactDTO.TouchpointSource;
		custAct.Touchpoint_Type__c = etlContactDTO.TouchpointType;
		custAct.Contact_Name__c = con.Id;
		custAct.Village__c = VillageCrossReferencer.getVillageIdByCode(etlContactDTO.Village);
		if (String.isNotBlank(etlContactDTO.CampaignId) && campaignIdXref.containsKey(etlContactDTO.CampaignId)) {
			custAct.Campaign__c = campaignIdXref.get(etlContactDTO.CampaignId);
		}
		logger.log('ETLWebService: Mapped ' + custAct);
		system.debug('ETLWebService: Mapped ' + custAct);
		return custAct;
	}
	
	/**
	 * Create CampaignMember from Customer Activity fields
	 */
	private static CampaignMember mapCampaignMemberFromCustomerActivity(Customer_Activity__c caRec) {
		logger.log('ETLWebService: Mapping Campaign Member ' + caRec.Touchpoint_Reference__c);
		system.debug('ETLWebService: Mapping Campaign Member ' + caRec.Touchpoint_Reference__c);
		CampaignMember cm = new CampaignMember();
		cm.CampaignId = caRec.Campaign__c;
		cm.ContactId = caRec.Contact_Name__c;
		logger.log('ETLWebService: Mapped ' + cm);
		system.debug('ETLWebService: Mapped ' + cm);
		return cm;
	}
	
	/**
	 * Return single "it's all gone tits up" message
	 */
	private static List<ETLContactResultDTO> totalDeathMessage(Exception e) {
		logger.log('ETLWebService: FATAL ERROR');
		logger.log('EXCEPTION: ' + e);
		system.debug('ETLWebService: FATAL ERROR');
		system.debug('EXCEPTION: ' + e);
		ETLContactResultDTO thisResult = new ETLContactResultDTO();
		thisResult.Result = 'Failed';
		thisResult.Status = 'System Error';
		thisResult.Message = 'FATAL ERROR: ' + e.getMessage();
		List<ETLContactResultDTO> resList = new List<ETLContactResultDTO> {thisResult};
		logger.commitLog();
		return resList;
	}
	
	/**
	 * Set up default values and validation maps
	 */
	private static void buildFieldValuesAndDefault(Schema.DescribeFieldResult dfr, Set<String> validValues, String defaultValueKey, Map<String, String> defValMap) {
		List<Schema.PicklistEntry> pleList = dfr.getPicklistValues();
		for (Schema.PicklistEntry spe : pleList) {
			String tempValue = spe.getValue();
			if (spe.isDefaultValue()) {
				defValMap.put(defaultValueKey, tempValue);
			}
			validValues.add(tempValue);
		}
		system.debug('PICKLIST VALUES: ' + validValues);
		system.debug('DEFAULT VALUE: ' + defValMap);
	}
	
	/**
	 * Run through incoming list and check for existing duplicates
	 * Build dupeMaps for Contacts and Customer Activities
	 */
	private static void buildDuplicateMaps(List<ETLContactDTO> dtoList, Map<String, List<Contact>> dupeMap, Map<String, List<Customer_Activity__c>> dupeActivityMap) {
		Set<String> emailSet = new Set<String>();
		Set<String> tpRefSet = new Set<String>();
		for (ETLContactDTO dto : dtoList){
			if (String.isNotBlank(dto.EmailAddress)) {
				emailSet.add(dto.EmailAddress);
			}
			tpRefSet.add(dto.TouchpointReference);
		}
		
		List<Contact> dupeContactList = [SELECT Id, LastName, FirstName, Email, Account.Name, Account.Id,
										 AccountId, Gender__c, Birthdate,
    									 I_am_18_years_old_or_more__c, HasOptedOutOfEmail, Mobile_Opt_Out__c,
    									 Postal_Opt_Out__c, Other_Village_Partner_Opt_Out__c, Profiling_Opt_Out__c,
    									 Mailing_Country_In_English__c, Preferred_language_of_communication__c,
    									 Nationality__c, MailingStreet, MailingCity, MailingState, MailingCountry,
    									 MailingPostalCode, MobilePhone, RecordTypeId, LeadSource, Lead_Source_Text__c,
    									 Original_Creation_Date__c, B2C_Password__c
    									 FROM Contact WHERE Email IN :emailSet];
		for (Contact dc : dupeContactList) {
			String dupeMapKey = dc.Email + '*' + dc.AccountId;
			List<Contact> dupeList;
			if (dupeMap.containsKey(dupeMapKey)) {
				dupeList = dupeMap.get(dupeMapKey);
				dupeList.add(dc);
			} else {
				dupeList = new List<Contact> {dc};
				dupeMap.put(dupeMapKey, dupeList);
			}
		}
		
		List<Customer_Activity__c> dupeActList = [SELECT Id, Contact_Name__c, Touchpoint_Reference__c, Activity_Date__c
												  FROM Customer_Activity__c
												  WHERE Touchpoint_Reference__c IN :tpRefSet];
		for (Customer_Activity__c ca : dupeActList) {
			List<Customer_Activity__c> dupeList;
			if (dupeActivityMap.containsKey(ca.Touchpoint_Reference__c)) {
				dupeList = dupeActivityMap.get(ca.Touchpoint_Reference__c);
				dupeList.add(ca);
			} else {
				dupeList = new List<Customer_Activity__c> {ca};
				dupeActivityMap.put(ca.Touchpoint_Reference__c, dupeList);
			}
		}
	}
	
	/**
	 * Check if incoming record has any duplicates
	 */
	private static ContactDataValidator.ValidationResult checkForDuplicates(Contact con, Map<String, List<Contact>> dupeMap) {
		ContactDataValidator.ValidationResult vr;
		if (con.Email != null && con.AccountId != null) {
			String checkKeyValue = con.Email.toLowerCase() + '*' + con.AccountId;
			if (dupeMap.containsKey(checkKeyValue)) {
				vr = new ContactDataValidator.ValidationResult(false, 'Duplicate contacts found', dupeMap.get(checkKeyValue));
			} else {
				vr = new ContactDataValidator.ValidationResult(true, null);
			}
		} else {
			vr = new ContactDataValidator.ValidationResult(true, null);
		}
		return vr;
	}
	
	/**
	 * Check if incoming record has any duplicate Customer Activity records
	 */
	private static Boolean allowCustomerActivityInsert(Customer_Activity__c activity, Map<String, List<Customer_Activity__c>> dupeActMap, ETLWebService_Settings__c touchpointSettings) {
		Boolean allow = true;
		if (touchpointSettings.Allow_Duplicate_Activity_Records__c && touchpointSettings.Allow_Multiple_Activities_Per_Day__c) {
			system.debug('ALL DUPLICATE CUSTOMER ACTIVITIES ALLOWED');
			return allow;
		}
		if (activity.Activity_Date__c == null || activity.Contact_Name__c == null) {
			system.debug('INCOMING ACTIVITY HAS NO DATE OR CONTACT');
			return allow;
		}
		String tpRef = activity.Touchpoint_Reference__c;
		if (dupeActMap.containsKey(tpRef)) {
			List<Customer_Activity__c> possibleDupes = dupeActMap.get(tpRef);
			system.debug('POSSIBLE DUPLICATE ACTIVITY - REF: ' + tpRef + ', LIST: ' + possibleDupes);
			system.debug('ACTIVITY: ' + activity);
			for (Customer_Activity__c dupe : possibleDupes) {
				if (activity.Contact_Name__c == dupe.Contact_Name__c && activity.Activity_Date__c.date() == dupe.Activity_Date__c.date()) {
					if (!touchpointSettings.Allow_Multiple_Activities_Per_Day__c) {
						system.debug('MATCHED ON DAY: ' + tpRef);
						allow = false;
						break;
					}
					if (!touchpointSettings.Allow_Duplicate_Activity_Records__c && activity.Activity_Date__c.format('dd/MM/yyyy HH:mm:ss') == dupe.Activity_Date__c.format('dd/MM/yyyy HH:mm:ss')) {
						system.debug('MATCHED ON DATE TIME: ' + tpRef);
						allow = false;
						break;
					}
				}
			}
		}
		system.debug('ALLOW CUSTOMER ACTIVITY INSERT: ' + allow);
		return allow;
	}
}