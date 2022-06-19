public class ITAM_reqChangeController {
@AuraEnabled
  public static List<User> getApprovalManager(Id setUserId) {
      System.debug('getApprovalManager: '+ setUserId);

      //String userId = UserInfo.getUserId();
      String userId = [SELECT ID, User__c FROM Employee__c WHERE id =:setUserId].User__c;
      ID userRole = UserInfo.getUserRoleId();
      List<User> managerResult = new List<User>();

      System.debug('user확인 : '+ [SELECT Name FROM User WHERE id =: userId]);
      // top Role 구해서 결재 시스템 예외
      List<UserRole> topRole = new List<UserRole>(topRole(userRole));
      User topUser = [SELECT id, Name FROM User WHERE UserRoleId =:topRole LIMIT 1];

      System.debug('dd : '+ topUser);
      System.debug('dd : '+ [SELECT ManagerId FROM USER WHERE id=:userId].ManagerId);

      UserRole exceptionUser = [SELECT id, Name FROM UserRole WHERE id =:userRole LIMIT 1];
      User exceptionManager = [SELECT ManagerId FROM USER WHERE id=:userId];

      //마케팅 팀 일 경우..예외 로직
      if ('마케팅팀' == exceptionUser.Name || topRole[0].Id == exceptionUser.Id || topUser.Id == exceptionManager.ManagerId){
          System.debug('마케팅팀? : ');
          managerResult.add(topUser);
      }else{
          System.debug('마케팅팀?ㄴㄴ : ');
          SET<ID> GroupMembers = new SET<ID>();

          Id directorGroup = [SELECT Id FROM Group WHERE DeveloperName ='ITAM_Approval' LIMIT 1].Id;

          for (Group gr :[SELECT Id, RelatedId, DeveloperName, Type FROM Group 
                          WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:directorGroup )] ){
                              GroupMembers.add(gr.RelatedId);
                          }
          Map<ID, User> GroupUser = New Map<ID,User>([SELECT Id, Name FROM User WHERE UserRoleId=:GroupMembers  and isActive = true]);
          System.debug('approval 리미트 : '+ GroupUser);

          //System.debug('getManager: '+getManager(userId, GroupUser, managerResult));
          managerResult = getManager(userId, GroupUser, managerResult);
          System.debug('getRelustManager: '+managerResult);
      }

      return managerResult;

  }
   private static List<User> getManager(Id Ids, Map<ID,User> groupUser, List<User> manager){
      // Manager 검색대상 , 예외대상, 적산되는 List
      List<User> tmpUserList = new List<User>(manager);
      User tmpUser = [SELECT id, ManagerId, Name FROM User WHERE Id=:Ids];
      User tmpManager = [SELECT Id, Name FROM User WHERE id=:tmpUser.ManagerId];

      if (tmpUser.ManagerId != null){
          if (groupUser.get(tmpManager.Id) == null){
              //그룹유저에 존재O
              tmpUserList.add(tmpmanager);
              return getManager(tmpManager.Id, groupUser, tmpUserList);
          }
          tmpUserList.add(tmpManager);
          return tmpUserList;
      }

      return tmpUserList;
  }

}
