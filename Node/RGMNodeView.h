//
//  RGMNodeView.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGMNodeDefines.h"

@class RGMNodeView;
@class RGMConnectionView;

@protocol RGMNodeViewDelegate <NSObject>

@required
- (void)nodeView:(RGMNodeView *)nodeView tappedSource:(RGMNodeSource)source index:(NSUInteger)idx;

@end

@interface RGMNodeView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *inputs;
@property (nonatomic, copy) NSArray *outputs;

@property (nonatomic, weak) id <RGMNodeViewDelegate> delegate;
@property (nonatomic, weak) RGMConnectionView *inputConnection;
@property (nonatomic, weak) RGMConnectionView *outputConnection;

- (CGRect)frameForSource:(RGMNodeSource)source index:(NSUInteger)idx;

@end
