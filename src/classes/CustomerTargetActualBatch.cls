/** Created by Eric on 3rd August 2013
 *  
 *  this batch job will:
 *  1. pick up all the Customer_Target__c records for the current Fiscal year
 *  2. For each account, fetch all the "completed" events in the current Fiscal Quarter.
 *     Completed means the end-date is today or before today
 *
 *  NOTE: this batch job runs under the timezone on the running user
 *    - we cannot use GMT, as it will not work for NZ or US based events
 *    - the same applies that we cannot run anything in NZ timezone... HOWEVER, the user who run the batch (system user) will be NZ time-zoned
 *    - it is decided to use the "local" timezone based on the login-user.  It means, if a user do a manual sync, the user's timezone will be used  
 */
global class CustomerTargetActualBatch implements Database.Batchable<SObject>{ // no need to implment interface Database.AllowsCallouts

    private Date referenceDate{set;get;}
    private Datetime referenceDateTimeLocal{set;get;}
    @TestVisible private String soqlStr{set;get;}
    @TestVisible private integer fiscalStartMonth{set;get;}
    @TestVisible private String singleAccount{set;get;}
    public CustomerTargetActualBatch() {
        this(null);
    }
    public CustomerTargetActualBatch(Datetime refDT){
        this(refDT,null);
    }
    public CustomerTargetActualBatch(Datetime refDT,String acctID){
    
    system.debug(acctID); 
        if(refDT==null){referenceDateTimeLocal=system.now();}//local timezone
        else{referenceDateTimeLocal=refDT;}
        referenceDate=referenceDateTimeLocal.date(); // local timezone to the user
        singleAccount=acctID;
        system.debug(refDT);
        // now based on the reference date, find the fiscal year
        fiscalStartMonth=[select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;       
        // the year__c field is a picklist and it is in the format of this under the Customer_Target__c object
        // e.g.  Aug 2012 - Jul 2013, Aug 2013 - Jul 2014
        soqlStr = 'Select id, name, account__c, Actuals_Q1__c, Actuals_Q2__c, Actuals_Q3__c, Actuals_Q4__c, '+
            'Target_Visits_Q1__c, Target_Visits_Q2__c, Target_Visits_Q3__c, Target_Visits_Q4__c from Customer_Target__c '+
            'Where year__c = \''+getYearString(fiscalStartMonth,referenceDate)+'\'';
        if(acctID!=null){soqlStr+=' and account__c= \''+acctID+'\'';}
        
    }

    @TestVisible private String getYearString(Integer FiscalYearStartMonth,Date refDate){       
        Map<Integer,String>mthMap=new Map<Integer,String>{
            1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',
            7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
        Integer FiscalYearEndMonth=FiscalYearStartMonth-1;
        if(FiscalYearEndMonth<=0){FiscalYearEndMonth=12;}
        
        String year=mthMap.get(FiscalYearStartMonth)+' ';
        Integer thisMonth=refDate.month(), thisYear=refDate.year();
        
        if(thisMonth>=FiscalYearStartMonth){year+=thisYear+' - ';}
        else{year+=(thisYear-1)+' - ';}
        
        year+=mthMap.get(FiscalYearEndMonth)+' ';
        
        if(FiscalYearEndMonth>FiscalYearStartMonth){year+=''+thisYear;}
        else if(FiscalYearEndMonth<FiscalYearStartMonth){
            if(thisMonth<=FiscalYearEndMonth){year+=''+thisYear;}
            else{year+=''+(thisYear+1);}
        }
        system.debug(year);
        return year;
    }

    @TestVisible private integer getFiscalQuarter(Integer FiscalYearStartMonth,Date refDate){
        Integer thisMonth=refDate.month(),q=0;
        Integer[] quarterStart=new Integer[]{}, quaterEnd=new Integer[]{};
        for(Integer i=0; i<4; i++){
            Integer temp=FiscalYearStartMonth+(i*3);
            if(temp>12){temp-=12;}//never reach negative
            quarterStart.add(temp);
            temp+=3;
            if(temp>12){temp-=12;}//never reach negative
            quaterEnd.add(temp);
        }
        for(Integer i=0;q==0&&i<4; i++){
            Integer e=quaterEnd[i],s=quarterStart[i];
            if(s>e&&(s<=thisMonth||e>=thisMonth)){q=i+1;}
            else if(s<=thisMonth && e>=thisMonth){q=i+1;}
        }
           system.debug(q);
        return q;
    }
    
    /* returns the start/end datetime on the provided quarter
     * for example, for a fiscal year starts from Aug (8) on 2013, the range for Q1 is:
     * the array contains 2 items, start and end datetime:
     * value[0] = 2013-8-1 00:00:00
     * value[1] = 2013-10-31 23:59:59
     */
    @TestVisible private Datetime[] getQuarter(Integer FiscalYearStartMonth, Integer theYear, Integer qtr){
        // from SF documentation:
        // Datetime.newInstance(): Constructs a Datetime from Integer representations of the 
        //  year, month (1=Jan), day, hour, minute, and second in the <b>local time zone</b>. The returned date is in the GMT time zone
        //
        //an event was created with enddate: 3/09/2013 1:00 PM (using user's local timezone)
        //Event e=[select id, enddatetime from event where id = '00UO0000003L4p5'];
        //Datetime loc=Datetime.newInstance(2013,9,3,13,0,0);
        //Datetime gmt=Datetime.newInstanceGMT(2013,9,3,13,0,0);
        //system.debug(logginglevel.info, 'event: '+e.enddatetime.gettime());
        //system.debug(logginglevel.info, 'newinstnace: '+ loc.gettime());
        //system.debug(logginglevel.info, 'newinstancegmt: ' + gmt.gettime());
        //
        // output:
        // USER_DEBUG|[4]|INFO|event: 1378170000000
        // USER_DEBUG|[8]|INFO|newinstnace: 1378170000000
        // USER_DEBUG|[9]|INFO|newinstancegmt: 1378213200000
        
        Datetime[] qtrPair=new Datetime[]{};
        Integer temp=(qtr-1)*3+FiscalYearStartMonth, tmpY=theYear;
        if(temp>12){temp-=12;tmpY=theYear+1;}//never reach negative
        qtrPair.add(Datetime.newInstance(tmpY,temp,1,0,0,0));
        temp+=3;//inclusive of current month
        if(temp>12){temp-=12;tmpY=theYear+1;}//never reach negative
        Datetime tmpEnd=Datetime.newInstance(tmpY,temp,1,0,0,0);
        qtrPair.add(tmpEnd.addSeconds(-1));
        return qtrPair;
    }

    @TestVisible private void updateTargets(SObject[]sObjects, Integer FiscalYearStartMonth, Datetime refDT){
        system.debug(refDT);
        system.debug(FiscalYearStartMonth);
        system.assert(sObjects.size()<=200);
        Map<String,Customer_Target__c>targetMap=new Map<String,Customer_Target__c>();
        for(SObject so:sObjects){
            // not Customer_Target__c object, it's a private method... very unlikely
            Customer_Target__c tc=(Customer_Target__c)so;
            targetMap.put(tc.account__c,tc);
        }
        
        Date refDate = refDT.date();//convert to local timezone
        //integer qtr=getFiscalQuarter(FiscalYearStartMonth,refDate);
        //system.assert(qtr>0);     
        integer theYear=refDate.year();
        system.debug(refDate.month());
        If(refDate.month()<8){ theYear = refDate.year() -1;} 
        system.debug(theYear );
        Map<id,Customer_Target__c>updatingTargets=new Map<id,Customer_Target__c>();
        for(integer qtr=1; qtr<5; qtr++){
            // we have to run through the current fiscal year
            // but have to remain the Q1, Q2, Q3, and Q4 logic
                                    
            // ALWAYS starts from Q1
            Datetime[] quarterDTs=getQuarter(FiscalYearStartMonth,theYear,qtr);
            system.debug(quarterDTs[0]);
            system.debug(quarterDTs[1]);
            system.assertEquals(2,quarterDTs.size());
            AggregateResult[] results=[select AccountId, count(id) cnt from Event 
                where EndDateTime <= :refDT
                and EndDateTime >= :quarterDTs[0] and EndDateTime <= :quarterDTs[1]
                and type = 'Customer Meeting (In Person / On Phone)'
                and accountid in :targetMap.keySet()
                group by AccountId];            
            
            for(AggregateResult ar:results){
                String aid=String.ValueOf(ar.get('AccountId'));
                Customer_Target__c tc=targetMap.get(aid);
                if(tc==null){continue;}//very unlikely
                integer cnt=Integer.valueOf(ar.get('cnt'));
                // now we need to update based on which Fiscal-Quarter we are in
                tc.Actuals_Q1__c=qtr==1?cnt:tc.Actuals_Q1__c;
                tc.Actuals_Q2__c=qtr==2?cnt:tc.Actuals_Q2__c;
                tc.Actuals_Q3__c=qtr==3?cnt:tc.Actuals_Q3__c;
                tc.Actuals_Q4__c=qtr==4?cnt:tc.Actuals_Q4__c;
                if(Test.isRunningTest()){tc.status__c='Tested';}
                updatingTargets.put(tc.id,tc);
                targetMap.put(aid,tc);
            }
        }
        
        Database.update(updatingTargets.values(),false);//allow partial success
    }


    global Database.QueryLocator start(Database.BatchableContext info){
        return Database.getQueryLocator(soqlStr);
    }

    global void execute(Database.BatchableContext info, List<SObject> scope){
        // may hit governor limit if not careful
        updateTargets(scope, this.fiscalStartMonth, this.referenceDateTimeLocal);
    }
    
    global void finish(Database.BatchableContext info){
        // nothing to do here
    }

}