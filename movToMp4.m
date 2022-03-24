#import "movToMp4.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface movToMp4()
@end
@implementation movToMp4

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(convertMovToMp4: (NSString*)rootFilePath
                  rootFileName:(NSString*)rootFileName
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
                )
{
    dispatch_sync(dispatch_get_main_queue(), ^{
      
      
        [self onConvertVideo:rootFilePath rootFileName:rootFileName resolver:resolve rejecter: reject];
  });
}

-(void) onConvertVideo: (NSString*)rootFilePath
          rootFileName:(NSString*)rootFileName
                resolver:(RCTPromiseResolveBlock)resolve
              rejecter:(RCTPromiseRejectBlock)reject
{
    NSString * filePath;
    NSString * fileName = rootFileName;
    
    if ([rootFilePath containsString:@"file://"]) {
          filePath = [rootFilePath stringByReplacingOccurrencesOfString:@"file://"
                                                    withString:@""];
    } else {
        filePath = rootFilePath;
    }
    
    if ([[rootFileName uppercaseString] containsString:@".MOV"]) {
        fileName = [rootFileName stringByReplacingOccurrencesOfString:@".MOV"
                                                    withString:@""];
    } else {
        filePath = rootFileName;
    }
    
    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:urlFile options:nil];

    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];

    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];

    NSString * resultPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.mp4", fileName];

    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];

    //set the output file format if you want to make it in other file format (ex .3gp)
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status])
        {
            case AVAssetExportSessionStatusFailed: {
                NSError* error = exportSession.error;
                NSString *codeWithDomain = [NSString stringWithFormat:@"E%@%zd", error.domain.uppercaseString, error.code];
                
                reject(codeWithDomain, error.localizedDescription, error);
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                //Video conversion finished
                //NSLog(@"Successful!");
                NSString *resultFileName = [NSString stringWithFormat:@"%@.mp4", fileName];
                NSDictionary *result =@{ @"resultPath": resultPath, @"fileName": resultFileName };
                resolve(result);
            }
                break;
            default:
                break;
        }
    }];
}

RCT_EXPORT_METHOD(removeConvertedVideo: (NSString*)rootFileName
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
                )
{
    dispatch_sync(dispatch_get_main_queue(), ^{
      
      
        [self onRemoveVideo:rootFileName resolver:resolve rejecter: reject];
  });
}

-(void) onRemoveVideo: (NSString*)convertedFileName
               resolver:(RCTPromiseResolveBlock)resolve
             rejecter:(RCTPromiseRejectBlock)reject {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
     NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

     NSString *filePath = [documentsPath stringByAppendingPathComponent:convertedFileName];
     NSError *error;
     BOOL success = [fileManager removeItemAtPath:filePath error:&error];
     if (success) {
         resolve(@"Successfully removed");
     }
     else
     {
         NSString *codeWithDomain = [NSString stringWithFormat:@"E%@%zd", error.domain.uppercaseString, error.code];
         reject(codeWithDomain, error.localizedDescription, error);
     }
}

@end
