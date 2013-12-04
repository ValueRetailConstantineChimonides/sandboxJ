trigger B2BAlertRecipientBefore on B2B_Alert_Recipient__c (before update) {
    //B2B_Alert_Recipient__c recipientsHolder = Trigger.new[0];
    List<B2B_Alert_Recipient__c> recipientHolders = new List<B2B_Alert_Recipient__c>();
    for (B2B_Alert_Recipient__c recipientsHolder : Trigger.new) {
        B2B_Alert_Recipient__c old = Trigger.oldMap.get(recipientsHolder.Id);
        if (!old.Ready_To_Dispatch__c  && recipientsHolder.Ready_To_Dispatch__c) {
            recipientHolders.add(recipientsHolder);
        }
    }
    if (!recipientHolders.isEmpty()) {
        // To Use OLD Sender Enable
        //B2BContactReportAlertSender sender = new B2BContactReportAlertSender();
        //sender.sendAlerts(recipientHolders);
        
        // To Use New Sender Enable
        AsynCB2BReportsSender.B2BReportsSender sender = new AsynCB2BReportsSender.B2BReportsSender();
        sender.sendAlerts(recipientHolders);
        
        //mark as sent
        for(B2B_Alert_Recipient__c recipientsHolder : recipientHolders){
            recipientsHolder.Ready_To_Dispatch__c = false;
            recipientsHolder.Sent__c = System.now();
        }
    }
    

}