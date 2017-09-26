/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class ResellerCommunityLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
		      
        String startUrl = '/s';
        PageReference portalPage = new PageReference(startUrl);
        portalPage.setRedirect(true);
        PageReference p = Site.login(username, password, startUrl);
        system.debug('p: ' + p);
        if (p == null) {
            return Site.login(username, password, null);
        } else { 
            return p;
        }
        
        return null;
    }
    
    global ResellerCommunityLoginController () {}
    

}