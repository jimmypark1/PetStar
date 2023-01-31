//
//  CropFilter.h
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 9..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface CropFilter : GPUImageCropFilter
- (void)setFrameBuffer:(NSInteger)ratioStatus;
- (UIImage*)getFrameBuffer:(GPUImageOutput*)filter size:(CGSize)size;

@end
