//
//  SaveImageToAblum.h
//  SavePhotoToAblum
//
//  Created by 龙青磊 on 2017/8/15.
//  Copyright © 2017年 龙青磊. All rights reserved.
//

/*
 
 1. 使用此类必须导入Photos.framework  #import <Photos/Photos.h>
 2. 在plist文件中添加key  Privacy - Photo Library Usage Description 获取读取相册的权限
 3. 创建新的相册名称 默认为 项目的名称（如果需要可自行更改.m文件中的DisplayName）
 
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SaveImageToAblum : NSObject

+ (instancetype)shareInstance;

- (void)saveImage:(UIImage *)image;

@end
