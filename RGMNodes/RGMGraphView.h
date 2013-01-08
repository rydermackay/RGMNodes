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
@class RGMConnection;

@protocol RGMGraphViewDelegate <UIScrollViewDelegate>

@optional
- (BOOL)graphView:(RGMGraphView *)graphView canConnect:(RGMConnection *)connection;
- (void)graphView:(RGMGraphView *)graphView willConnect:(RGMConnection *)connection;
- (void)graphView:(RGMGraphView *)graphView didConnect:(RGMConnection *)connection;

- (BOOL)graphView:(RGMGraphView *)graphView canDisconnect:(RGMConnection *)connection;
- (void)graphView:(RGMGraphView *)graphView willDisconnect:(RGMConnection *)connection;
- (void)graphView:(RGMGraphView *)graphView didDisconnect:(RGMConnection *)connection;

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

- (void)addConnection:(RGMConnection *)connection;

- (void)removeConnection:(RGMConnection *)connection;

- (void)removeAllConnectionsFromNode:(NSUInteger)node;

- (void)batchUpdateGraph:(void (^)())updates
              completion:(void (^)(BOOL finished))completion;

@end
