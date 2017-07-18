//
//  WXApiManager.h
//  BeautyLab
//
//  Created by cce on 16/1/5.
//  Copyright © 2016年 CCE. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WXApi.h"

#import "BLSocialManager.h"

@interface WXApiManager : NSObject<WXApiDelegate>

/** 微信开始分享*/
- (void)startShareWithShareMessage:(BLSocialShareMes*)shareModel shareType:(int)secen complete:(void(^)(BOOL isSuccess,NSError * error))block;

/** 微信授权开始*/
- (void)startOuthWechatWithRespose:(void(^)(BLSocialUserInfo* userInfo, NSError *error))block;

@end
