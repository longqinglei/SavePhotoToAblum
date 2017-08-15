//
//  ViewController.m
//  SavePhotoToAblum
//
//  Created by 龙青磊 on 2017/8/15.
//  Copyright © 2017年 龙青磊. All rights reserved.
//

#import "ViewController.h"
#import "SaveImageToAblum.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
        
}

- (IBAction)saveImageToAblum:(UIButton *)sender {
    [[SaveImageToAblum shareInstance] saveImage:self.imageView.image];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
