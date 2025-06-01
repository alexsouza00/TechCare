public with sharing class CaseRequestClosedHandler {
    
    //Create a case history
    public static void createCaseHistory(List<Case_Request__C> cases) {

        List<Case_History__c> caseHistoryList = new List<Case_History__c>();
        
		
        for(Case_Request__c caseReq : cases){
        
            Case_History__c caseHistory = new Case_History__c();

            caseHistory.Name = caseReq.Name + ' History';
            caseHistory.Case__c = caseReq.Id;
            caseHistory.Time_Closed__c = Datetime.now();
            
            // Calculates and stores SLA duration and if it was met
            caseHistory.SLA_Met__c = caseHistory.Time_Closed__c <= caseReq.SLA_Deadline__c;
            
            Datetime createdDate = caseReq.SLA_Deadline__c.addHours(-8);
            Long duration = caseHistory.Time_Closed__c.getTime() - createdDate.getTime();
			Long totalMinutes = duration / (1000 * 60);
			Long durationHours = totalMinutes / 60;
			Long durationMin = totalMinutes - (durationHours * 60);
            
            caseHistory.SLA_Duration_in_Hours__c = durationHours;

			caseHistory.SLA_Duration__c = durationHours+ 'h ' + durationMin + 'min';

            
            caseHistoryList.add(caseHistory);

    }

    insert caseHistoryList;
    
    }

}