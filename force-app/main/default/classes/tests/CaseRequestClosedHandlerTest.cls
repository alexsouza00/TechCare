@isTest
private class CaseRequestClosedHandlerTest {
      @isTest
    public static void caseRequestClosedTriggerTest(){

        Case_Request__c caseToClose = new Case_Request__c(Subject__c = 'Test', Status__c = 'In Progress', Resolution_Notes__c = 'Test');
        insert caseToClose;

        // Test that the trigger creates a case history when the status is changed to 'Closed'
        Test.startTest();
        caseToClose.Status__c = 'Closed';
        update caseToClose;
        Test.stopTest();

        List<Case_History__c> histories = [
            SELECT Case__c, SLA_Met__c
            FROM Case_History__c
            WHERE Case__c = :caseToClose.Id
        ];

        // Verify if a Case History was created for the case
        System.assertEquals(1, histories.size());
    }

    @isTest
    static void createCaseHistoryTest() {
        
        Case_Request__c caseInTime = new Case_Request__c(Subject__c = 'Test', Status__c = 'In Progress', Resolution_Notes__c = 'Test');
        Case_Request__c caseLate = new Case_Request__c(Subject__c = 'Test', Status__c = 'In Progress', Resolution_Notes__c = 'Test');
        
        
        List<Case_Request__c> cases = new List<Case_Request__c>();
        cases.add(caseInTime);
        cases.add(caseLate);
        
        insert cases;
            
        caseInTime.Status__c = 'Closed';
        caseLate.Status__c = 'Closed';
        caseLate.SLA_Deadline__c = Datetime.now().addDays(-1);
        
        update cases;

        List<Case_Request__c> casesList = [
            SELECT Id, Name, SLA_Deadline__c 
            FROM Case_Request__c 
            WHERE Id IN :new List<Id>{ caseInTime.Id, caseLate.Id }
        ];
        
        
        // Test the method that creates case histories 
        Test.startTest();
        CaseRequestClosedHandler.createCaseHistory(casesList);
        Test.stopTest();

        List<Case_History__c> histories = [
            SELECT Case__c, Name, SLA_Met__c
            FROM Case_History__c
            WHERE Case__c IN :new List<Id>{ caseInTime.Id, caseLate.Id }
        ];

      	// Verify that three history records were created
        System.assertEquals(4, histories.size());

        Map<Id, Case_History__c> historyByCase = new Map<Id, Case_History__c>();
        for (Case_History__c history : histories) {
            historyByCase.put(history.Case__c, history);
        }

        // Check the SLA status for each case
        System.assertEquals(true, historyByCase.get(caseInTime.Id).SLA_Met__c);
        System.assertEquals(false, historyByCase.get(caseLate.Id).SLA_Met__c);
    }
}