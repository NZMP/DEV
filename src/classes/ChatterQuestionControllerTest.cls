@isTest
private class ChatterQuestionControllerTest {
	
	@isTest static void test_method_one() {
		
		Topic t = new Topic();
		t.Name = 'Test topic';
		insert t;

		String strURL = 'https://qa-nzmp.cs5.force.com/knowledgehub/s/topic/'+t.Id;
		ChatterQuestionController.askQuestionMethod('Qtitle','qBody',strURL);
		try{ChatterQuestionController.getQuestionFeed(strURL);} catch(exception e){}

		ChatterQuestionController cont = new ChatterQuestionController();
		cont.codeCoverage();
		ChatterQuestionController.TopicAndGroup wrapper = new ChatterQuestionController.TopicAndGroup(t.Id,t.Id);


	}
	
}