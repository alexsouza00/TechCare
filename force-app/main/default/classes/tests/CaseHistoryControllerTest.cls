@isTest
private class CaseHistoryControllerTest {
    @isTest
    public static void getSlaDurationTest(){
        
        Case_Request__c caseReq = new Case_Request__c(Subject__c = 'Test');
        insert caseReq;
        
        Case_History__c caseHis = new Case_History__c(Case__c = caseReq.Id, 
                                                      SLA_Duration__c = '4 Hrs'); 
        insert caseHis;
        
        
        Test.startTest();   
        String result = CaseHistoryController.getSlaDuration(caseReq.Id);
        Test.stopTest(); 
        
        System.assertEquals('4 Hrs', result);
    }
}