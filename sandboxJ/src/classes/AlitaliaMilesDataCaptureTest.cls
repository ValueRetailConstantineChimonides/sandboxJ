public with sharing class AlitaliaMilesDataCaptureTest {
    static testMethod void testAlitaliaEarnMilesDatatCaptureController(){
        PageReference pageRef = new PageReference('/apex/Alitalia_Earn_Miles_Data_Capture');
        
        ApexPages.StandardController ssPointsTransaction = new ApexPages.StandardController(new Points_Transaction__c());
        AlitaliaEarnMilesDatatCaptureController alitaliEran = new AlitaliaEarnMilesDatatCaptureController(ssPointsTransaction);
        
        alitaliEran.inTesting = true;
        alitaliEran.resetVerifyFields();
        System.assertEquals('', alitaliEran.mileMigliaNo);
        System.assertEquals('', alitaliEran.custSurname);
        
        alitaliEran.mileMigliaNo = '676702';
        alitaliEran.verifyCustomer();
        alitaliEran.custSurname = 'NEGRIN';
        alitaliEran.verifyCustomer();
        System.assertEquals(false,alitaliEran.getHasVerifyCustomerError());
        
        alitaliEran.dummyPoints_Transaction.Promo_Type__c = 'Bonus';
        alitaliEran.doConversion();
        alitaliEran.transactBasicBonus = 'Bonus';
        alitaliEran.doConversion();
        alitaliEran.bonusConversionValue = 4;
        alitaliEran.doConversion();
        alitaliEran.dummyPoints_Transaction.Activity_Date__c = DateTime.newInstance(System.currentTimeMillis()).date();
        alitaliEran.doConversion();
        alitaliEran.setTransAmountValueString('100'); alitaliEran.doAddValue();
        alitaliEran.setTransAmountValueString('100'); alitaliEran.doAddValue();
        alitaliEran.setTransAmountValueString('100'); alitaliEran.doAddValue();
        alitaliEran.setTransAmountValueString('100'); alitaliEran.doAddValue();
        
        alitaliEran.transactionItemsList.get(0).removeItem = true;
        
        alitaliEran.doRemoveTransaction();
        alitaliEran.doRenderBonusField();
        
        alitaliEran.doConversion();
        System.assertEquals(false,alitaliEran.getHasConversionorAddError());
        
        System.assertEquals(true,alitaliEran.getRenderBONUS_POINTS_RESULTS());
        system.assertEquals('0.00',alitaliEran.getTransAmountValueString());
        System.assertEquals(300, alitaliEran.totalPointsAccrued);
        System.assertEquals(900, alitaliEran.totalPointsAccruedBonus);
        
        //test the web service calls
        alitaliEran.confirmTransactionSubmit =true;
        alitaliEran.doTransactionSubmit();
        
        
    }
    

}