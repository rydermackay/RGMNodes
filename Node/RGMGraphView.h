//
//  RGMGraphView.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGMNodeDefines.h"

@class RGMGraphView;
@class RGMNodeView;
@class RGMAddress;

@protocol RGMGraphViewDelegate <UIScrollViewDelegate>

- (BOOL)graphView:(RGMGraphView *)graphView shouldConnectNode:(NSIndexPath *)fromNode toNode:(NSIndexPath *)toNode;
- (void)graphView:(RGMGraphView *)graphView didConnectNode:(NSIndexPath *)fromNode toNode:(NSIndexPath *)toNode;
- (BOOL)graphView:(RGMGraphView *)graphView shouldDisconnectNode:(NSIndexPath *)fromNode toNode:(NSIndexPath *)toNode;
- (void)graphView:(RGMGraphView *)graphView didDisconnectNode:(NSIndexPath *)fromNode toNode:(NSIndexPath *)toNode;

@end

@protocol RGMGraphViewDatasource <NSObject>

@required
- (NSUInteger)graphViewNumberOfNodes:(RGMGraphView *)graphView;
- (RGMNodeView *)graphView:(RGMGraphView *)graphView nodeForIndex:(NSUInteger)idx;

@end

@interface RGMGraphView : UIScrollView

@property (nonatomic, weak) IBOutlet id <RGMGraphViewDatasource> datasource;
@property (nonatomic, weak) IBOutlet id <RGMGraphViewDelegate> delegate;

- (void)insertNodeAtIndex:(NSUInteger)idx animated:(BOOL)animated;
- (void)removeNodeAtIndex:(NSUInteger)idx animated:(BOOL)animated;

- (void)addConnectionFromAddress:(RGMAddress *)fromAddress
                       toAddress:(RGMAddress *)toAddress;

- (void)removeConnectionFromAddress:(RGMAddress *)fromAddress
                          toAddress:(RGMAddress *)toAddress;

- (void)removeAllConnectionsFromNode:(NSUInteger)node;

- (void)batchUpdateGraph:(void (^)())updates
              completion:(void (^)(BOOL finished))completion;

@end
