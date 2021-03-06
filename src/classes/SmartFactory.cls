@isTest
/*
   Copyright 2011 Mavens Consulting, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/   
public class SmartFactory {
	public static boolean FillAllFields = false;
	
	// Key : SobjectAPIName  For ex. Account 
	// Value : Map<String, Schema.SObjectField>, field map (k:fieldname, v:Schema.Sobjectfield)
	public static final Map<String, Map<String, Schema.SObjectField>> FieldMapCache = new Map<String, Map<String, Schema.SObjectField>>();

	public static final Map<String, Schema.SObjectType> GlobalDescribe = Schema.getGlobalDescribe();
	
	// Key: sobject.field
	// Value: first picklist value
	private static final Map<String, String> DefaultPicklistValue = new Map<String, String>();
	
	// can't map by Schema.sObjectType, use object name string instead
	static map<string, set<string>> excludedFields = new map<string, set<string>>{
		'All' => new set<string>{'OwnerId', 'LastModifiedById', 'Jigsaw'},
		'Account' => new set<string>{'FirstName', 'LastName'}
	};
	
	// kept public so that test cases can change this if required
	// Key : DisplayType name
	// Value : Object value for the field
	public static final Map<String, Object> FieldTypeValueMapping = 
										new Map<String, Object> {
												Schema.DisplayType.base64.name() => blob.valueOf('a'),
												Schema.DisplayType.Boolean.name() => false,
												Schema.DisplayType.Combobox.name() => 'a',
												Schema.DisplayType.Currency.name() => 0,
												Schema.DisplayType.Date.name() => System.today(),
												Schema.DisplayType.Datetime.name() => System.now(),
												Schema.DisplayType.Double.name() => 0.0,
												Schema.DisplayType.Email.name() => 'test@test.com',
												Schema.DisplayType.EncryptedString.name() => 's',
												Schema.DisplayType.Integer.name() => 0,
												Schema.DisplayType.Percent.name() => 0,
												Schema.DisplayType.Phone.name() => '123-456-7890',
												Schema.DisplayType.String.name() => 's',
												Schema.DisplayType.TextArea.name() => 's',
												Schema.DisplayType.Time.name() => Time.newInstance(0, 0, 0, 0),
												Schema.DisplayType.URL.name() => 'http:www.force.com'
											}; 	
	
	// Cache for Sobject Templates prepopulated with default values
	// This cache will be applicable for objects created with cascade option as false
	// Key : ObjectType Name
	// Value : The SObject instance										
	static final Map<String, Sobject> TemplateSobjectCache = new Map<String, Sobject>();
	
	public static SObject createSObject(string objectType) {
		// initialize with empty mapping
		return createSObject(objectType, new Map<String,Object>());
	}
	
	public static SObject createSObject(string objectType, Map<String, Object> fieldNameValueMapping) {
		return createSObject(objectType, false, fieldNameValueMapping);
	}	
	
	public static SObject createSObject(string objectType, boolean cascade) {
		// initialize with empty mapping
		return createSObject(objectType, cascade, new Map<String,Object>());
	}
	
	public static SObject createSObject(string objectType, boolean cascade, Map<String, Object> fieldNameValueMapping) {
		SObject obj = null;
		if (!cascade && TemplateSobjectCache.containsKey(objectType.toLowerCase())) {
			// if no cascading is there, we can easily cache the template object and override it as required.
			// no caching done for objects with references.
			obj = ((SObject)TemplateSobjectCache.get(objectType.toLowerCase())).clone();
		} else {
			Schema.sObjectType token = GlobalDescribe.get(objectType);
			if (token == null) {
				throw new UnsupportedObjectTypeException('Unsupported ObjectType ' + objectType);
			}
					
			obj = token.newSObject();		
			
			for (Schema.SObjectField field : fieldMapFor(objectType).values()) {
				setFieldValue(obj, field, cascade);
			}			
			
			if (!cascade) {
				// If not cascading the references cache it.
				// Cache the cloned object, as later on user applied override 
				// might change it
				TemplateSobjectCache.put(objectType.toLowerCase(), obj.clone());
			}
		}
		
		for (String key : fieldNameValueMapping.keyset()) {
			obj.put(key, fieldNameValueMapping.get(key));
		}
		
		return obj;
	}
	
	/**
		Returns a field map for a given sobject. 
		
		Note : this method is kept public for Test cases to share the same field map info, without requiring a field desribe.
		
		@param objectType sobject api name for ex. Account
		@returns FieldMap [Key:FieldName,Value:Schema.SObjectField]
	*/
	public static Map<String, Schema.SObjectField> fieldMapFor(String objectType) {
		Map<String, Schema.SObjectField> fieldMap = null;
		String normalizedObjectType = objectType.toLowerCase();
		
		if (FieldMapCache.containsKey(normalizedObjectType)) {
			fieldMap = FieldMapCache.get(normalizedObjectType);
		} else {
			fieldMap = GlobalDescribe.get(objectType).getDescribe().fields.getMap();
			// cache it for next use
			FieldMapCache.put(normalizedObjectType, fieldMap);
		}
		
		return fieldMap;
	}	
	
	/**
		Sept 3, 2011 : Fixed the bug to fetch the associated default value, instead of value at index zero
	*/
	public static string getDefaultPicklistValue(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
		string key = obj.getSObjectType() + '.' + fieldDescribe.getName();
		
		if (!DefaultPicklistValue.containsKey(key)) {
			List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
			string value = null;
			for (Schema.Picklistentry entry : entries) {
				// TODO check for entry.isActive() here
				if (entry.isDefaultValue()) {
					value = entry.getValue();
					break;
				}
			}
			// if somehow no default value is there
			if (value == null)
				value = entries.size() > 0 ? entries[0].getValue() : null;
			
			DefaultPicklistValue.put(key, value);
		}
		
		return DefaultPicklistValue.get(key);
	}		
	
	static boolean isExcludedField(Schema.DescribeFieldResult fieldDescribe) {
		return excludedFields.get('All').contains(fieldDescribe.getName());
	}
	
	static boolean isExcludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
		set<string> fields = excludedFields.get(obj.getSObjectType().getDescribe().getName());
		return fields == null ? false : fields.contains(fieldDescribe.getName());
	}
	
	static boolean isPersonAccountField(Schema.DescribeFieldResult fieldDescribe) {
        Boolean CustomPerson = fieldDescribe.isCustom() && fieldDescribe.getName().endsWith('pc');
        Boolean StandardPerson = !fieldDescribe.isCustom() && fieldDescribe.getName().startsWith('Person');
		return (CustomPerson || StandardPerson);
	} 
	
	static void setFieldValue(SObject obj, Schema.SObjectField field, boolean cascade) {
		Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
		
		if (fieldDescribe.isCreateable() && 
			((!fieldDescribe.isNillable() || FillAllFields) || 
				(fieldDescribe.getType() == Schema.DisplayType.Reference && cascade)) && // always fill references with cascade
			!isExcludedField(fieldDescribe) &&
			!isExcludedField(obj, fieldDescribe) &&
			!isPersonAccountField(fieldDescribe)) {
			
			if (FieldTypeValueMapping.containsKey(fieldDescribe.getType().name())) {
				obj.put(field, FieldTypeValueMapping.get(fieldDescribe.getType().name()));
			} else if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
				obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
			} else if (fieldDescribe.getType() == Schema.DisplayType.Reference) {
				string referenceObjectType = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
				if (referenceObjectType == 'RecordType') {
					setRecordType(obj);
				} else if (cascade && (referenceObjectType != obj.getSObjectType().getDescribe().getName()) && (referenceObjectType != 'User')) {
					// TODO avoid infinite loop for same-type references
					//System.debug('Creating reference to ' + referenceObjectType);
					SObject reference = createSObject(referenceObjectType);
					insert reference;
					obj.put(field, reference.Id);
				}
			}
		}	
	}
	
	static void setRecordType(SObject obj) {
		List<Schema.RecordTypeInfo> recordTypes = obj.getSObjectType().getDescribe().getRecordTypeInfos();
		
		if (recordTypes.size() > 1) { // all objects have default Master type
			//System.debug('RecordTypes ' + recordTypes);
			for (Schema.RecordTypeInfo recordType : recordTypes) {
				if (recordType.isAvailable() && recordType.isDefaultRecordTypeMapping() && (recordType.getName() != 'Master')) {
					obj.put('RecordTypeId', recordType.getRecordTypeId());
				}
			}
		}
		
	}

public class UnsupportedObjectTypeException extends Exception {}

/*
@isTest
private class SmartFactory_Test {

	static {
		SmartFactory.FillAllFields = true; // increase test coverage without creating custom objects
	}
*/
	//test different create methods
	static testMethod void createAccountWithoutFillAllFields() {
		//test basic create
		SmartFactory.FillAllFields = false;
    	Account account = (Account)SmartFactory.createSObject('Account');
    	System.assertNotEquals(null, account.Name);
    	System.assertEquals(null, account.Type);
    	
    	//test basic create with cascade
    	account = (Account)SmartFactory.createSObject('Account', true);
    	System.assertNotEquals(null, account.Name);
    	System.assertEquals(null, account.Type);
    	
    	//re-test basic create with cascade with caching
    	//account = (Account)SmartFactory.createSObject('Account', true);
	}

	//test unsupported object create with exception
	static testMethod void createUnsupportedObject() {
		SmartFactory.FillAllFields = false;
		try {
    		Account account = (Account)SmartFactory.createSObject('UnsupportedObject');
		} catch (UnsupportedObjectTypeException uote) {
			System.assertEquals('SmartFactory.UnsupportedObjectTypeException',uote.getTypeName());
		}
	}

	//test create with fieldNameValueMapping and database insert
	static testMethod void createAccountWithFillAllFields() {
		SmartFactory.FillAllFields = true;		
    	Map<String, Object> accValues = new Map<String, Object> {
    											'Name' => 'test'
										};
    	Account account = (Account)SmartFactory.createSObject('Account', accValues);
		insert account;
		System.assert(account.Id != null);
		System.assert(account.Name != null);
		SmartFactory.FillAllFields = false;
	}
	
	//test create simulate account load from Informatica
	static testMethod void createAccountTestInformaticaTrigger() {
       //Test Objective - gets the latest shell activity and changes the reference to the be the newly created case.
       	Profile p = [Select Id From Profile where Name='Sales User 1 - Revised'];
       	User u = new User(Alias='testpr', email='test@test.com', emailEncodingKey='UTF-8', lastname='Testing', languageLocaleKey='en_US',
	   	localeSidKey='en_US', profileId = p.Id,
       	timeZonesIdKey='Pacific/Auckland',
       	Sap_Employee_Key__c = '00000123',
       	username='salesuser1@fonterra.co.nz.dev');
       	insert u;		
		List<RecordType> recTypeList = [Select Id From RecordType where SobjectType='Account' and Name='Sold To Party'];
		//Create a SAP Employee
		//test basic create
		SmartFactory.FillAllFields = false;
    	Account account = new Account();
    	account.SAP_Account_Manager__c = '00000123';
    	account.Account_Group_Code__c = '0001';
    	account.Name = 'Test';
		insert account;
		//expected account before insert fires!
		
		system.debug('## account ' + account);
		system.debug('## u.Sap_Employee_Key__c ' + u.Sap_Employee_Key__c);
		system.debug('## account.SAP_Account_Manager__c ' + account.SAP_Account_Manager__c);
		system.assert(account.Id != null);
		system.assert(account.Name != null);
		system.assert(u.id != null);
		Account accTemp = [Select Id, OwnerId From Account where id=:account.id]; 
		//Account Owner is the matching SAP Key user
		system.assertEquals(accTemp.OwnerId, u.id);
	}

/*	
	static testMethod void createsObjectWithCascadeSetsLookupField() {
		Contact contact = (Contact)SmartFactory.createSObject('Contact', true);
		insert contact;
		System.assert(contact.Id != null);
		System.assert(contact.AccountId != null);
	}
*/	
/*
	static testMethod void createsObjectWithoutCascadeDoesNotSetLookupField() {
		Contact contact = (Contact)SmartFactory.createSObject('Contact', false);
		insert contact;
		System.assert(contact.AccountId == null);
	}
	
	static testMethod void createObjectWithUnsupportedTypeThrowsException() {
		try {
			SmartFactory.createSObject('Unsupported');
			System.assert(false);
		} catch (UnsupportedObjectTypeException ex) {
			System.assert(true);
		}
	}
*/
	/**
		Reproduces this issue
		https://github.com/mbotos/SmartFactory-for-Force.com/issues/3
	*/
/*
    static testMethod void loadTestWith100PlusAccountNContacts() {
    	for (Integer idx = 0; idx <= 101; idx++)
    		Account account = (Account)SmartFactory.createSObject('Account');
		for (Integer idx = 0; idx <= 101; idx++)
    		Contact cont = (Contact)SmartFactory.createSObject('Contact');    		
    }
*/
    /**
    */
/*
    static testMethod void testFieldValueOverride() {
    	Map<String, Object> accValues = new Map<String, Object> {
												'AnnualRevenue' => 20000.00,
												'Description' => 'My Account Description',
												 'Phone' => '123-234-2233'
											};
    	Account acc = (Account)SmartFactory.createSObject('Account', accValues);
		for (String fld: accValues.keySet()) {
			System.assertEquals(accValues.get(fld), acc.get(fld));
		}
		
		// it comes 454 here
		System.debug('Scripts Consumed:' + Limits.getScriptStatements());
				
		accValues = new Map<String, Object> {
												'NumberOfEmployees' => 2000,
												'Site' => 'www.tgerm.com',
												 'Fax' => '123-234-2233'
											};
		acc = (Account)SmartFactory.createSObject('Account', accValues);
		for (String fld: accValues.keySet()) {
			System.assertEquals(accValues.get(fld), acc.get(fld));
		}
		// Phone should be using the default value, instead of the one created previously
		// this will make sure fresh object from template is used.
		System.assertEquals(SmartFactory.FieldTypeValueMapping.get(Schema.DisplayType.Phone.name()), acc.Phone);
		
		// it comes 467, so we improved a lot with caching for the same operation
		System.debug('Scripts Consumed II:' + Limits.getScriptStatements());
    }
*/
    /**
    	Changed the default picklist value to "Education" for Account>Industury.
    	Code before was picking up the wrong first value i.e. Agriculture
    	Note: commenting out this test case, as all SFDC orgs will not have the 
    	same default value
    static testMethod void testAccountPicklistDefaultValue() {
    	Account acc = (Account)SmartFactory.createSObject('Account');
    	System.assertEquals('Education',  acc.Industry);
    }
    */
    
//}
	
}