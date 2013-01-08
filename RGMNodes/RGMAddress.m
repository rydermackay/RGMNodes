//
//  RGMAddress.m
//  Node
//
//  Created by Ryder Mackay on 2013-01-06.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMAddress.h"

@implementation RGMAddress

+ (id)addressWithNode:(NSUInteger)node source:(RGMNodeSource)source port:(NSUInteger)port
{
    return [[self alloc] initWithNode:node source:source port:port];
}

- (id)initWithNode:(NSUInteger)node source:(RGMNodeSource)source port:(NSUInteger)port
{
    if (self = [super init]) {
        _node = node;
        _source = source;
        _port = port;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: node: %d, source: %@, port: %d", [super description], self.node, RGMStringForSource(self.source), self.port ];
}

static inline NSString * RGMStringForSource(RGMNodeSource source) {
    switch (source) {
        case RGMNodeInput:
            return @"input";
            break;
        case RGMNodeOutput:
            return @"output";
            break;
        case RGMNodeUnknown:
            return @"unknown";
            break;
        default:
            return nil;
            break;
    }
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        RGMAddress *address = object;
        return self.node == address.node && self.source == address.source && self.port == address.port;
    } else {
        return NO;
    }
}

- (NSUInteger)hash
{
    return [@[@(self.node), @(self.source), @(self.port)] hash];
}

@end
