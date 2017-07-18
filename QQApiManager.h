//
//  QQApiManager.h
//  BeautyLab
//
//  Created by cce on 16/1/29.
//  Copyright © 2016年 CCE. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentApiInterface.h>

#import "BLSocialManager.h"


@interface QQApiManager : NSObject< TencentSessionDelegate, TCAPIRequestDelegate,QQApiInterfaceDelegate>

/** QQ授权属性变量*/
@property (nonatomic, strong)TencentOAuth *oauth;

/** QQ分享开始*/
- (void)startShareWithShareMessage:(BLSocialShareMes*)shareModel isQQZone:(BOOL)isQQZone withComplete:(void(^)(BOOL isSuccess,NSError * error))block;

/** QQ授权开始*/
- (void)startOuthQQWithRespose:(void(^)(BLSocialUserInfo* userInfo, NSError *error))block;
@end
