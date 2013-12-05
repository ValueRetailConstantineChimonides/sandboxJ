public without sharing class PickListValidator {
	private Map<String, Set<String>> validValuesMap;
	
	public PickListValidator() {
		validValuesMap = new Map<String, Set<String>>();
	}
	
	/**
	 * Retrieve valid values map
	 */
	public Map<String, Set<String>> getValidValuesMap(){
		if (validValuesMap == null) {
			validValuesMap = new Map<String, Set<String>>();
		}
		return validValuesMap;
	}
	
	/**
	 * Create validation set for specified Picklist
	 */
	public void buildFieldValueMaps(String mapKey, Schema.DescribeFieldResult dfr) {
		if (!validValuesMap.containsKey(mapKey)) {
			Set<String> validationSet = new Set<String>();
			List<Schema.PicklistEntry> pleList = dfr.getPicklistValues();
			for (Schema.PicklistEntry spe : pleList) {
				String tempValue = spe.getValue();
				validationSet.add(tempValue);
			}
			system.debug('Built ' + mapKey + ' Validation Set: ' + validationSet);
			validValuesMap.put(mapKey, validationSet);
		}
	}
	
	/**
	 * Check value is valid for PickList
	 */
	public Boolean isValidPickListValue(String mapKey, String checkValue) {
		Boolean result = true;
		Set<String> checkSet = validValuesMap.get(mapKey);

		if (!(checkSet.contains(checkValue))) {
			result = false;
		}
		return result;
	}
}