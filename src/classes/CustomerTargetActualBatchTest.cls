@isTest(seeAllData=false)
private with sharing class CustomerTargetActualBatchTest {    

    static testMethod void testYearStringAndFiscalQuarter(){
        CustomerTargetActualBatch batchJob=new CustomerTargetActualBatch();
        system.assertEquals('Jan 2012 - Dec 2012', batchJob.getYearString(1,Date.newInstance(2012,1,1)));
        system.assertEquals('Jan 2012 - Dec 2012', batchJob.getYearString(1,Date.newInstance(2012,12,31)));
        system.assertEquals('Jan 2012 - Dec 2012', batchJob.getYearString(1,Date.newInstance(2012,8,1)));
        
        system.assertEquals('Aug 2012 - Jul 2013', batchJob.getYearString(8,Date.newInstance(2012,8,1)));
        system.assertEquals('Aug 2012 - Jul 2013', batchJob.getYearString(8,Date.newInstance(2013,7,31)));
        system.assertEquals('Aug 2013 - Jul 2014', batchJob.getYearString(8,Date.newInstance(2013,10,31)));
        system.assertEquals('Aug 2012 - Jul 2013', batchJob.getYearString(8,Date.newInstance(2013,4,1)));
        system.assertEquals('Aug 2013 - Jul 2014', batchJob.getYearString(8,Date.newInstance(2013,12,31)));
        system.assertEquals('Aug 2012 - Jul 2013', batchJob.getYearString(8,Date.newInstance(2013,1,1)));

/*
        system.assertEquals(1, batchJob.getFiscalQuarter(1,Date.newInstance(2012,1,1)));
        system.assertEquals(4, batchJob.getFiscalQuarter(1,Date.newInstance(2012,12,31)));
        system.assertEquals(3, batchJob.getFiscalQuarter(1,Date.newInstance(2012,8,1)));
        
        system.assertEquals(1, batchJob.getFiscalQuarter(8,Date.newInstance(2012,8,1)));
        system.assertEquals(4, batchJob.getFiscalQuarter(8,Date.newInstance(2013,7,31)));
        system.assertEquals(1, batchJob.getFiscalQuarter(8,Date.newInstance(2013,10,31)));
        system.assertEquals(3, batchJob.getFiscalQuarter(8,Date.newInstance(2013,4,1)));
        system.assertEquals(2, batchJob.getFiscalQuarter(8,Date.newInstance(2013,12,31)));
        system.assertEquals(2, batchJob.getFiscalQuarter(8,Date.newInstance(2013,1,1)));

        system.assertEquals(1, batchJob.getFiscalQuarter(8,Date.newInstance(2013,8,1)));
*/
        
        // get the Q1 start and end datetime
        Datetime[] v=batchJob.getQuarter(8,2013,1);
        system.assertEquals(2,v.size());
        system.assertEquals(Datetime.newInstance(2013,8,1,0,0,0),v[0]);
        system.assertEquals(Datetime.newInstance(2013,10,31,23,59,59),v[1]);

        v=batchJob.getQuarter(1,2013,4);
        system.assertEquals(2,v.size());
        system.assertEquals(Datetime.newInstance(2013,10,1,0,0,0),v[0]);
        system.assertEquals(Datetime.newInstance(2013,12,31,23,59,59),v[1]);
    }
 
    
    static testMethod void testSchedule(){
        Test.startTest();
            CustomerTargetActualScheduler sch=new CustomerTargetActualScheduler();
            String cronFormat = 'ss mm HH dd MM ? yyyy';
            Datetime dt=system.now().addSeconds(1);//delay 1 second for test
            String cronText = dt.format(cronFormat, 'NZ');
            //system.Schedule('test batch run', cronText, sch);// should pick up zero account
        Test.stopTest();
    }
    
    static testMethod void testButton(){        
        Account tstAcct=TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY, 'TestAccountGroup', 'AccNo1', true);
        CustomerTargetActualRefreshCtrl buttonCtrl=new CustomerTargetActualRefreshCtrl(new ApexPages.StandardController(tstAcct));
        buttonCtrl.redir();
    }

    static testMethod void testTargetCount(){
        
        // batch job only executes THIS_FISCAL_QUARTER
        // have to set up an event that is part of current FISCAL-QUARTER   
        Date testDate=Date.today();
        integer fiscalStartMonth=[select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;       
        
        CustomerTargetActualBatch batchJob=new CustomerTargetActualBatch(testDate);//only use for data setup
        String yearString=batchJob.getYearString(fiscalStartMonth,testDate);
        integer tQ=batchJob.getFiscalQuarter(fiscalStartMonth,testDate);
        system.debug(LoggingLevel.INFO, 'Quarter: ' + tQ);
       
        Account tstAcct=TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY, 'TestAccountGroup', 'AccNo1', true);
        Contact tstCnt=new Contact(accountid=tstAcct.id,firstname='Testing',lastname='whatever');
        insert tstCnt;
        Customer_Target__c testTarget=new Customer_Target__c(account__c=tstAcct.id, status__c='NA',
            Actuals_Q1__c=0, Actuals_Q2__c=0, Actuals_Q3__c=0, Actuals_Q4__c=0, year__c=yearString);
        insert testTarget;
        Event tstEvt=new Event(startDateTime=Datetime.newInstance(testDate, Time.newInstance(11,0,0,0)),whoId=tstCnt.id,
            endDatetime=Datetime.newInstance(testDate, Time.newInstance(12,0,0,0)), type='Customer Meeting (In Person / On Phone)',
            subject='Testing 123');

        Event tstEvt2=new Event(startDateTime=Datetime.newInstance(testDate+3, Time.newInstance(11,0,0,0)),whoId=tstCnt.id,
            endDatetime=Datetime.newInstance(testDate+3, Time.newInstance(12,0,0,0)), type='Customer Meeting (In Person / On Phone)',
            subject='Testing XYZ future');// furture, excluded

        Event tstEvt3=new Event(startDateTime=Datetime.newInstance(testDate-370, Time.newInstance(11,0,0,0)),whoId=tstCnt.id,
            endDatetime=Datetime.newInstance(testDate-370, Time.newInstance(12,0,0,0)), type='Customer Meeting (In Person / On Phone)',
            subject='Testing XYZ future');//previous year, excluded

        Event tstEvt4=new Event(startDateTime=Datetime.newInstance(testDate, Time.newInstance(11,0,0,0)),whoId=tstCnt.id,
            endDatetime=Datetime.newInstance(testDate, Time.newInstance(12,0,0,0)), type='whatever',
            subject='Testing 123');//wrong type


        insert new Event[]{tstEvt,tstEvt2,tstEvt3,tstEvt4};

        Test.startTest();
            // seeAllData is set to false, should only see 1 customer_target
            // we have to run the batch job directly... or we cannot see the test data in scheduler context
            CustomerTargetActualBatch testJob=new CustomerTargetActualBatch(testDate);
            ID batchprocessid = Database.executeBatch(testJob);
        Test.stopTest();
        
        Customer_Target__c vTC=[Select id, name, account__c, Actuals_Q1__c, Actuals_Q2__c, Actuals_Q3__c, Actuals_Q4__c, status__c,
            Target_Visits_Q1__c, Target_Visits_Q2__c, Target_Visits_Q3__c, Target_Visits_Q4__c from Customer_Target__c where id=:testTarget.id];
        system.debug(LoggingLevel.INFO, 'Quarter: ' + tQ);
        system.debug(LoggingLevel.INFO, 'Actual: ' + vTC);
        system.assertEquals('Tested',vTC.status__c);
/*
        system.assertEquals(tQ==1?1:0, vTC.Actuals_Q1__c);
        system.assertEquals(tQ==2?1:0, vTC.Actuals_Q2__c);
        system.assertEquals(tQ==3?1:0, vTC.Actuals_Q3__c);
        system.assertEquals(tQ==4?1:0, vTC.Actuals_Q4__c);
*/
    }
}