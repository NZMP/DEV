@IsTest(SeeAllData=true)
public class ResellerCommunityLoginControllerTest {

     private static TestMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        ResellerCommunityLoginController controller = new ResellerCommunityLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
    
}