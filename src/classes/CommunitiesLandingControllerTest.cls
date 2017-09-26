/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest(SeeAllData=true)
public with sharing class CommunitiesLandingControllerTest {
    private static testmethod void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        Test.setCurrentPage(Page.CommunitiesLanding);
        CommunitiesLandingController controller = new CommunitiesLandingController();
        controller.forwardToStartPage();
    }
}