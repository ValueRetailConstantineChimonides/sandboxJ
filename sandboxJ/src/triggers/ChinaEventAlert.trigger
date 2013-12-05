trigger ChinaEventAlert on Event (after insert, after update) {
    ChinaEventsAlertManager.inclassTest = false;
    if(Trigger.isInsert){
        Map<Id,Event> oldMap = null;
        ChinaEventsAlertManager.processChinaEventAlert(Trigger.newMap, oldMap);
    }
    if(Trigger.isUpdate){
        ChinaEventsAlertManager.processChinaEventAlert(Trigger.newMap,Trigger.oldMap);
    }

}