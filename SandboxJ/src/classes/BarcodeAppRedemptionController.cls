public with sharing class BarcodeAppRedemptionController {
    public String cmid {get; private set;}
    private String cmsfid;
    public CampaignMember cm {get; private set;}
    public Contact contact {get; private set;}
    public List<Customer_Activity__c> recentActivityList {get; private set;}
    public Boolean over18 {get; set;}
    public Boolean optIn {get; set;}
    public Boolean renderOptIn {get; private set;}
    public Boolean mandatoryOver18 {get; private set;}
    public Decimal monoRedemptionCount {get; set;}
    public Boolean isValidCampaign {get; private set;}
    private Boolean redemptionProcessed;
    
    public BarcodeAppRedemptionController() {
        cmid = ApexPages.currentPage().getParameters().get('cmid');
        cmsfid = ApexPages.currentPage().getParameters().get('cmsfid');
        refresh();
    }
    
    /**
     * Return to Barcode Scanner screen
     */
    public PageReference back() {
        return Page.BarcodeAppScan;
    }
    
    /**
     * Boolean for whether mono contact section should render
     */
    public Boolean getRenderMonoContact() {
        if (cm.Mono_Contact__c == 'True') {
            return true;
        }
        return false;
    }
    
    /**
     * Logic for whether the Process Redemption button should be enabled
     */
    public Boolean getEnableRedeemButton() {
        system.debug('ENABLE REDEEM BUTTON: isValidCampaign (' + isValidCampaign + '), redemptionProcessed (' + redemptionProcessed + '), Campaign_Member_Redemption_Count (' + cm.Campaign.Campaign_Member_Redemption_Count__c + '), RedemptionCount (' + cm.Redemption_Count__c + ')');
        if (isValidCampaign && !redemptionProcessed && cm.Campaign.Campaign_Member_Redemption_Count__c > 0 && 
                (cm.Redemption_Count__c == null || cm.Redemption_Count__c < cm.Campaign.Campaign_Member_Redemption_Count__c)) {
            system.debug('ENABLE REDEEM BUTTON: over18 (' + over18 + '), cm.Mono_Contact__c (' + cm.Mono_Contact__c + '), renderOptIn (' + renderOptIn + '), optIn (' + optIn + ')');
            if (!mandatoryOver18 || over18 || cm.Mono_Contact__c == 'True') {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Logic for whether the Print Labels button should be enabled
     */
    public Boolean getEnablePrintLabels() {
        system.debug('ENABLE PRINT BUTTON: isValidCampaign (' + isValidCampaign + '), redemptionProcessed (' + redemptionProcessed + '), Campaign_Member_Redemption_Count (' + cm.Campaign.Campaign_Member_Redemption_Count__c + '), RedemptionCount (' + cm.Redemption_Count__c + ')');
        if (isValidCampaign && cm.Campaign.Campaign_Member_Redemption_Count__c > 0 && 
                (cm.Redemption_Count__c != null && cm.Redemption_Count__c > 0)) {
            system.debug('ENABLE PRINT BUTTON: over18 (' + over18 + '), cm.Mono_Contact__c (' + cm.Mono_Contact__c + '), renderOptIn (' + renderOptIn + '), optIn (' + optIn + ')');
            if ((!mandatoryOver18 || over18 || cm.Mono_Contact__c == 'True') && (!renderOptIn || (renderOptIn && optIn))) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Redemption Processing logic
     */
    public void processRedemption() {
        if (getEnableRedeemButton()) {
            Decimal countToUpdate = 1;
            Decimal existingCount;
            if (monoRedemptionCount != null && monoRedemptionCount > 0) {
                countToUpdate = monoRedemptionCount; 
            }
            if (cm.Redemption_Count__c == null) {
                existingCount = 0;
            } else {
                existingCount = cm.Redemption_Count__c; 
            }
            Decimal totalCount = countToUpdate + existingCount;
            if (totalCount > cm.Campaign.Campaign_Member_Redemption_Count__c) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to process - requested redemptions exceeds maximum allowed for campaign'));
            } else {
                if (cm.Redemption_Count__c == null) {
                    cm.Redemption_Count__c = countToUpdate;
                } else {
                    cm.Redemption_Count__c += countToUpdate;
                }
                cm.Status = 'Responded';
                update cm;

                if (!(cm.Mono_Contact__c == 'True')) {
                    updateContact();
            
                    Id userId = UserInfo.getUserId();
                    User thisUser = [SELECT Id, Campaign_Village__c FROM User WHERE Id = :userId];
                    List<String> villageList = thisUser.Campaign_Village__c.split(';');
                    Id villageId = VillageCrossReferencer.getVillageId(villageList);

                    Customer_Activity__c ca = new Customer_Activity__c(Activity_Date__c = system.now(), Activity_Quantity__c = 1, 
                                                                       Activity_Text__c = 'Redemption Performed', Activity_Type__c = 'Visitor', 
                                                                       Campaign__c = cm.Campaign.Id, Contact_Name__c = cm.Contact.Id, 
                                                                       Touchpoint_Type__c = 'Barcode Application', Village__c = villageId);
                    insert ca;
                    checkRedemptionCount();
                }
                redemptionProcessed = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Redemption Processed!'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please ensure all required fields are filled in to perform redemption'));
        }
    }
    
    /**
     * Refresh the contact data on the screen (for when it has been updated elsewhere)
     */
    public void refresh() {
        renderOptIn = false;
        redemptionProcessed = false;
        mandatoryOver18 = false;
        String queryString  = 'SELECT Id, CM_Unique_ID__c, Redemption_Count__c,Contact.Salutation, Contact.LastName,Contact.Id,';
               queryString += ' Contact.FirstName, Contact.Email, Contact.MobilePhone, Contact.MailingPostalCode, Contact.MailingStreet,';
               queryString += ' Contact.MailingCity, Contact.MailingCountry, Campaign.B2C_Campaign_ID__c, Campaign.Name,';
               queryString += ' Campaign.Campaign_Member_Redemption_Count__c, Campaign.StartDate, Campaign.EndDate, Campaign.IsActive,';
               queryString += ' Campaign.Active_Redemption_Segments__c, Contact.Account.Id, Contact.Mailing_Country_In_English__c,';
               queryString += ' Contact.Account.Name, Contact.I_am_18_years_old_or_more__c, Contact.Profiling_Opt_Out__c, Contact.Current_Segment__c,';
               queryString += ' Mono_Contact__c';
               queryString += ' FROM CampaignMember';
        
        if (cmsfid != null && cmsfid.length() > 0) {
            queryString += ' WHERE Id = :cmsfid';
        } else {
            queryString += ' WHERE CM_Unique_ID__c = :cmid';
        }

        try {
            List<CampaignMember> cmList = Database.query(queryString);
            if (cmList == null || cmList.size() == 0) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to retrieve campaign member'));
            } else if (cmList.size() > 1) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Multiple Campaign Members found for CMID: ' + cmid));
            } else {
                cm = cmList.get(0);
                if(cmid == null) {
                    cmid = cm.CM_Unique_ID__c;
                }
                isValidCampaign = validateCampaign(cm);
                over18 = cm.Contact.I_am_18_years_old_or_more__c;
                optIn = !cm.Contact.Profiling_Opt_Out__c;
                Redemption_Config_Settings__c settings = Redemption_Config_Settings__c.getValues(cm.Contact.AccountId);
                if (cm.Mono_Contact__c == 'True') {
                    monoRedemptionCount = 1;
                } else {
                    if (settings != null) {
                        renderOptIn = settings.Opt_In_Required__c;
                        mandatoryOver18 = settings.Over_18_Required__c;
                    }
                }
                checkRedemptionCount();
                recentActivityList = [SELECT Id, Name, Activity_Date__c, Touchpoint_Type__c, Village__r.Name, Activity_Type__c,
                                      Activity_Value__c, Activity_Quantity__c, Activity_Text__c
                                      FROM Customer_Activity__c
                                      WHERE Contact_Name__c = :cm.Contact.Id
                                      ORDER BY Activity_Date__c DESC LIMIT :Properties.BARCODE_CUSTOMER_ACTIVITY_MAX_RECORDS];
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Exception retrieving data: ' + e.getMessage()));
        }
    }
    
    /**
     * Check if the contact has reached the maximum redemption count for the campaign
     */
    private void checkRedemptionCount() {
        if (cm.Redemption_Count__c != null && cm.Campaign.Campaign_Member_Redemption_Count__c != null &&
                cm.Redemption_Count__c >= cm.Campaign.Campaign_Member_Redemption_Count__c) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'Maximum number of allowed redemptions reached'));
        }
    }
    
    /**
     * Check if the selected campaign is valid
     */
    private Boolean validateCampaign(CampaignMember cm) {
        system.debug('VALIDATING CAMPAIGN MEMBER: ID: ' + cm.Id + ', ACTIVE: ' + cm.Campaign.IsActive + ', START: ' + cm.Campaign.StartDate + ', END: ' + cm.Campaign.EndDate + ', REDEEM: ' + cm.Campaign.Active_Redemption_Segments__c);
        Boolean validCampaign = true;
        Date checkDate = system.today();
        if (!cm.Campaign.IsActive) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Campaign ' + cm.Campaign.Name + ' is flagged as inactive'));
            validCampaign = false;
        }
        if (checkDate < cm.Campaign.StartDate) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Campaign ' + cm.Campaign.Name + ' does not start until ' + cm.Campaign.StartDate));
            validCampaign = false;
        }
        if (checkDate > cm.Campaign.EndDate) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Campaign ' + cm.Campaign.Name + ' ended on ' + cm.Campaign.EndDate));
            validCampaign = false;
        }
        if (!cm.Campaign.Active_Redemption_Segments__c) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Campaign ' + cm.Campaign.Name + ' does not have Active Redemption Segments set'));
            validCampaign = false;
        }
        return validCampaign;
    }
    
    /**
     * Update Salesforce Contact record
     */
    public void updateContact() {
        Contact contact = new Contact(Id = cm.Contact.Id,
                                      I_am_18_years_old_or_more__c = over18,
                                      Profiling_Opt_Out__c = !optIn);
        update contact;
    }
}