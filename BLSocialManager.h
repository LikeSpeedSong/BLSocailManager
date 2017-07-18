//
//  BLSocialManager.h
//  BeautyLab
//
//  Created by A_zhi on 2017/7/14.
//  Copyright © 2017年 CCE. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NoWXAppInstalledTip  @"亲，您没有安装微信哦"
#define NoWBAppInstalledTip  @"亲，您没有安装微博哦"
#define NoQQAppInstalledTip  @"亲，您没有安装QQ哦"

typedef  NS_ENUM(NSUInteger,BLSocialPlatformType){
    BLSocialPlatformType_QQ, // qq
    BLSocialPlatformType_QQZone,//qq 空间
    BLSocialPlatformType_Wechat,// 微信
    BLSocialPlatformType_WechatFriend, //微信朋友圈
    BLSocialPlatformType_Sina,// 新浪微博
};

@interface BLSocialShareMes : NSObject
// 分享 iconpath 与 image 必须传一个 否则无法分享

/** 分享标题 */
@property (nonatomic,copy)NSString * shareTitle;
/** 分享内容*/
@property (nonatomic,copy)NSString * shareContent;
/** 分享头像icon 可以不传 */
@property (nonatomic,copy)NSString * shareIconPath;
/** 分享对应的链接  */
@property (nonatomic,copy)NSString * shareUrlPath;
/** 分享image*/
@property (copy, nonatomic)UIImage * shareImage;

@end

@interface BLSocialUserInfo : NSObject
/** 三方ID*/
@property (nonatomic,copy)NSString * openID;
/** 三方昵称*/
@property (nonatomic,copy)NSString * name;
/** 三方头像路劲*/
@property (nonatomic,copy)NSString * iconurl;
/** 三方 错误提示*/
@property (nonatomic,copy)NSString * errorStr;
/** 三方 位置*/
@property (nonatomic,copy)NSString * location;
/** 三方 accessToken*/
@property (nonatomic,copy)NSString * accessToken;
@end

@interface BLSocialManager : NSObject

/** 单列对象*/
+ (BLSocialManager *)defaultManager;

/** 注册微信 appkey*/
- (void)registerWechatkey:(NSString*)wechatKey;

/** 注册新浪 appkey*/
- (void)registerSinaKey:(NSString*)sinaKey;

/** 注册QQ appID*/
- (void)registerQQAppID:(NSString*)qqAppID;

/**处理 app之间的跳转 所有均可用*/
- (BOOL)handleOpenURL:(NSURL*)url;

/** 获取相应的用户信息*/
- (void)getUserInfoWithPlatform:(BLSocialPlatformType)platformType withRespose:(void(^)(BLSocialUserInfo* userInfo, NSError *error))block;

/** 分享到相应的平台*/
- (void)shareToPlatform:(BLSocialPlatformType)platformType shareMessage:(BLSocialShareMes*)shareMessage withIsSuccess:(void(^)(BOOL shareSuccess,NSError * error))block;


@end
