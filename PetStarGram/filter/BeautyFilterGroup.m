//
//  BeautyFilterGroup.m
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 5..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "BeautyFilterGroup.h"

@interface BeautyFilterGroup()
{
    GPUImageCropFilter      *cropFilter;
    GPUImageLookupFilter    *lookupFilter;
    
}

@end

@implementation BeautyFilterGroup

- (void)process
{
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 0.75)];
    [cropFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(480, 480)];
    
  //  self.initialFilters = [NSArray arrayWithObjects:sceneFilter,nil];
  //  self.terminalFilter = cropFilter;

}

@end
