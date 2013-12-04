public with sharing class B2BEventsUtility {
    public static String validateFollowUPEmails(String emailAddresses){
        String reportErrorEmail= '';
        
        Boolean allOK = true; 
        String DELIM_STR = ',';
        if(emailAddresses.indexOf(DELIM_STR) > 0 ){
            String[] emailValues=   emailAddresses.split(DELIM_STR);
            
            for(String anEmail : emailValues){
                Boolean validateResult = validateAnEmailAddress(anEmail);
                if(validateResult == false){
                    allOK = validateResult;
                    reportErrorEmail = anEmail;
                    break;
                }           }
            
        }else{
            allOK = validateAnEmailAddress(emailAddresses);
            if(allOK == false){
                reportErrorEmail = emailAddresses;
            }
        }
        
        return reportErrorEmail;
    }
    
    private static boolean validateAnEmailAddress(String anEmail){
        final String vr_email_surfix = '@valueretail.com'; 
        boolean allOK = true;
        
        if(!(anEmail.indexOf(vr_email_surfix) > 0) || !anEmail.endsWith(vr_email_surfix)){
            // check in non VR email list
            if(nonVRApprovedFollowUpEmails.contains(anEmail) == false){
                allOK = false;
            }
        }
        return allOK;
    }
    
    private static final Set<String> nonVRApprovedFollowUpEmails = new Set<String>{'fllpoirel@aol.com',
        'luca.deambrosis@dea-re.it','paul@pda-property.co.uk'};

    public class ValidationException extends Exception {}
}