/**
	helper class with set of methods that may be useful in triggers
*/
public class TriggerUtils {
//load more fields (not available by default) on current user in order to minimise number of SOQL queries in Triggers to load additional user info 
	public static User CURRENT_USER = [select Id, Apex_Off__c from User where Id=:UserInfo.getUserId()];
	
	public static Map<String, String> SKIP_TRIGGER_REASON = new Map<String, String>();
	
	public static void addToSkipTriggerMap(final String triggerName, final String skipReason) {
		SKIP_TRIGGER_REASON.put(triggerName, skipReason);
	}
    public static void removeFromSkipTriggerMap(final String triggerName) {
        SKIP_TRIGGER_REASON.remove(triggerName);
    }
	
	public static Boolean skipTrigger(final String triggerName) {
		final String reason = SKIP_TRIGGER_REASON.get(triggerName);
		if (null != reason) {
			System.debug('SKIP trigger: ' + triggerName + '; REASON: ' + reason);
			return true;
		}
		return false;
	}
	///////////////////////////////////////////////////////////////////////////////
	private static testMethod void test() {
		TriggerUtils.addToSkipTriggerMap('test#', 'test reason');
		System.assert(skipTrigger('test#'));
		System.assertEquals(false, skipTrigger('another-test#'));
		removeFromSkipTriggerMap('test#');
	}
}