@IsTest(SeeAllData=true)
public class CommunityForgotPasswordContTest {

    
    private static TestMethod void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        CommunityForgotPasswordController controller = new CommunityForgotPasswordController();
        controller.username = 'test@salesforce.com';     	
        
        System.assertEquals(controller.forgotPassword(),null); 
    }
}