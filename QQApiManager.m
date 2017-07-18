//
//  QQApiManager.m
//  BeautyLab
//
//  Created by cce on 16/1/29.
//  Copyright © 2016年 CCE. All rights reserved.
//

#import "QQApiManager.h"

@interface QQApiManager()
/** 分享的回调*/
@property (copy, nonatomic) void (^shareBlock)(BOOL isSuccess ,NSError * error);
/** 登录的回调*/
@property (copy, nonatomic) void (^outhBlock)(BLSocialUserInfo * userInfo,NSError * error);
@end

@implementation QQApiManager


#pragma mark qq分享

- (void)startShareWithShareMessage:(BLSocialShareMes*)shareModel isQQZone:(BOOL)isQQZone withComplete:(void(^)(BOOL isSuccess,NSError * error))block{
    self.shareBlock = block;
    
    if (![TencentOAuth iphoneQQInstalled])
    self.shareBlock(NO, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(NoQQAppInstalledTip, nil)}]);
    
     QQApiNewsObject * newsObj;
    // 先取 网页链接
    if (shareModel.shareIconPath&&![shareModel.shareIconPath isEqualToString:@""]) {
        newsObj = [QQApiNewsObject
                   objectWithURL :[NSURL URLWithString:shareModel.shareUrlPath]
                   title: shareModel.shareTitle
                   description :shareModel.shareContent
                   previewImageURL:[NSURL URLWithString:shareModel.shareIconPath]];
    }
    else if(shareModel.shareImage){
        UIImage * image = [self thumbnailWithImageWithoutScale:shareModel.shareImage size:CGSizeMake(200, 200)];
        newsObj=[QQApiNewsObject
                 objectWithURL:[NSURL URLWithString:shareModel.shareUrlPath]
                 title:shareModel.shareTitle
                 description:shareModel.shareContent
                 previewImageData:UIImagePNGRepresentation(image)];
    }
    uint64_t cflag = 0;
    // 判断是否是扣扣空间
    if (isQQZone)
    cflag = kQQAPICtrlFlagQZoneShareOnStart;
    
    [newsObj setCflag:cflag];
    QQApiObject* objc = newsObj;
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:objc];
    [QQApiInterface sendReq:req];
}

- (void)startOuthQQWithRespose:(void(^)(BLSocialUserInfo* userInfo, NSError *error))block{
    self.outhBlock = block;
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            nil];
    [_oauth authorize:permissions inSafari:YES];
}

#pragma mark qq登录成功 回调

- (void)tencentDidLogin
{
    [_oauth getUserInfo];
    
}

// 点击了取消登录
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
     self.outhBlock(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"QQ取消登录", nil)}]);
    
}

// 登录时 没有网络的回调
- (void)tencentDidNotNetWork
{
    self.outhBlock(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"请检查您的网络设置", nil)}]);
}

- (void)tencentDidLogout
{
    
}

#pragma mark qq登录的回调
- (void)getUserInfoResponse:(APIResponse*) response
{
    if (URLREQUEST_SUCCEED == response.retCode
        && kOpenSDKErrorSuccess == response.detailRetCode) {
       
        NSString * openID = [_oauth getUserOpenID];
        NSDictionary * dict = response.jsonResponse;
        
        BLSocialUserInfo * userInfo = [[BLSocialUserInfo alloc]init];
        userInfo.iconurl = dict[@"figureurl_qq_2"];
        userInfo.name = dict[@"nickname"];;
        userInfo.openID = openID;
//        userInfo.location = userInfoDict[@"location"];
//        userInfo.accessToken = dic[@"access_token"];
        self.outhBlock(userInfo, nil);
    }else{
        self.outhBlock(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"QQ授权失败", nil)}]);
    }
    
}

#pragma mark 扣扣分享的回调
- (void)onReq:(QQBaseReq *)req{
    
}
- (void)isOnlineResponse:(NSDictionary *)response{
    
}

- (void)onResp:(QQBaseResp *)resp{
    if ([resp isKindOfClass:[SendMessageToQQResp class]] ) {
        if (resp.errorDescription==nil&&[resp.result intValue]==0) {
            self.shareBlock(YES,nil);
           
        }
        else if([resp.result isEqualToString:@"-4"]){
            self.shareBlock(NO, [NSError errorWithDomain:NSCocoaErrorDomain code:402 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"QQ取消分享", nil)}]);
        }
    }
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
