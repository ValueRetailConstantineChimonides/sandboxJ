public with sharing class PointsProviderSelectionController {
    
    private PointsProvider__c  custPointsProvider = null;
    
    public Points_Provider__c dummyProvider {get; set;}
    public PointsProviderSelectionController(ApexPages.StandardController stdController) {
        dummyProvider = (Points_Provider__c) stdController.getRecord();
        
        custPointsProvider = PointsProvider__c.getInstance();
        
        this.selectedProviderType = custPointsProvider.Default_Provider_Type__c;
        loadPointsProvidersByType();
    }
    
    private String   selectedProviderType=null;
    public String getSelectedProviderType(){
        return selectedProviderType;
    }
    public void setSelectedProviderType(String selProType){
        selectedProvider=NULL;
        this.selectedProviderType=selProType;
    }
    public PageReference   doSelectProviderType(){
        selectedProvider=NULL;
        this.selectedProviderType=dummyProvider.Provider_Type__c;
        // call this to initialize Provider Selection
        getPointsProviderOptions();
        
        // use this to navigate immediately to first item  in Category
        return navigateToPtoviderPage();
        
    }
    private String   selectedProvider = null;
    public String getSelectedProvider(){
        return selectedProvider;
    }
    public void setSelectedProvider(String provider){
        this.selectedProvider=provider;
    }
    private Map<String,List<Points_Provider__c>> pointsProvidersByType= null;
    private Map<ID,Points_Provider__c> pointsProvidersByID  = null;    
    private void loadPointsProvidersByType(){
        List<Points_Provider__c> allAvailableProviders =
        [SELECT pp.ID,pp.Name, pp.Provider_Status__c, pp.Provider_Type__c FROM Points_Provider__c pp];
        
        Map<String,List<Points_Provider__c>> providersMap = new Map<String,List<Points_Provider__c>>();
        pointsProvidersByID = new Map<Id,Points_Provider__c>();
        for(Points_Provider__c aProvider :allAvailableProviders){
            if(providersMap.get(aProvider.Provider_Type__c)== null){
                List<Points_Provider__c>  providerList = new List<Points_Provider__c>();
                providerList.add(aProvider);
                providersMap.put(aProvider.Provider_Type__c,providerList);
            }else{
                providersMap.get(aProvider.Provider_Type__c).add(aProvider);
            }
        }
        
        if(providersMap.size()>0){
            pointsProvidersByType= providersMap;
            
        }
    }

    
    private List <Points_Provider__c> availableProvidersByType = null;

    public List<SelectOption> getPointsProviderOptions(){
        availableProvidersByType = new List<Points_Provider__c>();
        if(pointsProvidersByType !=null){
            availableProvidersByType = pointsProvidersByType.get(selectedProviderType);
        }
        List<SelectOption> pointsProviderOptions = new List<SelectOption>();
        if(availableProvidersByType != null && availableProvidersByType.size()>0){
            for(Points_Provider__c aProvider : availableProvidersByType){
            // default the selected Provider to the first in the list
            if(selectedProvider == null || selectedProvider.trim().length()==0){
                selectedProvider=aProvider.ID;
            }
            SelectOption anOption = new SelectOption(aProvider.ID,aProvider.Name);
            pointsProviderOptions.add(anOption);
        }
        }
        
        if(pointsProviderOptions !=null && pointsProviderOptions.size()==0){
            pointsProviderOptions.add(new SelectOption('','--No Match Found--'));
        }
        
        return pointsProviderOptions;
    }

    public PageReference  navigateToPtoviderPage(){
        if(selectedProvider == custPointsProvider.Alitalia_Provider_ID__c){
            return Page.Alitalia_Earn_Miles_Data_Capture;
         }else if(selectedProvider == custPointsProvider.Etihard_Provider_ID__c){
            
              return Page.Etihard_Earn_Points;

        }else{
            return Page.Points_Provider_Selection;
        }
        
        
        
    }
    
    //Village Map
    public static final Map<String,String> VILAGE_CODE_MAP = new Map<String,String>{
        '*Bicester Village'=>'BV',
        '*Fidenza Village'=>'FV',
        '*Ingolstadt Village'=>'IV',
        '*Kildare Village'=>'KV',
        '*La Roca Village'=>'LR',
        '*La Vallee Village'=>'LV',
        '*Las Rozas Village'=>'LZ',
        '*Maasmechelen Village'=>'MV',
        '*Wertheim Village'=>'WV'
        };
    
    public static final String POINTS_TRANS_TYPE_CREDIT ='Credit';
    public static final String POINTS_ACCR_BONUS ='Bonus';
    public static final String POINTS_ACCR_BASE ='Base';
    
    public static final String VERIFIED_SUCCESS ='CUSTOMER VERIFIED';
    public static final String VERIFIED_FAIL ='CUSTOMER VERIFY FAILED';
    public static final String CREDIT_COMPLETE='CREDITING COMPLETE';
    public static final String CREDITING_FAIL = 'CREDITING FAILED';
    
    
}