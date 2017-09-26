@isTest
public class MarkCaseAsRead_Batch_SchedulerTest {
    static testMethod void testMarkCaseAsRead() {
        List<Case> cases = TestDataHelper.createCases(2, 'Customer Cases', 'Email');
        insert cases;
        List<EmailMessage> ems = new List<EmailMessage>();
        EmailMessage em1 = new EmailMessage();
        em1.Status = '0';
        em1.ParentId = cases[0].id;
        ems.add(em1);
        EmailMessage em2 = new EmailMessage();
        em2.Status = '1';
        em2.ParentId = cases[1].id;
        ems.add(em2);
        insert ems;
        Test.StartTest();
        MarkCaseAsRead_Batch_Scheduler scheduleClass = new MarkCaseAsRead_Batch_Scheduler();
        String sch = '0 1 * * * ?';
        String jobId = System.schedule('MarkCaseAsRead_Batch_Scheduler', sch, scheduleClass);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(sch, ct.CronExpression);
        Test.stopTest(); 
    }
}