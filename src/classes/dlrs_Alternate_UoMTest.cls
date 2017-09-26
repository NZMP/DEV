/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Alternate_UoMTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Alternate_UoMTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Alternate_UoM__c());
    }
}