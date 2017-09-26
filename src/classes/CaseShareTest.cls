//@author JS@Davanti Consulting 09/16
@istest public class CaseShareTest {
	@istest static void test1(){
        Id SoldToRtypeID = [SELECT Id FROM RecordType WHERE Name = 'Sold To Party'].Id;
        id communityId = [select id from profile where name ='Reseller Partner Community Profile' limit 1].id;
     
		integer batchsize = 2; 
        account[] portalAccounts = new account[]{};
        contact[] portalContacts = new contact[]{}; 
        user[] portalUsers = new user[]{}; 
        user[] sysUsers = new user[]{};
        
            user a =  new User( email='getstsze@gmaitsststsl.com',
                               profileid = [select id from profile where name ='System Administrator' limit 1].id, 
                               userRoleId = [select id from userrole where name ='Account Manager Europe' limit 1].id,
                               UserName='gtszzztsts@gmaiststststsl.com', //+ system.label.PortalEmailSuffix, 
                               Alias = 'GDS',
                               TimeZoneSidKey='America/New_York',
                               EmailEncodingKey='ISO-8859-1',
                               LocaleSidKey='en_US', 
                               LanguageLocaleKey='en_US',
                               PortalRole = 'Manager',
                               FirstName = 'getststs',
                               LastName = 'getststs');
           sysUsers.add(a);
                               
           user b =  new User( email='getstsze@gmaitsststs2.com',
                               profileid = [select id from profile where name ='System Administrator' limit 1].id, 
                               userRoleId = [select id from userrole where name ='Account Manager Europe' limit 1].id,
                               UserName='gtszzztsts@gmaiststststs2.com', //+ system.label.PortalEmailSuffix, 
                               Alias = 'GDS',
                               TimeZoneSidKey='America/New_York',
                               EmailEncodingKey='ISO-8859-1',
                               LocaleSidKey='en_US', 
                               LanguageLocaleKey='en_US',
                               PortalRole = 'Manager',
                               FirstName = 'getststs2',
                               LastName = 'getststs2');
          sysUsers.add(b);     
        insert sysUsers;
        
             
        system.runAs(a ){
            for ( integer i = 0; i < batchsize; i ++)
                portalAccounts.add( new account ( name = 'portalAccounttststs'+i, recordtypeid = SoldToRtypeID));
            insert portalAccounts;
            
            for ( integer i = 0; i < batchsize; i ++)
                portalContacts.add( new contact (LastName = 'portalContacttstsst'+i, AccountId = portalAccounts[i].Id) );
            insert portalContacts;
            
            for ( integer i = 0; i < batchsize; i ++)
                portalUsers.add ( new User( email='getststs'+i+'@gmaitsststsl.com',
                                           profileid = communityId, 
                                           UserName='gtststs@gmaiststststsl.com'+i, //+ system.label.PortalEmailSuffix, 
                                           Alias = 'GDS'+i,
                                           TimeZoneSidKey='America/New_York',
                                           EmailEncodingKey='ISO-8859-1',
                                           LocaleSidKey='en_US', 
                                           LanguageLocaleKey='en_US',
                                           ContactId = portalContacts[i].Id,
                                           PortalRole = 'Manager',
                                           FirstName = 'getststs'+i,
                                           LastName = 'getststs'+i));
            insert portalUsers;   
            

            
            test.startTest();
            case[] cases = new case[]{};
                cases.add( new case ( accountid  = portalAccounts[0].id , 
                                     recordtypeid  = [select id from recordtype 
                                                      where sobjecttype ='Case' and name ='Complaints' 
                                                      and isActive = true limit 1].id ,
                                    Origin = 'Phone',
                                    Status = 'New')
                         );
            	
            insert cases;
            
            portalAccounts.get(0).OwnerId = sysUsers.get(1).Id;
            update portalAccounts;
            
            cases.get(0).Subject = 'test';
            update cases;
            test.stopTest();
        }
       integer x = [select count() from caseshare where rowcause = 'manual'];
       system.debug(x);
		system.assertEquals(2, x);

    }
}