//
//  PHURLSessionProtocol.h
//  ccbpuhui
//
//  Created by llbt on 2019/1/28.
//  Copyright © 2019年 yhb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PHURLSessionProtocol : NSURLProtocol

@property (nonatomic, copy) void(^ubtBlock)(NSString*);

@end


