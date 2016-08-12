//
//  NXBImageTextEditModel.m
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "NXBImageTextEditModel.h"

@implementation NXBImageTextEditModel
#pragma mark - 创建ImageTextEditModel
+ (NXBImageTextEditModel *)addObjectWithType:(NSString*)type detailString:(NSString*)detailString image:(UIImage*)image {
    NXBImageTextEditModel *ImageTextEditModel = [[NXBImageTextEditModel alloc]init];
    if ([type isEqualToString:@"text"]) {
        ImageTextEditModel.content = detailString;
        ImageTextEditModel.type = @"text";
    } else {
        ImageTextEditModel.image = image;
        ImageTextEditModel.type = @"image";
        ImageTextEditModel.content = @"";
    }
    return ImageTextEditModel;
}

#pragma mark - 删除多余重复空文本
+ (NSMutableArray*)updateImageTextEditModelWithArray:(NSMutableArray*)dataArray {
    BOOL delete = NO;
    for (int i=0; i<dataArray.count; i++) {
        NXBImageTextEditModel *ImageTextEditModel = dataArray[i];
        if ([ImageTextEditModel.type isEqualToString:@"text"]) {
            if ([ImageTextEditModel.content isEqualToString:@""]) {
                if (delete) {
                    [dataArray removeObjectAtIndex:i];
                }
            }
            delete = YES;
        } else {
            delete = NO;
        }
    }
    delete = NO;
    for (int i = (int)dataArray.count-1; i>=0; i--) {
        NXBImageTextEditModel *ImageTextEditModel = dataArray[i];
        if ([ImageTextEditModel.type isEqualToString:@"text"]) {
            if ([ImageTextEditModel.content isEqualToString:@""]) {
                if (delete) {
                    [dataArray removeObjectAtIndex:i];
                }
            }
            delete = YES;
        } else {
            delete = NO;
        }
    }
    
    return dataArray;
}

#pragma mark - 删除多余空文本
+ (NSMutableArray*)deleteImageTextEditModelNullWithArray:(NSMutableArray*)dataArray {
    for (int i=0; i<dataArray.count; i++) {
        NXBImageTextEditModel *ImageTextEditModel = dataArray[i];
        if ([ImageTextEditModel.type isEqualToString:@"text"] && [ImageTextEditModel.content isEqualToString:@""]) {
            [dataArray removeObjectAtIndex:i];
        }
    }
    return dataArray;
}

#pragma mark - 格式化请求数据
+ (NSArray *)formatToSendArray:(NSMutableArray*)dataArray {
    NSMutableArray *sendArray = [[NSMutableArray alloc]init];
    NSMutableArray *sendImageArray = [[NSMutableArray alloc]init];
    for (int i=0; i<dataArray.count; i++) {
        NXBImageTextEditModel *ImageTextEditModel = dataArray[i];
        
        NSMutableDictionary *sendDic = [[NSMutableDictionary alloc]init];
        [sendDic setObject:ImageTextEditModel.type forKey:@"type"];
        [sendDic setObject:ImageTextEditModel.content forKey:@"content"];
        [sendArray addObject:sendDic];
        
        if ([ImageTextEditModel.type isEqualToString:@"image"]) {
            [sendImageArray addObject:ImageTextEditModel.image];
        }
    }
    NSArray *sendMutArray = @[sendArray,sendImageArray];
    return sendMutArray;
}

#pragma mark - 格式化富文本 to 请求数据
+ (NSArray *)formatAttributedStringToSendArray:(NSAttributedString*)attributedString {
    NSMutableArray *sendArray = [[NSMutableArray alloc]init];
    NSMutableArray *sendImageArray = [[NSMutableArray alloc]init];
    NSMutableArray *rangeArray = [[NSMutableArray alloc]init];
    
    NSRange range = NSMakeRange(0, attributedString.length);
    [attributedString enumerateAttributesInRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSDictionary *dic = attrs;
        
        NSTextAttachment *attachmentImage = [dic objectForKey:@"NSAttachment"];
        
        if (attachmentImage && attachmentImage.image) {
            //富文本里图片数据
            UIImage *image = attachmentImage.image;
            [sendImageArray addObject:image];
            
            [rangeArray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)range.location]];
            NSLog(@"=====range.length======%lu===========",(unsigned long)range.length);
        }
    }];
    //文字
    NSAttributedString *AttributextText = [attributedString attributedSubstringFromRange:range];
    NSString *attribuString = [AttributextText string];
    NSLog(@"--attribuString-->%@<----",attribuString);
    
    NSInteger beginLocation = 0;
    for (int i = 0; i < rangeArray.count; i ++) {
        NSInteger rangLength = [rangeArray[i] integerValue]-beginLocation;
        NSString *testT = [attribuString substringWithRange:NSMakeRange(beginLocation, rangLength)];
        NSLog(@"---->%@<----text---->%@<----",rangeArray[i],testT);
        [sendArray addObject:[self sendDicWithType:@"text" detailString:testT]];
        
        [sendArray addObject:[self sendDicWithType:@"image" detailString:@""]];
        
        beginLocation = [rangeArray[i] integerValue];
    }
    if (beginLocation < attribuString.length) {
        beginLocation =  beginLocation == 0 ? 0 : beginLocation-1;
        NSString *testT2 = [attribuString substringWithRange:NSMakeRange(beginLocation, attribuString.length-beginLocation)];
        [sendArray addObject:[self sendDicWithType:@"text" detailString:testT2]];
        NSLog(@"----->%ld<-------text---->%@<----",(long)beginLocation,testT2);
    }
    return @[sendArray,sendImageArray];
}

#pragma mark - 添加数据方法
+ (NSMutableDictionary *)sendDicWithType:(NSString*)type detailString:(NSString*)detailString {
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc]init];
    [sendDic setObject:type forKey:@"type"];
    [sendDic setObject:detailString forKey:@"content"];
    return sendDic;
}

#pragma mark - 格式化 请求数据 to 富文本
+ (NSAttributedString *)formatModelDataToAttributedString:(NSArray *)dataArray {
    
    NSAttributedString *attributedString = [[NSAttributedString alloc]init];
    for (int i=0; i<dataArray.count; i++) {
        NXBImageTextEditModel *ImageTextEditModel = dataArray[i];
        
        if ([ImageTextEditModel.type isEqualToString:@"text"]) {
            attributedString = [self attributedString:attributedString addText:ImageTextEditModel.content];
        } else {
            attributedString = [self attributedString:attributedString addImage:ImageTextEditModel.image];
        }
    }
    return attributedString;
}

#pragma mark - 富文本 段落样式
+ (void)setupParagraphStyle:(NSAttributedString *)attributedString {
    NSMutableAttributedString *MutattributedString = [attributedString mutableCopy];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paragraphStyle.lineSpacing = 4.0;
    //段落间距
    paragraphStyle.paragraphSpacing = 4.0;
    [MutattributedString addAttribute:NSParagraphStyleAttributeName
                                value:paragraphStyle
                                range:NSMakeRange(0, attributedString.length)];
    
    attributedString = MutattributedString;
}

#pragma mark - 富文本 添加文本
+ (NSAttributedString *)attributedString:(NSAttributedString *)attributedString addText:(NSString *)text {
    NSMutableAttributedString *MutattributedString = [attributedString mutableCopy];
    NSMutableAttributedString *attribuText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    [MutattributedString appendAttributedString:attribuText];
    return MutattributedString;
}

#pragma mark - 富文本 添加图片
+ (NSAttributedString *)attributedString:(NSAttributedString *)attributedString addImage:(UIImage *)image {
    NSMutableAttributedString *MutattributedString = [attributedString mutableCopy];
    NSTextAttachment *imgTextAtta = [[NSTextAttachment alloc]init];
    imgTextAtta.image = image;
    imgTextAtta.bounds = [self scaleImage:image SizeToWidth:ImageTextEditScreen_width];//适配屏幕宽度
    //图片转AttributedString
    NSAttributedString *imageAttribut = [NSAttributedString attributedStringWithAttachment:imgTextAtta];
    NSMutableAttributedString *addLineAttri = [[NSMutableAttributedString alloc] initWithString:@""];
    //    NSMutableAttributedString *addLineAttriTwo = [[NSMutableAttributedString alloc] initWithString:@"\n"];//换行
    
    [addLineAttri appendAttributedString:imageAttribut];
    //    [addLineAttri appendAttributedString:addLineAttriTwo];
    //插入图片
    [MutattributedString appendAttributedString:addLineAttri];
    return MutattributedString;
}

#pragma mark - 计算新的图片大小 适配屏幕宽度
//这里不涉及对图片实际数据的压缩，所以不用异步处理~
+ (CGRect)scaleImage:(UIImage*)image   SizeToWidth:(CGFloat)width {
    //缩放系数
    CGFloat factor = 1.0;
    //获取原本图片大小
    CGSize oriSize = [image size];
    
    //计算缩放系数
    if (oriSize.width > ImageTextEditScreen_width) {
        factor = (CGFloat) (width / oriSize.width);
    }
    //创建新的Size
    CGRect newSize = CGRectMake(0, 0, oriSize.width * factor , oriSize.height * factor);
    return newSize;
}


#pragma mark - 写数据
+ (BOOL)wirte2File:(NSString *)fileName data:(NSData *)data {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,  NSUserDomainMask,YES);
    NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
    NSString *FileName=[ourDocumentPath stringByAppendingPathComponent:fileName];
    return [data writeToFile:FileName atomically:YES];
};

#pragma mark - 读数据
+ (id)readFile:(NSString *)fileName {
    NSData *data = [NSData dataWithContentsOfFile:fileName options:0 error:NULL];
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    return object;
}

#pragma mark- 过滤所有表情
+ (BOOL)stringContainsEmoji:(NSString *)string {
    // 过滤所有表情。returnValue为NO表示不含有表情，YES表示含有表情
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}

@end
