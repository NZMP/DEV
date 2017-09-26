/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        //return Site.login(username, password, startUrl);
		      
        String startUrl = '/home/home.jsp';
        PageReference portalPage = new PageReference(startUrl);
        portalPage.setRedirect(true);
        PageReference p = Site.login(username, password, startUrl);
        //system.debug('p: ' + p);
        if (p == null) {
            return Site.login(username, password, null);
        } else { 
            return p;
        }
        
        return null;
    }
    
    global SiteLoginController () {}
    
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}