public with sharing class TestExactTargetService3 {
    
    public TestExactTargetService3() {
    	
    }

    private static final string endpoint      = 'https://api.dc1.exacttarget.com';
    private static final string path          = '/integrate.aspx';
    private static final string method        = 'POST'; 
    private static final string username      = 'lcroker@valueretail.com';//'sfdcintegration@valueretail.com';
    private static final string password      = 'bicester_2';//'sa13!0rc3';
    private static final string authorisation = '<authorization><username>' + username + '</username><password>' + password + '</password></authorization>';
        
    //
    // Jobs
    // 
    @future (callout = true)public static void callwebservicetosendmail(string emailadd, string cntId){    
    	Jobs job1 = new Jobs();
    	job1.salesforceSend(emailadd, cntId);
    }
    
         
         
    public class Jobs {
    
        public Jobs() { 
                    
        }
        
        private string createSoapHeader(string un, string pw) {
        	string timestampCreated = system.now().formatGmt('yyyy-MM-dd HH:mm:ss.S') + 'Z';
            string timestampExpires = system.now().addMinutes(5).formatGmt('yyyy-MM-dd HH:mm:ss.S') + 'Z';
        	
        	string header  = '<soap:Header>';
        	header        += '  <wsse:Security soap:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
        	header        += '    <wsu:Timestamp wsu:Id="_0">';
        	header        += '      <wsu:Created>' + timestampCreated + '</wsu:Created>';
        	header        += '      <wsu:Expires>' + timestampExpires + '</wsu:Expires>';
            header        += '    </wsu:Timestamp>';
        	header        += '    <wsse:UsernameToken wsu:Id="uuid-732576b4-b68d-4d09-9cd4-d5cc52937581-1">';
        	header        += '      <wsse:Username>' + un + '</wsse:Username>';
        	header        += '      <wsse:Password wsse:Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">';
        	header        += '        ' + pw;
        	header        += '      </wsse:Password>';
        	header        += '    </wsse:UsernameToken>';
        	header        += '  </wsse:Security>';
        	header        += '</soap:Header>';
        	return header;
        }
        
        private string createSoapBody(string emailId, string fromAddress, string fromName, string contactId, string objectType) {
            string body  = '<soap:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
            body        += '  <CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">';
            body        += '    <Options /> ';
            body        += '    <Objects xsi:type="SalesforceSend">';
            body        += '      <PartnerKey xsi:nil="true" /> ';
            body        += '      <ObjectID xsi:nil="true" />';
            body        += '      <Email>';
            body        += '        <PartnerKey xsi:nil="true" /> ';
            body        += '        <ID>' + emailId + '</ID>';
            body        += '        <ObjectID xsi:nil="true" />';
            body        += '      </Email>';            
            body        += '      <FromAddress>' + fromAddress + '</FromAddress>';
            body        += '      <FromName>' + fromName + '</FromName>';
            body        += '      <Targets>';
            body        += '        <PartnerKey xsi:nil="true" /> ';
            body        += '        <ObjectID>' + contactId + '</ObjectID>';
            body        += '        <ObjectType>' + objectType + '</ObjectType> ';
            body        += '      </Targets>';            
            body        += '    </Objects>';
            body        += '  </CreateRequest>';
            body        += '</soap:Body>';
        	return body;
        }        
        

        public void salesforceSend(string emailadd, string cntId) {
        	string emailId     = emailadd;             // Exact Target email id
            string contactId   = cntId;  // SFDC id
            string objectType  = 'Contact';             // either: Lead, Contact, Campaign, Report
            
            // settings defined only for example 
            string fromAddress = 'test.user@wigroup.com';
            string fromName    = 'Exact Target - SFDC Integration';

            // define soap message                        
        	string envelope  = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
        	envelope        += createSoapHeader(TestExactTargetService3.username, TestExactTargetService3.password);
            envelope        += createSoapBody(emailId, fromAddress, fromName, contactId, objectType);
        	envelope        += '</soap:Envelope>';
        	
        	// define endpoint
        	string endpointAppEx  = 'https://etappx.exacttarget.com';
            string pathAppEx      = '/Service.asmx';
            
            // create request object
            HttpRequest request = new HttpRequest();
            // create header(s)
            request.setHeader('Content-type',   'text/xml; charset=utf-8');
            request.setHeader('Content-length', string.valueOf(envelope.length()));
            request.setHeader('SoapAction',     'Create');
            // define request method
            request.setMethod(method);
            // define request endpoint and data
            request.setEndpoint(endpointAppEx + pathAppEx);
            request.setBody(envelope);   
            
            system.debug('Jobs::salesforceSend::00 endpoint:=' + endpointAppEx + pathAppEx);
            system.debug('Jobs::salesforceSend::01 request:=' + request);                              
            system.debug('Jobs::salesforceSend::02 request.body:=' + request.getBody());
            
            try {
                // attempt to send request and handle response
                HTTPResponse response = new Http().send(request);
                system.debug('Jobs::salesforceSend::03 response.body:=' + response.getBody());

                // traverse document to job element/node
                Dom.Document document  = response.getBodyDocument();
                // iterate node(s)
                for (Dom.XMLNode node : document.getRootElement().getChildElements()) {
                	if (node.getName().toLowerCase() == 'body') {
                        for (Dom.XMLNode nodeBody : node.getChildElements()) {
                        	if (nodeBody.getName().toLowerCase() == 'createresponse') {
                        		for (Dom.XMLNode nodeCreateResponse : nodeBody.getChildElements()) {
                        			if (nodeCreateResponse.getName().toLowerCase() == 'results') {
                        				// xpath:= /Envelope/Body/CreateResponse/Results
                        				for (Dom.XMLNode nodeResult : nodeCreateResponse.getChildElements()) {
                        				    // system.debug('Jobs::salesforceSend::02 results:=' + nodeResult.getName() + ' [' + nodeResult.getText() + ']');	
                        				}
                        			}
                        			// system.debug('Jobs::salesforceSend::01 createresponse:=' + nodeCreateResponse.getName() + ' [' + nodeCreateResponse.getText() + ']');
                        		}
                        	}
                        }
                	}                	
                }
                
                /*
                // RESPONSE MESSAGE
                <?xml version="1.0" encoding="utf-8"?>
                <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
	                <soap:Header>
	                    <wsa:Action>CreateResponse</wsa:Action>
	                    <wsa:MessageID>urn:uuid:c689088e-7ecb-4e0f-a319-6ea361802e89</wsa:MessageID>
	                    <wsa:RelatesTo>urn:uuid:e03d7038-d53c-4c7b-804e-ac8187b45b49</wsa:RelatesTo>
	                    <wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>
	                    <wsse:Security><wsu:Timestamp wsu:Id="Timestamp-4b571691-390f-4461-88e4-5b616bcfc967">
	                    <wsu:Created>2010-10-20T15:06:44Z</wsu:Created>
	                    <wsu:Expires>2010-10-20T15:11:44Z</wsu:Expires>
	                    </wsu:Timestamp></wsse:Security>
	                </soap:Header>
	                <soap:Body>
	                  <CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI">
	                    <Results>
	                      <StatusCode>OK</StatusCode>
	                      <StatusMessage>SalesforceSend Created</StatusMessage>
	                      <OrdinalID>0</OrdinalID>
	                      <NewID>11677393</NewID>
	                      <Object xsi:type="SalesforceSend">
	                        <PartnerKey xsi:nil="true" />
	                        <ObjectID xsi:nil="true" />
	                        <Email>
	                          <PartnerKey xsi:nil="true" />
	                          <ID>3747782</ID>
	                          <ObjectID xsi:nil="true" />
	                        </Email>
	                        <FromAddress>test.user@wigroup.com</FromAddress>
	                        <FromName>Exact Target - SFDC Integration</FromName>
	                        <Targets>
	                          <PartnerKey xsi:nil="true" />
	                          <ObjectID>003T000000TklXo</ObjectID>
	                          <ObjectType>Contact</ObjectType>
	                        </Targets>
	                      </Object>
	                    </Results>
	                    <RequestID>d31f6786-c25d-4e87-b471-5405fbf3ee01</RequestID>
	                    <OverallStatus>OK</OverallStatus>
	                  </CreateResponse>
	                </soap:Body>
                </soap:Envelope>
                */               
            } catch (system.calloutException ex) {
               system.debug('Jobs::salesforceSend::calloutException - ' + ex.getMessage());
            }                   	
        }
        
        public void sendMassEmail() {
        	// EXAMPLE ONLY: THIS FEATURE REQUIRES A SUBSCRIBER TO EXIST IN EXACT TARGET
        	string emailId          = '3747782';
        	string subscriberListId = '2336407';
        	
            // create envelope
            string envelope  = '<?xml version="1.0" encoding="UTF-8"?><exacttarget>' + TestExactTargetService3.authorisation + '<system><system_name>job</system_name><action>send</action><search_type>emailid</search_type>';
            envelope        += '<search_value>' + emailId + '</search_value>';
            envelope        += '<from_name />';
            envelope        += '<from_email />';
            envelope        += '<additional />';
            envelope        += '<multipart_mime>false</multipart_mime>';
            envelope        += '<track_links>true</track_links>';
            envelope        += '<send_date>immediate</send_date>';
            envelope        += '<send_time />';
            envelope        += '<lists><list>' + subscriberListId + '</list></lists>';
            envelope        += '<suppress/>';
            envelope        += '<test_send>true</test_send>';
            
            envelope        += '</system></exacttarget>';
            envelope         = 'qf=xml&xml=' + EncodingUtil.urlEncode(envelope, 'UTF-8');
            
            // create request object
            HttpRequest request = new HttpRequest();
            // create header(s)
            request.setHeader('Content-type', 'application/x-www-form-urlencoded');
            request.setHeader('Content-length', string.valueOf(envelope.length()));
            request.setHeader('Connection', 'close');
            // define request method
            request.setMethod(method);
            // define request endpoint and data
            request.setEndpoint(endpoint + path);
            request.setBody(envelope);   
            
            // system.debug('Jobs::sendMassEmail::01 request:=' + request);                              
            // system.debug('Jobs::sendMassEmail::02 request.body:=' + request.getBody());
            
            try {
                // attempt to send request and handle response
                HTTPResponse response = new Http().send(request);
                // system.debug('Jobs::sendMassEmail::03 response.body:=' + response.getBody());

                // traverse document to job element/node
                // Dom.Document document  = response.getBodyDocument();
                // iterate node(s)
                // for (Dom.XMLNode node : document.getRootElement().getChildElements()) {
                //     if (node.getName().toLowerCase() == 'system') {
                //     	for (Dom.XMLNode nodeSystem : node.getChildElements()) {
                //     		if (nodeSystem.getName().toLowerCase()  == 'job') {
                //                 // xpath:= /exacttarget/system/job 
                //                 system.debug('ListManagement::retrieveAll::04 nodeSystem:=' + nodeSystem.getChildElement('job_info', null).getText());
                //                 system.debug('ListManagement::retrieveAll::04 nodeSystem:=' + nodeSystem.getChildElement('job_description', null).getText());
                //     		}                            		
                //     	}
                //     }                	
                // 	
                // }
                /*
                <?xml version='1.0'?>
                <exacttarget>
                    <system>
                        <job>
                            <job_info>Job was successfully created.</job_info>
                            <job_description>11676045</job_description>
                        </job>
                    </system>
                </exacttarget>
                */               
            } catch (system.calloutException ex) {
               system.debug('Jobs::sendMassEmail::calloutException - ' + ex.getMessage());
            }        	
        }
    }         
                
    //
    // EmailManagement
    //
    
    public class EmailManagement {
    
        public EmailManagement() { 
                    
        }
        
        public void retrieveAllEmailIds() {
            // create envelope
            string envelope = '<?xml version="1.0" encoding="UTF-8"?><exacttarget>' + TestExactTargetService3.authorisation + '<system><system_name>email</system_name><action>retrieve</action><sub_action>all</sub_action><search_type></search_type><search_value></search_value><search_value2></search_value2><daterange></daterange></system></exacttarget>';
            envelope        = 'qf=xml&xml=' + EncodingUtil.urlEncode(envelope, 'UTF-8');
            
            // create request object
            HttpRequest request = new HttpRequest();
            // create header(s)
            request.setHeader('Content-type', 'application/x-www-form-urlencoded');
            request.setHeader('Content-length', string.valueOf(envelope.length()));
            request.setHeader('Connection', 'close');
            // define request method
            request.setMethod(method);
            // define request endpoint and data
            request.setEndpoint(endpoint + path);
            request.setBody(envelope);   
            
            // system.debug('EmailManagement::retrieveAllEmailIds::01 request:=' + request);                              
            // system.debug('EmailManagement::retrieveAllEmailIds::02 request.body:=' + request.getBody());
            
            try {
                // attempt to send request and handle response
                HTTPResponse response = new Http().send(request);
                system.debug('EmailManagement::retrieveAllEmailIds::03 response.body:=' + response.getBody());               
            } catch (system.calloutException ex) {
               system.debug('EmailManagement::retrieveAllEmailIds::calloutException - ' + ex.getMessage());
            }
                   
        } 
        
        
    } 
    
        
    //
    // Tracking
    //
    
    public class Tracking {
    
        public Tracking() { 
                    
        }
        
        public void retrieveJobIds() {
            // create envelope
            string envelope = '<?xml version="1.0" encoding="UTF-8"?><exacttarget>' + TestExactTargetService3.authorisation + '<system><system_name>tracking</system_name><action>jobretrieve</action><sub_action>jobs</sub_action><search_type>daterange</search_type><search_value>8/1/2010 09:00:00AM</search_value></system></exacttarget>';
            envelope        = 'qf=xml&xml=' + EncodingUtil.urlEncode(envelope, 'UTF-8');
            
            // create request object
            HttpRequest request = new HttpRequest();
            // create header(s)
            request.setHeader('Content-type', 'application/x-www-form-urlencoded');
            request.setHeader('Content-length', string.valueOf(envelope.length()));
            request.setHeader('Connection', 'close');
            // define request method
            request.setMethod(method);
            // define request endpoint and data
            request.setEndpoint(endpoint + path);
            request.setBody(envelope);   
            
            // system.debug('Tracking::retrieveJobIds::01 request:=' + request);                              
            // system.debug('Tracking::retrieveJobIds::02 request.body:=' + request.getBody());
            
            try {
                // attempt to send request and handle response
                HTTPResponse response = new Http().send(request);
                system.debug('Tracking::retrieveJobIds::03 response.body:=' + response.getBody());               
            } catch (system.calloutException ex) {
               system.debug('Tracking::retrieveJobIds::calloutException - ' + ex.getMessage());
            }
                   
        } 
        
        
    }    
        
    //
    // ListManagement
    //
    
    public class ListManagement {
    
        public ListManagement() { 
                    
        }   
        
        public void retrieveAll() {
        	// create envelope
        	string envelope = '<?xml version="1.0" encoding="UTF-8"?><exacttarget>' + TestExactTargetService3.authorisation + '<system><system_name>list</system_name><action>retrieve</action><search_type>listname</search_type><search_value></search_value></system></exacttarget>';
        	envelope        = 'qf=xml&xml=' + EncodingUtil.urlEncode(envelope, 'UTF-8');
        	
        	// create request object
        	HttpRequest request = new HttpRequest();
	        // create header(s)
	        request.setHeader('Content-type', 'application/x-www-form-urlencoded');
	        request.setHeader('Content-length', string.valueOf(envelope.length()));
	        request.setHeader('Connection', 'close');
	        // define request method
	        request.setMethod(method);
	        // define request endpoint and data
	        request.setEndpoint(endpoint + path);
	        request.setBody(envelope);   
	        
            // system.debug('ListManagement::retrieveAll::01 request:=' + request);            	             	 
            // system.debug('ListManagement::retrieveAll::02 request.body:=' + request.getBody());
        	
            try {
            	// attempt to send request and handle response
	            HTTPResponse response = new Http().send(request);
	            system.debug('ListManagement::retrieveAll::03 response.body:=' + response.getBody());	            
	            
                // extract body and remove byte-order-mark                
                // string xmlData = response.getBody().replaceAll('^[^<]*', '');
                // XmlStreamReader xmlReader = new XmlStreamReader(xmlData);
                // while (xmlReader.hasNext()) {
                //     xmlReader.next();
                // }	            
	        } catch (system.calloutException ex) {
	           system.debug('ListManagement::retrieveAll::calloutException - ' + ex.getMessage());
	        }
	               
        } 
    } 
    
    
    public class TestMethodsCodeCoverage1 {
        public Boolean AllowErrors;
        public String FieldMappingType;
        public String FileSpec;
        public String FileType;
        public String SubscriberImportType;
        public String UpdateType;
        public Integer MaxFileAge;
        public Integer MaxFileAgeScheduleOffset;
        public Integer MaxImportFrequency;
        public String Delimiter;
        public Integer HeaderLines;
        public String ControlColumn;
        public String ControlColumnDefaultAction;
        public String EndOfLineRepresentation;
        public String NullRepresentation;
        public Boolean StandardQuotedStrings;
        public String Filter;
        private String[] AllowErrors_type_info = new String[]{'AllowErrors','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] DestinationObject_type_info = new String[]{'DestinationObject','http://exacttarget.com/wsdl/partnerAPI','APIObject','0','1','false'};
        private String[] FieldMappingType_type_info = new String[]{'FieldMappingType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionFieldMappingType','0','1','false'};
        private String[] FieldMaps_type_info = new String[]{'FieldMaps','http://exacttarget.com/wsdl/partnerAPI','FieldMaps_element','0','1','false'};
        private String[] FileSpec_type_info = new String[]{'FileSpec','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FileType_type_info = new String[]{'FileType','http://exacttarget.com/wsdl/partnerAPI','FileType','0','1','false'};
        private String[] Notification_type_info = new String[]{'Notification','http://exacttarget.com/wsdl/partnerAPI','AsyncResponse','0','1','false'};
        private String[] RetrieveFileTransferLocation_type_info = new String[]{'RetrieveFileTransferLocation','http://exacttarget.com/wsdl/partnerAPI','FileTransferLocation','0','1','false'};
        private String[] SubscriberImportType_type_info = new String[]{'SubscriberImportType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionSubscriberImportType','0','1','false'};
        private String[] UpdateType_type_info = new String[]{'UpdateType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionUpdateType','0','1','false'};
        private String[] MaxFileAge_type_info = new String[]{'MaxFileAge','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] MaxFileAgeScheduleOffset_type_info = new String[]{'MaxFileAgeScheduleOffset','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] MaxImportFrequency_type_info = new String[]{'MaxImportFrequency','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] Delimiter_type_info = new String[]{'Delimiter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] HeaderLines_type_info = new String[]{'HeaderLines','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] AutoGenerateDestination_type_info = new String[]{'AutoGenerateDestination','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionAutoGenerateDestination','0','1','false'};
        private String[] ControlColumn_type_info = new String[]{'ControlColumn','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ControlColumnDefaultAction_type_info = new String[]{'ControlColumnDefaultAction','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionColumnBasedActionType','0','1','false'};
        private String[] ControlColumnActions_type_info = new String[]{'ControlColumnActions','http://exacttarget.com/wsdl/partnerAPI','ControlColumnActions_element','0','1','false'};
        private String[] EndOfLineRepresentation_type_info = new String[]{'EndOfLineRepresentation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] NullRepresentation_type_info = new String[]{'NullRepresentation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] StandardQuotedStrings_type_info = new String[]{'StandardQuotedStrings','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] Filter_type_info = new String[]{'Filter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DateFormattingLocale_type_info = new String[]{'DateFormattingLocale','http://exacttarget.com/wsdl/partnerAPI','Locale','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://exacttarget.com/wsdl/partnerAPI','true','false'};
        private String[] field_order_type_info = new String[]{'AllowErrors','DestinationObject','FieldMappingType','FieldMaps','FileSpec','FileType','Notification','RetrieveFileTransferLocation','SubscriberImportType','UpdateType','MaxFileAge','MaxFileAgeScheduleOffset','MaxImportFrequency','Delimiter','HeaderLines','AutoGenerateDestination','ControlColumn','ControlColumnDefaultAction','ControlColumnActions','EndOfLineRepresentation','NullRepresentation','StandardQuotedStrings','Filter','DateFormattingLocale'};
    }
    
     public class TestMethodsCodeCoverage2 {
        public Boolean AllowErrors;
        public String FieldMappingType;
        public String FileSpec;
        public String FileType;       
        public String SubscriberImportType;
        public String UpdateType;
        public Integer MaxFileAge;
        public Integer MaxFileAgeScheduleOffset;
        public Integer MaxImportFrequency;
        public String Delimiter;
        public Integer HeaderLines;
        public String ControlColumn;
        public String ControlColumnDefaultAction;
        public String EndOfLineRepresentation;
        public String NullRepresentation;
        public Boolean StandardQuotedStrings;
        public String Filter;
        private String[] AllowErrors_type_info = new String[]{'AllowErrors','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] DestinationObject_type_info = new String[]{'DestinationObject','http://exacttarget.com/wsdl/partnerAPI','APIObject','0','1','false'};
        private String[] FieldMappingType_type_info = new String[]{'FieldMappingType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionFieldMappingType','0','1','false'};
        private String[] FieldMaps_type_info = new String[]{'FieldMaps','http://exacttarget.com/wsdl/partnerAPI','FieldMaps_element','0','1','false'};
        private String[] FileSpec_type_info = new String[]{'FileSpec','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FileType_type_info = new String[]{'FileType','http://exacttarget.com/wsdl/partnerAPI','FileType','0','1','false'};
        private String[] Notification_type_info = new String[]{'Notification','http://exacttarget.com/wsdl/partnerAPI','AsyncResponse','0','1','false'};
        private String[] RetrieveFileTransferLocation_type_info = new String[]{'RetrieveFileTransferLocation','http://exacttarget.com/wsdl/partnerAPI','FileTransferLocation','0','1','false'};
        private String[] SubscriberImportType_type_info = new String[]{'SubscriberImportType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionSubscriberImportType','0','1','false'};
        private String[] UpdateType_type_info = new String[]{'UpdateType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionUpdateType','0','1','false'};
        private String[] MaxFileAge_type_info = new String[]{'MaxFileAge','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] MaxFileAgeScheduleOffset_type_info = new String[]{'MaxFileAgeScheduleOffset','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] MaxImportFrequency_type_info = new String[]{'MaxImportFrequency','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] Delimiter_type_info = new String[]{'Delimiter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] HeaderLines_type_info = new String[]{'HeaderLines','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] AutoGenerateDestination_type_info = new String[]{'AutoGenerateDestination','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionAutoGenerateDestination','0','1','false'};
        private String[] ControlColumn_type_info = new String[]{'ControlColumn','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ControlColumnDefaultAction_type_info = new String[]{'ControlColumnDefaultAction','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionColumnBasedActionType','0','1','false'};
        private String[] ControlColumnActions_type_info = new String[]{'ControlColumnActions','http://exacttarget.com/wsdl/partnerAPI','ControlColumnActions_element','0','1','false'};
        private String[] EndOfLineRepresentation_type_info = new String[]{'EndOfLineRepresentation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] NullRepresentation_type_info = new String[]{'NullRepresentation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] StandardQuotedStrings_type_info = new String[]{'StandardQuotedStrings','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] Filter_type_info = new String[]{'Filter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DateFormattingLocale_type_info = new String[]{'DateFormattingLocale','http://exacttarget.com/wsdl/partnerAPI','Locale','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://exacttarget.com/wsdl/partnerAPI','true','false'};
        private String[] field_order_type_info = new String[]{'AllowErrors','DestinationObject','FieldMappingType','FieldMaps','FileSpec','FileType','Notification','RetrieveFileTransferLocation','SubscriberImportType','UpdateType','MaxFileAge','MaxFileAgeScheduleOffset','MaxImportFrequency','Delimiter','HeaderLines','AutoGenerateDestination','ControlColumn','ControlColumnDefaultAction','ControlColumnActions','EndOfLineRepresentation','NullRepresentation','StandardQuotedStrings','Filter','DateFormattingLocale'};
    }
    
    public class TestMethodsCodeCoverage3 {
        public Boolean AllowErrors;
        public String FieldMappingType;
        public String FileSpec;
        public String FileType;
        public String SubscriberImportType;
        public String UpdateType;
        public Integer MaxFileAge;
        public Integer MaxFileAgeScheduleOffset;
        public Integer MaxImportFrequency;
        public String Delimiter;
        public Integer HeaderLines;
        public String ControlColumn;
        public String ControlColumnDefaultAction;
        public String EndOfLineRepresentation;
        public String NullRepresentation;
        public Boolean StandardQuotedStrings;
        public String Filter;
        private String[] AllowErrors_type_info = new String[]{'AllowErrors','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] DestinationObject_type_info = new String[]{'DestinationObject','http://exacttarget.com/wsdl/partnerAPI','APIObject','0','1','false'};
        private String[] FieldMappingType_type_info = new String[]{'FieldMappingType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionFieldMappingType','0','1','false'};
        private String[] FieldMaps_type_info = new String[]{'FieldMaps','http://exacttarget.com/wsdl/partnerAPI','FieldMaps_element','0','1','false'};
        private String[] FileSpec_type_info = new String[]{'FileSpec','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FileType_type_info = new String[]{'FileType','http://exacttarget.com/wsdl/partnerAPI','FileType','0','1','false'};
        private String[] Notification_type_info = new String[]{'Notification','http://exacttarget.com/wsdl/partnerAPI','AsyncResponse','0','1','false'};
        private String[] RetrieveFileTransferLocation_type_info = new String[]{'RetrieveFileTransferLocation','http://exacttarget.com/wsdl/partnerAPI','FileTransferLocation','0','1','false'};
        private String[] SubscriberImportType_type_info = new String[]{'SubscriberImportType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionSubscriberImportType','0','1','false'};
        private String[] UpdateType_type_info = new String[]{'UpdateType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionUpdateType','0','1','false'};
        private String[] MaxFileAge_type_info = new String[]{'MaxFileAge','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] MaxFileAgeScheduleOffset_type_info = new String[]{'MaxFileAgeScheduleOffset','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] MaxImportFrequency_type_info = new String[]{'MaxImportFrequency','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] Delimiter_type_info = new String[]{'Delimiter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] HeaderLines_type_info = new String[]{'HeaderLines','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] AutoGenerateDestination_type_info = new String[]{'AutoGenerateDestination','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionAutoGenerateDestination','0','1','false'};
        private String[] ControlColumn_type_info = new String[]{'ControlColumn','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ControlColumnDefaultAction_type_info = new String[]{'ControlColumnDefaultAction','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionColumnBasedActionType','0','1','false'};
        private String[] ControlColumnActions_type_info = new String[]{'ControlColumnActions','http://exacttarget.com/wsdl/partnerAPI','ControlColumnActions_element','0','1','false'};
        private String[] EndOfLineRepresentation_type_info = new String[]{'EndOfLineRepresentation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] NullRepresentation_type_info = new String[]{'NullRepresentation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] StandardQuotedStrings_type_info = new String[]{'StandardQuotedStrings','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] Filter_type_info = new String[]{'Filter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DateFormattingLocale_type_info = new String[]{'DateFormattingLocale','http://exacttarget.com/wsdl/partnerAPI','Locale','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://exacttarget.com/wsdl/partnerAPI','true','false'};
        private String[] field_order_type_info = new String[]{'AllowErrors','DestinationObject','FieldMappingType','FieldMaps','FileSpec','FileType','Notification','RetrieveFileTransferLocation','SubscriberImportType','UpdateType','MaxFileAge','MaxFileAgeScheduleOffset','MaxImportFrequency','Delimiter','HeaderLines','AutoGenerateDestination','ControlColumn','ControlColumnDefaultAction','ControlColumnActions','EndOfLineRepresentation','NullRepresentation','StandardQuotedStrings','Filter','DateFormattingLocale'};
    }
    
    public class TestMethodsCodeCoverage4 {
        public Boolean AllowErrors;
        public String FieldMappingType;
        public String FileSpec;
        public String FileType;
        public String SubscriberImportType;
        public String UpdateType;
        public Integer MaxFileAge;
        public Integer MaxFileAgeScheduleOffset;
        public Integer MaxImportFrequency;
        public String Delimiter;
        public Integer HeaderLines;
        public String ControlColumn;
        public String ControlColumnDefaultAction;
        public String EndOfLineRepresentation;
        public String NullRepresentation;
        public Boolean StandardQuotedStrings;
        public String Filter;
        private String[] AllowErrors_type_info = new String[]{'AllowErrors','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] DestinationObject_type_info = new String[]{'DestinationObject','http://exacttarget.com/wsdl/partnerAPI','APIObject','0','1','false'};
        private String[] FieldMappingType_type_info = new String[]{'FieldMappingType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionFieldMappingType','0','1','false'};
        private String[] FieldMaps_type_info = new String[]{'FieldMaps','http://exacttarget.com/wsdl/partnerAPI','FieldMaps_element','0','1','false'};
        private String[] FileSpec_type_info = new String[]{'FileSpec','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FileType_type_info = new String[]{'FileType','http://exacttarget.com/wsdl/partnerAPI','FileType','0','1','false'};
        private String[] Notification_type_info = new String[]{'Notification','http://exacttarget.com/wsdl/partnerAPI','AsyncResponse','0','1','false'};
        private String[] RetrieveFileTransferLocation_type_info = new String[]{'RetrieveFileTransferLocation','http://exacttarget.com/wsdl/partnerAPI','FileTransferLocation','0','1','false'};
        private String[] SubscriberImportType_type_info = new String[]{'SubscriberImportType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionSubscriberImportType','0','1','false'};
        private String[] UpdateType_type_info = new String[]{'UpdateType','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionUpdateType','0','1','false'};
        private String[] MaxFileAge_type_info = new String[]{'MaxFileAge','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] MaxFileAgeScheduleOffset_type_info = new String[]{'MaxFileAgeScheduleOffset','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] MaxImportFrequency_type_info = new String[]{'MaxImportFrequency','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] Delimiter_type_info = new String[]{'Delimiter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] HeaderLines_type_info = new String[]{'HeaderLines','http://www.w3.org/2001/XMLSchema','int','0','1','false'};
        private String[] AutoGenerateDestination_type_info = new String[]{'AutoGenerateDestination','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionAutoGenerateDestination','0','1','false'};
        private String[] ControlColumn_type_info = new String[]{'ControlColumn','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ControlColumnDefaultAction_type_info = new String[]{'ControlColumnDefaultAction','http://exacttarget.com/wsdl/partnerAPI','ImportDefinitionColumnBasedActionType','0','1','false'};
        private String[] ControlColumnActions_type_info = new String[]{'ControlColumnActions','http://exacttarget.com/wsdl/partnerAPI','ControlColumnActions_element','0','1','false'};
        private String[] EndOfLineRepresentation_type_info = new String[]{'EndOfLineRepresentation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] NullRepresentation_type_info = new String[]{'NullRepresentation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] StandardQuotedStrings_type_info = new String[]{'StandardQuotedStrings','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] Filter_type_info = new String[]{'Filter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DateFormattingLocale_type_info = new String[]{'DateFormattingLocale','http://exacttarget.com/wsdl/partnerAPI','Locale','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://exacttarget.com/wsdl/partnerAPI','true','false'};
        private String[] field_order_type_info = new String[]{'AllowErrors','DestinationObject','FieldMappingType','FieldMaps','FileSpec','FileType','Notification','RetrieveFileTransferLocation','SubscriberImportType','UpdateType','MaxFileAge','MaxFileAgeScheduleOffset','MaxImportFrequency','Delimiter','HeaderLines','AutoGenerateDestination','ControlColumn','ControlColumnDefaultAction','ControlColumnActions','EndOfLineRepresentation','NullRepresentation','StandardQuotedStrings','Filter','DateFormattingLocale'};
    }
    
    
    
    public static testMethod void testCreateBTOppController() {
    	
    	TestExactTargetService3 testT3 = new TestExactTargetService3();
    	
   		TestExactTargetService3.Jobs testJobs = new TestExactTargetService3.Jobs();
    	
    	String test1 = 'Test';
     	
       //	testJobs.salesforceSend(test1, test1) ;
    	
    	TestExactTargetService3.TestMethodsCodeCoverage1 code1 = new TestExactTargetService3.TestMethodsCodeCoverage1();
    	TestExactTargetService3.TestMethodsCodeCoverage2 code2 = new TestExactTargetService3.TestMethodsCodeCoverage2();
     	TestExactTargetService3.TestMethodsCodeCoverage3 code3 = new TestExactTargetService3.TestMethodsCodeCoverage3();
     	TestExactTargetService3.TestMethodsCodeCoverage4 code4 = new TestExactTargetService3.TestMethodsCodeCoverage4();
     	
    	//testJobs.Jobs();
    	testJobs.sendMassEmail();   	
    	testJObs.salesforceSend(test1, test1);
    	
    	TestExactTargetService3.ListManagement  testList = new TestExactTargetService3.ListManagement();
    	
        //testList.ListManagement();
    	testList.retrieveAll();
    	    	  	   	
    	TestExactTargetService3.EmailManagement testEmail = new TestExactTargetService3.EmailManagement();
    	
    	testEmail.retrieveAllEmailIds();
    	//testEmail.EmailManagement();
    	
    	TestExactTargetService3.Tracking testTracking = new TestExactTargetService3.Tracking();
    	
    	testTracking.retrieveJobIds();
    	//testTracking.Tracking();
    	
    	//TestExactTargetService3.callwebservicetosendmail(test1, test1);
    	
    	
    	
    	
    	
    	
    	
    	
    }
    
    
    
    
    
}