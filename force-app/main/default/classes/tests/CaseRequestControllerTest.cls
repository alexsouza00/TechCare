@isTest
public class CaseRequestControllerTest {

    @isTest
    static void testUpdateStatus_Success() {
        Case_Request__c caseReq = new Case_Request__c(
            Subject__c = 'Test Case for updateStatus',
            Status__c = 'New',
            SLA_Deadline__c = Datetime.now().addHours(8),
            Resolution_Notes__c = 'Test resolution notes'  // Preenchido para passar validação
        );
        insert caseReq;

        Test.startTest();
        CaseRequestController.updateStatus(caseReq.Id, 'Closed');
        Test.stopTest();

        Case_Request__c updatedCase = [SELECT Status__c FROM Case_Request__c WHERE Id = :caseReq.Id];
        System.assertEquals('Closed', updatedCase.Status__c, 'Status must be updated to Closed');
    }

    @isTest
    static void testUpdateStatus_RecordNotFound() {
        Test.startTest();
        try {
            // Id inexistente (objeto customizado normalmente começa com 'a00')
            Id fakeId = 'a000000000000000AAA';
            CaseRequestController.updateStatus(fakeId, 'Closed');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No Case Request found'), 'Exception message must indicate no case found');
        }
        Test.stopTest();
    }
}