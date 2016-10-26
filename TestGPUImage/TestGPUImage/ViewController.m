//
//  ViewController.m
//  TestGPUImage
//
//  Created by 小胖的Mac on 16/10/26.
//  Copyright © 2016年 uxin. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface ViewController ()
@property (nonatomic , strong)  GPUImageView              * uxinGPUImgeView ;
@property (nonatomic , strong) GPUImageVideoCamera        * videoCamera;
@property (nonatomic , strong) GPUImageOutput<GPUImageInput> * filter;
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , copy)   NSString * pathToMovie;

@property (nonatomic , strong) UIButton *mButton;

#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    [self setUpConfigure];
    
}
- (void)setUpView{
    self.view.backgroundColor = [UIColor grayColor];
    // 预览层
    GPUImageView * uxinGPUImgeView  = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*0.8)];
    uxinGPUImgeView.fillMode  = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:uxinGPUImgeView];
    self.uxinGPUImgeView = uxinGPUImgeView;
    
    _mButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.5-25, SCREEN_HEIGHT*0.8+10, 100, 50)];
    [_mButton setBackgroundColor:[UIColor redColor]];
    [_mButton setTitle:@"录制" forState:UIControlStateNormal];
    [_mButton sizeToFit];
    [self.view addSubview:_mButton];
    [_mButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void)setUpConfigure{
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    [_videoCamera addAudioInputsAndOutputs];
    
    self.filter = [[GPUImageSepiaFilter alloc] init];

    [_videoCamera addTarget:_filter];
    [_filter addTarget:_uxinGPUImgeView];
    [_videoCamera startCameraCapture];
    
}
- (void)onClick:(UIButton *)sender {
  
    
    if([sender.currentTitle isEqualToString:@"录制"]) {
        
        [sender setTitle:@"结束" forState:UIControlStateNormal];
        NSLog(@"Start recording");
        self.pathToMovie = [self getPathStr];
        NSURL *movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        unlink([self.pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        _movieWriter.encodingLiveVideo = YES;
        [_filter addTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];
        
    }
    else {
        [sender setTitle:@"录制" forState:UIControlStateNormal];
        NSLog(@"End recording");
        
        [_filter removeTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecording];
        [self save:self.pathToMovie];
        
    }

}
- (void)save:(NSString*)urlString{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *movieURL = [NSURL fileURLWithPath:urlString];

    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlString))
    {
        [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 } else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
             });
         }];
    }
    
}



- (NSString*)getPathStr{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复
    
    [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
    
    NSString *videoCacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoCacheDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString * resultPath = [NSString stringWithFormat:@"%@/%@.mp4",videoCacheDir,[formater stringFromDate:[NSDate date]]];
    return resultPath;
    
}
@end
