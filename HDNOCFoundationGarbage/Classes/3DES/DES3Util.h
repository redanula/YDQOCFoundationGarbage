//
//  DES3Util.h
//  LHHome
//
//  Created by cityre on 2017/11/7.
//  Copyright © 2017年 Bank. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DES3Util : NSObject {
}
// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;
// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;
@end


