/**
    DO NOT USE METHODS OF THIS CLASS IN PRODUCTION CODE
    CLASS DESIGNED TO BE USED IN UNIT TESTING ONLY
    
    helper to enable/disable Validation rules during Unit Tests
*/
public without sharing class UnitTestUtils {
    public static void setApexOffFlag(Boolean val) {
        setApexOffFlag(UserInfo.getUserId(), val);    
    }
    public static void setApexOffFlag(Id userId, Boolean val) {
        update new User(Id=userId, Apex_Off__c = val);
        TriggerUtils.CURRENT_USER.Apex_Off__c = val;
    }

    // used for test methods to clear context valriables
    public static void clearStatics() {
		TriggerUtils.SKIP_TRIGGER_REASON.clear();
    }
    public static Map<String, RecordType> loadRecordTypes(final Set<String> sobjectTypes, final Set<String> rtApiNames) {
    	Map<String, RecordType> rtMap = new Map<String, RecordType>();
    	for (RecordType rt : [Select Id, SobjectType, Name, DeveloperName  From RecordType 
    							where SobjectType in: sobjectTypes and DeveloperName in: rtApiNames ]) {
    		rtMap.put(rt.DeveloperName, rt);						
    	}
    	return rtMap;
    }    
}