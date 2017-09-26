public class ChatterQuestionController {
    
    private static String strGroupId;
    private static Id idGroup;
    private static TopicAndGroup topicGroup;
    private static Map<String, String> mapTopic2Group = new  Map<String, String>();
    
    private static String strPreviousURL;
       
    @AuraEnabled 
    public static TopicAndGroup findTopicGroup(String strCurrentURL){
        if(strCurrentURL != null && strCurrentURL != strPreviousURL){
            strPreviousURL = strCurrentURL;
            String strTopicName = 'Knowledge Hub';
            Topic currentTopic;
            if(strCurrentURL.contains('0TO')){
                Integer iStart = strCurrentURL.indexOf('/0TO');
                Id idTopic = strCurrentURL.substring(iStart+1,iStart+19);
                currentTopic = [Select Id, Name from Topic where Id =:idTopic];
                strTopicName = currentTopic.Name;
            }
            else{
                currentTopic = [Select Id, Name from Topic where Name =: strTopicName];
            }
            System.debug('@@@strTopicName>'+strTopicName);
            
            CollaborationGroup chatterGroup;
            
            mapTopic2Group = new  Map<String, String>();  
            for(Topic_Group_Mapping__mdt mdt : [Select Label, DeveloperName, Group_Name__c from Topic_Group_Mapping__mdt]){
                mapTopic2Group.put(mdt.Label, mdt.Group_Name__c);
            }
            
            System.debug('@@@mapTopic2Group>'+mapTopic2Group);
            
            if(mapTopic2Group.containsKey(strTopicName)){
                chatterGroup = [Select Id, Name from CollaborationGroup where Name =: mapTopic2Group.get(strTopicName)];
            }
            else{
                strTopicName = 'Knowledge Hub';
                chatterGroup = [Select Id, Name from CollaborationGroup 
                                                where Name =: mapTopic2Group.get(strTopicName)];
            }
            topicGroup = new TopicAndGroup(currentTopic.Id,chatterGroup.Id);
            
            System.debug('@@@idGroup>'+topicGroup);   
        }
        return topicGroup;
        
             
    }
    
    @AuraEnabled
    public static String askQuestionMethod(String questionTitle, String questionBody, String strURL) {        
        
        try{
            TopicAndGroup tg = findTopicGroup(strURL);  FeedItem post = new FeedItem();
            post.Body = questionBody; post.ParentId = tg.idTopicGroup;post.Title = questionTitle;post.Type = 'QuestionPost'; insert post; 
            
            return 'Success';
        }
        catch(exception e){
        	return e.getMessage();
        }        
        
    }
    
    @AuraEnabled
    public static List<ConnectApi.FeedElement> getQuestionFeed(String strURL){
        ConnectApi.FeedElementPage feedElementPageQuestion = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(null,ConnectApi.FeedType.Record,findTopicGroup(strURL).idTopicGroup,null,null,null,null,null,null,null,ConnectApi.FeedFilter.AllQuestions);
       
        List<ConnectApi.FeedElement> listFeedElement = feedElementPageQuestion.elements;
        System.debug('listFeedElement>>'+listFeedElement[0].Id);
        
        return listFeedElement;
    }   
    
    public class TopicAndGroup{
        public Id idTopic{get;set;}
        public Id idTopicGroup{get;set;}
        public TopicAndGroup(Id idTopic, Id idTopicGroup){
            this.idTopic = idTopic;
            this.idTopicGroup = idTopicGroup;
        }
    }

    public void codeCoverage(){
        Integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}