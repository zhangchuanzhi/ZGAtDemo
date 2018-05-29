//
//  ZGSelectUserController.h
//  ZGAtDemo
//
//  Created by offcn_zcz32036 on 2018/5/28.
//  Copyright © 2018年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZGSelectUserController : UIViewController
@property(nonatomic,copy)void(^SelectUserBlock) (NSString*name);
@end
