//
//  WXApiManager.m
//  BeautyLab
//
//  Created by cce on 16/1/5.
//  Copyright © 2016年 CCE. All rights reserved.
//

#import "WXApiManager.h"

@interface WXApiManager  ()
/** 分享的回调*/
@property (strong, nonatomic) void (^shareBlock)(BOOL isSuccess,NSError * error);
/** 登录的回调*/
@property (strong, nonatomic) void (^outhBlock)(BLSocialUserInfo * userInfo,NSError * error);
@end

@implementation WXApiManager

#pragma mark 微信分享、授权

- (void)startShareWithShareMessage:(BLSocialShareMes*)shareModel shareType:(int)secen complete:(void(^)(BOOL isSuccess,NSError * error))block{
     self.shareBlock = block;
    
    if (![WXApi isWXAppInstalled])
    self.shareBlock(NO, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(NoWXAppInstalledTip, nil)}]);
    
    UIImage * newImage;
    if (shareModel.shareIconPath&&![shareModel.shareIconPath isEqualToString:@""]) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:shareModel.shareIconPath]];
        UIImage * image=[UIImage imageWithData:data];
        newImage=[self thumbnailWithImageWithoutScale:image size:CGSizeMake(50, 50)];
    }
    else if(shareModel.shareImage){
         newImage = [self thumbnailWithImageWithoutScale:shareModel.shareImage size:CGSizeMake(120, 120)];
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = shareModel.shareUrlPath;
    WXMediaMessage *message = [self messageWithTitle: shareModel.shareTitle
                                         Description:shareModel.shareContent
                                              Object:ext
                                          MessageExt:nil
                                       MessageAction:nil
                                          ThumbImage:newImage
                                            MediaTag:@""];
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.message=message;
    req.scene = secen;
    [WXApi sendReq:req];
    
}

- (void)startOuthWechatWithRespose:(void(^)(BLSocialUserInfo* userInfo, NSError *error))block{
    
    self.outhBlock = block;
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    [WXApi sendReq:req];
}

#pragma mark 微信回调
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        // 分享成功
        if (resp.errCode == WXSuccess) {
            
            self.shareBlock(YES,nil);
            
        }
        else if (resp.errCode == WXErrCodeUserCancel){
            self.shareBlock(NO, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"微信取消分享", nil)}]);
            
        }
        else{
            self.shareBlock(NO, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"微信授权失败", nil)}]);
        }
    }
    // 授权 相关
    else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        [self handelWeChatResponse:authResp];
    }
}


- (void)handelWeChatResponse:(SendAuthResp*)response{
    if (response.errCode==0) {
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *urlStr = [NSString stringWithFormat:kWeixinUrl,kWeixinAppKey,kWeixinAppSerect,response.code];
            NSString *zoneStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:nil];
            NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *userInfoUrl=[NSString stringWithFormat:kWeixinUserInfoUrl,dic[@"access_token"],dic[@"openid"]];
                
                NSString *userInfoStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:userInfoUrl] encoding:NSUTF8StringEncoding error:nil];
                NSData *userInfoData = [userInfoStr dataUsingEncoding:NSUTF8StringEncoding];
                if (userInfoData) {
                    NSDictionary *userInfoDict = [NSJSONSerialization JSONObjectWithData:userInfoData options:NSJSONReadingMutableContainers error:nil];
                    
                    BLSocialUserInfo * userInfo = [[BLSocialUserInfo alloc]init];
                    userInfo.iconurl = userInfoDict[@"headimgurl"];
                    userInfo.name = userInfoDict[@"nickname"];
                    userInfo.openID = userInfoDict[@"unionid"];
                    userInfo.location = userInfoDict[@"location"];
                    userInfo.accessToken = dic[@"access_token"];
                    self.outhBlock(userInfo, nil);
                }
                else{
                    self.outhBlock(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"微信认证失败", nil)}]);
                }
            }
            else{
                self.outhBlock(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"微信认证失败", nil)}]);
            }
        });
    }
    else{
        self.outhBlock(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"微信取消登录", nil)}]);
    }
    
}

- (WXMediaMessage *)messageWithTitle:(NSString *)title
                         Description:(NSString *)description
                              Object:(id)mediaObject
                          MessageExt:(NSString *)messageExt
                       MessageAction:(NSString *)action
                          ThumbImage:(UIImage *)thumbImage
                            MediaTag:(NSString *)tagName {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = mediaObject;
    message.messageExt = messageExt;
    message.messageAction = action;
    message.mediaTagName = tagName;
    [message setThumbImage:thumbImage];
    return message;
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            
            rect.size.width = asize.width;
            rect.size.height =asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = - (rect.size.height-asize.height)/2;
        }
        else{
            rect.size.height = asize.height;
            rect.size.width =asize.height*oldsize.width/oldsize.height;
            rect.origin.x =-(rect.size.width-asize.width)/2;
            rect.origin.y = 0;
        }
        
        UIGraphicsBeginImageContext(asize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        
        [image drawInRect:rect];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    return newimage;
    
}

@end
