public with sharing class tempuriOrgTest {
    private static final String SOAP_HEADER_PWS='5c19ef5173889ef6019d26d619d54aa6';
    private static final String SOAP_HEADER_USER='webservice';
    
    private static String partnerUSER_ID;
    private static String partnerPASSWORD;
    
    static testMethod void testAlitaliatempuriOrg(){
        tempuriOrg.AlitaliaServiceSoap objPTServiceSoap = new tempuriOrg.AlitaliaServiceSoap();
        PointsProvider__c custPointsProvider = PointsProvider__c.getInstance();
        partnerUSER_ID = custPointsProvider.Alitalia_Points_Service_User__c;
        partnerPASSWORD = custPointsProvider.Alitalia_Points_Service_Password__c;
        
        String surname ='676702';
        String mmCode ='NEGRIN';
        String partnerType =custPointsProvider.Alitalia_Partner_Type__c;
        String partnerCode =custPointsProvider.Alitalia_Partner_Code_Base__c;
        Integer transPoints = 200;
        Date activityDate = DateTime.newInstance(System.currentTimeMillis()).date();
        String transReference ='BV01234567';
        
        objPTServiceSoap.callLogin(SOAP_HEADER_USER,SOAP_HEADER_PWS,partnerUSER_ID,partnerPASSWORD);
        objPTServiceSoap.callVerifyCustomer(SOAP_HEADER_USER,SOAP_HEADER_PWS,partnerUSER_ID,partnerPASSWORD,mmCode,surname);
        objPTServiceSoap.creditPoints(SOAP_HEADER_USER,SOAP_HEADER_PWS,partnerUSER_ID,partnerPASSWORD,mmCode,surname,
                    partnerCode,partnerType,activityDate,transReference,transPoints);
                        
    }
   
}