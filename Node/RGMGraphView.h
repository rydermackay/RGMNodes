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

@optional
- (BOOL)graphView:(RGMGraphView *)graphView canConnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress;
- (void)graphView:(RGMGraphView *)graphView willConnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress;
- (void)graphView:(RGMGraphView *)graphView didConnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress;

- (BOOL)graphView:(RGMGraphView *)graphView canDisconnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress;
- (void)graphView:(RGMGraphView *)graphView willDisconnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress;
- (void)graphView:(RGMGraphView *)graphView didDisconnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress;

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
