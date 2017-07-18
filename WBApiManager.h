//
//  WBApiManager.h
//  BeautyLab
//
//  Created by cce on 16/1/5.
//  Copyright © 2016年 CCE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "BLSocialManager.h"

@interface WBApiManager : NSObject<WeiboSDKDelegate>


/** 微博分享开始*/
- (void)startShareWithShareMessage:(BLSocialShareMes*)shareModel complete:(void(^)(BOOL isSuccess,NSError * error))block;

/** 微博授权开始*/
- (void)startOuthSinaWithRespose:(void(^)(BLSocialUserInfo* userInfo, NSError *error))block;
@end
