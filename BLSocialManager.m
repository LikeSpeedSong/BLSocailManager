//
//  BLSocialManager.m
//  BeautyLab
//
//  Created by A_zhi on 2017/7/14.
//  Copyright © 2017年 CCE. All rights reserved.
//

#import "BLSocialManager.h"

#import "WBApiManager.h"
#import "WXApiManager.h"
#import "QQApiManager.h"

@implementation BLSocialUserInfo

@end

@implementation BLSocialShareMes


@end

@interface BLSocialManager()
{
    WXApiManager * wxManager;
    WBApiManager * wbManager;
    QQApiManager * qqManager;
}

@end

@implementation BLSocialManager
static BLSocialManager *instance;

+ (BLSocialManager *)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BLSocialManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        wxManager = [[WXApiManager alloc]init];
        wbManager = [[WBApiManager alloc]init];
        qqManager = [[QQApiManager alloc]init];
    }
    return self;
}

#pragma mark 配置 信息
/** 注册微信 appkey*/
- (void)registerWechatkey:(NSString*)wechatKey{
    [WXApi registerApp:wechatKey];
}

/** 注册新浪 appkey*/
- (void)registerSinaKey:(NSString*)sinaKey{
    [WeiboSDK registerApp:sinaKey];
}

/** 注册QQ appID*/
- (void)registerQQAppID:(NSString*)qqAppID{
    TencentOAuth * auth = [[TencentOAuth alloc] initWithAppId:qqAppID
                                     andDelegate:qqManager];
    qqManager.oauth = auth;
}

- (BOOL)handleOpenURL:(NSURL *)url{
   return  ([WXApi handleOpenURL:url delegate:wxManager]|| [WeiboSDK handleOpenURL:url delegate:wbManager]||[TencentOAuth HandleOpenURL:url]|| [QQApiInterface handleOpenURL:url delegate:qqManager]);
}

#pragma mark 分享 登录操作
/** 获取相应的用户信息*/
- (void)getUserInfoWithPlatform:(BLSocialPlatformType)platformType withRespose:(void(^)(BLSocialUserInfo* userInfo, NSError *error))block{
    switch (platformType) {
            // 开启QQ 授权
        case BLSocialPlatformType_QQ:
        case BLSocialPlatformType_QQZone:
            [qqManager startOuthQQWithRespose:block];
            break;
            
            // 开启 新浪授权
        case BLSocialPlatformType_Sina:
            [wbManager startOuthSinaWithRespose:block];
            break;
            
            // 开启微信 授权
        case BLSocialPlatformType_Wechat:
        case BLSocialPlatformType_WechatFriend:
            [wxManager startOuthWechatWithRespose:block];
            break;
            
        default:
            break;
    }
}


- (void)shareToPlatform:(BLSocialPlatformType)platformType shareMessage:(BLSocialShareMes*)shareMessage withIsSuccess:(void(^)(BOOL shareSuccess,NSError*error))block{
    switch (platformType) {
            
        case BLSocialPlatformType_QQ:
            [qqManager startShareWithShareMessage:shareMessage isQQZone:false withComplete:block];
            break;
        case BLSocialPlatformType_QQZone:
            [qqManager startShareWithShareMessage:shareMessage isQQZone:YES withComplete:block];
            break;
            
        case BLSocialPlatformType_Sina:
            [wbManager startShareWithShareMessage:shareMessage complete:block];
            break;
            // 微信 朋友圈 收藏 对应的类型为 0 ，1 ，2
        case BLSocialPlatformType_Wechat:
            [wxManager startShareWithShareMessage:shareMessage shareType:0 complete:block];
            break;
        case BLSocialPlatformType_WechatFriend:
             [wxManager startShareWithShareMessage:shareMessage shareType:1 complete:block];
            break;
            
        default:
            break;
    }
}


@end
