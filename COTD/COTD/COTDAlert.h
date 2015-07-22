//
//  COTDAlert.h
//  COTD
//
//  Created by Javier Fuchs on 7/22/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COTDAlert : UIAlertView <UIAlertViewDelegate, UITextFieldDelegate>

+ (void)alertWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message leftTitle:(NSString*)leftTitle leftBlock:(void (^)())leftBlock rightTitle:(NSString*)rightTitle rightBlock:(void (^)())rightBlock;

+ (void)alertWithFrame:(CGRect)frame prompt:(NSString *)prompt placeholder:(NSString *)placeholder textBlock:(void (^)(NSString* text))textBlock leftTitle:(NSString*)leftTitle leftBlock:(void (^)())leftBlock rightTitle:(NSString*)rightTitle rightBlock:(void (^)())rightBlock;

+ (void)alertWithFrame:(CGRect)frame prompt:(NSString *)prompt placeholder:(NSString *)placeholder value:(NSString *)value textBlock:(void (^)(NSString* text))textBlock leftTitle:(NSString*)leftTitle leftBlock:(void (^)())leftBlock rightTitle:(NSString*)rightTitle rightBlock:(void (^)())rightBlock;



@end
