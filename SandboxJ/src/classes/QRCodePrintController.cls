public without sharing class QRCodePrintController {
    public String cmid {get; private set;}
    
    public QRCodePrintController(){
        cmid =  ApexPages.currentPage().getParameters().get('cmid');
    }
}