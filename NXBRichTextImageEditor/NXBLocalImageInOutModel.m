//
//  NXBLocalImageInOutModel.m
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "NXBLocalImageInOutModel.h"

@implementation NXBLocalImageInOutModel
#pragma mark - 保存数据到NSUserDefaults
+ (void)saveNSUserDefaults:(NSArray*)objectArray forKey:(NSString*)Vkey {
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([self readNSUserDefaultsForKey:Vkey]) {
        [userDefaults removeObjectForKey:Vkey];
        [userDefaults synchronize];
    }
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    [userDefaults setObject:objectArray forKey:Vkey];
    //这里建议同步存储到磁盘中
    [userDefaults synchronize];
    
}

#pragma mark-从NSUserDefaults中读取数据
+ (NSArray*)readNSUserDefaultsForKey:(NSString*)Vkey {
    
    if (!Vkey) {
        NSArray*SaveDataArray=@[];
        return SaveDataArray;
    }
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSArray*userDefaultArray = [userDefaultes objectForKey:Vkey];
    return userDefaultArray;
}

#pragma mark- 删除 临时编辑数据
+ (void)DeleteUserDefaultsDataForKey:(NSString*)Vkey {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:Vkey];
    [userDefaults synchronize];
    
}

#pragma mark- 保存图片文件
+ (NSMutableArray *)saveImageArray:(NSArray*)imageArray {
    NSMutableArray *filePathArray = [[NSMutableArray alloc]init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    
    for (int I=0; I<imageArray.count; I++) {
        NSString* date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYYMMddhhmmss"];
        date = [formatter stringFromDate:[NSDate date]];
        
        NSString*imagesName = [NSString stringWithFormat:@"ActivityImages%@%d.jpg",date,I];
        NSString *toPath = [cachesDir stringByAppendingString:[NSString stringWithFormat:@"/%@",imagesName]];
        UIImage *currentImage = imageArray[I];
        
        NSLog(@"====%@===",toPath);
        NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
        [imageData writeToFile:toPath atomically:NO];
        [filePathArray addObject:toPath];
        
    }
    return filePathArray;
}

#pragma mark- 获取image图片文件
+ (NSMutableArray *)getImageArray:(NSArray*)imageUrlArray {
    NSMutableArray *imageArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<imageUrlArray.count; i++) {
        UIImage *imagedata = [self getImageFileWithName:imageUrlArray[i]];
        if (imagedata) {
            [imageArray addObject:imagedata];
        }
    }
    return imageArray;
}

#pragma mark- 本地地址 转image
+ (UIImage*)getImageFileWithName:(NSString*)filePath {
    NSError* err = [[NSError alloc] init];
    NSData* data = [[NSData alloc] initWithContentsOfFile:filePath
                    
                                                  options:NSDataReadingMapped
                    
                                                    error:&err];
    
    UIImage* img = nil;
    if(data != nil) {
        img = [[UIImage alloc] initWithData:data];
    } else {
        img = [UIImage imageNamed:@"zhanwei1"];
        NSLog(@"图片为空！");
    }
    return img;
}



+ (UIImage *)handleImage:(UIImage *)originalImage withSize:(CGSize)size {
    if (!originalImage) {
        return originalImage;
    }
    CGSize originalsize = [originalImage size];
    NSLog(@"改变前图片的宽度为%f,图片的高度为%f",originalsize.width,originalsize.height);
    if (originalsize.width < 0.0001 || originalsize.height< 0.0001 || size.width < 0.0001 || size.height < 0.0001 ) {
        
        return originalImage;
    }
    
    float origWH = originalsize.width / originalsize.height;
    float sizeWH = size.width / size.height;
    
    //原图宽高比 大于 标准宽高比
    if(origWH > sizeWH) {
        CGFloat rate = 1.0;
        CGFloat widthRate = originalsize.width/size.width;
        CGFloat heightRate = originalsize.height/size.height;
        
        rate = widthRate>heightRate?heightRate:widthRate;
        
        CGSize tempSize;
        tempSize.height = originalsize.height;
        tempSize.width = sizeWH * originalsize.height;
        size = tempSize;
        
        CGImageRef imageRef = nil;
        
        if (heightRate>widthRate) {
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(0, originalsize.height/2-size.height*rate/2, originalsize.width, size.height*rate));//获取图片整体部分
        } else {
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(originalsize.width/2-size.width*rate/2, 0, size.width*rate, originalsize.height));//获取图片整体部分
        }
        UIGraphicsBeginImageContext(size);//指定要绘画图片的大小
        CGContextRef con = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(con, 0.0, size.height);
        CGContextScaleCTM(con, 1.0, -1.0);
        
        CGContextDrawImage(con, CGRectMake(0, 0, size.width, size.height), imageRef);
        
        UIImage *standardImage = UIGraphicsGetImageFromCurrentImageContext();
        NSLog(@"改变后图片的宽度为%f,图片的高度为%f",[standardImage size].width,[standardImage size].height);
        
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        
        return standardImage;
        
    } else if(origWH < sizeWH) {
        CGImageRef imageRef = nil;
        
        CGSize tempSize;
        tempSize.height = originalsize.width * (size.height / size.width);
        tempSize.width = originalsize.width;
        size = tempSize;
        
        
        if(originalsize.height>size.height)
        {
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(0, originalsize.height/2-size.height/2, originalsize.width, size.height));//获取图片整体部分
        }
        else if (originalsize.width>size.width)
        {
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(originalsize.width/2-size.width/2, 0, size.width, originalsize.height));//获取图片整体部分
        }
        
        UIGraphicsBeginImageContext(size);//指定要绘画图片的大小
        CGContextRef con = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(con, 0.0, size.height);
        CGContextScaleCTM(con, 1.0, -1.0);
        
        CGContextDrawImage(con, CGRectMake(0, 0, size.width, size.height), imageRef);
        
        UIImage *standardImage = UIGraphicsGetImageFromCurrentImageContext();
        NSLog(@"改变后图片的宽度为%f,图片的高度为%f",[standardImage size].width,[standardImage size].height);
        
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        
        return standardImage;
    } else {//原图为标准长宽的，不做处理
        return originalImage;
    }
}

@end
