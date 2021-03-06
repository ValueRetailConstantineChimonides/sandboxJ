//Generated by wsdl2apex

public class Etihard_Proxy_2 {
    public class EtihadProxyResponse {
        public String ReturnCode;
        public String ReturnCodeDescription;
        public String MergedAccount;
        public DateTime Date_x;
        public Boolean DateSpecified;
        public Etihard_Proxy_2.EtihadProxyMessageInfo MessageInfo;
        private String[] ReturnCode_type_info = new String[]{'ReturnCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ReturnCodeDescription_type_info = new String[]{'ReturnCodeDescription','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MergedAccount_type_info = new String[]{'MergedAccount','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Date_x_type_info = new String[]{'Date','http://www.w3.org/2001/XMLSchema','dateTime','0','1','false'};
        private String[] DateSpecified_type_info = new String[]{'DateSpecified','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] MessageInfo_type_info = new String[]{'MessageInfo','http://ValueRetail/SalesForceProxies/','EtihadProxyMessageInfo','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://ValueRetail/SalesForceProxies/','true','false'};
        private String[] field_order_type_info = new String[]{'ReturnCode','ReturnCodeDescription','MergedAccount','Date_x','DateSpecified','MessageInfo'};
    }
    public class EtihadProxyMessageInfo {
        public String MessageId;
        public String SystemId;
        public DateTime TimeStamp;
        public Boolean TimeStampSpecified;
        public String TransactionId;
        private String[] MessageId_type_info = new String[]{'MessageId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SystemId_type_info = new String[]{'SystemId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TimeStamp_type_info = new String[]{'TimeStamp','http://www.w3.org/2001/XMLSchema','dateTime','0','1','false'};
        private String[] TimeStampSpecified_type_info = new String[]{'TimeStampSpecified','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] TransactionId_type_info = new String[]{'TransactionId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://ValueRetail/SalesForceProxies/','true','false'};
        private String[] field_order_type_info = new String[]{'MessageId','SystemId','TimeStamp','TimeStampSpecified','TransactionId'};
    }
    public class InsertPartnerPoints_element {
        public Etihard_Proxy_2.EtihadProxyRequest etihadProxyRequest;
        public Etihard_Proxy_2.EtihadProxyMessageInfo etihadProxyMessageInfo;
        private String[] etihadProxyRequest_type_info = new String[]{'etihadProxyRequest','http://ValueRetail/SalesForceProxies/','EtihadProxyRequest','0','1','false'};
        private String[] etihadProxyMessageInfo_type_info = new String[]{'etihadProxyMessageInfo','http://ValueRetail/SalesForceProxies/','EtihadProxyMessageInfo','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://ValueRetail/SalesForceProxies/','true','false'};
        private String[] field_order_type_info = new String[]{'etihadProxyRequest','etihadProxyMessageInfo'};
    }
    public class EtihadProxyServiceSoap {
        public String endpoint_x = 'https://partners.valueretail.com/EtihadProxyservice.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://ValueRetail/SalesForceProxies/', 'Etihard_Proxy_2'};
        public Etihard_Proxy_2.EtihadProxyResponse InsertPartnerPoints(Etihard_Proxy_2.EtihadProxyRequest etihadProxyRequest,Etihard_Proxy_2.EtihadProxyMessageInfo etihadProxyMessageInfo) {
            Etihard_Proxy_2.InsertPartnerPoints_element request_x = new Etihard_Proxy_2.InsertPartnerPoints_element();
            Etihard_Proxy_2.InsertPartnerPointsResponse_element response_x;
            request_x.etihadProxyRequest = etihadProxyRequest;
            request_x.etihadProxyMessageInfo = etihadProxyMessageInfo;
            Map<String, Etihard_Proxy_2.InsertPartnerPointsResponse_element> response_map_x = new Map<String, Etihard_Proxy_2.InsertPartnerPointsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://ValueRetail/SalesForceProxies/InsertPartnerPoints',
              'http://ValueRetail/SalesForceProxies/',
              'InsertPartnerPoints',
              'http://ValueRetail/SalesForceProxies/',
              'InsertPartnerPointsResponse',
              'Etihard_Proxy_2.InsertPartnerPointsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.InsertPartnerPointsResult;
        }
    }
    public class EtihadProxyRequest {
        public String ActClassifications;
        public DateTime ActivityDate;
        public String Company;
        public String MemberId;
        public String Name;
        public String PartnerPoints;
        public String Points;
        public String Surname;
        public String SystemId;
        public String TransactionId;
        public Etihard_Proxy_2.EtihadProxyMessageInfo MessageInfo;
        private String[] ActClassifications_type_info = new String[]{'ActClassifications','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ActivityDate_type_info = new String[]{'ActivityDate','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
        private String[] Company_type_info = new String[]{'Company','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MemberId_type_info = new String[]{'MemberId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Name_type_info = new String[]{'Name','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PartnerPoints_type_info = new String[]{'PartnerPoints','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Points_type_info = new String[]{'Points','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Surname_type_info = new String[]{'Surname','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SystemId_type_info = new String[]{'SystemId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TransactionId_type_info = new String[]{'TransactionId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MessageInfo_type_info = new String[]{'MessageInfo','http://ValueRetail/SalesForceProxies/','EtihadProxyMessageInfo','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://ValueRetail/SalesForceProxies/','true','false'};
        private String[] field_order_type_info = new String[]{'ActClassifications','ActivityDate','Company','MemberId','Name','PartnerPoints','Points','Surname','SystemId','TransactionId','MessageInfo'};
    }
    public class InsertPartnerPointsResponse_element {
        public Etihard_Proxy_2.EtihadProxyResponse InsertPartnerPointsResult;
        private String[] InsertPartnerPointsResult_type_info = new String[]{'InsertPartnerPointsResult','http://ValueRetail/SalesForceProxies/','EtihadProxyResponse','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://ValueRetail/SalesForceProxies/','true','false'};
        private String[] field_order_type_info = new String[]{'InsertPartnerPointsResult'};
    }
    
    static testMethod void  testEtihardProxy(){
        Etihard_Proxy_2.EtihadProxyServiceSoap  proxyService = new  Etihard_Proxy_2.EtihadProxyServiceSoap();
        PointsProvider__c custPointsProvider = PointsProvider__c.getInstance();
        
        Etihard_Proxy_2.EtihadProxyRequest aCallRequest = new Etihard_Proxy_2.EtihadProxyRequest();
        
        aCallRequest.ActClassifications = custPointsProvider.Etihad_Base_Credit_Activity_Classificati__c;
         aCallRequest.ActivityDate = System.now();
         aCallRequest.Company = custPointsProvider.Etihad_WS_Company__c;
         aCallRequest.MemberId = '1234567890123';
         aCallRequest.Name = 'Name';
         aCallRequest.Surname = 'Surname';
         
         aCallRequest.PartnerPoints = '1000';
         aCallRequest.Points = '1000';
         aCallRequest.SystemId = custPointsProvider.System_ID__c;
         aCallRequest.TransactionId = 'BV123456789012345678';
         
         Etihard_Proxy_2.EtihadProxyMessageInfo testMessageInfo = new Etihard_Proxy_2.EtihadProxyMessageInfo();
         
         testMessageInfo.MessageId ='BV123456789012345678';
         testMessageInfo.SystemId = custPointsProvider.System_ID__c;
         testMessageInfo.TimeStamp = System.now();
         testMessageInfo.TimeStampSpecified = true;
         
         Etihard_Proxy_2.EtihadProxyResponse testCallResult = proxyService.InsertPartnerPoints(aCallRequest,testMessageInfo);
         System.assertEquals(testCallResult.ReturnCode != null ?true : false ,true);
         System.assertEquals(testCallResult.ReturnCodeDescription != null ?true : false ,true);
         
         Etihard_Proxy_2.EtihadProxyResponse testCallResult_2 = new Etihard_Proxy_2.EtihadProxyResponse();
         testCallResult_2.ReturnCode = testCallResult.ReturnCode;
         testCallResult_2.ReturnCodeDescription = testCallResult.ReturnCodeDescription;
         
         System.assertEquals(testCallResult_2.ReturnCode != null ?true : false ,true);
         System.assertEquals(testCallResult_2.ReturnCodeDescription != null ?true : false ,true);
    }
}