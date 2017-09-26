public with sharing class TestingUtil {
  public String opId;
  public String scsId;
  public String scsecId;
  public String scsecItemId;
  public String actId;

  public TestingUtil(){
    opId = makeTestableOp();
    scsId = makeSalesCoachStage();
    scsecId = makeSalesCoachSections();
    scsecItemId = makeSecItem();
    actId = makeActivities();
    ApexPages.currentPage().getParameters().put('id', this.opId);
  }

  private String makeTestableOp(){
    Opportunity op = new Opportunity();
    op.Name='testOpName';
    op.CloseDate = Date.today();
    op.StageName='Prospect';
// Added by eric on 22nd July 2013, part of the Opportunity release
//  1. new validation rule to make sure the Qualified_to_proceed__c field is not null
//  2. new validation rule to make sure Ship_To_Countries__c field is not null and Customer_Application__c is not null
    op.Qualified_to_proceed__c='Yes';
    op.Ship_To_Countries__c='New Zealand';
    op.Customer_Application__c='NA';
    Account acc = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
      op.AccountId = acc.Id;
      op.Opportunity_Type_Overview__c = 'Services';
      op.Opportunity_Sub_Type__c = 'Technical in Market';
      op.Stage_in_Buying_Cycle__c  = 'Prospect'; 
    insert op;
    return op.Id;
  }
  
  private String makeSalesCoachStage(){
    Sales_Coach_Stage__c scs = new Sales_Coach_Stage__c();
    scs.Name='testStage';
    scs.Buyer_Stage__c='testBuyStage';
    scs.Active__c=true;
    insert scs;
    return scs.Id;
  }
  
  private String makeSalesCoachSections(){
    Sales_Coach_Section__c scsec =  new Sales_Coach_Section__c();
    scsec.Section_Ordering__c =1.0;
    scsec.Section_Name__c='testSection';
    scsec.Sales_Coach_Stage__c=scsId;
    scsec.Section_Width__c=33.0;
    insert scsec;
    return scsec.Id;
  }
  
 private String makeSecItem(){
    Sales_Coach_Section_Item__c secItem = new Sales_Coach_Section_Item__c();
    secItem.Section_Ordering__c=1.0;
    secItem.Sales_Coach_Section__c=scsecId;
    secItem.Link_to_Content__c='http://www.google.com';
    secItem.Item_Name__c='testItem';
    secItem.Display__c=true;
    secItem.Products__c='';
    insert secItem;
    return secItem.Id;
 }
 
 private String makeActivities(){
  Sales_Coach_Activity__c sca = new Sales_Coach_Activity__c();
  sca.Sales_Coach_Stage__c=scsId;
  sca.Ordering_Number__c=1.0;
  sca.Activity_Details__c='testActivity';
  insert sca;
  return sca.Id;
 }

}