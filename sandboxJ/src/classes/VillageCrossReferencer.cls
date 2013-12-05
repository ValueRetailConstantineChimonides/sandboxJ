public without sharing class VillageCrossReferencer {
	public static String b2cAccountRecType = Properties.B2C_ACCOUNT_RECORD_TYPE;
	public static String cosAccountId = Properties.CHIC_OUTLET_SHOPPING_ACCOUNT_ID;
	public static String cosVillageId = Properties.CHIC_OUTLET_SHOPPING_VILLAGE_ID;
	public static Map<String, Village__c> villageNameXrefMap = getVillageMap();
	public static Map<String, Village__c> villageCodeXrefMap = getVillageCodeMap(villageNameXrefMap);
	public static Map<String, Id> accountCodeXrefMap = getVillageCodeMap();
	
	/**
	 * Construct a map of Village__c records keyed on the Village__c.Name field.
	 */
	private static Map<String, Village__c> getVillageMap() {
		Map<String, Village__c> villageNameXrefMap2 = new Map<String, Village__c>();
		List<Village__c> temp = [SELECT Id, Name, Village_Code__c FROM Village__c];
		for (Village__c v : temp) {
			villageNameXrefMap2.put(v.Name, v);
		}
		return villageNameXrefMap2;
	}
	
	/**
	 * Construct a map of Village__c records keyed on the Village__c.Villge_Code__c field.
	 */
	private static Map<String, Village__c> getVillageCodeMap(Map<String, Village__c> inMap) {
		Map<String, Village__c> villageCodeXrefMap2 = new Map<String, Village__c>();
		for (Village__c v : inMap.values()) {
			villageCodeXrefMap2.put(v.Village_Code__c, v);
		}
		return villageCodeXrefMap2;
	}

	/**
	 * Construct a map of Account Ids keyed on the two-char village code.
	 */
	private static Map<String, Id> getVillageCodeMap() {
		Map<String, Id> villageXrefMap2 = new Map<String, Id>();
		List<Account> accList = [SELECT Id, Site FROM Account WHERE Site != null AND RecordTypeId = :b2cAccountRecType];
		for (Account a : accList) {
			villageXrefMap2.put(a.Site, a.Id);
		}
		return villageXrefMap2;
	}
	
	/**
	 * Return the Id of the Village__c record with the name passed in.
	 */
	public static Id getVillageId(String inName) {
		if (villageNameXrefMap.containsKey(inName)) {
			return villageNameXrefMap.get(inName).Id;
		}
		return null;
	}
	
	/**
	 * Return the Id of the first matching Village__c record from a list of village names.
	 */
	public static Id getVillageId(List<String> villageList) {
		return getVillageId(villageList, false);
	}
	
	/**
	 * Return the Id of the first matching Village__c record from a list of village names.
	 */
	public static Id getVillageId(List<String> villageList, Boolean allowCOS) {
		Id villageId;
		for (String vString : villageList) {
			villageId = getVillageId(vString);
			if (villageId != null && (allowCOS || villageId != cosVillageId)) {
				return villageId;
			}
		}
		return null;
	}

	/**
	 * Return the Id of the Village__c record with the code passed in.
	 */
	public static Id getVillageIdByCode(String inCode) {
		if (String.isNotBlank(inCode) && villageCodeXrefMap.containsKey(inCode)) {
			return villageCodeXrefMap.get(inCode).Id;
		}
		return null;
	}

	/**
	 * Retrieve a list containing the Campaign_Village__c field values from the active user.
	 */
	private static List<String> getUserVillageList() {
		Id userId = UserInfo.getUserId();
		User thisUser = [SELECT Id, Campaign_Village__c FROM User WHERE Id = :userId];
		List<String> villageList = thisUser.Campaign_Village__c.split(';');
		return villageList;
	}
	
	/**
	 * Retrieve Village__c Name for the user's village.
	 * Only entries that have a Village__c record are valid.  Others are ignored.
	 * The first valid id is the one returned if there are more than one..
	 */
	public static String getUserVillageName() {
		return getUserVillageName(false);
	}

	/**
	 * Retrieve Village__c Name for the user's village.
	 * Only entries that have a Village__c record are valid.  Others are ignored.
	 * The first valid id is the one returned if there are more than one..
	 */
	public static String getUserVillageName(Boolean allowCOS) {
		List<String> villageList = getUserVillageList();
		for (String s : villageList) {
			if (villageNameXrefMap.containsKey(s)) {
				if (allowCOS || villageNameXrefMap.get(s).Id != cosVillageId) {
					return s;
				}
			}
		}
		return null;
	}

	/**
	 * Retrieve Village__c ID for the user's village.
	 * Only entries that have a Village__c record are valid.  Others are ignored.
	 * The first valid id is the one returned if there are more than one..
	 */
	public static Id getUserVillageId() {
		return getUserVillageId(false);
	}
	
	/**
	 * Retrieve Village__c ID for the user's village.
	 * Only entries that have a Village__c record are valid.  Others are ignored.
	 * The first valid id is the one returned if there are more than one..
	 */
	public static Id getUserVillageId(Boolean allowCOS) {
		List<String> villageList = getUserVillageList();
		Id villageId = getVillageId(villageList);
		return villageId;
	}

	/**
	 * Retrieve Account ID for the village name given.
	 * Only entries that have a Village__c record are valid
	 */
	public static Id getVillageAccountId(String inName) {
		List<String> inNames = new List<String> {inName};
		return getVillageAccountId(inNames);
	}
	
	/**
	 * Retrieve Account ID for the village names given.
	 * Only entries that have a Village__c record are valid
	 * The first valid id is the one returned if there are more than one..
	 */
	public static Id getVillageAccountId(List<String> inNames) {
		return getVillageAccountId(inNames, false);
	}
	
	/**
	 * Retrieve Account ID for the village names given.
	 * Only entries that have a Village__c record are valid
	 * The first valid id is the one returned if there are more than one..
	 */
	public static Id getVillageAccountId(List<String> inNames, Boolean allowCOS) {
		List<Account> accList = [SELECT Id, Name FROM Account WHERE Name IN :inNames];
		if (accList != null && accList.size() == 1) {
			if (allowCOS || accList.get(0).Id != cosAccountId) {
				return accList.get(0).Id;
			}
		} else if(accList.size() > 1) {
			for (Account a : accList) {
				if (villageNameXrefMap.containsKey(a.Name)) {
					if (allowCOS || a.Id != cosAccountId) {
						return a.Id;
					}
				}
			}
		}
		return null;
	}

	/**
	 * Retrieve Account ID for the user's village.
	 * Only entries that have a Village__c record are valid
	 * Others are ignored. COS IS EXCLUDED by default
	 */
	public static Id getUserVillageAccountId() {
		return getUserVillageAccountId(false);
	}

	/**
	 * Retrieve Account ID for the user's village.
	 * Only entries that have a Village__c record are valid
	 * Others are ignored. Boolean passed to Allow / Disallow COS
	 */
	public static Id getUserVillageAccountId(Boolean allowCOS) {
		List<String> villageList = getUserVillageList();
		Id accountId = getVillageAccountId(villageList, allowCOS);
		return accountId;
	}

	/**
	 * Retrieve Account ID for the two character code passed in (e.g. Bicester Village = BV)
	 * If no match is found, return null.
	 */
	public static Id getVillageAccountIdByCode(String villageCode) {
		if (String.isNotBlank(villageCode) && accountCodeXrefMap.containsKey(villageCode)) {
			return accountCodeXrefMap.get(villageCode);
		}
		return null;
	}
	
	/**
	 * Retrieve list of account id's for all the Campaign_Village__c items on the active user record.
	 * Only entries that have a Village__c record are valid (unless COS is included).
	 * Others are ignored.
	 */
	public static List<Id> getUserVillageAccountIdList(boolean includeCOS) {
		List<String> villageList = getUserVillageList();
		List<Id> outputList = new List<Id>();
		List<Account> accList = [SELECT Id, Name FROM Account WHERE Name IN :villageList];
		for (Account a : accList) {
			if (villageNameXrefMap.containsKey(a.Name) || (includeCOS && a.Id == cosAccountId)) {
				outputList.add(a.Id);
			}
		}
		return outputList;
	}
}