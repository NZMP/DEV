public with sharing class CustomerTargetActualRefreshCtrl {
	ApexPages.StandardController std;
	Account rec{set;get;}
	public CustomerTargetActualRefreshCtrl(ApexPages.StandardController con) {
		this.rec = (Account)con.getRecord();
		this.std=con;
	}
	public PageReference redir() {
		CustomerTargetActualBatch testJob=new CustomerTargetActualBatch(null,rec.id);
		ID batchprocessid = Database.executeBatch(testJob);
		return new PageReference('/' + rec.Id + '?nooverride=1');
	}
}