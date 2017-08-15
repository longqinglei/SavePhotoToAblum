//
//  SaveImageToAblum.m
//  SavePhotoToAblum
//
//  Created by 龙青磊 on 2017/8/15.
//  Copyright © 2017年 龙青磊. All rights reserved.
//

#import "SaveImageToAblum.h"
#import <Photos/Photos.h>

#define DisplayName [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

@interface SaveImageToAblum ()

@property (nonatomic, strong)UIImage *image;

@end

@implementation SaveImageToAblum

+ (instancetype)shareInstance{

    static SaveImageToAblum *instance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[SaveImageToAblum alloc] init];
    });
    return instance;
}

- (void)saveImage:(UIImage *)image{
    self.image = image;
    [self checkAblumPrivacy];
}

// 判断授权状态
-(void)checkAblumPrivacy{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted) {
        NSLog(@"无法访问相簿--PHAuthorizationStatusRestricted");
    } else if (status == PHAuthorizationStatusDenied) {
        NSLog(@"无法访问相簿--PHAuthorizationStatusDenied");
    } else if (status == PHAuthorizationStatusAuthorized) {
        NSLog(@"可以访问相簿--PHAuthorizationStatusAuthorized");
        [self saveImage];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        // 弹框请求用户授权
        NSLog(@"第一次访问--PHAuthorizationStatusNotDetermined");
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) { // 用户点击了好
                [self saveImage];
            }
        }];
    }
}

//保存到指定相册(默认相册名称为项目名称,如果不存在相册,创建新相册)
-(void)saveImage{
    //    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    __block  NSString *assetLocalIdentifier;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //1.保存图片到相机胶卷中----创建图片的请求
        
        UIImageJPEGRepresentation(self.image, 0.1);
        assetLocalIdentifier = [PHAssetCreationRequest creationRequestForAssetFromImage:self.image].placeholderForCreatedAsset.localIdentifier;
        NSLog(@"assetLocalIdentifier = %@",assetLocalIdentifier);
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success == NO){
            NSLog(@"保存图片失败----(创建图片的请求)");
            return ;
        }
        // 2.获得相簿
        PHAssetCollection *createdAssetCollection = [self createAssetCollection];
        if (createdAssetCollection == nil) {
            NSLog(@"保存图片成功----(创建相簿失败!)");
            return;
        }
        // 3.将刚刚添加到"相机胶卷"中的图片到"自己创建相簿"中
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            //获得图片
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalIdentifier] options:nil].lastObject;
            //添加图片到相簿中的请求
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            // 添加图片到相簿
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(success){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //
                    //                    [MBProgressHUD showSuccess:@"成功保存到相册" toView:nil];
                    //                    hud.hidden = YES;
                    NSLog(@"保存图片到创建的相簿成功");
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //
                    //                    [MBProgressHUD showSuccess:@"保存失败" toView:nil];
                    //                    hud.hidden = YES;
                    NSLog(@"保存到创建的相册失败");
                });
            }
            
        }];
    }];
}

//获取要存储的相册
-(PHAssetCollection *)createAssetCollection{
    //判断是否已存在
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection * assetCollection in assetCollections) {
        if ([assetCollection.localizedTitle isEqualToString:DisplayName]) {
            //说明已经有哪对象了
            NSLog(@"相册已经存在");
            return assetCollection;
        }
    }
    //创建新的相簿
    __block NSString *assetCollectionLocalIdentifier = nil;
    NSError *error = nil;
    //同步方法
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 创建相簿的请求
        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:DisplayName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error)return nil;
    NSLog(@"创建相册成功");
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject;
}

@end
