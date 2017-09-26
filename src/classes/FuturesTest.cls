@istest public class FuturesTest {
//    @author JS @ Davanti Consulting 08/16

    @istest  static void testCallout(){
         // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements FuturesCalloutMock. 
        
        // schedule new run of schedulable class
        
        
        String CRON_EXP = '0 0 * * * ?';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FuturesCalloutMock());
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new Futures());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        Futures.setFutures();
        Test.stopTest();

        //assert cache has a record
        system.assertNotEquals( null, Futures.getFutures());
        

        
    }
    
}