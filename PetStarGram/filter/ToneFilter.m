//
//  ToneFilter.m
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 9..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "ToneFilter.h"

@implementation ToneFilter
- (void)setFrameBuffer:(NSInteger)ratioStatus
{
    CGSize size = CGSizeMake(1280, 720);
    if(ratioStatus == 1)
    {
        size = CGSizeMake(640, 480);
    }
    else if(ratioStatus == 2)
    {
        size = CGSizeMake(480, 480);
    }
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:size textureOptions:self.outputTextureOptions onlyTexture:NO];
    
    [outputFramebuffer activateFramebuffer];
    
}
- (UIImage*)getFrameBuffer:(GPUImageFilter*)filter size:(CGSize)size
{
    GPUImageFramebuffer *_outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:size textureOptions:filter.outputTextureOptions onlyTexture:NO];
    [_outputFramebuffer activateFramebuffer];
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIImageOrientation imageOrientation = UIImageOrientationLeft;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationRight;
            break;
        default:
            imageOrientation = UIImageOrientationUp;
            break;
    }
    
    CGImageRef image = [_outputFramebuffer newCGImageFromFramebufferContents];
    
    UIImage *finalImage = [UIImage imageWithCGImage:image scale:1.0 orientation:imageOrientation];
    CGImageRelease(image);
    
    return finalImage;
}
@end
