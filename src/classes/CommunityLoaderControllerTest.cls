@isTest
public class CommunityLoaderControllerTest {
    
    public static testMethod void testController() {
        CommunityLoaderController controller = new CommunityLoaderController();
        
        Test.startTest();
    	PageReference pageRef = Page.CommunityLoader;
		Test.setCurrentPage(pageRef);
        Test.stopTest();
        
        controller.loadPage();
    }

}