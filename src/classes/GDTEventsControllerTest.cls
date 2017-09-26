@isTest
private class GDTEventsControllerTest {
	
	@isTest static void GDTEventsTest() {

		GDT_Event__c gdt = new GDT_Event__c(name='testGDT');
		insert gdt;

		List<GDT_Event__C> gdts = GDTEventsController.gdtevents();

		system.assert(gdts != null);
	}
	
	
}