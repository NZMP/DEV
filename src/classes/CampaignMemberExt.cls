public class CampaignMemberExt {
	public Id campaignMemberId {get;set;}
	public String responseCode {get;set;}
	public String errorMessage{get; set;}
	public String eventType{get;set;}
	public Boolean error{get;set;}
	public String inviteSubject{get;set;}
  
	public string contactFirstName{get;set;}
	public string contactLastName{get;set;}
	public string contactEmail{get;set;}
	public string contactDietaryRequirements{get;set;}
	public string contactDietaryRequirementsAddDetails{get;set;}
	public string contactPhoneNumber{get;set;}
	public string emergencyContactPhoneNumber{get;set;}
	public string emergencyContactName{get;set;}
	public boolean isRegistered {get;set;}
	
	public CampaignMember theCampaignMember;
  
	public CampaignMemberExt (ApexPages.StandardController controller){
		string tempCampaignMemberId = ApexPages.currentPage().getParameters().containskey('cid') ? ApexPages.currentPage().getParameters().get('cid') : null;
		responseCode = ApexPages.currentPage().getParameters().containsKey('response') ?  ApexPages.currentPage().getParameters().get('response') : null;
	    System.debug('### campaignMemberId: ' + campaignMemberId);
	    System.debug('### responseCode: ' + responseCode);
	    
	    error = (tempCampaignMemberId == null || tempCampaignMemberId == '' || responseCode==null || responseCode == '');//false;
	    System.debug('### error: ' + error);
	    if(!error && tempCampaignMemberId != null && tempCampaignMemberId != ''){
	    	campaignMemberId = tempCampaignMemberId;
	    }
	    
	    if(campaignMemberId!= null) getCampaignMemberDetails();
	}
	
	public void getCampaignMemberDetails(){
		theCampaignMember = [select Id, Status, Subscription__c, Contact.Name, Contact.FirstName,Contact.LastName,Contact.Email,Contact.Dietary_Requirements__c,Contact.Mobile_2__c,
     							Contact.MobilePhone,Contact.Dietary_Requirements_1__c,Contact.Emergency_Contact_Name__c,Contact.Emergency_Contact_Phone_Number__c,Contact.AccountId, 
     							ContactId, Invitation_Subject_Text__c, Campaign.Name  
     						from CampaignMember where Id = :campaignMemberId];

	}
	
     
     
	public void updateMember(){
    	System.Debug('## campaignMemberId:' +campaignMemberId );
       	System.Debug('## responseCode:' +responseCode ); 		
		if(theCampaignMember == null) {
			error=true;
		}
		else{
	        if (responseCode == '1'){ // if accept
				theCampaignMember.Status = 'Accept';
	           	setPageDetails();
         	}
         	else if (responseCode == '0'){
         		theCampaignMember.Status = 'Decline';
         	}
         	else if (responseCode == '9'){ // If unsubscribe
           		theCampaignMember.Status = 'Unsubscribe';
           		theCampaignMember.Subscription__c = 'Unsubscribe';
           	}
			else if (responseCode == '10'){ // If unsubscribe all
	           theCampaignMember.Status = 'Unsubscribe';
	           theCampaignMember.Subscription__c = 'Unsubscribe All';
	        }
         	theCampaignMember.Send_Invite__c=False;
         	inviteSubject=theCampaignMember.Invitation_Subject_Text__c; 		  
       		try{       	
         		update theCampaignMember;         
       		}catch(Exception e){
        		System.Debug('## error on update: ' + campaignMemberId);
         		System.Debug('## error on update: ' + e.getMessage());
         		error = true;
       		}
		}
       
     }
     public void setPageDetails(){
     	
     	contactFirstName=theCampaignMember.Contact.FirstName;
        contactLastName=theCampaignMember.Contact.LastName;
        contactEmail=theCampaignMember.Contact.Email;
        contactDietaryRequirements=theCampaignMember.Contact.Dietary_Requirements__c;
        contactPhoneNumber=theCampaignMember.Contact.MobilePhone;  
        emergencyContactPhoneNumber = theCampaignMember.Contact.Emergency_Contact_Phone_Number__c;
        emergencyContactName = theCampaignMember.Contact.Emergency_Contact_Name__c;
        contactDietaryRequirementsAddDetails = theCampaignMember.Contact.Dietary_Requirements_1__c;
        system.debug('theCampaignMember: '+theCampaignMember);
    }
    public void Save(){
    	system.debug('theCampaignMember: '+theCampaignMember);
    	if( theCampaignMember != null && theCampaignMember.ContactId!=null ){
    		Contact contact = [select Id, FirstName,LastName,Email,MobilePhone,Dietary_Requirements__c,Dietary_Requirements_1__c,Emergency_Contact_Name__c,Emergency_Contact_Phone_Number__c from Contact where id = :theCampaignMember.ContactId];
    		system.debug('## contact' +contact);
    	
    		if(emergencyContactPhoneNumber == null || emergencyContactPhoneNumber == ''|| contactPhoneNumber==null ||contactPhoneNumber == ''|| contactFirstName == null ||contactFirstName == ''
    			|| contactLastName == null || contactLastName == '' || contactEmail == null || contactEmail == '' ||  emergencyContactName == null || emergencyContactName == ''){
    			
    			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Please enter all the required(*) fields'));
    		}
    		else{
		    	contact.MobilePhone = contactPhoneNumber;
		    	system.debug('## contactPhoneNumber' +contactPhoneNumber);
		    	system.debug('## contact.MobilePhone: ' +contact.MobilePhone);
		    	contact.FirstName = contactFirstName;
		    	contact.LastName = contactLastName;
		    	contact.Email = contactEmail;
		    	contact.Dietary_Requirements__c = contactDietaryRequirements;
		    	contact.Dietary_Requirements_1__c = contactDietaryRequirementsAddDetails;
		    	contact.Emergency_Contact_Name__c = emergencyContactName;
		    	contact.Emergency_Contact_Phone_Number__c = emergencyContactPhoneNumber;
		    	system.debug('## contact 2:' +contact);
		    	
		    	update contact;
		    	
		    	system.debug('## contact 3:' +contact);
		    	isRegistered = true;
    		}
    	}
    }
    
    public List<SelectOption> getDietaryRequirements() {
		List<SelectOption> options = new List<SelectOption>();
	        
		Schema.DescribeFieldResult fieldResult = Contact.Dietary_Requirements__c.getDescribe();
	   	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   	for( Schema.PicklistEntry f : ple) {
			options.add(new SelectOption(f.getLabel(), f.getValue()));
	   	}       
	   	system.debug('### options:' +options);
	   	return options;
	}
     public Boolean getAccepted(){
       if (responseCode != null && responseCode == '1' && !error) return true;
       else return false;
     }
     
     public Boolean getDeclined(){
       if (responseCode != null && responseCode == '0' && !error) return true;
       else return false;
     }
     public Boolean getUnsubscribe(){
       if (responseCode != null && responseCode == '9' && !error) return true;
       else return false;
     }
     public Boolean getUnsubscribeAll(){
       if (responseCode != null && responseCode == '10' && !error) return true;
       else return false;
     }
}