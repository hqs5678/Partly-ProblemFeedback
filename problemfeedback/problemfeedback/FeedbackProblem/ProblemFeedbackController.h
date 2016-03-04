//
//  ProblemFeedbackController.h
//  testPickerView
//
//  Created by hqs on 16/3/1.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProblemFeedbackController;

@protocol ProblemFeedbackControllerDelegate <NSObject>

- (void)proglemFeedbackController:(ProblemFeedbackController *)problemFeedbackController didSubmitInfo:(NSDictionary *)info;

@end


@interface ProblemFeedbackController : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic,weak) id<ProblemFeedbackControllerDelegate> problemFeedbackDelegate;
// 是否显示标题 默认是YES  即不显示
@property (nonatomic,assign) BOOL hideTitle;
@property (nonatomic,strong) UIColor *titleBackgroundColor;
@property (nonatomic,strong) UIColor *titleColor;
@property (nonatomic,assign) CGFloat titleHeight;
@property (nonatomic,assign) CGFloat titleFontSize;
@property (nonatomic,strong) NSString *cancelText;

@end
