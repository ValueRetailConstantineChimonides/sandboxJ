public with sharing class EtihardPointsServiceClient {
    PointsProvider__c custPointsProvider ;
    private Etihard_Proxy_2.EtihadProxyServiceSoap  proxyService;
    public static Boolean inTesting = false;
    
    public static final String SUCCESS_RESPONSE_CODE = '00';
    
    public EtihardPointsServiceClient(){
        // Get custom settings 
        custPointsProvider = PointsProvider__c.getInstance();
         proxyService = new Etihard_Proxy_2.EtihadProxyServiceSoap();
         proxyService.timeout_x = 90000;
        
    }
    
    public List<String> insertPoints(String grpFirstName, String grpLastName,Points_Transaction__c   transactionInProcess,
                                                Points_Transaction__c   transactionBonusInProcess){
         List<String> retList = new List<String>();
         
         Etihard_Proxy_2.EtihadProxyRequest baseRequest = new Etihard_Proxy_2.EtihadProxyRequest();
         Etihard_Proxy_2.EtihadProxyMessageInfo baseMessageInfo = new Etihard_Proxy_2.EtihadProxyMessageInfo();
         
         baseRequest.ActClassifications = custPointsProvider.Etihad_Base_Credit_Activity_Classificati__c;
         baseRequest.ActivityDate = transactionInProcess.Transaction_Date__c;
         baseRequest.Company = custPointsProvider.Etihad_WS_Company__c;
         baseRequest.MemberId = transactionInProcess.Customer_Card_Number__c;
         baseRequest.Name = grpFirstName;
         baseRequest.Surname = grpLastName;
         
         baseRequest.PartnerPoints = transactionInProcess.Transaction_Value__c+ '';
         baseRequest.Points = transactionInProcess.Points_Value__c+'';
         baseRequest.SystemId = custPointsProvider.System_ID__c;
         baseRequest.TransactionId = transactionInProcess.Transaction_Reference__c;
         
         baseMessageInfo.MessageId =transactionInProcess.Transaction_Reference__c;
         baseMessageInfo.SystemId = custPointsProvider.System_ID__c;
         baseMessageInfo.TimeStamp = transactionInProcess.Transaction_Date__c;
         baseMessageInfo.TimeStampSpecified = true;
         
         Etihard_Proxy_2.EtihadProxyResponse baseResult = null;
         if(inTesting){
            baseResult = new Etihard_Proxy_2.EtihadProxyResponse();
            baseResult.ReturnCode =  '00';
            baseResult.ReturnCodeDescription ='SUCCESS';
         }else{
            baseResult = proxyService.InsertPartnerPoints(baseRequest,baseMessageInfo);
         }
         
         
         if(null != baseResult){
            retList.add(baseResult.ReturnCode);
            retList.add(baseResult.ReturnCodeDescription);
         }
         
         if(null != transactionBonusInProcess && (null != baseResult.ReturnCode && baseResult.ReturnCode == '00')){
            Etihard_Proxy_2.EtihadProxyRequest bonusRequest = new Etihard_Proxy_2.EtihadProxyRequest();
            Etihard_Proxy_2.EtihadProxyMessageInfo bonusMessageInfo = new Etihard_Proxy_2.EtihadProxyMessageInfo();
         
            bonusRequest.ActClassifications = custPointsProvider.Etihad_Base_Credit_Activity_Classificati__c;
            bonusRequest.ActivityDate = transactionBonusInProcess.Transaction_Date__c;
            bonusRequest.Company = custPointsProvider.Etihad_WS_Company__c;
            bonusRequest.MemberId = transactionBonusInProcess.Customer_Card_Number__c;
            bonusRequest.Name = grpFirstName;
            bonusRequest.Surname = grpLastName;
         
            bonusRequest.PartnerPoints = transactionBonusInProcess.Transaction_Value__c+ '';
            bonusRequest.Points = transactionBonusInProcess.Points_Value__c+'';
            bonusRequest.SystemId = custPointsProvider.System_ID__c;
            bonusRequest.TransactionId = transactionBonusInProcess.Transaction_Reference__c;
         
            bonusMessageInfo.MessageId =transactionBonusInProcess.Transaction_Reference__c;
            bonusMessageInfo.SystemId = custPointsProvider.System_ID__c;
            bonusMessageInfo.TimeStamp = transactionBonusInProcess.Transaction_Date__c;
            baseMessageInfo.TimeStampSpecified = true;
            
            Etihard_Proxy_2.EtihadProxyResponse bonusResult = null;
            if(inTesting){
                bonusResult = new Etihard_Proxy_2.EtihadProxyResponse();
                bonusResult.ReturnCode =  '00';
                bonusResult.ReturnCodeDescription ='SUCCESS';
            }else{
                bonusResult = proxyService.InsertPartnerPoints(bonusRequest,bonusMessageInfo);
            }

            
            if(null != bonusResult){
                retList.add(bonusResult.ReturnCode);
                retList.add(bonusResult.ReturnCodeDescription);
            }
            
         }
         
        return retList;    
    }
}