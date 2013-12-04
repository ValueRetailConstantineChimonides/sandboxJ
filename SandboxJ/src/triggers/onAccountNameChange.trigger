/*
ENG-0711-45
*/
trigger onAccountNameChange on Account (before insert, before update) {
    List<Account> accountsBatch = Trigger.new;
    Integer i=0;
    while (i < accountsBatch.size()) {
    	Account changingAccount = accountsBatch.get(i++);

    	if (changingAccount.Name == null)
    		continue;
    	String str = changingAccount.Name;
    	{//last name
    		String localNameStr = AccentCharactersMapping.replaceAccents(changingAccount.Name);
    		if (changingAccount.NameLocal <> localNameStr) {
    			changingAccount.NameLocal = localNameStr;
    			//update changingAccount;
    			System.debug('updated Account with NameLocal=' + changingAccount.NameLocal);
    		}
    	}
    		
    	{//first name
    		String localNameStr = AccentCharactersMapping.replaceAccents(changingAccount.Name);
    		if (changingAccount.NameLocal <> localNameStr) {
    			changingAccount.NameLocal = localNameStr;
    			//update changingAccount;
    			System.debug('updated Account with NameLocal=' + changingAccount.NameLocal);
    		}
    	}	
        i++;
    }
}