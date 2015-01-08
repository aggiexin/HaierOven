//
//  InternetManager.h
//  追爱行动
//
//  Created by 刘康 on 14-10-3.
//  Copyright (c) 2014年 origheart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHNetworkUrls.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "User.h"
#import "CookbookDetail.h"
#import "Tag.h"

typedef NS_ENUM(NSInteger, InternetErrorCode) {
    InternetErrorCodeConnectInternetFailed      = -100,      //网络连接失败
    InternetErrorCodeRequestFailed,                          //网络请求失败
    InternetErrorCodeErrorMessageReturned,                   //返回错误信息
    InternetErrorCodeLoginExpired,                           //登录过期
    InternetErrorCodeDefaultFailed,                          //其他错误
};

typedef NS_ENUM(NSInteger, ValidateType) {
    ValidateTypeNormal,      //

};

typedef NS_ENUM(NSInteger, ValidateScene) {
    ValidateSceneNormal,      //
    
};

typedef NS_ENUM(NSInteger, AccType) {
    AccTypeHaier    = 0,    //官网
    AccTypeQQ,      //QQ
    AccTypeWeixin,  //微信
    AccTypeSina,    //新浪
    
};

typedef NS_ENUM(NSInteger, LoginType) {
    LoginTypeUserName = 0,  //用户名登录
    LoginTypeMobile,      //手机号登录
    LoginTypeEmail,         //邮箱登录
    
};


#define ErrorDomain     @"cn.edaysoft.51keman"

/**
 *  分页请求每页的数量
 */
#define PageLimit   20


@interface InternetManager : NSObject

typedef void (^myCallback) (BOOL success, id obj, NSError* error);

+ (InternetManager*)sharedManager;

#pragma mark - 检查网络状态

/**
 * 检查是否能连接网站
 */
- (BOOL)canConnectInternet;

/**
 *  当前网络环境是不是Wifi
 */
@property (nonatomic) BOOL isWiFiConnected;

#pragma mark - 登录注册

/**
 *  用户注册，邮箱或者手机号注册，至少传一个
 *
 *  @param email      邮箱
 *  @param phone      手机号
 *  @param password   密码
 *  @param completion 调用结果回调，调用失败可从error中（NSLocalizedDescriptionKey）获取错误描述信息
 */
- (void)registerWithEmail:(NSString*)email andPhone:(NSString*)phone andPassword:(NSString*)password callBack:(myCallback)completion;

/**
 *  激活用户, 注册成功后海尔会发个验证码到注册的手机，然后需要通过app激活，app只需要传入收到的uvc（验证码）和用户名(注册用户名、手机号或邮箱)
 *
 *  @param loginName     <#loginName description#>
 *  @param validateType  <#validateType description#>
 *  @param scene         <#scene description#>
 *  @param accType       <#accType description#>
 *  @param transactionId <#transactionId description#>
 *  @param uvc           <#uvc description#>
 *  @param completion    <#completion description#>
 */
- (void)activateUserWithLoginName:(NSString*)loginName
                  andValidateType:(ValidateType)validateType
                 andValidateScene:(ValidateScene)scene
                       andAccType:(AccType)accType
                 andTransactionId:(NSString*)transactionId
                           andUvc:(NSString*)uvc
                         callBack:(myCallback)completion;


/**
 *  用户登录
 *
 *  @param sequenceId            <#sequenceId description#>
 *  @param accType               <#accType description#>
 *  @param loginId               用户名
 *  @param password              密码
 *  @param thirdPartyAppId       第三方登录AppId
 *  @param thirdPartyAccessToken 第三方登录AccessToken
 *  @param loginType             <#loginType description#>
 *  @param completion            登录结果回调
 */
- (void)loginWithSequenceId:(NSString*)sequenceId
                 andAccType:(AccType)accType
                 andloginId:(NSString*)loginId
                andPassword:(NSString*)password
         andThirdpartyAppId:(NSString*)thirdPartyAppId
   andThirdpartyAccessToken:(NSString*)thirdPartyAccessToken
               andLoginType:(LoginType)loginType
                   callBack:(myCallback)completion;

/**
 *  获取动态验证码
 *
 *  @param loginName     用户名
 *  @param validateType  <#validateType description#>
 *  @param validateScene <#validateScene description#>
 *  @param accType       <#accType description#>
 *  @param transactionId <#transactionId description#>
 *  @param completion    结果回调
 */
- (void)getVerCodeWithLoginName:(NSString*)loginName
                andValidateType:(ValidateType)validateType
               andValidateScene:(ValidateScene)scene
                     andAccType:(AccType)accType
               andTransactionId:(NSString*)transactionId
                       callBack:(myCallback)completion;

/**
 *  退出登录
 *
 *  @param loginName  登录名
 *  @param completion 结果回调
 */
- (void)logoutWithLoginName:(NSString*)loginName callBack:(myCallback)completion;


#pragma mark - 个人信息

/**
 *  根据userBaseId获取个人信息
 *
 *  @param userBaseId userBaseId
 *  @param completion 结果回调
 */
- (void)getUserInfoWithUserBaseId:(NSString*)userBaseId callBack:(myCallback)completion;

/**
 *  修改邮箱
 *
 *  @param userBaseId
 *  @param email      新邮箱
 *  @param completion 结果回调
 */
- (void)updateEmailUserBaseId:(NSString*)userBaseId andEmail:(NSString*)email callBack:(myCallback)completion;

/**
 *  修改手机号
 *
 *  @param userBaseId
 *  @param phone      新手机号
 *  @param completion 结果回调
 */
- (void)updatePhoneUserBaseId:(NSString*)userBaseId andPhone:(NSString*)phone callBack:(myCallback)completion;

/**
 *  修改其他用户信息
 *
 *  @param user       用户对象
 *  @param completion 结果回调
 */
- (void)updateUserInfo:(User*)user callBack:(myCallback)completion;

/**
 *  添加关注
 *
 *  @param userBaseId 用户Id
 *  @param userBaseId 被关注用户Id
 *  @param completion 结果回调
 */
- (void)addFollowWithUserBaseId:(NSString*)userBaseId andFollowedUserBaseId:(NSString*)followdUserBaseId callBack:(myCallback)completion;

/**
 *  取消关注
 *
 *  @param userBaseId 用户Id
 *  @param userBaseId 被关注用户Id
 *  @param completion 结果回调
 */
- (void)deleteFollowWithUserBaseId:(NSString*)userBaseId andFollowedUserBaseId:(NSString*)followdUserBaseId callBack:(myCallback)completion;

/**
 *  获取关注的人列表
 *
 *  @param userBaseId 用户Id
 *  @param pageIndex  当前请求的页数
 *  @param completion 结果回调
 */
- (void)getFollowersWithUserBaseId:(NSString*)userBaseId andPageIndex:(NSInteger)pageIndex callBack:(myCallback)completion;

/**
 *  获取粉丝列表
 *
 *  @param userBaseId 用户Id
 *  @param pageIndex  当前请求页数
 *  @param completion 结果回调
 */
- (void)getFansWithUserBaseId:(NSString*)userBaseId andPageIndex:(NSInteger)pageIndex callBack:(myCallback)completion;



#pragma mark - 标签

/**
 *  获取所有标签
 *
 *  @param completion 结果回调
 */
- (void)getTagsCallBack:(myCallback)completion;

/**
 *  获取热门标签
 *
 *  @param completion 结果回调
 */
- (void)getHotTagsCallback:(myCallback)completion;


#pragma mark - 评论

/**
 *  添加菜谱评论
 *
 *  @param cookbookId 菜谱ID
 *  @param userBaseId 用户ID
 *  @param content    评论内容
 *  @param completion 结果回调
 */
- (void)addCommentWithCookbookId:(NSString*)cookbookId andUserBaseid:(NSString*)userBaseId andComment:(NSString*)content callBack:(myCallback)completion;

/**
 *  获取指定菜谱的评论
 *
 *  @param cookbookId 菜谱Id
 *  @param pageIndex  当前请求页数
 *  @param completion 结果回调
 */
- (void)getCommentsWithCookbookId:(NSString*)cookbookId andPageIndex:(NSInteger)pageIndex callBack:(myCallback)completion;


#pragma mark - 菜谱

/**
 *  获取所有菜谱
 *
 *  @param pageIndex  当前请求页数
 *  @param completion 结果回调
 */
- (void)getAllCookbooksWithPageIndex:(NSInteger)pageIndex callBack:(myCallback)completion;

/**
 *  获取我发布的菜谱
 *
 *  @param pageIndex  当前请求页数
 *  @param completion 结果回调
 */
/**
 *  获取我发布的菜谱
 *
 *  @param userBaseId 用户ID
 *  @param status     菜谱状态：-1为所有状态的菜谱 0为草稿 1为已发布
 *  @param pageIndex  获取页数
 *  @param completion 结果回调
 */
- (void)getCookbooksWithUserBaseId:(NSString*)userBaseId cookbookStatus:(NSInteger)status pageIndex:(NSInteger)pageIndex callBack:(myCallback)completion;

/**
 *  搜索菜谱
 *
 *  @param keyword    搜索关键字
 *  @param pageIndex  当前请求页数
 *  @param completion 结果回调
 */
- (void)searchCookbooksWithKeyword:(NSString*)keyword pageIndex:(NSInteger)pageIndex callBack:(myCallback)completion;

/**
 *  获取菜谱详情
 *
 *  @param cookbookId 菜谱ID
 *  @param completion 结果回调
 */
- (void)getCookbookDetailWithCookbookId:(NSString*)cookbookId userBaseId:(NSString*)userBaseId callBack:(myCallback)completion;

/**
 *  添加菜谱
 *
 *  @param cookbookDetail   菜谱对象
 *  @param completion       结果回调
 */
- (void)addCookbookWithCookbook:(CookbookDetail*)cookbookDetail callBack:(myCallback)completion;

/**
 *  修改菜谱
 *
 *  @param cookbookDetail 菜谱对象
 *  @param completion     结果回调
 */
- (void)modifyCookbook:(CookbookDetail*)cookbookDetail callBack:(myCallback)completion;

/**
 *  删除菜谱
 *
 *  @param cookbookId 菜谱ID
 *  @param completion 结果回调
 */
- (void)deleteCookbookWithCookbookId:(NSString*)cookbookId callBack:(myCallback)completion;

/**
 *  赞菜谱
 *
 *  @param cookbookId 菜谱ID
 *  @param userBaseId 用户ID
 *  @param completion 结果回调
 */
- (void)praiseCookbookWithCookbookId:(NSString*)cookbookId userBaseId:(NSString*)userBaseId callBack:(myCallback)completion;


#pragma mark - 文件

/**
 *  文件上传 上传文件到服务器临时文件夹，并返回已上传文件路径。支持多个文件同时上传。
 *
 *  @param data       文件Data
 *  @param completion 结果回调
 */
- (void)uploadFile:(NSData*)data callBack:(myCallback)completion;


#pragma mark - 测试API接口使用

- (void)testRegisterWithEmail:(NSString*)email andPhone:(NSString*)phone andPassword:(NSString*)password callBack:(myCallback)completion;

- (void)testLoginWithSequenceId:(NSString*)sequenceId
                     andAccType:(AccType)accType
                     andloginId:(NSString*)loginId
                    andPassword:(NSString*)password
             andThirdpartyAppId:(NSString*)thirdPartyAppId
       andThirdpartyAccessToken:(NSString*)thirdPartyAccessToken
                   andLoginType:(LoginType)loginType
                       callBack:(myCallback)completion;


@end

































