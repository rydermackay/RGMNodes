//
//  RGMConnectionView.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RGMNodeView;

@interface RGMConnectionView : UIView

- (id)initWithFromNodeInputIndexPath:(NSIndexPath *)fromNodeOutputIndexPath
                toNodeInputIndexPath:(NSIndexPath *)toNodeInputIndexPath;

@property (nonatomic, readonly) NSIndexPath *fromNodeOutputIndexPath;
@property (nonatomic, readonly) NSIndexPath *toNodeInputIndexPath;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@end
