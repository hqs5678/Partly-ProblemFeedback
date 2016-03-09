//
//  UIViewController+Image.m
//  problemfeedback
//
//  Created by hqs on 16/3/9.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "UIViewController+Image.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface TmpClass : NSObject

@property (nonatomic,strong) UIScrollView *backgroundView;
@property (nonatomic,assign) CGFloat lastScale;
@property (nonatomic,strong) UIImageView *scaleImgView;
@property (nonatomic,assign) CGRect oldframe;

+ (instancetype)sharedInstance;

@end

static TmpClass *sharedSingleton = nil;

@implementation TmpClass

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(void) {
        sharedSingleton = [[TmpClass alloc] init];
    });
    return sharedSingleton;
}


@end

@interface UIViewController() <UIScrollViewDelegate>

@end

@implementation UIViewController (Image)


// 显示大图片
-(void)showImage:(UIImageView *)avatarImageView{
    UIImage *image=avatarImageView.image;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    [TmpClass sharedInstance].backgroundView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [TmpClass sharedInstance].oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    
    [TmpClass sharedInstance].backgroundView.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [TmpClass sharedInstance].backgroundView.alpha=0;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:[TmpClass sharedInstance].oldframe];
    imageView.image=image;
    imageView.tag=1;
    [TmpClass sharedInstance].scaleImgView = imageView;
    [TmpClass sharedInstance].backgroundView.delegate = self;
    [TmpClass sharedInstance].backgroundView.maximumZoomScale = 4;
    [TmpClass sharedInstance].backgroundView.minimumZoomScale = 1;
    [TmpClass sharedInstance].backgroundView.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    [[TmpClass sharedInstance].backgroundView addSubview:imageView];
    [window addSubview:[TmpClass sharedInstance].backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [[TmpClass sharedInstance].backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,(SCREEN_HEIGHT-image.size.height*SCREEN_WIDTH/image.size.width) * 0.5, SCREEN_WIDTH, image.size.height*SCREEN_WIDTH/image.size.width);
        [TmpClass sharedInstance].backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (scrollView.contentSize.height<SCREEN_HEIGHT && scrollView.contentSize.width>=SCREEN_WIDTH) {
        [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, SCREEN_HEIGHT)];
    }
    else if (scrollView.contentSize.width<SCREEN_WIDTH) {
        [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT)];
    }
    else{
    }
    
    [[TmpClass sharedInstance].scaleImgView setCenter:CGPointMake(scrollView.contentSize.width/2, scrollView.contentSize.height/2)];
    
}

// 缩放图片
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [TmpClass sharedInstance].scaleImgView;
}

// 隐藏图片
-(void)hideImage:(UITapGestureRecognizer*)tap{
    [UIView animateWithDuration:[TmpClass sharedInstance].backgroundView.zoomScale/24 animations:^{
        [TmpClass sharedInstance].backgroundView.zoomScale = 1;
    } completion:^(BOOL finished) {
        UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame=[TmpClass sharedInstance].oldframe;
            [TmpClass sharedInstance].backgroundView.alpha=0;
        } completion:^(BOOL finished) {
            [[TmpClass sharedInstance].backgroundView removeFromSuperview];
        }];
    }];
}

@end
