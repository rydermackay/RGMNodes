//
//  RGMAddress.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-06.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMNodeDefines.h"

@interface RGMAddress : NSObject

@property (nonatomic, readonly) NSUInteger node;
@property (nonatomic, readonly) RGMNodeSource source;
@property (nonatomic, readonly) NSUInteger port;

+ (id)addressWithNode:(NSUInteger)node source:(RGMNodeSource)source port:(NSUInteger)port;
- (id)initWithNode:(NSUInteger)node source:(RGMNodeSource)source port:(NSUInteger)port;

@end
