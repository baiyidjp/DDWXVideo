//
//  ViewController.m
//  DDWXVideo
//
//  Created by tztddong on 16/3/2.
//  Copyright © 2016年 dongjiangpeng. All rights reserved.
//

#import "ViewController.h"
#import "DDWXVideoController.h"
#import<MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 200, 100, 30)];
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)click{
    
    UIAlertController *sheetCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [sheetCtrl addAction:[UIAlertAction actionWithTitle:@"本地视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self locaClick];
    }]];
    [sheetCtrl addAction:[UIAlertAction actionWithTitle:@"录制视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self takeClick];
    }]];
    [sheetCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:sheetCtrl animated:YES completion:nil];
}

- (void)takeClick{
    
    DDWXVideoController *ctrl = [[DDWXVideoController alloc]init];
    ctrl.allTime = 10;
    ctrl.minTime = 1.0;
    [self presentViewController:ctrl animated:YES completion:nil];
    
}

- (void)locaClick{
    
    UIImagePickerController *Videopicker = [[UIImagePickerController alloc]init];
    Videopicker.delegate = self;
    [Videopicker setEditing:NO];
    Videopicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    Videopicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    [self presentViewController:Videopicker animated:YES completion:nil];
    
}

#pragma mark  imagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"%@",[info valueForKey:UIImagePickerControllerMediaURL]);
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
