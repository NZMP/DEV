/*
* Author: Jerson Poblete
* Description: FeedView Email default handler
*/
global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherLoader() {
    }
    // The main interface method  
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {  
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;  
        // get user Return Email Address
        
        User u = [SELECT SenderEmail, SenderName FROM User WHERE Id = :UserInfo.getUserId()][0];
        String userSenderEmail = u.SenderEmail;
        String userSenderName = u.SenderName;
        
        // Check if the quick action is the standard Case Feed send email action
        for (Integer j = 0; j < defaults.size(); j++) {  
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults &&   
                defaults.get(j).getTargetSObject().getSObjectType() ==   
                EmailMessage.sObjectType &&   
                defaults.get(j).getActionName().equals('Case.Email') &&   
                defaults.get(j).getActionType().equals('Email')) {  
                    sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);  
                    break;  
                }  
        }  
        if (sendEmailDefaults != null && userSenderEmail != null) {  
            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();    
            // Set From address  
            
            /*
            Set<String> emailOrigin = Email_Origin_Default__c.getall().keyset();
            List<Case> c = [SELECT Origin, Unread_Emails__c FROM Case WHERE Id=:sendEmailDefaults.getContextId() AND Origin in: emailOrigin];
            Case cas = [SELECT Unread_Emails__c FROM Case WHERE Id=:sendEmailDefaults.getContextId() LIMIT 1];
            if(cas.Unread_Emails__c ){
                    Case ca = new Case();
                    ca.Id = cas.Id;
                    ca.Unread_Emails__c = false;
                    update ca;
                }
            if(c.size() > 0){
                emailMessage.FromName = Email_Origin_Default__c.getValues(c[0].Origin).FromName__c;
                emailMessage.FromAddress = Email_Origin_Default__c.getValues(c[0].Origin).FromAddress__c;
            }else{
                emailMessage.FromName = userSenderName;
                emailMessage.FromAddress = userSenderEmail;
            }
            */
            
            Case cas = [SELECT Unread_Emails__c, Unread_Email_Filter__c, Origin FROM Case WHERE Id=:sendEmailDefaults.getContextId() LIMIT 1];
            
            if(Email_Origin_Default__c.getValues(cas.Origin) != null){
                emailMessage.FromName = Email_Origin_Default__c.getValues(cas.Origin).FromName__c;
                emailMessage.FromAddress = Email_Origin_Default__c.getValues(cas.Origin).FromAddress__c;
            }else{
                emailMessage.FromName = userSenderName;
                emailMessage.FromAddress = userSenderEmail;
            }
            
            if(cas.Unread_Emails__c ){
                Case ca = new Case();
                ca.Id = cas.Id;
                ca.Unread_Emails__c = false;
                ca.Unread_Email_Filter__c = true;
                update ca;
            }
            
            if(cas.Unread_Email_Filter__c ){
                Case ca = new Case();
                ca.Id = cas.Id;
                ca.Unread_Email_Filter__c = false;
                update ca;
            }
            
        }  
    }    
}