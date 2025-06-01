@RestResource(urlMapping='/CaseHistory/*')
global with sharing class CaseHistoryApi {
    
    @HttpGet
    global static void getCaseHistoryDetails() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String caseHistoryId = req.requestURI.substringAfterLast('/');
            
            List<Case_History__c> caseList = [
                SELECT Id, Case__r.Status__c, SLA_Met__c
                FROM Case_History__c
                WHERE Id = :caseHistoryId
                LIMIT 1
            ];
            
            if (caseList.isEmpty()) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"error": "Case History not found"}');
                return;
            }
            
            Case_History__c caseHis = caseList[0];
            
            Map<String, Object> result = new Map<String, Object>();
            result.put('Status', caseHis.Case__r.Status__c);
            result.put('SLA_Met_c', caseHis.SLA_Met__c);
            
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(result));
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "Internal Server Error"}');
        }
    }
}