global class CPQCatalogScheduler implements Schedulable {
  String jsonObject = null;
  public CPQCatalogScheduler(String jsonObject){   
    // We are called from CPQJobSpec with the next job to run
    this.jsonObject = jsonObject;
  }
  public CPQCatalogScheduler() {    
    // We are called from the scheduler to run the first job
    this.jsonObject = null;
  }
  global void execute(SchedulableContext cat) {
    CPQJobSpec.run(this.jsonObject);
  }
}