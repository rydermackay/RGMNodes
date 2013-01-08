//
//  RGMConnection.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-07.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGMAddress;

@interface RGMConnection : NSObject

// one-way for now. from.source must be "output" and to.source must be "input"
+ (id)connectionFrom:(RGMAddress *)fromAddress to:(RGMAddress *)toAddress;
- (id)initWithFrom:(RGMAddress *)fromAddress to:(RGMAddress *)toAddress;

@property (nonatomic, readonly) RGMAddress *fromAddress;
@property (nonatomic, readonly) RGMAddress *toAddress;

@end
