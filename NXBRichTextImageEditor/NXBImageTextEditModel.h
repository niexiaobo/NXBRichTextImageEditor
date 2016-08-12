//
//  NXBImageTextEditModel.h
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define ImageTextEditScreen_height  [[UIScreen mainScreen] bounds].size.height
#define ImageTextEditScreen_width  [[UIScreen mainScreen] bounds].size.width

@interface NXBImageTextEditModel : NSObject
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, assign) NSString *type; //text  &&  image


+ (NXBImageTextEditModel *)addObjectWithType:(NSString*)type detailString:(NSString*)detailString image:(UIImage*)image;
#pragma mark - 删除多余重复空文本
+ (NSMutableArray*)updateImageTextEditModelWithArray:(NSMutableArray*)dataArray;
#pragma mark - 删除多余空文本
+ (NSMutableArray*)deleteImageTextEditModelNullWithArray:(NSMutableArray*)dataArray;
#pragma mark - 格式化请求数据
+ (NSArray *)formatToSendArray:(NSMutableArray*)dataArray;
#pragma mark - 格式化富文本 to 请求数据
+ (NSArray *)formatAttributedStringToSendArray:(NSAttributedString*)attributedString;
#pragma mark - 格式化 请求数据 to 富文本
+ (NSAttributedString *)formatModelDataToAttributedString:(NSArray *)dataArray;
#pragma mark - 计算新的图片大小 适配屏幕宽度
//这里不涉及对图片实际数据的压缩，所以不用异步处理~
+ (CGRect)scaleImage:(UIImage*)image   SizeToWidth:(CGFloat)width;
#pragma mark - 富文本 添加图片
+ (NSAttributedString *)attributedString:(NSAttributedString *)attributedString addImage:(UIImage *)image;
#pragma mark - 富文本 段落样式
+ (void)setupParagraphStyle:(NSAttributedString *)attributedString;
#pragma mark- 过滤所有表情
+ (BOOL)stringContainsEmoji:(NSString *)string;
@end
