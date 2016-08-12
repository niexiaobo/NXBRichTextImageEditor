//
//  NXBRichTextView.h
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlacehoderTextView.h"

@protocol NXBTextViewDelegate <NSObject>
- (void)selectImageBtnClick;
@end

@interface NXBRichTextView : PlacehoderTextView
@property(nonatomic, weak) id<NXBTextViewDelegate> textDelegate;

- (void)drawRect:(CGRect)rect delegate:(id)delegate FontOfSize:(CGFloat)fontSize placehoder:(NSString*)placehoder;
@end
