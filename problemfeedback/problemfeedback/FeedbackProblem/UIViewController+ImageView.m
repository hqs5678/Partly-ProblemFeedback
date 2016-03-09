//
//  UIViewController+ImageView.m
//  problemfeedback
//
//  Created by hqs on 16/3/9.
//  Copyright © 2016年 hqs. All rights reserved.
//

//
//  UIViewController+Image.m
//  problemfeedback
//
//  Created by hqs on 16/3/9.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "UIViewController+ImageView.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface TmpHolder : NSObject

@property (nonatomic,strong) UIScrollView *backgroundView;
@property (nonatomic,assign) CGFloat lastScale;
@property (nonatomic,strong) UIImageView *scaleImgView;
@property (nonatomic,assign) CGRect oldframe;

+ (instancetype)sharedInstance;

@end

static TmpHolder *sharedSingleton = nil;

@implementation TmpHolder

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(void) {
        sharedSingleton = [[TmpHolder alloc] init];
    });
    return sharedSingleton;
}


@end

@interface UIViewController() <UIScrollViewDelegate>

@end

@implementation UIViewController (Image)


// 显示大图片
-(void)showFullScreenImage:(UIImageView *)imgView{
    UIImage *image=imgView.image;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    [TmpHolder sharedInstance].backgroundView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [TmpHolder sharedInstance].oldframe=[imgView convertRect:imgView.bounds toView:window];
    
    [TmpHolder sharedInstance].backgroundView.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [TmpHolder sharedInstance].backgroundView.alpha=0;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:[TmpHolder sharedInstance].oldframe];
    imageView.image=image;
    imageView.tag=1;
    [TmpHolder sharedInstance].scaleImgView = imageView;
    [TmpHolder sharedInstance].backgroundView.delegate = self;
    [TmpHolder sharedInstance].backgroundView.maximumZoomScale = 4;
    [TmpHolder sharedInstance].backgroundView.minimumZoomScale = 1;
    [TmpHolder sharedInstance].backgroundView.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    [[TmpHolder sharedInstance].backgroundView addSubview:imageView];
    [window addSubview:[TmpHolder sharedInstance].backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [[TmpHolder sharedInstance].backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,(SCREEN_HEIGHT-image.size.height*SCREEN_WIDTH/image.size.width) * 0.5, SCREEN_WIDTH, image.size.height*SCREEN_WIDTH/image.size.width);
        [TmpHolder sharedInstance].backgroundView.alpha=1;
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
    
    [[TmpHolder sharedInstance].scaleImgView setCenter:CGPointMake(scrollView.contentSize.width/2, scrollView.contentSize.height/2)];
    
}

// 缩放图片
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [TmpHolder sharedInstance].scaleImgView;
}

// 隐藏图片
-(void)hideImage:(UITapGestureRecognizer*)tap{
    [UIView animateWithDuration:[TmpHolder sharedInstance].backgroundView.zoomScale/24 animations:^{
        [TmpHolder sharedInstance].backgroundView.zoomScale = 1;
    } completion:^(BOOL finished) {
        UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame=[TmpHolder sharedInstance].oldframe;
            [TmpHolder sharedInstance].backgroundView.alpha=0;
        } completion:^(BOOL finished) {
            [[TmpHolder sharedInstance].backgroundView removeFromSuperview];
        }];
    }];
}

@end
