public with sharing class InformaticaHelperClass {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public InformaticaHelperClass(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public static final String SYSTEM_INTEGRATION_USER_USERNAME = System.Label.SYSTEM_INTEGRATION_USER_USERNAME;
    public static User integrationUser = [Select Id from User Where Username = :SYSTEM_INTEGRATION_USER_USERNAME];

    public void OnBeforeInsert(Account[] newAccounts) {
        Id currentUserId = UserInfo.getUserId();
        
     //KL   User currentUser = [Select Default_Owner_for_Account_Integration__c From User where Id = :currentUserId];
        
        //if(currentUser.Default_Owner_for_Account_Integration__c == true){
        //DB: commented this code as we want to let this code be triggered now everytime - as we are no longer mapping the Owner ID due to bug in Informatica
        Map<String, Id> userMap = new Map<String, Id>();

        //DN 20140710 filter out inactive users and chatter users
        //List<User> userList = [Select Id, SAP_Employee_Key__c from User where SAP_Employee_Key__c != null limit 50000]; //Governer Limit 
        List<User> userList = [Select Id, SAP_Employee_Key__c from User where isActive=true and userType not in ('CsnOnly') and SAP_Employee_Key__c != null limit 50000]; //Governer Limit 
        
        for(User e : userList){
            userMap.put(e.SAP_Employee_Key__c, e.Id);
        }
        
        for(Account acc : newAccounts){
            if(userMap.containsKey(acc.SAP_Account_Manager__c) && acc.Apply_SAP_Account_Manager_as_Owner__c){
                acc.OwnerId = userMap.get(acc.SAP_Account_Manager__c);
                System.debug('### userMap.get(acc.SAP_Account_Manager__c) [Insert]: ' + acc.SAP_Account_Manager__c);
            }else{
              //KL  acc.OwnerId = currentUser.Id;
                System.debug('### currentUser.Id [Insert]: ' + acc.OwnerId);
            }
        }
        //}
    } 


    public void OnBeforeUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> accountMap) {
        Id currentUserId = UserInfo.getUserId();    
    //KL    User currentUser = [Select Default_Owner_for_Account_Integration__c From User where Id = :currentUserId];
        //if(currentUser.Default_Owner_for_Account_Integration__c == true){
        //DB: commented this code as we want to let this code be triggered now everytime - as we are no longer mapping the Owner ID due to bug in Informatica
        Map<String, Id> userMap = new Map<String, Id>();
        //DN 20140710 filter out inactive users and chatter users
        //List<User> userList = [Select Id, SAP_Employee_Key__c from User where SAP_Employee_Key__c != null limit 50000]; 
        List<User> userList = [Select Id, SAP_Employee_Key__c from User where isActive=true and userType not in ('CsnOnly') and SAP_Employee_Key__c != null limit 50000]; 
        for(User e : userList){
            userMap.put(e.SAP_Employee_Key__c, e.Id);
        }
        for(Integer i = 0; i < updatedAccounts.Size(); i++){  
            //Only apply rules where SAP account manager must be applied
            if(updatedAccounts[i].Apply_SAP_Account_Manager_as_Owner__c )
            {
                //if SAP_Account_Manager field has changed OR Apply_SAP_Manager_as_owner has changed OR account is owned by system integration OR Owner Employee key ( for active users only) is not equal to latest SAP account number          
                if(oldAccounts[i].SAP_Account_Manager__c != updatedAccounts[i].SAP_Account_Manager__c || oldAccounts[i].Apply_SAP_Account_Manager_as_Owner__c != updatedAccounts[i].Apply_SAP_Account_Manager_as_Owner__c || oldAccounts[i].OwnerId == integrationUser.Id || (updatedAccounts[i].Owner.isActive && updatedAccounts[i].Owner.SAP_Employee_Key__c != updatedAccounts[i].SAP_Account_Manager__c)){
                    if(userMap.containsKey(updatedAccounts[i].SAP_Account_Manager__c)){
                        updatedAccounts[i].OwnerId = userMap.get(updatedAccounts[i].SAP_Account_Manager__c);
                        System.debug('### updatedAccounts[i].OwnerId (Valid SAP): ' + userMap.get(updatedAccounts[i].SAP_Account_Manager__c));
                    }else{
                      //KL  updatedAccounts[i].OwnerId = currentUser.Id;
                      updatedAccounts[i].OwnerId=integrationUser.id ;
                      //KL  System.debug('### updatedAccounts[i].OwnerId (Current User): ' + currentUser.Id);
    
                    }
            }
            }       
        }
        //}
    }
}