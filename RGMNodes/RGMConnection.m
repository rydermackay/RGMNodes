//
//  RGMConnection.m
//  Node
//
//  Created by Ryder Mackay on 2013-01-07.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMConnection.h"
#import "RGMNodeDefines.h"
#import "RGMAddress.h"

@implementation RGMConnection

+ (id)connectionFrom:(RGMAddress *)fromAddress to:(RGMAddress *)toAddress
{
    return [[self alloc] initWithFrom:fromAddress to:toAddress];
}

- (id)initWithFrom:(RGMAddress *)fromAddress to:(RGMAddress *)toAddress
{
    if (self = [super init]) {
        
        NSParameterAssert(fromAddress.source == RGMNodeOutput &&
                          toAddress.source == RGMNodeInput);
        
        _fromAddress = fromAddress;
        _toAddress = toAddress;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    } else {
        RGMConnection *connection = object;
        return [self.fromAddress isEqual:connection.fromAddress] && [self.toAddress isEqual:connection.toAddress];
    }
}

- (NSUInteger)hash
{
    return [@[self.fromAddress, self.toAddress] hash];
}

@end
