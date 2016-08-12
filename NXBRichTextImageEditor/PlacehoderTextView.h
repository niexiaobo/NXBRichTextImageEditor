//
//  PlacehoderTextView.h
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacehoderTextView : UITextView
@property (nonatomic, copy) NSString *placehoder;
@property (nonatomic, strong) UIColor *placehoderColor;
@property (nonatomic, strong) UILabel *placehoderLabel;
@end
