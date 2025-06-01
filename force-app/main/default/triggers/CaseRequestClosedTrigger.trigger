trigger CaseRequestClosedTrigger on Case_Request__c(after update) {

    List<Case_Request__c> closedCases = new List<Case_Request__c>();

    // Check if the case status is set to 'Closed'
    for (Case_Request__c caseReq : Trigger.new) {
        if (caseReq.Status__c == 'Closed') {
            closedCases.add(caseReq);
        }
    }

    if (!closedCases.isEmpty()) {
        CaseRequestClosedHandler.createCaseHistory(closedCases);
    }
    
}