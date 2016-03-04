//
//  SGCollectionController.m
//  SGImagePickerController
//
//  Created by yyx on 15/9/20.
//  Copyright (c) 2015年 yyx. All rights reserved.
//

#import "SGCollectionController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SGAssetModel.h"
#import "SGImagePickerController.h"
#define MARGIN 3
#define COL 4
#define kWidth [UIScreen mainScreen].bounds.size.width

@interface SGShowCell : UICollectionViewCell
@property (nonatomic,weak) UIImageView *selectIcon;
@end

@implementation SGShowCell

@end

@interface SGCollectionController ()
@property (nonatomic,strong) NSMutableArray *assetModels;
//选中的模型
@property (nonatomic,strong) NSMutableArray *selectedModels;
//选中的图片
@property (nonatomic,strong) NSMutableArray *selectedImages;
@end

@implementation SGCollectionController

static NSString * const reuseIdentifier = @"Cell";
//设置类型
- (instancetype)init
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = MARGIN;
    flowLayout.minimumInteritemSpacing = MARGIN;
    CGFloat cellHeight = (kWidth - (COL + 1) * MARGIN) / COL;
    flowLayout.itemSize = CGSizeMake(cellHeight, cellHeight);
    flowLayout.sectionInset = UIEdgeInsetsMake(MARGIN, MARGIN, MARGIN, MARGIN);
    return [super initWithCollectionViewLayout:flowLayout];
}
- (NSMutableArray *)assetModels{
    if (_assetModels == nil) {
        _assetModels = [NSMutableArray array];
    }
    return _assetModels;
}
- (NSMutableArray *)selectedImages{
    if (_selectedImages == nil) {
        _selectedImages = [NSMutableArray array];
    }
    return _selectedImages;
}
- (NSMutableArray *)selectedModels{
    if (_selectedModels == nil) {
        _selectedModels = [NSMutableArray array];
    }
    return _selectedModels;
}
- (void)setGroup:(ALAssetsGroup *)group{
    _group = group;
    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset == nil) return ;
        if (![[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {//不是图片
            return;
        }
        SGAssetModel *model = [[SGAssetModel alloc] init];
        model.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        model.imageURL = asset.defaultRepresentation.url;
        [self.assetModels addObject:model];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[SGShowCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.title = @"选择图片";
    
    //右侧完成按钮
    UIBarButtonItem *finish = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishSelecting)];
    self.navigationItem.rightBarButtonItem = finish;
    
}
//出口,选择完成图片
- (void)finishSelecting{
    
    if ([self.navigationController isKindOfClass:[SGImagePickerController class]]) {
        SGImagePickerController *picker = (SGImagePickerController *)self.navigationController;
        if (picker.didFinishSelectThumbnails || picker.didFinishSelectImages) {
            
            for (SGAssetModel *model in self.assetModels) {
                if (model.isSelected) {
                    [self.selectedModels addObject:model];
                }
            }
            
            //获取原始图片可能是异步的,因此需要判断最后一个,然后传出
            for (int i = 0; i < self.selectedModels.count; i++) {
                SGAssetModel *model = self.selectedModels[i];
                [model originalImage:^(UIImage *image) {
                    [self.selectedImages addObject:image];
                    
                    if ( i == self.selectedModels.count - 1) {//最后一个
                        if (picker.didFinishSelectImages) {
                            picker.didFinishSelectImages(self.selectedImages);
                        }
                        
                    }
                }];
            }
            
            if (picker.didFinishSelectThumbnails) {
                picker.didFinishSelectThumbnails([_selectedModels valueForKeyPath:@"thumbnail"]);
            }
            
        }
    }
    
    //移除
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.assetModels.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SGShowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    SGAssetModel *model = self.assetModels[indexPath.item];
   
    if (cell.backgroundView == nil) {//防止多次创建
        UIImageView *imageView = [[UIImageView alloc] init];
        cell.backgroundView = imageView;
    }
    UIImageView *backView = (UIImageView *)cell.backgroundView;
    backView.image = model.thumbnail;
    if (cell.selectIcon == nil) {//防止多次创建
        UIImageView *imgView = [[UIImageView alloc] init];
        [imgView setImage:[UIImage imageNamed:@"sg_seleted"]];
        CGFloat width = cell.bounds.size.width;
        imgView.frame = CGRectMake(width - 20, 0, 20, 20);
        [cell.contentView addSubview:imgView];
        cell.selectIcon = imgView;
        cell.selectIcon.hidden = YES;
    }
    if (model.isSelected) {
        cell.selectIcon.hidden = NO;
    }
    else{
        cell.selectIcon.hidden = YES;
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    SGPhotoBrowser *browser = [[SGPhotoBrowser alloc] init];
//    browser.assetModels = self.assetModels;
//    browser.currentIndex = indexPath.item;
//    [browser show];
    SGAssetModel *model = self.assetModels[indexPath.item];
    SGShowCell *cell =(SGShowCell *) [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if (model.isSelected) {
        model.isSelected = NO;
        cell.selectIcon.hidden = NO;
    }
    else{
        model.isSelected = YES;
        cell.selectIcon.hidden = YES;
    }
    [collectionView reloadData];
}
@end
