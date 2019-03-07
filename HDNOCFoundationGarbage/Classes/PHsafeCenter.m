//
//  safeCenter.m
//  TouchIDDemo
//
//  Created by llbt on 2018/7/30.
//  Copyright © 2018年 Lee2Go. All rights reserved.
//
#import <LocalAuthentication/LocalAuthentication.h>
#define FingerPrint @"fingerPrint"
#define failFingerCountID @"failFingerCount"
#define CELLPHONE @"Phones"
#define FACE @"face"
#define FACEDEAL @"facedeal"
#define FINGER @"finger"
#import "PHsafeCenter.h"
#import "SAMKeychain.h"
#import "YKeychain.h"
#import <UIKit/UIKit.h>
static NSString *const TOUCH_ID_DATA_SERVICE = @"TOUCH_ID_DATA_SERVICE";

static NSString *CURRENT_TOUCH_ID_IDENTITY = nil;

static NSString *const CURRENT_TOUCH_ID_IDENTITY_PERFIX = @"TOUCH_ID@";
@implementation PHsafeCenter
+ (void)setCurrentTouchIdDataIdentity:(NSString *)identity
{
    CURRENT_TOUCH_ID_IDENTITY = identity;
}
+ (NSString*)currentTouchIdDataIdentity
{
    return CURRENT_TOUCH_ID_IDENTITY;
}
+ (BOOL)setCurrentIdentityTouchIdData
{
    if (CURRENT_TOUCH_ID_IDENTITY == nil) {
        NSLog(@"[touchId]:currentIdentity not set");
        return NO;
    }
    else
    {
        return [self setCurrentIdentityTouchIdData:[self currentOriTouchIdData]];
    }
}
//+(BOOL)systemVersinHasChanged{
//   NSString *currentSystemVersion = []
//
//
//    return  false
//}

+(void)setTheNewSystemVersionInChain{
    NSString *version = [[UIDevice currentDevice]  systemVersion];
    [YKeychain setValue:version forKey:@"systemversion"];
}

+(BOOL)hasSetSystemVersionInChain{
    NSString *version = [YKeychain valueForKey:@"systemversion"];
    if (version.length == 0 ||version ==nil ||[version  isEqualToString:@""]) {
        return  false;
    }
    return  true;
}
//是否改变
+(BOOL)hasChangedTheSystemVersionInChain{
    NSString *chainVersion = [YKeychain valueForKey:@"systemversion"];
    NSString *currentVersion = [[UIDevice currentDevice]  systemVersion];
    if ([chainVersion isEqualToString: currentVersion]) {
        return  false;
    }
    return  true;
    
}

+(BOOL)hasSystemChangedOrTouchIdInfoChanged{
    if ([self hasChangedTheSystemVersionInChain]==false && [self touchIdInfoDidChange]==false) {
        return NO;
    }
    return YES;
}

+ (BOOL)touchIdInfoDidChange
{
    
    NSData *data = [self currentTouchIdDataForCompare];
    if (!data && [self isErrorTouchIDLockout]) {
        //输入次数过多被锁定，此时指纹并没有变更
        return NO;
    }
    NSData *oldData = [self currentIdentityTouchIdData];
    if (oldData == nil) {
        //应用内该账号未设置过指纹
        return NO;
    }
    else if ([oldData isEqual:data]) {
        //没有变化
        return NO;
    }
    else
    {
        //指纹信息发生变化
        return YES;
    }
}
+ (NSData*)currentTouchIdDataForCompare
{
    return  [self currentOriTouchIdData];
}


+ (NSData*)currentOriTouchIdData
{
    //实测不同app返回的值不一样,这个不能做担保。
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"error:%@",error);
    }
    return context.evaluatedPolicyDomainState;
}


#pragma mark - identityTouchData
+ (NSData*)currentIdentityTouchIdData
{
    if ([self accountForKeychainWithIdentify]) {
        return [SAMKeychain passwordDataForService:TOUCH_ID_DATA_SERVICE account:[self accountForKeychainWithIdentify]];
    }
    else
    {
        return nil;
    }
}

//获取保存在钥匙串中的指纹数据
+ (NSData*) getFingerprintData{
    return [self currentIdentityTouchIdData];
}

#pragma mark - currentTouchIdData
+ (NSString*)accountForKeychainWithIdentify
{
    if ([self currentTouchIdDataIdentity]) {
        return [CURRENT_TOUCH_ID_IDENTITY_PERFIX stringByAppendingString:[self currentTouchIdDataIdentity]];
    }
    else
    {
        return nil;
    }
}



+ (BOOL)setCurrentIdentityTouchIdData:(NSData *)data
{
    if ([self accountForKeychainWithIdentify] && data) {
        NSError *error;
        [SAMKeychain setPasswordData:data forService:TOUCH_ID_DATA_SERVICE account:[self accountForKeychainWithIdentify] error:&error];
        if (!error) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
    
}
#pragma mark -
+ (BOOL)isErrorTouchIDLockout
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    return error.code == kLAErrorTouchIDLockout ? YES : NO;
}

//+(BOOL)isOpenFingerPrint{
//    return  [[NSUserDefaults standardUserDefaults ] boolForKey:FingerPrint];
//}
//获取手势
+(NSInteger)failFingerCount{
    return  [[[NSUserDefaults standardUserDefaults] objectForKey:failFingerCountID]  integerValue];
}

+(void)setFailFingerNum:(NSInteger)index{
    [[NSUserDefaults standardUserDefaults]  setObject:@(index) forKey:failFingerCountID];
}

+(void)addFailFingerNum:(NSInteger)num{
    NSInteger count = [self failFingerCount] + num;
    [self setFailFingerNum:count];
}

+(void)OpenOrCloseFace:(BOOL)isOpen{
    //    UserDefaults.standard.set(valueData, forKey: kPhone)
    NSString *cellPhone = [[NSUserDefaults standardUserDefaults] objectForKey:CELLPHONE];
    NSString *key = [NSString stringWithFormat:@"%@%@",cellPhone,FACE];
    [[NSUserDefaults standardUserDefaults] setBool:isOpen forKey:key];
}

+(void)openOrCloseFaceDeal:(BOOL)isOpen{
    NSString *cellPhone = [[NSUserDefaults standardUserDefaults] objectForKey:CELLPHONE];
    NSString *key = [NSString stringWithFormat:@"%@%@",cellPhone,FACEDEAL];
    [[NSUserDefaults standardUserDefaults] setBool:isOpen forKey:key];
}


+(BOOL)getFaceOpenOrNot{
    NSString *cellPhone = [[NSUserDefaults standardUserDefaults] objectForKey:CELLPHONE];
    NSString *key = [NSString stringWithFormat:@"%@%@",cellPhone,FACE];
    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    return b;
    
}

+(BOOL)getFaceDealOpenOrNot{
    NSString *cellPhone = [[NSUserDefaults standardUserDefaults] objectForKey:CELLPHONE];
    NSString *key = [NSString stringWithFormat:@"%@%@",cellPhone,FACEDEAL];
    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    return b;
    
    
}


+(void)OpenOrCloseFinger:(BOOL)isOpen{
    NSString *cellPhone = [[NSUserDefaults standardUserDefaults] objectForKey:CELLPHONE];
    NSString *key = [NSString stringWithFormat:@"%@%@",cellPhone,FINGER];
    [[NSUserDefaults standardUserDefaults] setBool:isOpen forKey:key];
}

+(BOOL)getFingerOpenOrNot{
    NSString *cellPhone = [[NSUserDefaults standardUserDefaults] objectForKey:CELLPHONE];
    NSString *key = [NSString stringWithFormat:@"%@%@",cellPhone,FINGER];
    //    [[NSUserDefaults standardUserDefaults] setBool:isOpen forKey:key];
    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    return b;
}



//+(void)openFingerOrNot:(BOOL)b{
//
//    [[NSUserDefaults standardUserDefaults] setBool:b forKey:FingerPrint];
//}

+(BOOL)supportFingerOrNot{
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //支持指纹验证
        return YES;
    }else{
        return  NO;
        //不支持指纹识别，LOG出错误详情
        
    }
    
}

//能否使用指纹判断 是否被锁定
+(BOOL)canUseFinger{
    if ([self supportFingerOrNot]==YES &&[self  failFingerCount]<=5) {
        return true;
    }
    return false;
}

+(void)handleFingerSuccess:(void(^)(void))successHandle andFailed:(void(^)(int))fail{
    if ([self touchIdInfoDidChange]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"指纹信息变更" message:nil delegate:nil cancelButtonTitle:@"cannel" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    //    if  [self touchIdInfoDidChange] == true {
    //
    //
    //    }
    
    
    
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    
    //    context.localizedCancelTitle = @"请输入验证码";
    context.localizedFallbackTitle = @"请输入验证码";
    //    context.touchIDAuthenticationAllowableReuseDuration
    NSString* result = @"请验证已有指纹";
    BOOL b = [self supportFingerOrNot];//b==no 说明无不再支持了
    //    if (b==NO) {
    //        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"指纹验证错误次数过多，请输入密码" reply:^(BOOL success, NSError * _Nullable error) {
    //            if (success) {
    //                successHandle();
    //            }
    //        }];
    //        return;
    //    }
    
    
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    //其他情况，切换主线程处理
                    successHandle();
                }];
                //                [self setFailFingerNum:0];
                
                //验证成功，主线程处理UI
            }
            else
            {
                //                [self addFailFingerNum:3];
                //                fail(error)
                //                error.code
                //                result = @"还1次";
                //                context.localizedReason = @"123";
                NSLog(@"%@",error.localizedDescription);
                //                fail(error.code)
                
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        //系统取消授权，如其他APP切入
                        break;
                    }
                    case kLAErrorTouchIDLockout:{
                        //系统已经被锁定
                        fail(error.code);
                        //                        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"指纹验证错误次数过多，请输入密码" reply:^(BOOL success, NSError * _Nullable error) {
                        //                            if (success) {
                        //                                successHandle();
                        //                            }
                        //                        }];
                        
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        //授权失败 三次失败后
                        [self addFailFingerNum:3];
                        NSLog(@"授权失败");
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        //系统未设置密码
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        //设备Touch ID不可用，例如未打开
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        //设备Touch ID不可用，用户未录入
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        //                        [self setFailFingerNum:6];
                        //                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        //                            //用户选择输入密码，切换主线程处理
                        //                            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请输入密码" reply:^(BOOL success, NSError * _Nullable error) {
                        //                                if (success) {
                        //                                  successHandle();
                        //                                }
                        //                            }];
                        //                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
            }
        }];
    }
    else
    {
        
        //不支持指纹识别，LOG出错误详情
        NSLog(@"不支持指纹识别");
        fail(error.code);
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                NSLog(@"A passcode has not been set");
                break;
            }
            default:
            {
                NSLog(@"TouchID not available");
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
    
    
    
}




@end

