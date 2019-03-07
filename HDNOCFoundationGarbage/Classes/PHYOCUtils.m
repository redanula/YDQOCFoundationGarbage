//
//  VKYOCUtils.m
//  Vankeyi-Swift
//
//  Created by SimonYHB on 2017/4/18.
//  Copyright © 2017年 yhb. All rights reserved.
//

#import "PHYOCUtils.h"

@implementation PHYOCUtils
+(NSStringDrawingOptions)getDrawingOptions
{
    return NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
}

+ (NSString *)moneyCommaFormat:(double)money
{
    if (isnan(money)) return @"";
    
    NSString *moneyStr = [NSString stringWithFormat:@"%.2f", money];
    NSString *unSignStr = @"";
    NSMutableString *formatStr = [NSMutableString string];
    
    // handle the sign + -
    if ([moneyStr characterAtIndex:0] == '+' || [moneyStr characterAtIndex:0] == '-') {
        unSignStr = [NSString stringWithString:[moneyStr substringFromIndex:1]];
        [formatStr appendString:[NSString stringWithFormat:@"%c", [moneyStr characterAtIndex:0]]];
    } else {
        unSignStr = [NSString stringWithString:moneyStr];
    }
    
    // divide the integer and fraction part
    NSArray *componentsArray = [unSignStr componentsSeparatedByString:@"."];
    NSString *intString = componentsArray[0];
    NSString *fraString = componentsArray.count>1 ? componentsArray[1] : @"00";
    
    // handle the integer part
    NSInteger dotSum = intString.length/3 - ((intString.length%3 == 0) ? 1 : 0);
    NSRange firstRange = NSMakeRange(0, intString.length - dotSum*3);
    
    if ([intString substringWithRange:firstRange]) {
        [formatStr appendString:[intString substringWithRange:firstRange]];
    }
    for (NSInteger i = 0; i < dotSum; i++) {
        [formatStr appendString:[NSString stringWithFormat:@",%@",[intString substringWithRange:NSMakeRange(firstRange.length + 3*i, 3)]]];
    }
    
    // append the fraction part
    if(![fraString isEqualToString:@"00"])
    {
        [formatStr appendString:@"."];
        [formatStr appendString:fraString];
    }
    
    return [NSString stringWithString:formatStr];
}

+ (NSString *)moneyWordsFormat:(double)money
{
    if (isnan(money) || money<0 || money>=pow(10, 16)) return @"";
    
    NSArray *numberchar = @[@"零",@"壹",@"贰",@"叁",@"肆",@"伍",@"陆",@"柒",@"捌",@"玖"];
    NSArray *inunitchar = @[@"",@"拾",@"佰",@"仟"];
    NSArray *unitname = @[@"",@"万",@"亿",@"万亿"];
    //金额乘以100转换成字符串（去除圆角分数值）
    NSString *valstr=[NSString stringWithFormat:@"%.2f",money];
    NSString *prefix;
    NSString *suffix;
    if (valstr.length <= 2)
    {
        prefix=@"零元";
        if (valstr.length == 0)
        {
            suffix=@"零角零分";
        }
        else if (valstr.length == 1)
        {
            suffix=[NSString stringWithFormat:@"%@分",[numberchar objectAtIndex:[valstr intValue]]];
        }
        else
        {
            NSString *head = [valstr substringToIndex:1];
            NSString *foot = [valstr substringFromIndex:1];
            suffix=[NSString stringWithFormat:@"%@角%@分",[numberchar objectAtIndex:[head intValue]],[numberchar objectAtIndex:[foot intValue]]];
        }
    }
    else
    {
        prefix=@"";
        suffix=@"";
        int flag = (int)valstr.length - 2;
        NSString *head = [valstr substringToIndex:flag-1];
        NSString *foot = [valstr substringFromIndex:flag];
        if (head.length>13)
        {
            // 数值太大（最大支持13位整数），无法处理
            return @"";
        }
        //处理整数部分
        NSMutableArray * ch = [[NSMutableArray alloc]init];
        for (int i = 0; i < head.length; i++)
        {
            NSString * str=[NSString stringWithFormat:@"%x",[head characterAtIndex:i]-'0'];
            
            [ch addObject:str];
        }
        int zeronum = 0;
        for (int i = 0; i < ch.count; i++)
        {
            int index = (ch.count - i - 1) % 4;//取段内位置
            int indexloc = (int)(ch.count - i - 1) / 4;//取段位置
            if ([[ch objectAtIndex:i] isEqualToString:@"0"])
            {
                zeronum++;
            }
            else
            {
                if (zeronum != 0)
                {
                    if (index != 3)
                    {
                        prefix=[prefix stringByAppendingString:@"零"];
                    }
                    zeronum = 0;
                }
                prefix = [prefix stringByAppendingString:[numberchar objectAtIndex:[[ch objectAtIndex:i]intValue]]];
                prefix = [prefix stringByAppendingString:[inunitchar objectAtIndex:index]];
            }
            if (index == 0 && zeronum < 4)
            {
                prefix=[prefix stringByAppendingString:[unitname objectAtIndex:indexloc]];
            }
        }
        prefix = [prefix stringByAppendingString:@"元"];
        //处理小数位
        if ([foot isEqualToString:@"00"])
        {
            suffix =[suffix stringByAppendingString:@"整"];
        }
        else if ([foot hasPrefix:@"0"])
        {
            NSString * footch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:1]-'0'];
            suffix = [NSString stringWithFormat:@"%@分",[numberchar objectAtIndex:[footch intValue]]];
        }
        else
        {
            NSString * headch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:0]-'0'];
            
            NSString * footch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:1]-'0'];
            
            suffix = [NSString stringWithFormat:@"%@角%@分",[numberchar objectAtIndex:[headch intValue]],[numberchar objectAtIndex:[footch intValue]]];
        }
    }
    return [prefix stringByAppendingString:suffix];
}

//2017-10-10 yuyy begin
/*
 证件类型转换
 1010 大陆身份证
 1999 港澳台身份证
 1050 护照
 1020 军官证
 */
 
+ (NSString *)idCardName2Type:(NSString *)name
{
    if ([name isEqualToString:@"大陆身份证"]) {
        return @"1010";
    }
    // by LXF 2017-11-08 begin 拆分港澳台身份证
    else if ([name isEqualToString:@"香港身份证"] || [name isEqualToString:@"澳门身份证"] || [name isEqualToString:@"台湾身份证"]) {
        // by LXF 2017-11-08 end
        
        // [name isEqualToString:@"港澳台身份证"]
        
        return @"1999";
    }
    else if ([name isEqualToString:@"护照"]) {
        return @"1050";
    }
    else if ([name isEqualToString:@"军官证"]) {
        return @"1020";
    }
    else {
        return @"";
    }
    
}
//2017-10-10 yuyy end





/*
 *  by LXF 2017-10-21
 *  判断设备类型
 */
+ (IPhone_Type)isIPhoneType {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    if (screenHeight < 568.0) {
        return IS_IPhone4_4S;
    }else if (screenHeight == 568.0) {
        return IS_IPhone5_5C_5S_SE;
    }else if (screenHeight == 667.0) {
        return IS_IPhone6_7_8;
    }else if (screenHeight == 736.0 || screenWidth == 736.0) {
        return IS_IPhone6_7_8_Plus;
    }else {
        return Unknown;
    }
}

/// 手机号码加*显示  12344556667 -> 123****6667
+(NSString *)phoneNumEncodeFormat:(NSString*)teleStr{
    
    if(teleStr.length < 8){
        return teleStr;
    }
    
    NSString *preStr = [teleStr substringWithRange:NSMakeRange(0,4)];
    NSString *sufStr = [teleStr substringWithRange:NSMakeRange(teleStr.length - 4,4)];
    NSInteger starCount = 3;
    for (NSInteger i = 0; i < starCount; i ++) {
        preStr = [preStr stringByAppendingString:@"*"];
    }
    preStr = [preStr stringByAppendingString:sufStr];
    return preStr;
}
/*
 *  by LXF 2017-11-20
 *  获取当月 第一天和最后一天
 */
+ (NSArray *)getMonthFirstAndLastDayWith:(NSString *)dateString {
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *newDate=[format dateFromString:dateString];
    double interval = 0;
    NSDate *firstDate = nil;
    NSDate *lastDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    BOOL OK = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDate interval:&interval forDate:newDate];
    
    if (OK) {
        lastDate = [firstDate dateByAddingTimeInterval:interval - 1];
    }else {
        return @[@"",@""];
    }
    
    NSString *firstString = [format stringFromDate: firstDate];
    NSString *lastString = [format stringFromDate: lastDate];
    return @[firstString, lastString];
}

+(NSString *)idCardNumEncodeFormat:(NSString*)cardNum
{
    if(cardNum.length == 0){
        return @"";
    }
    
    NSInteger preAndSufCount = 4;
    if(cardNum.length < 9){
        preAndSufCount = 2;
    }
    
    NSString *preStr = [cardNum substringWithRange:NSMakeRange(0,preAndSufCount)];
    NSString *sufStr = [cardNum substringWithRange:NSMakeRange(cardNum.length - preAndSufCount,preAndSufCount)];
    NSInteger starCount = 3;//cardNum.length - (preStr.length + sufStr.length);
    for (NSInteger i = 0; i < starCount; i ++) {
        preStr = [preStr stringByAppendingString:@"*"];
    }
    preStr = [preStr stringByAppendingString:sufStr];
    return preStr;
}


+(NSAttributedString *)attributeStringWithContent:(NSString *)content keyWordAttriDicts:(NSArray *)keyWords
{
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
    if (keyWords) {
        [keyWords enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
            NSMutableString *tmpString=[NSMutableString stringWithString:content];
            NSRange range=[content rangeOfString:obj[@"word"]];
            NSInteger location=0;
            while (range.length>0) {
                [attString addAttribute:(NSString*)NSForegroundColorAttributeName value:obj[@"color"] ? obj[@"color"] : [UIColor redColor] range:NSMakeRange(location+range.location, range.length)];
                location+=(range.location+range.length);
                NSString *tmp= [tmpString substringWithRange:NSMakeRange(range.location+range.length, content.length-location)];
                tmpString=[NSMutableString stringWithString:tmp];
                range=[tmp rangeOfString:obj[@"word"]];
            }
        }];
    }
    return attString;
    
}

+ (NSDate *)getPacketBuildTime{
    NSString *buildDate = [NSString stringWithFormat:@"%s %s",__DATE__, __TIME__];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM d yyyy HH:mm:ss"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setLocale:usLocale];
    NSDate *date = [df dateFromString:buildDate];
    return date;
}

+ (NSString *)getParamStrFromParams:(NSDictionary *)params{
    NSMutableString *str = [NSMutableString string];
    for (NSString *key in params.allKeys) {
        [str appendFormat:@"%@", [NSString stringWithFormat:@"%@=%@",key,params[key]]];
        if(params.allKeys.lastObject == key){
            continue;
        }
        [str appendString:@"&"];
    }
    return str;
}

+ (NSString *)urlEncodedString:(NSString *)str
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}


+ (NSString *)urlDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

@end
