public class CaseRequestController {
    
	// Reopens the case when triggered by an LWC component    
    @AuraEnabled
    public static void reopenCase(Id caseId){
        
        Case_Request__c caseReq = [SELECT Id, Status__c 
                                   FROM Case_Request__c 
                                   WHERE Id = :caseId LIMIT 1];
        
        caseReq.SLA_Deadline__c = Datetime.now().addHours(+8);
        caseReq.Status__c = 'In Progress';
        update caseReq;
    }
    
    //Updates the status using the Aura Path component
    @AuraEnabled
    public static void updateStatus(Id recordId, String newStatus) {
        
        List<Case_Request__c> caseRequestList = [SELECT Id, Status__c 
                                                 FROM Case_Request__c 
                                                 WHERE Id = :recordId 
                                                 LIMIT 1
                                                ];
        
        if(caseRequestList.isEmpty()) {
            throw new AuraHandledException('No Case Request found for Id: ' + recordId);
        }
        
        Case_Request__c caseRequest = caseRequestList[0];
        
        caseRequest.Status__c = newStatus;
        update caseRequest;
    }
}