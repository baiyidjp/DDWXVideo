//
//  DDPhotoViewController.m
//  DDWXVideo
//
//  Created by peng on 2019/8/29.
//  Copyright © 2019 dongjiangpeng. All rights reserved.
//

#import "DDPhotoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface DDPhotoViewController ()
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/** cameraImageView */
@property(nonatomic,strong) UIImageView *cameraImageView;

@end

@implementation DDPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getAuthorization];
}


- (void)getAuthorization{
    /*
     AVAuthorizationStatusNotDetermined = 0,// 未进行授权选择
     
     AVAuthorizationStatusRestricted,　　　　// 未授权，且用户无法更新，如家长控制情况下
     
     AVAuthorizationStatusDenied,　　　　　　 // 用户拒绝App使用
     
     AVAuthorizationStatusAuthorized,　　　　// 已授权，可使用
     */
    //此处获取摄像头授权
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
    {
        case AVAuthorizationStatusAuthorized:       //已授权，可使用    The client is authorized to access the hardware supporting a media type.
        {
            NSLog(@"授权摄像头使用成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self p_ConfigView];
            });
            break;
        }
        case AVAuthorizationStatusNotDetermined:    //未进行授权选择     Indicates that the user has not yet made a choice regarding whether the client can access the hardware.
        {
            //则再次请求授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){    //用户授权成功
                    [self p_ConfigView];
                    return;
                } else {        //用户拒绝授权
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    return;
                }
            }];
            break;
        }
        default:                                    //用户拒绝授权/未授权
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
    }
    
}

#pragma mark - config view
- (void)p_ConfigView {

    self.view.backgroundColor = [UIColor whiteColor];
    UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*0.5-self.view.frame.size.width*0.5, self.view.frame.size.width, self.view.frame.size.width)];
    photoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:photoView];
    
    UIButton *takePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(300, 637, 75, 30)];
    [takePhotoButton setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhotoButton setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:takePhotoButton];
    [takePhotoButton addTarget:self action:@selector(p_TakePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 637, 75, 30)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(p_BackButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.session beginConfiguration];
    
    // 获取前置摄像头设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for (AVCaptureDevice *device in devices ) {
        if (device.position == AVCaptureDevicePositionFront ) {
            // 前置摄像头
            captureDevice = device;
            break;
        }
    }
    
    [captureDevice lockForConfiguration:nil];
    // 设置闪光灯自动
    [captureDevice setFlashMode:AVCaptureFlashModeAuto];
    [captureDevice unlockForConfiguration];
    
    NSError *videoError;
    self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&videoError];
    if (videoError) {
        NSLog(@"获取摄像头失败");
        return;
    }
 
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = photoView.bounds;
//    self.previewLayer.position = CGPointMake(self.view.frame.size.width*0.5,photoView.frame.size.height*0.5);
    
    photoView.layer.masksToBounds = YES;
    [self.view layoutIfNeeded];
    [photoView.layer addSublayer:self.previewLayer];
    
    [self.session commitConfiguration];
    
    [self.session startRunning];
}

#pragma mark - TakePhoto
- (void)p_TakePhoto {
    
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!stillImageConnection) {
        NSLog(@"拍照失败!");
        return;
    }
    stillImageConnection.videoMirrored = YES;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        NSLog(@"image data %zd",imageData.length);
        [self.session stopRunning];
        self.cameraImageView.image = image;
        [self.view addSubview:self.cameraImageView];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);

    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}



- (void)p_BackButton {
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.cameraImageView removeFromSuperview];
    [self.session startRunning];
}


- (AVCaptureSession *)session {
    
    if (!_session) {
        
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            [_session setSessionPreset:AVCaptureSessionPresetPhoto];
        }
    }
    return _session;
}

- (AVCaptureStillImageOutput *)stillImageOutput {
    
    if (!_stillImageOutput) {
        
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
        [_stillImageOutput setOutputSettings:outputSettings];
    }
    return _stillImageOutput;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    
    if (!_previewLayer) {
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    }
    return _previewLayer;
}

- (UIImageView *)cameraImageView {
    
    if (!_cameraImageView) {
        
        _cameraImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*0.5-self.view.frame.size.width*0.5, self.view.frame.size.width, self.view.frame.size.width)];
        _cameraImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _cameraImageView;
}

@end
