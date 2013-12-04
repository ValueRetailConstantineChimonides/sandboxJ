@isTest
private class TestExactTarget {

    static testMethod void myUnitTest() {    	
    
	List<CampaignMember> CampaignMemberList = new List<CampaignMember>();

	Integer count = 1;

    for(Contact contact :[select c.Id from Contact c where c.RecordType.Name =: 'B2C' and c.RecordType.SobjectType =: 'Contact' limit 3]){
   	/////////////////Add-Hoc references..Still have the sandbox ids...need to change to live ids//////////////////////////////////////////////
/*    	if(count == 1){
	    Campaign camp = [select Id from Campaign where Id =: '701T0000000BKui'limit 1];	
	    CampaignMember campMem = new CampaignMember();
		campMem.CampaignId = camp.Id;
		campMem.ContactId = contact.Id;
		campMem.Status = 'Responded';
		CampaignMemberList.add(campMem);
		count = 2;
    	}
    	
		else if(count == 2){
		Campaign camp2 = [select Id from Campaign where Id =: '701T0000000BKvA' limit 1];	
	    CampaignMember campMem2 = new CampaignMember();
		campMem2.CampaignId = camp2.Id;
		campMem2.ContactId = contact.Id;
		campMem2.Status = 'Responded';
		CampaignMemberList.add(campMem2);
		count = 3;
    	} 
    	
		else if(count == 3){
		Campaign camp3 = [select Id from Campaign where Id =: '701T0000000BKv5' limit 1];	
	    CampaignMember campMem3 = new CampaignMember();
		campMem3.CampaignId = camp3.Id;
		campMem3.ContactId = contact.Id;
		campMem3.Status = 'Responded';
		CampaignMemberList.add(campMem3);
		count = 4;
    	}
		else if(count == 4){
		Campaign camp4 = [select Id from Campaign where Id =: '701T0000000BKtf' limit 1];	
	    CampaignMember campMem4 = new CampaignMember();
		campMem4.CampaignId = camp4.Id;
		campMem4.ContactId = contact.Id;
		campMem4.Status = 'Responded';
		CampaignMemberList.add(campMem4);
		count = 5;
    	}
		else if(count == 5){
		Campaign camp5 = [select Id from Campaign where Id =: '701T0000000BKvK' limit 1];	
	    CampaignMember campMem5 = new CampaignMember();
		campMem5.CampaignId = camp5.Id;
		campMem5.ContactId = contact.Id;
		campMem5.Status = 'Responded';
		CampaignMemberList.add(campMem5);
		count = 6;
    	}
		else if(count == 6){
		Campaign camp6 = [select Id from Campaign where Id =: '701T0000000BKuj' limit 1];	
	    CampaignMember campMem6 = new CampaignMember();
		campMem6.CampaignId = camp6.Id;
		campMem6.ContactId = contact.Id;
		campMem6.Status = 'Responded';
		CampaignMemberList.add(campMem6);
		count = 7;
    	}
		else if(count == 7){
		Campaign camp7 = [select Id from Campaign where Id =: '701T0000000BKv6' limit 1];	
	    CampaignMember campMem7 = new CampaignMember();
		campMem7.CampaignId = camp7.Id;
		campMem7.ContactId = contact.Id;
		campMem7.Status = 'Responded';
		CampaignMemberList.add(campMem7);
		count = 8;
    	}     */
 ///////////////////////////////////////////Web Survey References/////////////////////////////////////////////////////////////////
 
    	
		if(count == 1){
		Campaign camp8 = [select Id from Campaign where Id =: '70120000000N46x' limit 1];	
	    CampaignMember campMem8 = new CampaignMember();
		campMem8.CampaignId = camp8.Id;
		campMem8.ContactId = contact.Id;
		campMem8.Status = 'Responded';
		CampaignMemberList.add(campMem8);
		count = 2;
    	}
		else if(count == 2){
		Campaign camp9 = [select Id from Campaign where Id =: '70120000000N46s' limit 1];	
	    CampaignMember campMem9 = new CampaignMember();
		campMem9.CampaignId = camp9.Id;
		campMem9.ContactId = contact.Id;
		campMem9.Status = 'Responded';
		CampaignMemberList.add(campMem9);
		count = 3;
    	}
		else if(count == 3){
		Campaign camp10 = [select Id from Campaign where Id =: '70120000000N46n' limit 1];	
	    CampaignMember campMem10 = new CampaignMember();
		campMem10.CampaignId = camp10.Id;
		campMem10.ContactId = contact.Id;
		campMem10.Status = 'Responded';
		CampaignMemberList.add(campMem10);
		count = 4;
    	}
    }
	insert CampaignMemberList;
	
	
	
	
	
	RecordType rectype = [select Id from RecordType where Name =: 'B2C' AND SobjectType =: 'Contact' limit 1];
	Account acc = [select Id from Account limit 1];
	
	Contact contact2 = new Contact();
	contact2.AccountId = acc.Id;
	contact2.RecordTypeId = rectype.Id;
	contact2.LastName = 'testname';
	contact2.Email = 'abcd.efgh@wigroup.com';
	contact2.Mailing_Country_In_English__c = 'India';
	contact2.Primary_Village_of_interest__c = 'La Vallée - Paris';
	contact2.Original_Creation_Date__c = date.today();
	try{
	insert contact2;
	}
	catch(exception e){}
	

    }
    

    static testMethod void myUnitTest2() {
        
    List<CampaignMember> CampaignMemberList = new List<CampaignMember>();

	Integer count = 1;
    for(Contact contact :[select c.Id from Contact c where c.RecordType.Name =: 'B2C' and c.RecordType.SobjectType =: 'Contact' limit 21]){
    	count++;
		if(count == 4){
		Campaign camp11 = [select Id from Campaign where Id =: '70120000000N4E9'  or Id =: '701T0000000BKu8'limit 1];	
	    CampaignMember campMem11 = new CampaignMember();
		campMem11.CampaignId = camp11.Id;
		campMem11.ContactId = contact.Id;
		campMem11.Status = 'Responded';
		CampaignMemberList.add(campMem11);
		count = 5;
    	}
		else if(count == 5){
		Campaign camp12 = [select Id from Campaign where Id =: '70120000000N46i' limit 1];	
	    CampaignMember campMem12 = new CampaignMember();
		campMem12.CampaignId = camp12.Id;
		campMem12.ContactId = contact.Id;
		campMem12.Status = 'Responded';
		CampaignMemberList.add(campMem12);
		count = 6;
    	}
		else if(count == 6){
		Campaign camp13 = [select Id from Campaign where Id =: '70120000000N4E4' or Id =: '701T0000000BKur'limit 1];	
	    CampaignMember campMem13 = new CampaignMember();
		campMem13.CampaignId = camp13.Id;
		campMem13.ContactId = contact.Id;
		campMem13.Status = 'Responded';
		CampaignMemberList.add(campMem13);
		count = 7;
    	}
		else if(count == 7){
		Campaign camp14 = [select Id from Campaign where Id =: '70120000000N477' limit 1];	
	    CampaignMember campMem14 = new CampaignMember();
		campMem14.CampaignId = camp14.Id;
		campMem14.ContactId = contact.Id;
		campMem14.Status = 'Responded';
		CampaignMemberList.add(campMem14);
		count = 8;
    	}
		else if(count == 8){
		Campaign camp15 = [select Id from Campaign where Id =: '70120000000N47C' or Id =: '701T0000000BKu2' limit 1];	
	    CampaignMember campMem15 = new CampaignMember();
		campMem15.CampaignId = camp15.Id;
		campMem15.ContactId = contact.Id;
		campMem15.Status = 'Responded';
		CampaignMemberList.add(campMem15);
		count = 9;
    	}
		else if(count == 9){
		Campaign camp16 = [select Id from Campaign where Id =: '70120000000N47H' limit 1];	
	    CampaignMember campMem16 = new CampaignMember();
		campMem16.CampaignId = camp16.Id;
		campMem16.ContactId = contact.Id;
		campMem16.Status = 'Responded';
		CampaignMemberList.add(campMem16);
		count = 10;
    	}
		else if(count == 10){
		Campaign camp17 = [select Id from Campaign where Id =: '70120000000N49T' or Id =: '701T0000000BKuC' limit 1];	
	    CampaignMember campMem17 = new CampaignMember();
		campMem17.CampaignId = camp17.Id;
		campMem17.ContactId = contact.Id;
		campMem17.Status = 'Responded';
		CampaignMemberList.add(campMem17);
		count = 11;
    	}
		else if(count == 11){
		Campaign camp18 = [select Id from Campaign where Id =: '70120000000N49d' limit 1];	
	    CampaignMember campMem18 = new CampaignMember();
		campMem18.CampaignId = camp18.Id;
		campMem18.ContactId = contact.Id;
		campMem18.Status = 'Responded';
		CampaignMemberList.add(campMem18);
		count = 12;
    	}
		else if(count == 12){
		Campaign camp19 = [select Id from Campaign where Id =: '70120000000N49Y' or Id =: '701T0000000BKuM' limit 1];	
	    CampaignMember campMem19 = new CampaignMember();
		campMem19.CampaignId = camp19.Id;
		campMem19.ContactId = contact.Id;
		campMem19.Status = 'Responded';
		CampaignMemberList.add(campMem19);
		count = 13;
    	}
		else if(count == 13){
		Campaign camp20 = [select Id from Campaign where Id =: '70120000000N4AC' limit 1];	
	    CampaignMember campMem20 = new CampaignMember();
		campMem20.CampaignId = camp20.Id;
		campMem20.ContactId = contact.Id;
		campMem20.Status = 'Responded';
		CampaignMemberList.add(campMem20);
		count = 14;
    	}
		else if(count == 14){
		Campaign camp21 = [select Id from Campaign where Id =: '70120000000N4AH' or Id =: '701T0000000BKub' limit 1];	
	    CampaignMember campMem21 = new CampaignMember();
		campMem21.CampaignId = camp21.Id;
		campMem21.ContactId = contact.Id;
		campMem21.Status = 'Responded';
		CampaignMemberList.add(campMem21);
		count = 15;
    	}
    }
	insert CampaignMemberList; 
        
        
    }
    
    
    static testMethod void myUnitTest3() {
        
    List<CampaignMember> CampaignMemberList = new List<CampaignMember>();

	Integer count = 1;
    for(Contact contact :[select c.Id from Contact c where c.RecordType.Name =: 'B2C' and c.RecordType.SobjectType =: 'Contact' limit 28]){
    	count++;
		if(count == 15){
		Campaign camp22 = [select Id from Campaign where Id =: '70120000000N4A2' or Id =:'701T0000000BKug' limit 1];	
	    CampaignMember campMem22 = new CampaignMember();
		campMem22.CampaignId = camp22.Id;
		campMem22.ContactId = contact.Id;
		campMem22.Status = 'Responded';
		CampaignMemberList.add(campMem22);
		count = 16;
    	}
		else if(count == 16){
		Campaign camp23 = [select Id from Campaign where Id =: '70120000000N4AM' limit 1];	
	    CampaignMember campMem23 = new CampaignMember();
		campMem23.CampaignId = camp23.Id;
		campMem23.ContactId = contact.Id;
		campMem23.Status = 'Responded';
		CampaignMemberList.add(campMem23);
		count = 17;
    	}
		else if(count == 17){
		Campaign camp24 = [select Id from Campaign where Id =: '70120000000N49i' or Id =:'701T0000000BKul' limit 1];	
	    CampaignMember campMem24 = new CampaignMember();
		campMem24.CampaignId = camp24.Id;
		campMem24.ContactId = contact.Id;
		campMem24.Status = 'Responded';
		CampaignMemberList.add(campMem24);
		count = 18;
    	}
		else if(count == 18){
		Campaign camp25 = [select Id from Campaign where Id =: '70120000000N49n' limit 1];	
	    CampaignMember campMem25 = new CampaignMember();
		campMem25.CampaignId = camp25.Id;
		campMem25.ContactId = contact.Id;
		campMem25.Status = 'Responded';
		CampaignMemberList.add(campMem25);
		count = 19;
    	}
		else if(count == 19){
		Campaign camp26 = [select Id from Campaign where Id =: '70120000000N4AW' or Id =: '701T0000000BKuq' limit 1];	
	    CampaignMember campMem26 = new CampaignMember();
		campMem26.CampaignId = camp26.Id;
		campMem26.ContactId = contact.Id;
		campMem26.Status = 'Responded';
		CampaignMemberList.add(campMem26);
		count = 20;
    	}
		else if(count == 20){
		Campaign camp27 = [select Id from Campaign where Id =: '70120000000N4Ag' limit 1];	
	    CampaignMember campMem27 = new CampaignMember();
		campMem27.CampaignId = camp27.Id;
		campMem27.ContactId = contact.Id;
		campMem27.Status = 'Responded';
		CampaignMemberList.add(campMem27);		
		count = 21;
    	}
    	
    /*	
		else if(count == 28){
		Campaign camp28 = [select Id from Campaign where Id =: '701T0000000BKvP' limit 1];	
	    CampaignMember campMem28 = new CampaignMember();
		campMem28.CampaignId = camp28.Id;
		campMem28.ContactId = contact.Id;
		campMem28.Status = 'Responded';
		CampaignMemberList.add(campMem28);
		}     */
    }
	insert CampaignMemberList; 
        
        
    }  
}