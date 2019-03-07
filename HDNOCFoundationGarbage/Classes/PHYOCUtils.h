//
//  VKYOCUtils.h
//  Vankeyi-Swift
//
//  Created by SimonYHB on 2017/4/18.
//  Copyright © 2017年 yhb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    IS_IPhone4_4S,
    IS_IPhone5_5C_5S_SE,
    IS_IPhone6_7_8,
    IS_IPhone6_7_8_Plus,
    Unknown
} IPhone_Type;

@interface PHYOCUtils : NSObject
+ (NSStringDrawingOptions)getDrawingOptions;

/*
 * 金额格式转换
 * add by czw at 20171012
 */
// 金额3位逗号格式化  1000 -> 1,000；1000.01 -> 1,000.01
+ (NSString *)moneyCommaFormat:(double)money;
// 金额转大写 180000 ->壹拾捌万元整；180,000.10 ->壹拾捌万元壹角零分
+ (NSString *)moneyWordsFormat:(double)money;
//证件类型转换，从中文名称转成编码
+ (NSString *)idCardName2Type:(NSString *)name;

/*
 *  by czw 2017-11-2
 *  手机号码加*显示  12344556667 -> 1234***6667
 */
+(NSString *)phoneNumEncodeFormat:(NSString*)teleStr;

/*
 *  by czw 2017-11-2
 *  身份证加*显示  12344556667 -> 123****6667
 */
+(NSString *)idCardNumEncodeFormat:(NSString*)cardNum;

/*
 *  by LXF 2017-10-21
 *  判断设备类型
 */
+ (IPhone_Type)isIPhoneType;

/*
 *  by LXF 2017-11-20
 *  获取当月 第一天和最后一天
 *  @paramter   dateString    @"2017-11-11"
 *  @return     NSArray     2017-11-01,2017-11-30
 */
+ (NSArray *)getMonthFirstAndLastDayWith:(NSString *)dateString;

/*
 // 关键字特定颜色
 {
 "word":"关键词"
 "color":字体颜色
 }
 */
+(NSAttributedString *)attributeStringWithContent:(NSString *)content keyWordAttriDicts:(NSArray *)keyWords;

+ (NSDate *)getPacketBuildTime;

+ (NSString *)getParamStrFromParams:(NSDictionary *)params;
+ (NSString *)urlEncodedString:(NSString *)str;
+ (NSString *)urlDecodedString:(NSString *)str;
@end
