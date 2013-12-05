public with sharing class AlitaliaPointsServiceClient {
    private static final String SOAP_HEADER_PWS='5c19ef5173889ef6019d26d619d54aa6';
    private static final String SOAP_HEADER_USER='webservice';
    private tempuriOrg.AlitaliaServiceSoap objPTServiceSoap;
    private String partnerUSER_ID;
    private String partnerPASSWORD;
    public Boolean inTesting= false;
    
    public AlitaliaPointsServiceClient(String appUserName, String appUserPwd){
        objPTServiceSoap = new tempuriOrg.AlitaliaServiceSoap();
        
        partnerUSER_ID = appUserName;
        partnerPASSWORD = appUserPwd;
    }

    public  List<String> login(){ 
        
        List<String> resultOf = new List<String>();
            objPTServiceSoap.timeout_x = 60000;
        webservicesAlitaliaComWsPservicesPt.CLSResults objLoginResult = null;
            if(!inTesting){
                 objLoginResult =  
                    objPTServiceSoap.callLogin(SOAP_HEADER_USER,SOAP_HEADER_PWS,partnerUSER_ID,partnerPASSWORD);
        
            }else{
                objLoginResult = new webservicesAlitaliaComWsPservicesPt.CLSResults();
                objLoginResult.ERROR_CODE ='0000';
            }
        
        
            if(objLoginResult !=null){
                resultOf.add(objLoginResult.ERROR_CODE);
                resultOf.add(objLoginResult.ERROR_MESSAGE);
            }
         
        return resultOf;
    }

    public  List<String> verifyCustomer(String surname,String mmCode){
        List<String> errorCodeAndMessage = null;
        
            objPTServiceSoap.timeout_x = 60000;
        
        webservicesAlitaliaComWsPservicesPt.CLSResults objVerifyResult =  null;
        if(!inTesting){
            objVerifyResult =  
                    objPTServiceSoap.callVerifyCustomer(SOAP_HEADER_USER,SOAP_HEADER_PWS,partnerUSER_ID,partnerPASSWORD,mmCode,surname);
        
        }else{
             objVerifyResult = new webservicesAlitaliaComWsPservicesPt.CLSResults();
                objVerifyResult.ERROR_CODE ='0000';
        }
          
            if(objVerifyResult !=null){
                errorCodeAndMessage = new List<String>();
                errorCodeAndMessage.add(objVerifyResult.ERROR_CODE);
                errorCodeAndMessage.add(objVerifyResult.ERROR_MESSAGE);
        }
         return errorCodeAndMessage;  
    }
    
    public List<String> doCreditTransfer(String partnerType, String partnerCode,String surname, String mmCode,
                                Integer transPoints,Date activityDate,String transReference){
        List<String> resultOfCall = new List<String>();
        
            webservicesAlitaliaComWsPservicesPt.CLSResults  transferPointsResult= null;
         
            if(!inTesting){
                  transferPointsResult= 
                    objPTServiceSoap.creditPoints(SOAP_HEADER_USER,SOAP_HEADER_PWS,partnerUSER_ID,partnerPASSWORD,mmCode,surname,
                    partnerCode,partnerType,activityDate,transReference,transPoints);
            }else{
                transferPointsResult = new webservicesAlitaliaComWsPservicesPt.CLSResults ();
                transferPointsResult.ERROR_CODE ='0000';
            }
            
         if(transferPointsResult !=null){
            resultOfCall.add(transferPointsResult.ERROR_CODE);
            resultOfCall.add(transferPointsResult.ERROR_MESSAGE);
         }
        return resultOfCall;
    }

    
}