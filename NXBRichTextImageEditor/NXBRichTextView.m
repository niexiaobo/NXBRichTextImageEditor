//
//  NXBRichTextView.m
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "NXBRichTextView.h"

#define RichTextScreenheight  [[UIScreen mainScreen] bounds].size.height
#define RichTextScreenwidth  [[UIScreen mainScreen] bounds].size.width

@interface NXBRichTextView ()
@property (nonatomic, strong) UIView *toolView;
@end

@implementation NXBRichTextView
- (void)drawRect:(CGRect)rect delegate:(id)delegate FontOfSize:(CGFloat)fontSize placehoder:(NSString*)placehoder {
    if (self) {
        self.frame = rect;
        self.placehoder = placehoder;
        self.delegate = delegate;
        self.textDelegate = delegate;
        self.font = [UIFont systemFontOfSize:fontSize];
        [self setupToolView];
    }
}

#pragma mark - 键盘 tabbar
- (void)setupToolView {
    _toolView  = [[UIView alloc]init];
    _toolView.backgroundColor = [UIColor whiteColor];
    _toolView.frame = CGRectMake(0, 0, RichTextScreenwidth, 50);
    self.inputAccessoryView  = _toolView;
    
    UIButton *losebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    losebtn.frame = CGRectMake(20, 0, 50, 50);
    [losebtn addTarget:self action:@selector(doneBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [losebtn setTitleColor:[UIColor colorWithRed:(float)201/255.0 green:(float)52/255.0 blue:(float)21/255.0 alpha:1] forState:UIControlStateNormal];
    [losebtn setTitle:@"完成" forState:UIControlStateNormal];
    [_toolView addSubview:losebtn];
    
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageBtn setImage:[self imagesNamedFromCustomBundle:@"c-Camera"] forState:UIControlStateNormal];
    imageBtn.frame = CGRectMake(RichTextScreenwidth-58, 0, 58 , 44);
    [imageBtn setTitleColor:[UIColor colorWithRed:(float)201/255.0 green:(float)52/255.0 blue:(float)21/255.0 alpha:1] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(imageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:imageBtn];
}

#pragma mark - 完成
- (void)doneBtnClick {
    [self endEditing:YES];
}

#pragma mark - 选择图片
- (void)imageBtnClick {
    [self endEditing:YES];
    if ([self.textDelegate respondsToSelector:@selector(selectImageBtnClick)]) {
        [self.textDelegate selectImageBtnClick];
    }
}

- (UIImage *)imagesNamedFromCustomBundle:(NSString *)imgName {
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"RichImages.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *img_path = [bundle pathForResource:imgName ofType:@"png"];
    return [UIImage imageWithContentsOfFile:img_path];
    
}
@end
