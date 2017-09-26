public class CrmsConstants {

	public final static String EMPTY_STRING = '';
	public final static String CARRIAGE_RETURN = '\r';
	public final static String LINE_FEED = '\n';
	public final static String URL_S_GIF = '/s.gif';
	public final static String COLON_STRING = ':';
	public final static String FORWARDSLASH_STRING = '/';
	public final static String EQUAL_STRING = '=';
	public final static String SPACE_STRING = ' ';
	public final static String SPACE_STRING_HTML = '&nbsp;';
	public final static String AMPERSAND_STRING = '&';
	public final static String AMPERSAND_STRING_XML = '&amp;';
	public final static String DOUBLEQUOTE_STRING = '"';

	public final static String HTTP_PROTOCOL_SUFFIX = '://';
	public final static String HTTP_METHOD_GET = 'GET';
	public final static String HTTP_METHOD_POST = 'POST';
	public final static String HTML_UNIT_PX = 'px';
	public final static String HTML_TAG_END = '/>';
	public final static String HTML_IMG_TAG_START = '<img';
	public final static String HTML_IMG_TAG_ATTR_SRC = 'src';
	public final static String HTML_IMG_TAG_ATTR_SRC_START = 'src="';
	public final static String HTML_IMG_TAG_ATTR_WIDTH = 'width';
	public final static String HTML_IMG_TAG_ATTR_WIDTH_START = 'width="';
	public final static String HTML_IMG_TAG_ATTR_HEIGHT = 'height';
	public final static String HTML_IMG_TAG_ATTR_HEIGHT_START = 'height="';
	
	public final static String URL_RICHTEXTAREA_IMG_SRC_PARAM_REFID_START = 'refid=';

	public static final Map<String, Schema.SObjectType> GlobalDescribe = Schema.getGlobalDescribe();
	
	public final static String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';
	public final static String PROFILE_SALES_USER_RESTRICTED = 'Sales User - Restricted';

	public final static String SHARING_ROWCAUSE_TEAM = 'Team';
	public final static String SHARING_ROWCAUSE_MANUAL = 'Manual';
	public final static String SHARING_ROWCAUSE_OWNER = 'Owner';
	public final static String SHARING_ACCESSLEVEL_READ = 'Read';
	public final static String SHARING_ACCESSLEVEL_EDIT = 'Edit';
	
	public final static String ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY = 'Sold To Party';
	public final static String ACCOUNT_RECORD_TYPE_PARTNER_FUNCTION = 'Partner Function';
	public final static String ACCOUNT_RECORD_TYPE_PARENT_ACCOUNT = 'Parent Account';

	public final static Integer ACCOUNT_PLAN_MAX_CATEGORIES = 5;
	public final static Integer ACCOUNT_PLAN_MAX_PRODUCTS = 5;
	//public final static String ACCOUNT_PLAN_STATUS_DRAFT = 'Draft';
	public final static String ACCOUNT_PLAN_STATUS_READYFORAPPROVAL = 'Ready for approval';
	
	public final static String CUSTOMER_SNAPSHOT_EXTERNAL_ID_SEPARATOR = '-';

	public final static String CUSTOMER_SNAPSHOT_LINE_COMMODITY_GROUP_ALL = 'All';
	public final static String CUSTOMER_SNAPSHOT_LINE_RECORD_TYPE_PA = 'Edit Record - Price Achievement';
	public final static String CUSTOMER_SNAPSHOT_LINE_RECORD_TYPE_SDC = 'Edit Record - Share, DSO and CVM';
	public final static String CUSTOMER_SNAPSHOT_LINE_RECORD_TYPE_VGM = 'Edit Record - Volume and Gross Margin';

	public static Map<String, Map<String, Schema.RecordTypeInfo>> sObjectNameToRecordTypeInfoMap = new Map<String, Map<String, Schema.RecordTypeInfo>>(); 

	public static Map<String, Schema.RecordTypeInfo> getRecordTypeInfoMap(String sObjectName) {
		if (!sObjectNameToRecordTypeInfoMap.containsKey(sObjectName)) {
			Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = new Map<String, Schema.RecordTypeInfo>();
			for (Schema.RecordTypeInfo recordType : GlobalDescribe.get(sObjectName).getDescribe().getRecordTypeInfos()) {
				recordTypeInfoMap.put(recordType.getName(), recordType);
			}
			sObjectNameToRecordTypeInfoMap.put(sObjectName, recordTypeInfoMap);
		}
		return sObjectNameToRecordTypeInfoMap.get(sObjectName);
	}
	
	public static Id getRecordTypeId(String sObjectName, String recordTypeName) {
		return getRecordTypeInfoMap(sObjectName).get(recordTypeName).getRecordTypeId();
	}

	public static Id StandardPriceBook2Id = null;

	public static Id getStandardPriceBook2Id() {
		if (StandardPriceBook2Id == null) {
			List<Pricebook2> standardPricebooks = [Select p.Id, p.Name From Pricebook2 p Where p.IsStandard = true And p.IsActive = true];
			if (standardPricebooks.size() == 1) {
				StandardPriceBook2Id = standardPricebooks[0].Id;
			}
		}
		return StandardPriceBook2Id;
	}

	public static Map<String, Report> reportNameToReportMap = new Map<String, Report>(); 

	public static Report getReport(String reportName) {
		if (reportNameToReportMap.keySet().size() == 0) {
			for (Report report : [Select r.SystemModstamp, r.OwnerId, r.NamespacePrefix, r.Name, r.LastRunDate, r.LastModifiedDate, r.LastModifiedById, r.IsDeleted, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById From Report r]) {
				reportNameToReportMap.put(report.DeveloperName, report);
				reportNameToReportMap.put(report.Name, report);
			}
		}
		return reportNameToReportMap.get(reportName);
	}
	
	public static Id getReportId(String reportName) {
		Id reportId = null;
		Report report = getReport(reportName);
		if (report != null) {
			reportId = report.Id;
		}
		return reportId;
	}

	public static Map<Id, User> userIdToUserMap;
	public static Map<Id, User> getUserIdToUserMap() {
		if (userIdToUserMap == null) {
			userIdToUserMap = new Map<Id, User>([select Id, Name, Profile.Name from User]);
		}
		return userIdToUserMap;
	}

	public static String getProfileNameForId(Id userId) {
		if (getUserIdToUserMap().containsKey(userId)) {
			return getUserIdToUserMap().get(userId).Profile.Name;
		}
		return null;
	}

 public static Set<ID> getRoleSubordinateUsers(Id userId) {
 
    // get requested user's role
    Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
    // get all of the roles underneath the user
    Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
    // get all of the ids for the users in those roles
    Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
      UserRoleId IN :allSubRoleIds]);
    // return the ids as a set so you can do what you want with them
    return users.keySet();
 
  }
 
  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
 
    Set<ID> currentRoleIds = new Set<ID>();
 
    // get all of the roles underneath the passed roles
    for(UserRole userRole :[select Id from UserRole where ParentRoleId 
      IN :roleIds AND ParentRoleID != null])
    currentRoleIds.add(userRole.Id);
 
    // go fetch some more rolls!
    if(currentRoleIds.size() > 0)
      currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
 
    return currentRoleIds;
 
  }
 
	public static final String TASK_PRIORITY_NORMAL = 'Normal';
    public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
    public static final String TASK_STATUS_COMPLETED = 'Completed';

	public static Task createTask(String subject, String description, String parentId, String ownerId, String taskType, String priority, String status, Boolean setReminder, Integer reminderDays, Integer dueDays, Datetime reminderDatetime) {
		Task task = new Task();
		task.WhatId = parentId;
		task.OwnerId = UserInfo.getUserId();
		if (ownerId != null) {
			task.OwnerId = ownerId; 
		}
		if ((subject != null) && (subject.length() > 255)) {
			task.Subject = subject.substring(255);
		} else {
			task.Subject = subject;
		}
		if (taskType != null) {
			task.Type = taskType;
		}
		task.Priority = TASK_PRIORITY_NORMAL;
		if (priority != null) {
			task.Priority = priority; 
		}
		if (status != null) {
			task.Status = status;
		}
		task.Description = description;
		if (dueDays != null) {
			task.ActivityDate = System.today().addDays(dueDays);
		}
		task.IsReminderSet = setReminder;
		if (setReminder) {
			if (reminderDays != null) {
				task.ReminderDateTime = System.now().addDays(reminderDays);
			}
			if (reminderDatetime != null) {
				task.ReminderDateTime = reminderDatetime;
			}
		}
		return task;
	}

}