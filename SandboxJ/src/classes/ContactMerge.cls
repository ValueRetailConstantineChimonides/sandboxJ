global class ContactMerge
{
   WebService static String StartMerge(integer sets)
   {
   System.debug('1st hello>>>>>');
    //integer sets = 1;
    // Number of sets to process
    integer stp_limit = sets;
    // Processing completed indicator
    boolean boodone = TRUE;
    // count of sets processed
    long ic = 0; // Set to 1 to return immediately
    long cm = 0;
    long ctm = 0;
    string status = '';
    Contact[] forSet;
    string setNo = '';

   try {
    // Determine anything to process
    while (ic < stp_limit)
    {
     System.debug('2st hello>>>>>'+ic);
        // Select first set number for processing
        string sset = '';
        string saccount = '';

        forSet = [select Individual_Set__c, AccountId from Contact where Individual_Set_Processed__c = FALSE and Individual_Set__c <> '' order by Individual_Set__c asc limit 1]; //= '1000001' limit 1];//
      System.debug('3st hello>>>>>'+forset);
        if (forSet.size() > 0)
        {
            setNo = forSet[0].Individual_Set__c;
        sset = forSet[0].Individual_Set__c;
            saccount = forSet[0].AccountId;

            // Select all contacts members of sset
            Contact[] records = [select Id
            ,LastModifiedDate
            ,Original_Creation_Date__c
            ,Individual_Set__c
            ,AccountId
            ,LastName
            ,FirstName
            ,Salutation
            ,MailingStreet
            ,MailingCity
            ,MailingState
            ,MailingPostalCode
            ,MailingCountry
            ,Mailing_Country_In_English__c
            ,Phone
            ,MobilePhone
            ,Mobile_Opt_Out__c
            ,Email
            ,LeadSource
            ,BirthDate
            ,HasOptedOutOfEmail
            ,Gender__c
            ,Marital_Status__c
            ,Preferred_email_format__c
            ,Professional_activity__c
            ,Date_Last_Cleaned_Checked__c
            ,Profiling_Flag_under_hire__c
            ,Profiling_Flag_Expiry_hire_end_date__c
            ,Other_Village_Partner_Opt_Out__c
            ,Postal_Opt_Out__c
            ,Email_address_quality__c
            ,Calculated_Date_of_Birth__c
            ,Date_of_Birth_was_calculated__c
            ,Secondary_Village_s_of_interest__c
            ,Visits_to_secondary_village_s_per_annum__c
            ,Source_ID__c
            ,Age_Range__c
            ,Number_of_email_bounces__c
            ,Number_of_undelivered_mail_items__c
            ,Unique_Contact_ID_View__c
            ,CCR_TestImpID__c
            ,Language_ID__c
            ,Preferred_language_of_communication__c
            ,Primary_village_of_interest__c
            ,Brand_Registration_Lead_Source__c
            ,Primary_Household_Contact__c
            ,Duplicate_email_address__c
            ,Primary_email_address__c
            ,BadMailingAddress__c
            ,Postal_address_quality__c
            ,Lead_Source_Text__c
            ,Hard_Bounce__c
            ,Email_Inactive__c
            ,Do_you_play_sport__c
            ,What_sports_do_you_play__c
            ,Children__c
            ,Age_of_Children__c
            ,Abroad_travel_per_annum__c
            ,Preferred_holiday_destination__c
            ,Specific_occasions_to_visit_Village__c
            ,Primary_Village_visited__c
            ,Category_s_of_Interest__c
            ,Amount_willing_to_spend_in_Village__c
            ,How_Village_was_heard_about__c
            ,Method_of_transportation_to_Village__c
            ,Preferred_time_to_visit_Primary_Village__c
            ,Visits_per_annum_to_Primary_Village__c
            ,Date_of_last_visit_to_primary_village__c
            ,Date_of_first_visit_to_primary_village__c
            ,Preferred_shopping_venue_s__c
//New Fields Text
			,FirstNameLocal
			,Future_segment1__c
			,LastNameLocal
			,Where_did_you_hear_about_the_Competition__c
			,Month_of_last_visit__c
			,Year_of_last_visit__c 

//New Fields PickList           
            ,Aware_of_8_other_villages__c
            
// New Fields MPL
            ,Bicester__c
			,Fidenza__c
			,Ingolstadt__c
			,Kildare__c
			,La_Roca__c
			,La_Vallee__c
			,Las_Rozas__c
			,Maasmechelen__c
			,Wertheim__c
			
//New Fields Boolean
			,I_am_18_years_old_or_more__c
			,Never_received_postal_mailing__c
			,Profiling_Opt_Out__c
			,Web_Account_Active__c

//New Fields Dates
			,Date_of_last_visited_village__c
			,Last_Redemption_Date__c
			
//New Fields Number
			,Current_Segment__c
			,Experience_rating__c
			       

             from Contact
             where Individual_Set__c = : sset and AccountId = : saccount order by CreatedDate desc];

            ctm = records.size();
            Contact Mc = records[0];
            string MasterId = records[0].Id;

            string NewFirstName = Mc.FirstName;
            string NewLastName = Mc.LastName;
            string NewSalutation = Mc.Salutation;
            string NewMailingStreet = Mc.MailingStreet;
            string NewMailingCity = Mc.MailingCity;
            string NewMailingState = Mc.MailingState;
            string NewPostalCode = Mc.MailingPostalCode;
            string NewMailingCountry = Mc.MailingCountry;
            string NewMailingCountryEnglish = Mc.Mailing_Country_In_English__c;
            string NewPhone = Mc.Phone;
            string NewMobile = Mc.MobilePhone;
            string NewEmail = Mc.Email;
            date NewBirthDate = Mc.BirthDate;
            boolean NewEmailOptOut = Mc.HasOptedOutOfEmail;
            string Source_ID = Mc.Source_ID__c;
            string Lead_Source = Mc.LeadSource;
            string AgeRange = '';
            string NewAgeRange = Mc.Age_Range__c;
            double Number_of_email_bounces = Mc.Number_of_email_bounces__c;
            double New_Number_of_email_bounces = Mc.Number_of_email_bounces__c;
            double Number_of_undelivered_mail_items = Mc.Number_of_undelivered_mail_items__c;
            double New_Number_of_undelivered_mail_items = Mc.Number_of_undelivered_mail_items__c;
            string Unique_Contact_ID_View = Mc.Unique_Contact_ID_View__c;
            double CCR_TestImpID = Mc.CCR_TestImpID__c;
            string Language_ID = Mc.Language_ID__c;
            string NewPreferredCommLanguage = Mc.Preferred_language_of_communication__c;
            string NewBrand_Registration_Lead_Source = Mc.Brand_Registration_Lead_Source__c;
            boolean Primary_Household_Contact = Mc.Primary_Household_Contact__c;
            boolean Duplicate_email_address = Mc.Duplicate_email_address__c;
            boolean Primary_email_address = Mc.Primary_email_address__c;
            boolean BadMailingAddress = Mc.BadMailingAddress__c;
            string Postal_address_quality = Mc.Postal_address_quality__c;
            string Lead_Source_Text = Mc.Lead_Source_Text__c;
            boolean Hard_Bounce = Mc.Hard_Bounce__c;
            string Email_Inactive = Mc.Email_Inactive__c;
            string NewGender = Mc.Gender__c;
            date NewOrigCreationDate = Mc.Original_Creation_Date__c;
            string NewPrimaryVillage = Mc.Primary_village_of_interest__c;
            string NewHowVillageHeardAbout = Mc.How_village_was_heard_about__c;
            string NewWillingToSpend = Mc.Amount_willing_to_spend_in_village__c;
            string NewPreferredVisitTime = Mc.Preferred_time_to_visit_primary_village__c;
            date NewDateOfLastPrimaryVisit = Mc.Date_of_last_visit_to_primary_village__c;
            date NewDateOfFirstPrimaryVisit = Mc.Date_of_first_visit_to_primary_village__c;
            string NewTransportationMethod = Mc.Method_of_transportation_to_village__c;
            string NewPrimaryVillageVisited = Mc.Primary_Village_visited__c;
            string PrimaryVisitsPerAnnum = '';
            string NewPrimaryVisitsPerAnnum = '';
            string VisitOccasions = '';
            string COI = '';
            string SecondaryVillages = '';
            string NewSecondaryVillages = Mc.Secondary_Village_s_of_interest__c;
            string SecondaryVillageVisits = '';
            string NewSecondaryVillageVisits = Mc.Visits_to_secondary_village_s_per_annum__c;
            string NewPlaySport = Mc.Do_you_play_sport__c;
            string SportsPlayed = '';
            string HasChildren = Mc.Children__c;
            string ChildrenAges = '';
            string NewAbroadTravel;
            string AbroadTravel = '';
            string WillingToSpend = '';
            string HolidayDestinations = '';
            string ShoppingVenues = '';
            string NewShoppingVenues = Mc.Preferred_shopping_venue_s__c;
            string NewVisitOccasions = Mc.Specific_occasions_to_visit_Village__c;
            string NewCOI = Mc.Category_s_of_Interest__c;
            string NewSportsPlayed = Mc.What_sports_do_you_play__c;
            string NewChildrenAges = Mc.Age_of_Children__c;
            string NewHolidayDestinations = Mc.Preferred_holiday_destination__c;
            double NewEmailAddressQuality = Mc.Email_address_quality__c;
            boolean NewMobileOptOut = Mc.Mobile_Opt_Out__c;
            boolean NewPostalOptOut = Mc.Postal_Opt_Out__c;
            date NewCalcDateOfBirth = Mc.Calculated_Date_of_Birth__c;
            boolean NewDOBCalc = Mc.Date_of_Birth_was_calculated__c;
            boolean NewPartnerOptOut = Mc.Other_Village_Partner_Opt_Out__c;
            string NewProfilingFlag = Mc.Profiling_Flag_under_hire__c;
            date NewProfilingExpiry = Mc.Profiling_Flag_Expiry_hire_end_date__c;
            date NewDateLastCleaned = Mc.Date_Last_Cleaned_Checked__c;
            string NewProfessionalActivity = Mc.Professional_activity__c;
            string NewEmailFormat = Mc.Preferred_email_format__c;
            string NewMaritalStatus = Mc.Marital_Status__c;
            
// New Fields Text
			string NewFirstNameLocal = Mc.FirstNameLocal;
			string NewFuture_segment1 = Mc.Future_segment1__c;
			string NewLastNameLocal = Mc.LastNameLocal;
			string NewWhere_did_you_hear_about_the_Competition = Mc.Where_did_you_hear_about_the_Competition__c;
			string NewMonth_of_last_visit = Mc.Month_of_last_visit__c;
			string NewYear_of_last_visit = Mc.Year_of_last_visit__c;
			
//New Fields PickList 
			string NewAware_of_8_other_villages = Mc.Aware_of_8_other_villages__c;
			
//New Fields MPC			
			string Bicester = '';
			string Fidenza = '';
			string Ingolstadt = '';
			string Kildare = '';
			string La_Roca = '';
			string La_Vallee = '';
			string Las_Rozas = '';
			string Maasmechelen = '';
			string Wertheim = '';
			string NewBicester = Mc.Bicester__c;
			string NewFidenza = Mc.Fidenza__c;
			string NewIngolstadt = Mc.Ingolstadt__c;
			string NewKildare = Mc.Kildare__c;
			string NewLa_Roca = Mc.La_Roca__c;
			string NewLa_Vallee = Mc.La_Vallee__c;
			string NewLas_Rozas = Mc.Las_Rozas__c;
			string NewMaasmechelen = Mc.Maasmechelen__c;
			string NewWertheim = Mc.Wertheim__c;

//New Fields Boolean
			boolean NewI_am_18_years_old_or_more = Mc.I_am_18_years_old_or_more__c;
			boolean NewNever_received_postal_mailing = Mc.Never_received_postal_mailing__c;
			boolean NewProfiling_Opt_Out = Mc.Profiling_Opt_Out__c;
			boolean NewWeb_Account_Active = Mc.Web_Account_Active__c;

//New Fields Dates
			Date NewDate_of_last_visited_village = Mc.Date_of_last_visited_village__c;
			Date NewLast_Redemption_Date = Mc.Last_Redemption_Date__c;

//New Fields Number
			Double NewCurrent_Segment = Mc.Current_Segment__c;
			Double NewExperience_rating = Mc.Experience_rating__c;

// Field update loop

            for (integer i = 1; i < records.size(); ++i)
            {
                // 01 FirstName
                if (NewFirstName == null) { if (records[i].FirstName != null) { NewFirstName = records[i].FirstName; } }

                // 02 LastName
                if (NewLastName == null || NewLastName.toUpperCase() == 'ANON') { if (records[i].LastName != null) { NewLastName = records[i].LastName; } }

                // 03 Salutation
                if (NewSalutation == null) { if (records[i].Salutation != null) { NewSalutation = records[i].Salutation; } }

                // 04 Mailingstreet
                if (NewMailingStreet == null) { if (records[i].MailingStreet != null) { NewMailingStreet = records[i].MailingStreet; } }

                // 05 Mailingcity
                if (NewMailingCity == null) { if (records[i].MailingCity != null) { NewMailingCity = records[i].MailingCity; } }

                // 06 Mailingstate
                if (NewMailingState == null) { if (records[i].MailingState != null) { NewMailingState = records[i].MailingState; } }

                // 45 Postcode
                if (NewPostalCode == null) { if (records[i].MailingPostalCode != null) { NewPostalCode = records[i].MailingPostalCode; } }

                // 07 MailingCountry
                if (NewMailingCountry == null) { if (records[i].MailingCountry != null) { NewMailingCountry = records[i].MailingCountry; } }

                // 07 MailingCountryInEnglish
                if (NewMailingCountryEnglish == null) { if (records[i].Mailing_Country_In_English__c != null) { NewMailingCountryEnglish = records[i].Mailing_Country_In_English__c; } }

                // 08 Phone
                if (NewPhone == null) { if (records[i].Phone != null) { NewPhone = records[i].Phone; } }

                // 09 Mobilephone
                if (NewMobile == null) { if (records[i].MobilePhone != null) { NewMobile = records[i].MobilePhone; } }

                // 10 Email
                if (NewEmail == null) { if (records[i].Email != null) { NewEmail = records[i].Email; } }

                // 11 Email Opt Out
                if (NewEmailOptOut == FALSE) { if (records[i].HasOptedOutOfEmail == TRUE) { NewEmailOptOut = TRUE; } }

                // 12 Birthdate
                if (NewBirthDate == null) { if (records[i].BirthDate != null) { NewBirthDate = records[i].BirthDate; } }

                // 13 Gender
                if (NewGender == null) { if (records[i].Gender__c != null) { NewGender = records[i].Gender__c; } }

                // 14 Marital status
                if (NewMaritalStatus == null) { if (records[i].Marital_Status__c != null) { NewMaritalStatus = records[i].Marital_Status__c; } }

                // 15 Preferred email format
                if (NewEmailFormat == null) { if (records[i].Preferred_email_format__c != null) { NewEmailFormat = records[i].Preferred_email_format__c; } }

                // 16 Professional activity
                if (NewProfessionalActivity == null) { if (records[i].Professional_activity__c != null){ NewProfessionalActivity = records[i].Professional_activity__c; } }

                // 17 Date last cleaned
                if (NewDateLastCleaned == null) { if (records[i].Date_Last_Cleaned_Checked__c != null) { NewDateLastCleaned = records[i].Date_Last_Cleaned_Checked__c; } } else { if (NewDateLastCleaned < records[i].Date_Last_Cleaned_Checked__c && records[i].Date_Last_Cleaned_Checked__c != null) { NewDateLastCleaned = records[i].Date_Last_Cleaned_Checked__c; } }

                // 18 Profiling flag under hire
                if (NewProfilingFlag == null) { if (records[i].Profiling_Flag_under_hire__c != null) { NewProfilingFlag = records[i].Profiling_Flag_under_hire__c; } }

                // 19 Profiling flag expiry
                if (NewProfilingExpiry == null) { if (records[i].Profiling_Flag_Expiry_hire_end_date__c != null) { NewProfilingExpiry = records[i].Profiling_Flag_Expiry_hire_end_date__c; } }

                // 20 Mobile opt out
                if (NewMobileOptOut == FALSE) { if (records[i].Mobile_Opt_Out__c == TRUE) { NewMobileOptOut = records[i].Mobile_Opt_Out__c; } }

                // 21 Other village partner opt out
                if (NewPartnerOptOut == FALSE) { if (records[i].Other_Village_Partner_Opt_Out__c == TRUE) { NewPartnerOptOut = records[i].Other_Village_Partner_Opt_Out__c; } }

                // 22 Postal opt out
                if (NewPostalOptOut == FALSE) { if (records[i].Postal_Opt_Out__c == TRUE) { NewPostalOptOut = TRUE; } }

                // 23 Email address quality
                if (records[i].Email_Address_Quality__c != null) { if (NewEmailAddressQuality == null) { NewEmailAddressQuality = records[i].Email_Address_Quality__c; } else { if (records[i].Email_Address_Quality__c > NewEmailAddressQuality) { NewEmailAddressQuality = records[i].Email_Address_Quality__c; } } }

                // 24 Calculated date of birth
                if (NewCalcDateOfBirth == null)
                {
                    if (records[i].Calculated_Date_of_Birth__c != null)
                    {
                        NewCalcDateOfBirth = records[i].Calculated_Date_of_Birth__c;
                    // 25
                        if (records[i].Date_of_Birth_was_calculated__c == TRUE)
                        {
                            NewDOBCalc = TRUE;
                        }
                    }
                } else {
                    if (NewCalcDateOfBirth == records[i].Calculated_Date_of_Birth__c)
                    {
                    // 25
                        if (records[i].Date_of_Birth_was_calculated__c == TRUE)
                        {
                            NewDOBCalc = TRUE;
                        }
                    }
                }

                // 26 Original creation date
                if (NewOrigCreationDate == null) { NewOrigCreationDate = records[i].Original_Creation_Date__c; } else { if (NewOrigCreationDate > records[i].Original_Creation_Date__c) { NewOrigCreationDate = records[i].Original_Creation_Date__c; Lead_Source = records[i].LeadSource; Lead_Source_Text = records[i].Lead_Source_Text__c; } }

                // 27.1 Secondary villages
                if (records[i].Secondary_Village_s_of_interest__c != null) { SecondaryVillages += ';' + records[i].Secondary_Village_s_of_interest__c; }

                // 28.1
                if (records[i].Visits_to_secondary_village_s_per_annum__c != null) { SecondaryVillageVisits += ';' + records[i].Visits_to_secondary_village_s_per_annum__c; }

                // 29.1 Shopping venues
                if (records[i].Preferred_shopping_venue_s__c != null) { ShoppingVenues += ';' + records[i].Preferred_shopping_venue_s__c; }

                // 30.1 Visit occasions
                if (records[i].Specific_occasions_to_visit_Village__c != null) { VisitOccasions += ';' + records[i].Specific_occasions_to_visit_Village__c; }

                // 31.1 Categories of interest
                if (records[i].Category_s_of_Interest__c != null) { COI += ';' + records[i].Category_s_of_Interest__c; }

                // 32.1 Sports played
                if (records[i].What_sports_do_you_play__c != null) { SportsPlayed += ';' + records[i].What_sports_do_you_play__c; }

                // 33.1 Children ages
                if (records[i].Age_of_Children__c != null) { ChildrenAges += ';' + records[i].Age_of_Children__c; }

                // 34.1 Holiday destinations
                if (records[i].Preferred_holiday_destination__c != null) { HolidayDestinations += ';' + records[i].Preferred_holiday_destination__c; }

                // 35 Primary village of interest
                if (NewPrimaryVillage == null) { NewPrimaryVillage = records[i].Primary_village_of_interest__c; }

                // 36 How village was heard about
                if (NewHowVillageHeardAbout == null) { NewHowVillageHeardAbout = records[i].How_village_was_heard_about__c; }

                // 37.1 Amount willing to spend in primary village
  				if (records[i].Amount_willing_to_spend_in_village__c != null) { WillingToSpend += ';' + records[i].Amount_willing_to_spend_in_village__c; }

                // 38 Preferred time to visit primary village
                if (NewPreferredVisitTime == null) { NewPreferredVisitTime = records[i].Preferred_time_to_visit_primary_village__c; }

                // 39 Date of last visit to primary village
                if (NewDateOfLastPrimaryVisit == null)
                {
                    NewDateOfLastPrimaryVisit = records[i].Date_of_last_visit_to_primary_village__c;
                } else {
                    if (NewDateOfLastPrimaryVisit < records[i].Date_of_last_visit_to_primary_village__c) { NewDateOfLastPrimaryVisit = records[i].Date_of_last_visit_to_primary_village__c; }
                }

                // 40 Date of first visit to primary village
                if (NewDateOfFirstPrimaryVisit == null)
                {
                    NewDateOfFirstPrimaryVisit = records[i].Date_of_first_visit_to_primary_village__c;
                } else {
                    if (NewDateOfFirstPrimaryVisit > records[i].Date_of_first_visit_to_primary_village__c) { NewDateOfFirstPrimaryVisit = records[i].Date_of_first_visit_to_primary_village__c;}
                }

                // 41 Preferred language of communication
                if (NewPreferredCommLanguage == null) { NewPreferredCommLanguage = records[i].Preferred_language_of_communication__c; }

                // 42 Preferred method of transportation
                if (NewTransportationMethod == null) { NewTransportationMethod = records[i].Method_of_transportation_to_village__c; }

                // 43.1 Visits per annum to primary village
                if (records[i].Visits_per_annum_to_Primary_Village__c != null) { PrimaryVisitsPerAnnum += ';' + records[i].Visits_per_annum_to_Primary_Village__c; }

                // 44.1 Abroad travel per annum
                if (records[i].Abroad_travel_per_annum__c != null) { AbroadTravel += ';' + records[i].Abroad_travel_per_annum__c; }

                // 45.1 Age Range
                if (records[i].Age_Range__c != null) { AgeRange += ';' + records[i].Age_Range__c; }
                
                // 46 Number of email bounces
                if (records[i].Email == NewEmail) {
                if (records[i].Number_of_email_bounces__c != null) { if (records[i].Number_of_email_bounces__c > 0) { if (New_Number_of_email_bounces == null) { New_Number_of_email_bounces = 0; } New_Number_of_email_bounces += records[i].Number_of_email_bounces__c; } } }

                // 47 Number of undelivered mail items
                if (records[i].Number_of_undelivered_mail_items__c != null) { if (records[i].Number_of_undelivered_mail_items__c > 0) { if (New_Number_of_undelivered_mail_items == null) { New_Number_of_undelivered_mail_items = 0; } New_Number_of_undelivered_mail_items += records[i].Number_of_undelivered_mail_items__c; } }

                // 48 Bad Mailing Address
                if (records[i].BadMailingAddress__c == TRUE) { BadMailingAddress = records[i].BadMailingAddress__c; }

                // 49 Postal Address Quality
                if (records[i].Postal_Address_Quality__c != null) { if (Postal_Address_Quality == null) { Postal_Address_Quality = records[i].Postal_Address_Quality__c; } else { if (records[i].Postal_Address_Quality__c > Postal_Address_Quality) { Postal_Address_Quality = records[i].Postal_Address_Quality__c; } } }

                // 50 Hard Bounce
                if (records[i].Hard_Bounce__c == TRUE) { Hard_Bounce = TRUE; }
                
                // 51 Email Inactive
                if (Email_Inactive == null) { if (records[i].Email_Inactive__c != null) { Email_Inactive = records[i].Email_Inactive__c; } }

                //52 Primary Household Contact
                if (records[i].Primary_Household_Contact__c == TRUE) { Primary_Household_Contact = TRUE; } 

              
//New Fields Text
				//61 FirstNameLocal
				if (NewFirstNameLocal == null) { if (records[i].FirstNameLocal != null) { NewFirstNameLocal = records[i].FirstNameLocal; } }
				//62 Future_segment1
				if (records[i].Future_segment1__c != null) { if (NewFuture_segment1 == null) { NewFuture_segment1 = records[i].Future_segment1__c; } else { if (records[i].Future_segment1__c < NewFuture_segment1) { NewFuture_segment1 = records[i].Future_segment1__c; } } }
				//63 LastNameLocal
				if (NewLastNameLocal == null) { if (records[i].LastNameLocal != null) { NewLastNameLocal = records[i].LastNameLocal; } }
				//64 Where_did_you_hear_about_the_Competition
				if (NewWhere_did_you_hear_about_the_Competition == null) { if (records[i].Where_did_you_hear_about_the_Competition__c != null) { NewWhere_did_you_hear_about_the_Competition = records[i].Where_did_you_hear_about_the_Competition__c; } }
				//102 Month_of_last_visit
				if (NewMonth_of_last_visit == null) { if (records[i].Month_of_last_visit__c != null) { NewMonth_of_last_visit = records[i].Month_of_last_visit__c; } }
				//103 Year_of_last_visit
				if (NewYear_of_last_visit == null) { if (records[i].Year_of_last_visit__c != null) { NewYear_of_last_visit = records[i].Year_of_last_visit__c; } }

//New Fields PickList           
  				//60 Aware_of_8_other_villages
                if (NewAware_of_8_other_villages == 'No' || NewAware_of_8_other_villages == null) { if (records[i].Aware_of_8_other_villages__c == 'Yes') { NewAware_of_8_other_villages = records[i].Aware_of_8_other_villages__c; } }

//New Fields MPL
				//65.1 Bicester
				if (records[i].Bicester__c != null) { Bicester += ';' + records[i].Bicester__c; }
				//66.1 Fidenza
				if (records[i].Fidenza__c != null) { Fidenza += ';' + records[i].Fidenza__c; }
				//67.1 Ingolstadt
				if (records[i].Ingolstadt__c != null) { Ingolstadt += ';' + records[i].Ingolstadt__c; }
				//68.1 Kildare
				if (records[i].Kildare__c != null) { Kildare += ';' + records[i].Kildare__c; }
				//69.1 La_Roca
				if (records[i].La_Roca__c != null) { La_Roca += ';' + records[i].La_Roca__c; }
				//70.1 La_Vallee
				if (records[i].La_Vallee__c != null) { La_Vallee += ';' + records[i].La_Vallee__c; }
				//71.1 Las_Rozas
				if (records[i].Las_Rozas__c != null) { Las_Rozas += ';' + records[i].Las_Rozas__c; }
				//72.1 Maasmechelen
				if (records[i].Maasmechelen__c != null) { Maasmechelen += ';' + records[i].Maasmechelen__c; }
				//73.1 Wertheim
				if (records[i].Wertheim__c != null) { Wertheim += ';' + records[i].Wertheim__c; }
//New Fields Boolean
				//80 I_am_18_years_old_or_more
				if (NewI_am_18_years_old_or_more == FALSE) { if (records[i].I_am_18_years_old_or_more__c == TRUE) { NewI_am_18_years_old_or_more = TRUE; } }
				//81 Never_received_postal_mailing
				if (NewNever_received_postal_mailing == FALSE) { if (records[i].Never_received_postal_mailing__c == TRUE) { NewNever_received_postal_mailing = TRUE; } }
				//82 Profiling_Opt_Out
				if (NewProfiling_Opt_Out == FALSE) { if (records[i].Profiling_Opt_Out__c == TRUE) { NewProfiling_Opt_Out = TRUE; } }
				//83 Web_Account_Active
				if (NewWeb_Account_Active == FALSE) { if (records[i].Web_Account_Active__c == TRUE) { NewWeb_Account_Active = TRUE; } }


//New Fields Dates
			//90 Date_of_last_visited_village (Use most Recent Date)
			    if (NewDate_of_last_visited_village == null)
                {   NewDate_of_last_visited_village = records[i].Date_of_last_visited_village__c;} 
                else 
                { if (NewDate_of_last_visited_village < records[i].Date_of_last_visited_village__c) { NewDate_of_last_visited_village = records[i].Date_of_last_visited_village__c; }}
			//91 Last_Redemption_Date  (Use most Recent Date)
						    if (NewLast_Redemption_Date == null)
                {   NewLast_Redemption_Date = records[i].Last_Redemption_Date__c;} 
                else 
                { if (NewLast_Redemption_Date < records[i].Last_Redemption_Date__c) { NewLast_Redemption_Date = records[i].Last_Redemption_Date__c; }}


//New Fields Number
			//100 Current_Segment (Use Lowest Value)
			if (records[i].Current_Segment__c != null) { if (NewCurrent_Segment == null) { NewCurrent_Segment = records[i].Current_Segment__c; } else { if (records[i].Current_Segment__c < NewCurrent_Segment) { NewCurrent_Segment = records[i].Current_Segment__c; } } }	
			//101 Experience_rating (Use Highest Value)
			if (records[i].Experience_rating__c != null) { if (NewExperience_rating == null) { NewExperience_rating = records[i].Experience_rating__c; } else { if (records[i].Experience_rating__c > NewExperience_rating) { NewExperience_rating = records[i].Experience_rating__c; } } }

//Old Field but now with a Rule
             if (NewBrand_Registration_Lead_Source == null) { if (records[i].Brand_Registration_Lead_Source__c != null) { NewBrand_Registration_Lead_Source = records[i].Brand_Registration_Lead_Source__c; } }

            }

// End field update loop

// Multi picklist update loop

    string[] ValueArray;

    // 27.2 Secondary Villages
    ValueArray = SecondaryVillages.split(';');
    for (integer i = 0; i < ValueArray.size(); ++i)
    {
        if (NewSecondaryVillages == null) { NewSecondaryVillages = ''; }
        if (!NewSecondaryVillages.contains(ValueArray[i])) { NewSecondaryVillages += ';' + ValueArray[i]; }
    }

    // 28.2 Visit to secondary villages
    if (Mc.Visits_to_secondary_village_s_per_annum__c != null) { SecondaryVillageVisits += ';' + Mc.Visits_to_secondary_village_s_per_annum__c; }
    if (SecondaryVillageVisits != null)
    {
        NewSecondaryVillageVisits = '';
        ValueArray = SecondaryVillageVisits.split(';');
        ValueArray.sort();
        NewSecondaryVillageVisits = ValueArray[(ValueArray.size()-1)];
    }
    
    // 45.1
    if (Mc.Age_Range__c != null) { AgeRange += ';' + Mc.Age_Range__c; }
    if (AgeRange != null)
    {
        NewAgeRange = '';
        ValueArray = AgeRange.split(';');
        ValueArray.sort();
        NewAgeRange = ValueArray[(ValueArray.size()-1)];
    }

    // 29.2 Shopping venues
    ValueArray = ShoppingVenues.split(';');
    for (integer i = 0; i < ValueArray.size(); ++i)
    {
        if (NewShoppingVenues == null) { NewShoppingVenues = ''; }
        if (!NewShoppingVenues.contains(ValueArray[i])) { NewShoppingVenues += ';' + ValueArray[i]; }
    }

    // 30.2 Visit Occasions
    ValueArray = VisitOccasions.split(';');
    for (integer i = 0; i < ValueArray.size(); ++i)
    {
        if (NewVisitOccasions == null) { NewVisitOccasions = ''; }
        if (!NewVisitOccasions.contains(ValueArray[i])) { NewVisitOccasions += ';' + ValueArray[i]; }
    }
    // 31.2 Categories of interest
    ValueArray = COI.split(';');
    for (integer i = 0; i < ValueArray.size(); ++i)
    {
        if (NewCOI == null) { NewCOI = ''; }
        if (!NewCOI.contains(ValueArray[i])) { NewCOI += ';' + ValueArray[i]; }
    }
    // 32.2 Sports played
    ValueArray = SportsPlayed.split(';');
    for (integer i = 0; i < ValueArray.size(); ++i)
    {
        if (NewSportsPlayed == null) { NewSportsPlayed = ''; }
        if (!NewSportsPlayed.contains(ValueArray[i])) { NewSportsPlayed += ';' + ValueArray[i]; }
    }

    // 32.3 Do you play sport
    if (NewPlaySport == 'No' || NewPlaySport == null)
    {
        if (SportsPlayed != null && SportsPlayed != '') { NewPlaySport = 'Yes'; }
        else {NewSportsPlayed = null;}
    }


    // 33.2 Children ages
    ValueArray = ChildrenAges.split(';');
    for (integer i = 0; i < ValueArray.size(); ++i)
    {
        if (NewChildrenAges == null) { NewChildrenAges = ''; }
        if (!NewChildrenAges.contains(ValueArray[i])) { NewChildrenAges += ';' + ValueArray[i]; }
    }

    // 33.3 Has Children
    if (ChildrenAges != null && ChildrenAges != '')
    {
        HasChildren = 'Yes';
    }
    else {ChildrenAges = null;}

    // 34.2 Holiday destinations
    ValueArray = HolidayDestinations.split(';');
    for (integer i = 0; i < ValueArray.size(); ++i)
    {
        if (NewHolidayDestinations == null) { NewHolidayDestinations = ''; }
        if (!NewHolidayDestinations.contains(ValueArray[i])) { NewHolidayDestinations += ';' + ValueArray[i]; }
    }
    
    // 37.2 Amount willing to Spend
    if (Mc.Amount_willing_to_spend_in_village__c != null) { WillingToSpend += ';' + Mc.Amount_willing_to_spend_in_village__c; }
    if (WillingToSpend != null)
    {
        NewWillingToSpend = '';
        ValueArray = WillingToSpend.split(';');
        ValueArray.sort();
        NewWillingToSpend = ValueArray[(ValueArray.size()-1)];
    }
    
    // 44.2 Abroad travel per annum
    if (Mc.Abroad_travel_per_annum__c != null) { AbroadTravel += ';' + Mc.Abroad_travel_per_annum__c; }
    if (AbroadTravel != null)
    {
        NewAbroadTravel = '';
        ValueArray = AbroadTravel.split(';');
        ValueArray.sort();
        NewAbroadTravel = ValueArray[(ValueArray.size()-1)];
    }

    // 43.2 Visits to primary village per annum
    if (Mc.Visits_per_annum_to_Primary_Village__c != null) { PrimaryVisitsPerAnnum += ';' + Mc.Visits_per_annum_to_Primary_Village__c;}
    if (PrimaryVisitsPerAnnum  != null)
    {
        ValueArray = PrimaryVisitsPerAnnum.split(';');
        ValueArray.sort();
        NewPrimaryVisitsPerAnnum = ValueArray[(ValueArray.size()-1)];
    }

    // 45 Primary village visited
    if ((NewPrimaryVisitsPerAnnum  != null && NewPrimaryVisitsPerAnnum != '')
    || (NewTransportationMethod != null && NewTransportationMethod != '')
    || (NewPrimaryVisitsPerAnnum != null && NewPrimaryVisitsPerAnnum != '')
    || (NewDateOfFirstPrimaryVisit != null)
    || (NewDateOfLastPrimaryVisit != null)
    || (NewVisitOccasions != null && NewVisitOccasions != '')
    || (NewPreferredVisitTime != null && NewPreferredVisitTime != '') 
    || (NewWillingToSpend != null && NewWillingToSpend != '')
    || (NewCOI != null && NewCOI != '')
    || (NewHowVillageHeardAbout != null && NewHowVillageHeardAbout != ''))
    {
        NewPrimaryVillageVisited  = 'Yes';
    }
	//New Fields MPL
				//65.1 Bicester
				ValueArray = Bicester.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewBicester == null) { NewBicester = ''; }
        				if (!NewBicester.contains(ValueArray[i])) { NewBicester += ';' + ValueArray[i]; }}
				//66.1 Fidenza
			ValueArray = Fidenza.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewFidenza == null) { NewFidenza = ''; }
        				if (!NewFidenza.contains(ValueArray[i])) { NewFidenza += ';' + ValueArray[i]; }}
				//67.1 Ingolstadt
			ValueArray = Ingolstadt.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewIngolstadt == null) { NewIngolstadt = ''; }
        				if (!NewIngolstadt.contains(ValueArray[i])) { NewIngolstadt += ';' + ValueArray[i]; }}
				//68.1 Kildare
			ValueArray = Kildare.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewKildare == null) { NewKildare = ''; }
        				if (!NewKildare.contains(ValueArray[i])) { NewKildare += ';' + ValueArray[i]; }}
				//69.1 La_Roca
			ValueArray = La_Roca.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewLa_Roca == null) { NewLa_Roca = ''; }
        				if (!NewLa_Roca.contains(ValueArray[i])) { NewLa_Roca += ';' + ValueArray[i]; }}
				//70.1 La_Vallee
			ValueArray = La_Vallee.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewLa_Vallee == null) { NewLa_Vallee = ''; }
        				if (!NewLa_Vallee.contains(ValueArray[i])) { NewLa_Vallee += ';' + ValueArray[i]; }}
				//71.1 Las_Rozas
			ValueArray = Las_Rozas.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewLas_Rozas == null) { NewLas_Rozas = ''; }
        				if (!NewLas_Rozas.contains(ValueArray[i])) { NewLas_Rozas += ';' + ValueArray[i]; }}
				//72.1 Maasmechelen
			ValueArray = Maasmechelen.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewMaasmechelen == null) { NewMaasmechelen = ''; }
        				if (!NewMaasmechelen.contains(ValueArray[i])) { NewMaasmechelen += ';' + ValueArray[i]; }}
				//73.1 Wertheim
			ValueArray = Wertheim.split(';');
   					 for (integer i = 0; i < ValueArray.size(); ++i)
    				{ if (NewWertheim == null) { NewWertheim = ''; }
        				if (!NewWertheim.contains(ValueArray[i])) { NewWertheim += ';' + ValueArray[i]; }}
    
// End multi picklist update loop
// Display original and new values

// Detect existing brands of interest

    // Compile list of master boi
    string mbois = '';
    Brands_of_Interest__c[] mboi = [select id, accounts_brands__c from brands_of_interest__c where contact__c = : Mc.Id];
    for (integer i = 0; i < mboi.size(); ++i)
    {
        mbois += ';' + mboi[i].accounts_brands__c;
    }

    // Compare duplicate boi to master list 
    string dbois = '';
    for (integer i = 1; i < records.size(); ++i)
    {
        Brands_of_Interest__c[] dboi = [select id, accounts_brands__c from brands_of_interest__c where contact__c = : records[i].Id];

        for (integer j = 0; j < dboi.size(); ++j)
        {
            if (mbois.contains(dboi[j].accounts_brands__c)) { delete(dboi[j]); } else { mbois += ';' + dboi[j].accounts_brands__c; }
        }
    }

// End detect of existing brands of interest

        // Select Master Contact record for merging
            Contact McR = [select Id
            ,Original_Creation_Date__c
            ,Individual_Set__c
            ,AccountId
            ,LastName
            ,FirstName
            ,Salutation
            ,MailingStreet
            ,MailingCity
            ,MailingState
            ,MailingPostalCode
            ,MailingCountry
            ,Mailing_Country_In_English__c
            ,Phone
            ,MobilePhone
            ,Mobile_Opt_Out__c
            ,Email
            ,LeadSource
            ,BirthDate
            ,HasOptedOutOfEmail
            ,Gender__c
            ,Marital_Status__c
            ,Preferred_email_format__c
            ,Professional_activity__c
            ,Date_Last_Cleaned_Checked__c
            ,Profiling_Flag_under_hire__c
            ,Profiling_Flag_Expiry_hire_end_date__c
            ,Other_Village_Partner_Opt_Out__c
            ,Postal_Opt_Out__c
            ,Email_address_quality__c
            ,Calculated_Date_of_Birth__c
            ,Date_of_Birth_was_calculated__c
            ,Secondary_Village_s_of_interest__c
            ,Visits_to_secondary_village_s_per_annum__c
            ,Source_ID__c
            ,Age_Range__c
            ,Number_of_email_bounces__c
            ,Number_of_undelivered_mail_items__c
            ,Unique_Contact_ID_View__c
            ,CCR_TestImpID__c
            ,Language_ID__c
            ,Preferred_language_of_communication__c
            ,Primary_village_of_interest__c
            ,Brand_Registration_Lead_Source__c
            ,Primary_Household_Contact__c
            ,Duplicate_email_address__c
            ,Primary_email_address__c
            ,BadMailingAddress__c
            ,Postal_address_quality__c
            ,Lead_Source_Text__c
            ,Hard_Bounce__c
            ,Email_Inactive__c
            ,Do_you_play_sport__c
            ,What_sports_do_you_play__c
            ,Children__c
            ,Age_of_Children__c
            ,Abroad_travel_per_annum__c
            ,Preferred_holiday_destination__c
            ,Specific_occasions_to_visit_Village__c
            ,Primary_Village_visited__c
            ,Category_s_of_Interest__c
            ,Amount_willing_to_spend_in_Village__c
            ,How_Village_was_heard_about__c
            ,Method_of_transportation_to_Village__c
            ,Preferred_time_to_visit_Primary_Village__c
            ,Visits_per_annum_to_Primary_Village__c
            ,Date_of_last_visit_to_primary_village__c
            ,Date_of_first_visit_to_primary_village__c
            ,Preferred_shopping_venue_s__c
//New Fields Text
			,FirstNameLocal
			,Future_segment1__c
			,LastNameLocal
			,Where_did_you_hear_about_the_Competition__c 
			,Month_of_last_visit__c
			,Year_of_last_visit__c

//New Fields PickList           
            ,Aware_of_8_other_villages__c
            
// New Fields MPL
            ,Bicester__c
			,Fidenza__c
			,Ingolstadt__c
			,Kildare__c
			,La_Roca__c
			,La_Vallee__c
			,Las_Rozas__c
			,Maasmechelen__c
			,Wertheim__c
			
//New Fields Boolean
			,I_am_18_years_old_or_more__c
			,Never_received_postal_mailing__c
			,Profiling_Opt_Out__c
			,Web_Account_Active__c

//New Fields Dates
			,Date_of_last_visited_village__c
			,Last_Redemption_Date__c
			
//New Fields Number
			,Current_Segment__c
			,Experience_rating__c
			
             from Contact where Id = : Mc.Id];
        // End select

        // Update Master Contact Field Values
            McR.FirstName  =  NewFirstName;
            McR.LastName  =  NewLastName;
            McR.Salutation  =  NewSalutation;
            McR.MailingStreet  =  NewMailingStreet;
            McR.MailingCity  =  NewMailingCity;
            McR.MailingState  =  NewMailingState;
            McR.MailingCountry = NewMailingCountry;
            McR.Mailing_Country_In_English__c  =  NewMailingCountryEnglish;
            McR.MailingPostalCode = NewPostalCode;
            McR.Phone  =  NewPhone;
            McR.MobilePhone  =  NewMobile;
            McR.Email  =  NewEmail;
            McR.BirthDate  =  NewBirthDate;
            McR.LeadSource = Lead_Source;
            McR.Source_ID__c  =  Source_ID;
            McR.Age_Range__c  =  NewAgeRange;
            McR.Number_of_email_bounces__c  =  New_Number_of_email_bounces;
            McR.Number_of_undelivered_mail_items__c  =  New_Number_of_undelivered_mail_items;
            McR.Unique_Contact_ID_View__c  =  Unique_Contact_ID_View;
            McR.CCR_TestImpID__c  =  CCR_TestImpID;
            McR.Language_ID__c  =  Language_ID;
            McR.Preferred_language_of_communication__c  =  NewPreferredCommLanguage;
            McR.Brand_Registration_Lead_Source__c  =  NewBrand_Registration_Lead_Source;
            McR.Primary_Household_Contact__c  =  Primary_Household_Contact;
            McR.Duplicate_email_address__c  =  Duplicate_email_address;
            McR.Primary_email_address__c  =  Primary_email_address;
            McR.BadMailingAddress__c  =  BadMailingAddress;
            McR.Postal_address_quality__c  =  Postal_address_quality;
            McR.Lead_Source_Text__c  =  Lead_Source_Text;
            McR.Hard_Bounce__c  =  Hard_Bounce;
            McR.Email_Inactive__c  =  Email_Inactive;
            McR.Gender__c  =  NewGender;
            McR.HasOptedOutOfEmail  =  NewEmailOptOut;
            McR.Original_Creation_Date__c  =  NewOrigCreationDate;
            McR.Primary_village_of_interest__c  =  NewPrimaryVillage;
            McR.How_village_was_heard_about__c  =  NewHowVillageHeardAbout;
            McR.Amount_willing_to_spend_in_village__c  =  NewWillingToSpend;
            McR.Preferred_time_to_visit_primary_village__c  =  NewPreferredVisitTime;
            McR.Date_of_last_visit_to_primary_village__c  =  NewDateOfLastPrimaryVisit;
            McR.Date_of_first_visit_to_primary_village__c  =  NewDateOfFirstPrimaryVisit;
            McR.Method_of_transportation_to_village__c  =  NewTransportationMethod;
            McR.Primary_Village_visited__c  =  NewPrimaryVillageVisited;
            McR.Visits_per_annum_to_Primary_Village__c  =  NewPrimaryVisitsPerAnnum;
            McR.Secondary_Village_s_of_interest__c  =  NewSecondaryVillages;
            McR.Visits_to_secondary_village_s_per_annum__c  =  NewSecondaryVillageVisits;
            McR.Do_you_play_sport__c  =  NewPlaySport;
            McR.Children__c  =  HasChildren;
            McR.Preferred_shopping_venue_s__c  =  NewShoppingVenues;
            McR.Specific_occasions_to_visit_Village__c  =  NewVisitOccasions;
            McR.Category_s_of_Interest__c  =  NewCOI;
            McR.What_sports_do_you_play__c  =  SportsPlayed;
            McR.Age_of_Children__c  =  NewChildrenAges;
            McR.Preferred_holiday_destination__c  =  NewHolidayDestinations;
            McR.Email_address_quality__c  =  NewEmailAddressQuality;
            McR.Mobile_Opt_Out__c  =  NewMobileOptOut;
            McR.Postal_Opt_Out__c  =  NewPostalOptOut;
            McR.Calculated_Date_of_Birth__c  =  NewCalcDateOfBirth;
            McR.Date_of_Birth_was_calculated__c  =  NewDOBCalc;
            McR.Other_Village_Partner_Opt_Out__c  =  NewPartnerOptOut;
            McR.Profiling_Flag_under_hire__c  =  NewProfilingFlag;
            McR.Profiling_Flag_Expiry_hire_end_date__c  =  NewProfilingExpiry;
            McR.Date_Last_Cleaned_Checked__c  =  NewDateLastCleaned;
            McR.Professional_activity__c  =  NewProfessionalActivity;
            McR.Preferred_email_format__c  =  NewEmailFormat;
            McR.Marital_Status__c  =  NewMaritalStatus;
            McR.What_sports_do_you_play__c  =  NewSportsPlayed;
            McR.Abroad_travel_per_annum__c  =  NewAbroadTravel;
            McR.Individual_set_processed__c = true;
// New Fields Text
			McR.FirstNameLocal = NewFirstNameLocal;
			McR.Future_segment1__c = NewFuture_segment1;
			McR.LastNameLocal = NewLastNameLocal;
			McR.Where_did_you_hear_about_the_Competition__c = NewWhere_did_you_hear_about_the_Competition;
			McR.Month_of_last_visit__c = NewMonth_of_last_visit;
			McR.Year_of_last_visit__c = NewYear_of_last_visit;
			
			
//New Fields PickList 
			McR.Aware_of_8_other_villages__c = NewAware_of_8_other_villages;
			
//New Fields MPC			
			McR.Bicester__c = NewBicester;
			McR.Fidenza__c = NewFidenza;
			McR.Ingolstadt__c = NewIngolstadt;
			McR.Kildare__c = NewKildare;
			McR.La_Roca__c = NewLa_Roca;
			McR.La_Vallee__c = NewLa_Vallee;
			McR.Las_Rozas__c = NewLas_Rozas;
			McR.Maasmechelen__c = NewMaasmechelen;
			McR.Wertheim__c = NewWertheim;

//New Fields Boolean
			McR.I_am_18_years_old_or_more__c = NewI_am_18_years_old_or_more;
			McR.Never_received_postal_mailing__c = NewNever_received_postal_mailing;
			McR.Profiling_Opt_Out__c = NewProfiling_Opt_Out;
			McR.Web_Account_Active__c = NewWeb_Account_Active;

//New Fields Dates
			McR.Date_of_last_visited_village__c = NewDate_of_last_visited_village;
			McR.Last_Redemption_Date__c = NewLast_Redemption_Date;

//New Fields Number
			McR.Current_Segment__c = NewCurrent_Segment;
			McR.Experience_rating__c = NewExperience_rating;


        // End update master contact field values

        // Merge each duplicate against master
        for (integer i = 1; i < records.size(); ++i)
        {
            Contact Dc = records[i];
            Merge McR Dc;
            ++cm;
        }
        if (ctm > (cm + 1)) { boodone = false; status = 'Not all Contacts Merged'; }
        // End merge each duplicate against master

        } else { status = 'no sets to process'; ic = stp_limit; boodone = true; }
    ++ic;
    }
   } catch (System.QueryException e) { boodone = true; status = 'QueryException';  system.Debug(e);
   } catch (System.DmlException e) { boodone = true; status = 'DmlException';  system.Debug(e);
   } catch (System.StringException e) { boodone = true; status = 'StringException'; system.Debug(e);
   } catch (System.NullPointerException e) { boodone = true; status = 'NullPointerException'; system.Debug(e);
   }
   finally {}

    return '' + ic + ',' + boodone + ',' + cm + ',' + status + ',' + setNo;

    }
}