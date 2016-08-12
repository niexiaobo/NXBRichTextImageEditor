//
//  RichTextImageEditorBaseViewCtrl.m
//  NXBRichTextImageEditor
//
//  Created by beyondsoft-聂小波 on 16/8/12.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "RichTextImageEditorBaseViewCtrl.h"
#import "UIImage+NXMScaleSize.h"
#import "UIView+XBXYWH.h"
#import "NXBImageTextEditModel.h"
#import "NXBRichTextView.h"
#import "NXBSelectPhotosModel.h"
#import "NXBLocalImageInOutModel.h"

@interface RichTextImageEditorBaseViewCtrl ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SelectPhotosDelegate,NXBTextViewDelegate,UIActionSheetDelegate>
{
    UILabel *placeholder;
    NSInteger keyBoardHeight;
    NSMutableString *text;
    float image_h;
}
@property(nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NXBRichTextView *textView;
@property (nonatomic, strong) NXBSelectPhotosModel *selectPhotosModel;

@end
@implementation RichTextImageEditorBaseViewCtrl
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self creatUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark - 数据懒加载
- (NXBSelectPhotosModel *)selectPhotosModel {
    if (!_selectPhotosModel) {
        _selectPhotosModel = [[NXBSelectPhotosModel alloc] init];
        _selectPhotosModel.delegate = self;
    }
    return _selectPhotosModel;
}

- (NXBRichTextView*)textView {
    if (!_textView) {
        //编辑框
        _textView = [[NXBRichTextView alloc]init];
        [_textView drawRect:CGRectMake(0, 64, ImageTextEditScreen_width, ImageTextEditScreen_height-64) delegate:self FontOfSize:16.0 placehoder:@"点击编辑"];
        
        //初始化本地数据
        if (self.dataArray.count > 0) {
            if (_textView.text.length == 0) {//没有内容时插入图片，赋值空格删除placehoder
                _textView.text =@" ";
            }
            [_textView.textStorage insertAttributedString:[NXBImageTextEditModel formatModelDataToAttributedString:self.dataArray] atIndex:0];
            
            [self resetTextStyle];//设置样式
            [self setupParagraphStyle];//设置段落样式
        }
    }
    return _textView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        
        _dataArray = [[NSMutableArray alloc]init];
        
        if (self.infoArray && self.infoArray.count == 2 && [self.infoArray[0] count] >0) {
            
//            _dataArray = [[NXBImageTextEditModel mj_objectArrayWithKeyValuesArray:self.infoArray[0]] mutableCopy];
            NSMutableArray *imageArray = [self.infoArray[1] mutableCopy];//图片数组
            for (int i=0; i<_dataArray.count; i++) {
                NXBImageTextEditModel *EditModel = _dataArray[i];
                if ([EditModel.type isEqualToString:@"image"]) {
                    if (imageArray.count > 0) {
                        EditModel.image = [imageArray firstObject];
                        [imageArray removeObjectAtIndex:0];
                    }
                }
            }
        }
    }
    return _dataArray;
}

#pragma mark 创建界面
- (void)creatUI {
    [self.view addSubview:self.textView];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyBoardHeight = keyboardRect.size.height;
    //    NSLog(@"%ld",(long)keyBoardHeight);
    [UIView animateWithDuration:0.1 animations:^{
        _textView.height = ImageTextEditScreen_height - keyBoardHeight - 64 ;
        
    }];
}

#pragma mark 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    [UIView animateWithDuration:0.1 animations:^{
        _textView.height = ImageTextEditScreen_height - 64;
        
    }];
}

#pragma mark NXBTextViewDelegate 相册
- (void)selectImageBtnClick {
    [self.selectPhotosModel callActionSheetWithCtrl:self];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *uiImage =  [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (_textView.text.length == 0) {//没有内容时插入图片，赋值空格删除placehoder
        _textView.text =@" ";
    }
    //插入图片
    NSAttributedString *imageAttributString = [[NSAttributedString alloc]init] ;
    [_textView.textStorage insertAttributedString:[NXBImageTextEditModel attributedString:imageAttributString addImage:uiImage] atIndex:_textView.selectedRange.location];
    //设置光标位置
    _textView.selectedRange = NSMakeRange(_textView.selectedRange.location + 1, _textView.selectedRange.length);
    //设置样式
    [self resetTextStyle];
    [self dismissViewControllerAnimated:YES completion:nil];
    //每次添加完图片后  返回编辑状态
    [_textView becomeFirstResponder];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    //设置样式
    [self resetTextStyle];
    [self textViewContainsEmoji];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self textViewContainsEmoji];
}

#pragma mark 不能输入表情符号
- (void)textViewContainsEmoji {
    if ([NXBImageTextEditModel stringContainsEmoji:self.textView.text]) {
        NSLog(@"不能输入表情符号！");
        
        return;
    }
}

#pragma mark 字体样式
- (void)resetTextStyle {
    [self resetTextStyleFone];
    [self setupParagraphStyle];
}

#pragma mark 改变字体大小
- (void)resetTextStyleFone {
    //After changing text selection, should reset style.
    NSRange wholeRange = NSMakeRange(0, self.textView.textStorage.length);
    [self.textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [self.textView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0f] range:wholeRange];
    
}

#pragma mark - 段落样式
- (void)setupParagraphStyle {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paragraphStyle.lineSpacing = 4.0;
    //段落间距
    paragraphStyle.paragraphSpacing = 4.0;
    [_textView.textStorage addAttribute:NSParagraphStyleAttributeName
                                  value:paragraphStyle
                                  range:NSMakeRange(0, _textView.textStorage.length)];
    
    
}

#pragma mark -  导航右上角按钮事件
- (void)rightBtnClick {
    [self.view endEditing:YES];
    
    if (self.textView.textStorage.length == 0) {
        NSLog(@"请编辑详情！");
        
        return ;
    } else if ([NXBImageTextEditModel stringContainsEmoji:self.textView.text]) {
        NSLog(@"不能输入表情符号！");
        return;
        
    }
    
    [NXBLocalImageInOutModel saveNSUserDefaults:[NXBImageTextEditModel formatAttributedStringToSendArray:self.textView.textStorage] forKey:ActivityHomepageSaveDataArray];
    
}

#pragma mark - 关闭键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - 返回方法 （继承命名不方便改）
- (void)back_btn_click {
    [self.view endEditing:YES];
    
    [self callActionSheetView];
}

#pragma mark - 弹框
- (void)callActionSheetView {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存草稿",@"放弃编辑", nil];
    [actionSheet showInView:self.view];
}
#pragma mark - 弹框点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {//保存草稿
        [self rightBtnClick];
    } else if (buttonIndex == 1) {//放弃编辑
        [self .navigationController popViewControllerAnimated:YES];
    } else {
        return;
    }
    
}
@end
