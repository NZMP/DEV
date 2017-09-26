public with sharing class CampaignExt {
 
    public Campaign camp {get;set;}
    public boolean disableSend {get;set;}
    public Id campaignId {get;set;}
    public List<CampaignMember> cMembers = new List<CampaignMember>();
    
    public Map<String,Site_Settings__c> siteSettings = new Map<string,Site_Settings__c>();
    String URL_ACCEPT; 
    String URL_DECLINE;
    
    public String folderId {get;set;}
    public List<OrgWideEmailAddress> emailList = new List<OrgWideEmailAddress>();
    
    public String replyto {get;set;}
    public List<SelectOption> replyOptions = new List<SelectOption>();
    public Map<String, String> replyOptionsMap = new Map<String, String>();
    public String previewTemplate {get;set;}
    public String inviteSubject {get;set;}
    
    
    public CampaignExt(ApexPages.StandardController controller){
    	System.debug('### in the constructor() ');
        this.camp = (Campaign)controller.getRecord();
        disableSend=false;   
        
        if(this.camp.Mail_Body_Text__c==null){
            disableSend=true;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'The Invitation Body text field is blank.  Please add your invitation and try again.'));
        }else if(this.camp.Accept_Link_Text__c==null || this.camp.Decline_Link_Text__c==null || this.camp.Invitation_Subject_Text__c==null){
            disableSend=true;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Please enter the Accept Link Text, Decline Link Text and Invitation Subject Text fields.'));
        }
        
        campaignId = ApexPages.currentPage().getParameters().get('id'); 
        
        cMembers = new List<CampaignMember>([
            select Id, CampaignId, Send_Invite__c, Send_Invite_As__c, LeadId, ContactId, Status,Accept_URL__c, 
            Decline_URL__c,Mail_Body_Text__c, Reminder_Body_Text__c, Campaign.Mail_Body_Text__c, Campaign.Reminder_Body_Text__c,Contact.Email,Contact.Name,Email_Field_Displayed__c    
            from CampaignMember where CampaignId = :campaignId 
            AND Status = 'Invite Not Sent' AND Send_Invite__c = false AND Contact.Email <> '']);
		
		// Create URLs based on a custom setting
		siteSettings = Site_Settings__c.getAll();
		Site_Settings__c regSiteSetting = siteSettings.get('registrationDomainUrl');

        URL_ACCEPT = regSiteSetting.Value__c + '?response=1&cid=';
        URL_DECLINE = regSiteSetting.Value__c + '?response=0&cid=';
        
              
        List<Folder> folders = [select Id, Name, DeveloperName, Type from Folder where DeveloperName = 'Fonterra_Events_Template' and Type = 'Email'];
        if (folders != null) folderId = folders[0].Id;
        
        emailList = [select Address, DisplayName From OrgWideEmailAddress];
        replyOptions.add(new SelectOption('', ''));
        for(OrgWideEmailAddress owea: emailList){
            replyOptions.add(new SelectOption(owea.Address, owea.DisplayName+' ('+owea.Address+')'));
            replyOptionsMap.put(owea.Address, owea.DisplayName);
        }
   }
    
    public PageReference sendInvite(){
        
        if(replyto==null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Please select a Reply-To Address.'));
            return null;
        }
    	system.debug('### cm.cMembers: '+cMembers);

        for (CampaignMember cm : cMembers) {
        	system.debug('### cm.ContactId: '+cm.ContactId);
            cm.Status = 'Invite Sent';
            cm.Send_Invite__c=true;
            cm.Send_Invite_As__c=replyto;
            cm.Mail_Body_Text__c = cm.Campaign.Mail_Body_Text__c;
            cm.Reminder_Body_Text__c = cm.Campaign.Reminder_Body_Text__c;
            cm.Accept_URL__c= URL_ACCEPT + cm.Id;
            cm.Decline_URL__c= URL_DECLINE + cm.Id;
        }
        system.debug('### cMembers: '+cMembers);
       // system.debug('### campaignMemberIds: '+campaignMemberIds);
        update cMembers;
        
        Pagereference page = new Pagereference ('/' + campaignId);
        return page;
    }
    
    public List<CampaignMember> getMembers(){
        return cMembers;
    }
    public PageReference cancelInvite(){
        return new PageReference ('/' + campaignId);
    }
    public List<SelectOption> getReplyOptions(){
        return replyOptions;
    }
    public void showPreview(){
        EmailTemplate template = new EmailTemplate();
        try{
            template = [Select TemplateType, TemplateStyle,  
                Subject, NamespacePrefix, Name, IsActive, Id, HtmlValue, brandtemplateId, 
                FolderId, DeveloperName, Description,Body From EmailTemplate 
                    where FolderId = :folderId and DeveloperName='Email_Template_Preview'];
           System.debug('### in the showPreview() method');
            if(template.Id !=null){
    
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setTemplateId(template.Id);
                
                Savepoint sp = Database.setSavepoint();
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                Database.rollback(sp);
                
                previewTemplate=mail.getHTMLBody();
                previewTemplate = previewTemplate.replace('[0]',camp.Mail_Body_Text__c);
                previewTemplate = previewTemplate.replace('[1]',camp.Accept_Link_Text__c);
                previewTemplate = previewTemplate.replace('[2]',camp.Decline_Link_Text__c);
                inviteSubject = camp.Invitation_Subject_Text__c;
            }   
        }catch(Exception e){
            system.debug('### template does not exist');
        }
    }
}