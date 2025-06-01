public class CaseHistoryController {
    
    // Returns the SLA duration
    @AuraEnabled(cacheable=true)
    public static String getSlaDuration(Id caseRequestId) {
        
        Case_History__c history = [
        							SELECT SLA_Duration__c
       	 							FROM Case_History__c
        							WHERE Case__c = :caseRequestId
        							LIMIT 1
        ];
        return history.SLA_Duration__c;
    }
    
}