//
//  NXBLocalImageInOutModel.h
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#define ActivityHomepageSaveDataArray @"ActivityHomepageSaveDataArray"
@interface NXBLocalImageInOutModel : NSObject
+ (void)saveNSUserDefaults:(NSArray*)objectArray forKey:(NSString*)Vkey;
+ (NSArray*)readNSUserDefaultsForKey:(NSString*)Vkey;
+ (void)DeleteUserDefaultsDataForKey:(NSString*)Vkey;
#pragma mark- 保存图片文件
+ (NSMutableArray *)saveImageArray:(NSArray*)imageArray;
+ (UIImage*)getImageFileWithName:(NSString*)filePath;
+ (UIImage *)handleImage:(UIImage *)originalImage withSize:(CGSize)size;
@end
