@isTest
public with sharing class CampaignMemberExt_Test {
	static CampaignMemberExt classInstance;
	public static testmethod void testClass(){
		Contact con = new Contact();
		con.FirstName ='Test FN';
		con.LastName ='Test LN';
		insert con; 
		Campaign c = new Campaign();
		c.Name ='Test Campaign';
		insert c;
		CampaignMember cm = new CampaignMember();
		cm.ContactId = con.id;
		cm.CampaignId = c.id;
		insert cm;
		Apexpages.currentPage().getParameters().put('cid',cm.Id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(cm); 
		classInstance = new CampaignMemberExt(stdController);
		classInstance.emergencyContactName ='con Name';
		classInstance.emergencyContactPhoneNumber ='123';
		classInstance.contactDietaryRequirements ='Dietary Req';
		classInstance.contactEmail = 'test@test.com';
		classInstance.contactFirstName ='con fn';
		classInstance.contactLastName ='con ln';
		classInstance.contactPhoneNumber = '12345';
		classInstance.theCampaignMember=cm;
		classInstance.Save();
		classInstance.updateMember();
		classInstance.responseCode ='1';
		classInstance.responseCode = '0';
		classInstance.setPageDetails();
		classInstance.getAccepted();
		classInstance.getDeclined();
		classInstance.getUnsubscribe();
		classInstance.getUnsubscribe();
		classInstance.getUnsubscribeAll();
		classInstance.getDietaryRequirements();
		
	}

}