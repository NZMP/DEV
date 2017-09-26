public without sharing class AccountDetailsController {
    
    @AuraEnabled public static user retrieveAccountDetails(){
        return [select 
                account.name,
                account.owner.CompanyName,
                account.owner.Full_Name_Email__c, 
                account.Owner.Name,
                account.Owner.MobilePhone,
                account.Owner.Phone, 
                account.Owner.City, 
                account.Owner.Street, 
                account.Owner.State, 
                account.Owner.Country, 
                account.Owner.PostalCode,
                
                account.Account_Logo__c,
                account.Account_Logo_URL__c,
                
                account.owner.manager.name,
                account.owner.manager.Full_Name_Email__c,
                account.owner.manager.phone,
                account.owner.manager.MobilePhone
                from user
                where id =: UserInfo.getUserId()
               ];
        
    }
    
}