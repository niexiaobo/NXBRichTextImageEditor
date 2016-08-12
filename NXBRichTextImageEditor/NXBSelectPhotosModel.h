//
//  NXBSelectPhotosModel.h
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@protocol SelectPhotosDelegate <NSObject>
//- (void)getSelectImage:(UIImage*)image;
@end
@interface NXBSelectPhotosModel : NSObject
@property(nonatomic, weak) id<SelectPhotosDelegate> delegate;

#pragma mark - 上传头像 代理方法
- (void)callActionSheetWithCtrl:(UIViewController*)Ctrl;
@end
