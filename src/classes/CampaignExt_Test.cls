@isTest(seeAllData = true)
public with sharing class CampaignExt_Test {
	static CampaignExt classInstance;
	public static testmethod void testClass(){
	Campaign c = new Campaign();
	c.Name ='Test Campaign';
	c.Mail_Body_Text__c = 'test mail body';
	c.Accept_Link_Text__c ='Accept';
	c.Decline_Link_Text__c ='Decline';
	c.Invitation_Subject_Text__c ='Invitaiton subject';
	insert c;
	ApexPages.StandardController stdController = new ApexPages.StandardController(c); 
	classInstance = new CampaignExt(stdController);
	classInstance.replyto ='test@test.com';
	classInstance.showPreview();
	classInstance.cancelInvite();
	classInstance.getMembers();
	classInstance.getReplyOptions();
	classInstance.sendInvite();
	}
}