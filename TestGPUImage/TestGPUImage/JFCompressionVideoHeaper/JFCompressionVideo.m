//
//  JFCompressionVideo.m
//  textUpLoad
//
//  Created by iOS-Developer on 16/2/19.
//  Copyright © 2016年 iOS-Jessonliu. All rights reserved.
//

#import "JFCompressionVideo.h"
#import <AVFoundation/AVFoundation.h>
//compress

@interface JFCompressionVideo ()
@end

@implementation JFCompressionVideo

+ (void)compressedVideoOtherMethodWithURL:(NSURL *)url compressionType:(NSString *)compressionType compressionResultPath:(CompressionSuccessBlock)resultPathBlock {
    
    
//    NSData *data = [NSData dataWithContentsOfURL:url];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];

    // 所支持的压缩格式中是否有 所选的压缩格式
    if ([compatiblePresets containsObject:compressionType]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:compressionType];
        
        NSString *videoCacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/compressVideo"];
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL isExists = [manager fileExistsAtPath:videoCacheDir];
        if (!isExists) {
            [manager createDirectoryAtPath:videoCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSRange range = [url.absoluteString rangeOfString:@"/userVideo/"];
        NSString * tempStr = @"";
        NSInteger temp = range.location +range.length ;
        if (temp < url.absoluteString.length) {
            tempStr = [url.absoluteString substringFromIndex:temp];
        }
        NSString *videoPath = [NSString stringWithFormat:@"%@/%@",videoCacheDir,tempStr];

        
        exportSession.outputURL = [NSURL fileURLWithPath:videoPath];
        
        exportSession.outputFileType = AVFileTypeAppleM4V;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                 
                 NSData *data = [NSData dataWithContentsOfFile:videoPath];
                 
                 float memorySize = (float)data.length / 1024 / 1024;
                 
                 unlink([url.path UTF8String]);
                 [[NSFileManager defaultManager] moveItemAtPath:videoPath toPath:url.path error:nil];
                 if ( [manager fileExistsAtPath:url.path]) {
                     resultPathBlock (url.path, memorySize);
                 }
             } else {
                 
//                 JFLog(@"压缩失败");
             }
             
         }];
        
    } else {
//        JFLog(@"不支持 %@ 格式的压缩", compressionType);
    }
}



+ (float)countVideoTotalMemorySizeWithURL:(NSURL *)url {
    NSData *data = [NSData dataWithContentsOfURL:url];
    CGFloat totalSize = (float)data.length / 1024 / 1024;
    return totalSize;
}


@end
