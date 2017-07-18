//
//  WBApiManager.m
//  BeautyLab
//
//  Created by cce on 16/1/5.
//  Copyright © 2016年 CCE. All rights reserved.
//

#import "WBApiManager.h"

@interface WBApiManager ()
/** 分享的回调*/
@property (strong, nonatomic) void (^shareBlock)(BOOL isSuccess,NSError *error);
/** 登录的回调*/
@property (strong, nonatomic) void (^outhBlock)(BLSocialUserInfo * userInfo,NSError * error);

@end

@implementation WBApiManager


// 微博分享
- (void)startShareWithShareMessage:(BLSocialShareMes*)shareModel complete:(void(^)(BOOL isSuccess,NSError * error))block{
    self.shareBlock = block;
    
    if (![WeiboSDK isWeiboAppInstalled])
    self.shareBlock(NO, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(NoWBAppInstalledTip, nil)}]);
    
    WBMessageObject *message = [WBMessageObject message];
    NSString * content = shareModel.shareContent;
    // 分享 字数大于100 会以。。。结尾
    if (content.length>100) {
        content=[[content substringToIndex:100] stringByAppendingString:@"...."];
    }
    // 分享 image
    NSData * imageData;
    imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:shareModel.shareIconPath]];
    if (imageData==nil)
    imageData=UIImagePNGRepresentation(shareModel.shareImage);
    
    
    content = [content stringByAppendingString:shareModel.shareUrlPath];
    message.text = content;
    WBImageObject *images = [WBImageObject object];
    images.imageData = imageData;
    message.imageObject = images;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.userInfo = @{@"ShareMessageFrom": @"WBApiManager",
                         @"info": @"123"};
    [WeiboSDK sendRequest:request];
}

// 微博登录
- (void)startOuthSinaWithRespose:(void(^)(BLSocialUserInfo* userInfo, NSError *error))block{
    
    self.outhBlock = block;
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kWeiboRedirectUrl;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

// 微博 分享 登录 相关回调
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    // 微博 分享
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            self.shareBlock(YES,nil);

        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
             self.shareBlock(NO, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"微博取消分享", nil)}]);
        }else{
               self.shareBlock(NO, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"微博授权失败", nil)}]);
        }
    }
    //  微博 登录
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        WBAuthorizeResponse *autoResponse=(WBAuthorizeResponse*)response;
        if (autoResponse.accessToken) {
            NSString *urlStr=[NSString stringWithFormat:kWeiboUserInfoUrl,autoResponse.accessToken,autoResponse.userID];
//            NSLog(@"微博 的 token====%@",autoResponse.accessToken);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *zoneUrl = [NSURL URLWithString:urlStr];
                NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
                NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
                if (data) {
                    NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                  
                    BLSocialUserInfo * userInfo = [[BLSocialUserInfo alloc]init];
                    userInfo.iconurl = dict[@"avatar_hd"];
                    userInfo.name = dict[@"name"];
                    userInfo.openID = dict[@"idstr"];
                    userInfo.location = dict[@"location"];
                    userInfo.accessToken = autoResponse.accessToken;
                    self.outhBlock(userInfo, nil);
                }
                else{
                    self.outhBlock(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"获取微博数据失败", nil)}]);
                }
            });
        }else{
             self.outhBlock(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"微博取消登录", nil)}]);
        }
        
    }
    
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

//    WBWebpageObject *webpage = [WBWebpageObject object];
//    webpage.objectID = @"identifier1";
//    webpage.title = NSLocalizedString(@"分享网页标题", nil);
//    webpage.description = [NSString stringWithFormat:NSLocalizedString(@"分享网页内容简介-%.0f", nil), [[NSDate date] timeIntervalSince1970]];
//    webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
//        webpage.webpageUrl = @"http://sina.cn?a=1";
//    message.mediaObject = webpage;

@end
