//
//  NSIndexPath+RGMNodeSource.m
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "NSIndexPath+RGMNodeSource.h"

@implementation NSIndexPath (RGMNodeSource)

+ (NSIndexPath *)indexPathForSource:(NSInteger)source inNode:(NSInteger)node
{
    return [NSIndexPath indexPathForRow:source inSection:node];
}

- (NSInteger)node
{
    return self.section;
}

- (NSInteger)source
{
    return self.row;
}

@end
