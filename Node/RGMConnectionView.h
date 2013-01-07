//
//  RGMConnectionView.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RGMNodeView;
@class RGMAddress;

@interface RGMConnectionView : UIView

- (id)initWithFromAddress:(RGMAddress *)fromAddress
                toAddress:(RGMAddress *)toAddress;

@property (nonatomic, readonly) RGMAddress *fromAddress;
@property (nonatomic, readonly) RGMAddress *toAddress;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@end
