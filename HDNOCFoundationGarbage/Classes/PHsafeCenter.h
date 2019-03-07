//
//  safeCenter.h
//  TouchIDDemo
//
//  Created by llbt on 2018/7/30.
//  Copyright © 2018年 Lee2Go. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHsafeCenter : NSObject

/**
 是否已经打开指纹认证
 
 @return <#return value description#>
 */
//+(BOOL)isOpenFingerPrint;

/**
 设置指纹认证
 
 @param b <#b description#>
 */
//+(void)openFingerOrNot:(BOOL)b;

/**
 是否支持指纹认证
 
 @return <#return value description#>
 */
+(BOOL)supportFingerOrNot;

/**
 指纹认证
 
 @param successHandle 成功回调
 @param fail 失败回调
 */
+(void)handleFingerSuccess:(void(^)(void))successHandle andFailed:(void(^)(int))fail;

/**
 是否开启了刷脸
 
 @return <#return value description#>
 */
+(BOOL)getFaceOpenOrNot;

/**
 设置刷脸开关
 
 @param isOpen <#isOpen description#>
 */
+(void)OpenOrCloseFace:(BOOL)isOpen;

/**
 设置指纹解锁
 
 @param isOpen <#isOpen description#>
 */
+(void)OpenOrCloseFinger:(BOOL)isOpen;

/**
 获取指纹解锁
 
 @return <#return value description#>
 */
+(BOOL)getFingerOpenOrNot;

//touchid改变
+(BOOL)touchIdInfoDidChange;
/**
 设置当前身份用于绑定touchIdData的操作
 
 @param identity <#identity description#>
 */
+ (void)setCurrentTouchIdDataIdentity:(NSString *)identity;

/**
 获取当前touchIdData绑定的身份
 
 @return <#return value description#>
 */
+ (NSString*)currentTouchIdDataIdentity;


/**
 为当前身份绑定touchIdData，需先调用setCurrentTouchIdDataIdentity绑定身份
 
 @return <#return value description#>
 */
+ (BOOL)setCurrentIdentityTouchIdData;


//是否已经设置系统到chain
+(BOOL)hasSetSystemVersionInChain;
//是否已经改变chain
+(BOOL)hasChangedTheSystemVersionInChain;
//设置最新的系统写入chain
+(void)setTheNewSystemVersionInChain;

/**
 关闭或者打开刷脸交易

 @param isOpen <#isOpen description#>
 */
+(void)openOrCloseFaceDeal:(BOOL)isOpen;

/**
 获取刷脸交易

 @return <#return value description#>
 */
+(BOOL)getFaceDealOpenOrNot;

/**
 系统变化 或者指纹变化

 @return <#return value description#>
 */
+(BOOL)hasSystemChangedOrTouchIdInfoChanged;

/*
 获取保存在钥匙串中的指纹数据
 */
+ (NSData*) getFingerprintData;

@end

