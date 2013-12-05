trigger WebServiceSendEmailToCampaignMember on CampaignMember (after insert) {
	
	Set<Id> CampMemIds = new Set<Id>();
	
	for(CampaignMember campmem: Trigger.new){
		//CampMemIds.add(campmem.CampaignId);
		CampMemIds.add(campmem.Id);
	}
	
    // developer note: is there any point in this code???
	for(CampaignMember campmem: [select Id, Status, CampaignId, ContactId from CampaignMember where Id in: CampMemIds]){
		
	/*	if(campmem.Status == 'Responded') {	
				if(campmem.CampaignId == '701T0000000BKui'){
					TestExactTargetService3.callwebservicetosendmail('3767563', campmem.ContactId); 
				}
				else if(campmem.CampaignId == '701T0000000BKvA'){
					TestExactTargetService3.callwebservicetosendmail('3767561', campmem.ContactId);
				}
				else if(campmem.CampaignId == '701T0000000BKv5'){
					TestExactTargetService3.callwebservicetosendmail('3767564', campmem.ContactId);
				}
				else if(campmem.CampaignId == '701T0000000BKtf'){
					TestExactTargetService3.callwebservicetosendmail('3767566', campmem.ContactId);
				}
				else if(campmem.CampaignId == '701T0000000BKvK'){
					TestExactTargetService3.callwebservicetosendmail('3767568', campmem.ContactId);
				}
				else if(campmem.CampaignId == '701T0000000BKuj'){
					TestExactTargetService3.callwebservicetosendmail('3767569', campmem.ContactId);
				}
				else if(campmem.CampaignId == '701T0000000BKvP'){
					TestExactTargetService3.callwebservicetosendmail('3767574', campmem.ContactId);
				}
				else if(campmem.CampaignId == '701T0000000BKv6'){
					TestExactTargetService3.callwebservicetosendmail('3767578', campmem.ContactId);
				}	
			}
			
		*/	
			/*
			
			if(campmem.CampaignId == '70120000000N46x'){
				TestExactTargetService3.callwebservicetosendmail('3796949', campmem.ContactId); 
			}
			else if(campmem.CampaignId == '70120000000N46s'){
				TestExactTargetService3.callwebservicetosendmail('3796945', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N46n'){
				TestExactTargetService3.callwebservicetosendmail('3797909', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N4E9'){
				TestExactTargetService3.callwebservicetosendmail('3797913', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N46i'){
				TestExactTargetService3.callwebservicetosendmail('3797378', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N4E4'){
				TestExactTargetService3.callwebservicetosendmail('3797902', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N477'){
				TestExactTargetService3.callwebservicetosendmail('3797331', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N47C'){
				TestExactTargetService3.callwebservicetosendmail('3797330', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N47H'){
				TestExactTargetService3.callwebservicetosendmail('3797335', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N49T'){
				TestExactTargetService3.callwebservicetosendmail('3797327', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N49d'){
				TestExactTargetService3.callwebservicetosendmail('3796103', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N49Y'){
				TestExactTargetService3.callwebservicetosendmail('3795630', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N4AC'){
				TestExactTargetService3.callwebservicetosendmail('3797905', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N4AH'){
				TestExactTargetService3.callwebservicetosendmail('3797911', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N4A2'){
				TestExactTargetService3.callwebservicetosendmail('3797908', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N4AM'){
				TestExactTargetService3.callwebservicetosendmail('3797912', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N49i'){
				TestExactTargetService3.callwebservicetosendmail('3798076', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N49n'){
				TestExactTargetService3.callwebservicetosendmail('3798530', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N4AW'){
				TestExactTargetService3.callwebservicetosendmail('3802932', campmem.ContactId);
			}
			else if(campmem.CampaignId == '70120000000N4Ag'){
				TestExactTargetService3.callwebservicetosendmail('3796186', campmem.ContactId);
			}
		*/	
			
			// developer note: this is likely to fail if there are more than 10 campaign members.
			//                 ideally the email request should be batched and sent into via a single callout  
			//                 [Total number of callouts (HTTP requests or Web services calls) in a transaction]
			
			//                 Also, what happens if there is an error?  How is the user/adminstrator notified?     
			
	        // ensure that the campaign id matches the same number of characters in the Campaign Map 
			string campaignMemberCampaignId = (campmem.CampaignId != null) ? string.valueOf(campmem.CampaignId).substring(0, 15) : campmem.CampaignId;
			String emailId = CampaignExactTargetMapping.CAMPAIGN_MAP.get(campaignMemberCampaignId);
			if (emailId != null) {
				TestExactTargetService3.callwebservicetosendmail(emailId, campmem.ContactId);	
			}  
			
			
	}


}