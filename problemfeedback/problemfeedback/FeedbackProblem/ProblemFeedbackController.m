//
//  ProblemFeedbackController.m
//  testPickerView
//
//  Created by hqs on 16/3/1.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "ProblemFeedbackController.h"
#import "SGImagePickerController.h"
#import "UIViewController+Image.h"
#define kRadius 4
#define kPadding 5

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation ProblemFeedbackController{
    UITextView *tvInfo;
    UIScrollView *svImg;
    CGFloat imgH;
    NSMutableArray *imgs;
    CGRect oldframe;
    CGFloat lastScale;
    UIImageView *scaleImgView;
    UIScrollView *backgroundView;
    
    CGFloat marginTop;
    
}

- (instancetype)init{
    self = [super init];
    if (self){
        lastScale = 1;
        _hideTitle = YES;
        _titleFontSize = 15;
        _titleHeight = 40;
        _titleColor = [UIColor whiteColor];
        _titleBackgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
        _cancelText = @"取消";
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addViews];
    [self setImages];
}


- (void)addViews{
    
    if (self.hideTitle) {
        marginTop = 20;
    }
    else{
        // title view
        
        marginTop = _titleHeight + 22 + 20;
        
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, marginTop - 20)];
        titleView.backgroundColor = self.titleBackgroundColor;
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 22, self.view.frame.size.width, _titleHeight)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font =  [[titleLabel font]fontWithSize:_titleFontSize];
        titleLabel.textColor = _titleColor;
        titleLabel.text = self.title;
        
        [titleView addSubview:titleLabel];
        
        [self.view addSubview:titleView];
        
        // add cancel
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat w = self.view.frame.size.width * 0.5;
        CGFloat margin = 5;
        NSDictionary *attr = @{NSFontAttributeName:cancel.titleLabel.font};
        
        CGRect frame  = [_cancelText boundingRectWithSize:CGSizeMake(w, _titleHeight) options:NSStringDrawingUsesDeviceMetrics attributes:attr context:nil];
        frame.size.height = _titleHeight;
        frame.origin.x = margin;
        frame.origin.y = 22;
        cancel.frame = frame;
        [cancel setTitle:_cancelText forState:UIControlStateNormal];
        cancel.titleLabel.frame = cancel.bounds;
        cancel.titleLabel.font = [cancel.titleLabel.font fontWithSize:self.titleFontSize];
        cancel.titleLabel.textColor = _titleColor;
        cancel.titleLabel.textAlignment = NSTextAlignmentLeft;
        [cancel addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:cancel];
    }
    
    // 添加输入框
    CGRect frame = self.view.frame;
    frame.origin.x = 20;
    frame.origin.y = marginTop;
    frame.size.width = self.view.frame.size.width - frame.origin.x * 2;
    frame.size.height = frame.size.width * 0.6;
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    view.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = kRadius;
    [self.view addSubview:view];
    
    frame.origin.x = 4;
    frame.origin.y = 0;
    imgH = frame.size.height * 0.35;
    frame.size.height = frame.size.height - imgH - kPadding * 2;
    frame.size.width = frame.size.width - frame.origin.x * 2;
    tvInfo = [[UITextView alloc]initWithFrame:frame];
    tvInfo.textColor = [UIColor darkGrayColor];
    
    tvInfo.returnKeyType = UIReturnKeyNext;
    [view addSubview:tvInfo];
    
    // 添加图片
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(tvInfo.frame) + kPadding;
    frame.size.width = view.frame.size.width;
    frame.size.height = imgH;
    svImg = [[UIScrollView alloc] initWithFrame:frame];
    [view addSubview:svImg];
    
    
    // 添加提交按钮
    frame = view.frame;
    frame.origin.y = CGRectGetMaxY(view.frame) + kPadding * 2;
    frame.size.height = 30;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setBackgroundColor:[[UIColor blueColor]colorWithAlphaComponent:0.6]];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    btn.titleLabel.font = [btn.titleLabel.font fontWithSize:14];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    btn.layer.cornerRadius = kRadius;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tap];
    
}

- (void)tap:(UIGestureRecognizer *)recognizer{
    if (recognizer.view == self.view) {
        [self.view endEditing:YES];
    }
}

- (void)setImages{
    if (!imgs) {
        imgs = [NSMutableArray arrayWithObject:[UIImage imageNamed:@"add.png"]];
    }
    for (UIView *view in svImg.subviews) {
        [view removeFromSuperview];
    }
    CGFloat x = 0;
    
    CGFloat delH = 20;
    CGRect delFrame = CGRectMake(imgH - delH, 0, delH, delH);
    for (int i=0; i<imgs.count; i++) {
        x = (kPadding + imgH) * i + kPadding;
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, kPadding, imgH, imgH)];
        [btn setImage:imgs[i] forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.tag = i;
        [svImg addSubview:btn];
        [btn addTarget:self action:@selector(imgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 添加图片上的删除按钮
        if (i != imgs.count - 1) {
            UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteButton.frame = delFrame;
            [deleteButton setBackgroundImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
            deleteButton.tag = i;
            [btn addSubview:deleteButton];
        }
    }
    
    CGFloat w = x + kPadding + imgH;
    CGSize contentSize = CGSizeMake(w, svImg.frame.size.height);
    [svImg setContentSize:contentSize];
}

- (void)imgBtnClick:(UIButton *)imgBtn{
    if (imgBtn.tag == imgs.count - 1) {
        [self addImage];
    }
    else{
        // 查看大图片
        [self showImage:imgBtn.imageView];
    }
}

- (void)addToImgs:(NSArray *)newImgs{
    for (int i = 0; i < newImgs.count; i++) {
        [imgs insertObject:newImgs[i] atIndex: imgs.count - 1];
    }
}

// 选择图片
- (void)addImage{
    __weak typeof(self) wSelf=  self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [wSelf addImageFromCamera];
    }];
    [alertVC addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [wSelf addImageFromThumbnails];
    }];
    [alertVC addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:action];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)addImageFromCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"不可使用摄像功能" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    if (img) {
        [self addToImgs:@[img]];
        [self setImages];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)addImageFromThumbnails{
    __weak typeof(self) wSelf=  self;
    SGImagePickerController *imagePickerController = [[SGImagePickerController alloc]init];
    //    imagePickerController.barTintColor = self.titleColor;
    //    imagePickerController.navBarTintColor = self.titleBackgroundColor;
    [imagePickerController setDidFinishSelectImages:^(NSArray *images) {
        if (images && images.count > 0) {
            [wSelf addToImgs:images];
            [wSelf setImages];
        }
    }];
    [imagePickerController setDidFinishSelectThumbnails:^(NSArray *thumbnails) {
        //NSLog(@"thumbnails = %@",thumbnails);
    }];
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)deleteImage:(UIButton *)button{
    [imgs removeObjectAtIndex:button.tag];
    [self setImages];
}

- (void)submit{
    [tvInfo endEditing: YES];
    
    if (self.problemFeedbackDelegate) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:imgs];
        [array removeLastObject];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"images"] = array;
        info[@"textContent"] = tvInfo.text;
        [self.problemFeedbackDelegate proglemFeedbackController:self didSubmitInfo:info];
    }
}


- (void)back{
    if (self.problemFeedbackDelegate) {
        [self.problemFeedbackDelegate proglemFeedbackController:self didSubmitInfo:nil];
    }
}

@end
