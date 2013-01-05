//
//  RGMGraphView.m
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMGraphView.h"
#import "RGMNodeView.h"
#import "RGMConnectionView.h"
#import "NSIndexPath+RGMNodeSource.h"

@interface RGMGraphView () <RGMNodeViewDelegate>

@end

@implementation RGMGraphView {
    RGMNodeView *_heldNode;
    CGPoint _offset;
    NSMutableArray *_nodes;
    NSMutableArray *_connections;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor lightGrayColor];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_nodes == nil) {
        [self reloadData];
    }
    
    for (RGMConnectionView *connection in _connections) {
        
        
        RGMNodeView *fromNode = [self nodeForIndex:connection.fromNodeOutputIndexPath.node];
        RGMNodeView *toNode = [self nodeForIndex:connection.toNodeInputIndexPath.node];
        
        CGRect fromFrame = [self convertRect:[fromNode frameForSource:RGMNodeOutput index:connection.fromNodeOutputIndexPath.source]
                                    fromView:fromNode];
        CGRect toFrame = [self convertRect:[toNode frameForSource:RGMNodeInput index:connection.toNodeInputIndexPath.source]
                                  fromView:toNode];
        
        CGFloat minY = MIN(CGRectGetMinY(fromFrame), CGRectGetMinY(toFrame));
        CGFloat maxY = MAX(CGRectGetMaxY(fromFrame), CGRectGetMaxY(toFrame));
        connection.frame = CGRectMake(CGRectGetMaxX(fromFrame),
                                      minY,
                                      CGRectGetMinX(toFrame) - CGRectGetMaxX(fromFrame),
                                      maxY - minY);
        
        connection.startPoint = [self convertPoint:CGPointMake(CGRectGetMaxX(fromFrame), CGRectGetMidY(fromFrame))
                                            toView:connection];
        connection.endPoint = [self convertPoint:CGPointMake(CGRectGetMinX(toFrame), CGRectGetMidY(toFrame))
                                          toView:connection];
    }
}

- (void)setDatasource:(id<RGMGraphViewDatasource>)datasource
{
    if ([_datasource isEqual:datasource]) {
        return;
    }
    
    _datasource = datasource;
    
    [self reloadData];
}

- (void)reloadData
{
    // kill all nodes and connections
    for (RGMNodeView *node in _nodes) {
        [node removeFromSuperview];
    }
    
    for (RGMConnectionView *connection in _connections) {
        [connection removeFromSuperview];
    }
    
    if (_nodes == nil) {
        _nodes = [NSMutableArray new];
    } else {
        [_nodes removeAllObjects];
    }
    
    if (_connections == nil) {
        _connections = [NSMutableArray new];
    } else {
        [_connections removeAllObjects];
    }
    
    NSUInteger nodeNumber = [self.datasource graphViewNumberOfNodes:self];

    for (int i = 0; i < nodeNumber; i++) {
        RGMNodeView *node = [self.datasource graphView:self nodeForIndex:i];
        node.delegate = self;
        [self addSubview:node];
        [_nodes addObject:node];
    }
}

- (IBAction)didLongPress:(UILongPressGestureRecognizer *)sender
{
    [self setNeedsLayout];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            for (RGMNodeView *node in _nodes) {
                CGPoint point = [sender locationInView:node];
                if ([node pointInside:point withEvent:nil]) {
                    _heldNode = node;
                    [self bringSubviewToFront:node];
                    CGPoint pointOutside = [self convertPoint:point fromView:node];
                    _offset = CGPointMake(node.center.x - pointOutside.x, node.center.y - pointOutside.y);
                    break;
                }
            }
            
            if (_heldNode == nil) {
                return;
            }
            
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 _heldNode.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                 _heldNode.alpha = 0.75f;
                                 [self layoutIfNeeded];
                             }];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint pressLocation = [sender locationInView:self];
            CGPoint translation = CGPointMake(pressLocation.x - _heldNode.center.x + _offset.x,
                                              pressLocation.y - _heldNode.center.y + _offset.y);
            CGAffineTransform transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
            _heldNode.transform = CGAffineTransformScale(transform, 1.1, 1.1);
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 _heldNode.transform = CGAffineTransformIdentity;
                                 _heldNode.alpha = 1;
                                 [self layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 _heldNode = nil;
                             }];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 _heldNode.center = CGPointMake(CGRectGetMidX(_heldNode.frame), CGRectGetMidY(_heldNode.frame));
                                 _heldNode.transform = CGAffineTransformIdentity;
                                 _heldNode.alpha = 1;
                                 [self layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 _heldNode = nil;
                             }];
            break;
        }
        default:
            break;
    }
}

- (RGMNodeView *)nodeForIndex:(NSUInteger)idx
{
    return [_nodes objectAtIndex:idx];
}

#pragma mark - Public methods

- (void)insertNodeAtIndex:(NSUInteger)idx animated:(BOOL)animated
{
    RGMNodeView *node = [self.datasource graphView:self nodeForIndex:idx];
    node.delegate = self;
    node.center = self.center;
    [self addSubview:node];
    [_nodes addObject:node];
    
    NSParameterAssert([self.datasource graphViewNumberOfNodes:self] == _nodes.count);
    
    node.alpha = 0;
    node.transform = CGAffineTransformMakeScale(0, 0);
    
    [UIView animateWithDuration:animated ? 0.25f : 0
                     animations:^{
                         node.alpha = 1;
                         node.transform = CGAffineTransformIdentity;
                     }];
}

- (void)removeNodeAtIndex:(NSUInteger)idx animated:(BOOL)animated
{
    RGMNodeView *node = [_nodes objectAtIndex:idx];
    
    node.alpha = 1;
    node.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:animated ? 0.25f : 0
                     animations:^{
                         node.alpha = 0;
                         node.transform = CGAffineTransformMakeScale(0, 0);
                     }
                     completion:^(BOOL finished) {
                         [node removeFromSuperview];
                         [_nodes removeObjectAtIndex:idx];
                     }];
    
    NSParameterAssert([self.datasource graphViewNumberOfNodes:self] == _nodes.count);
}

- (void)batchUpdateGraph:(void (^)())updates completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:0.25f
                     animations:updates
                     completion:completion];
}

- (void)addConnectionFromNodeOutput:(NSIndexPath *)fromNodeOutputIndexPath toNodeInput:(NSIndexPath *)toNodeInputIndexPath
{
    RGMConnectionView *connectionView = [[RGMConnectionView alloc] initWithFromNodeInputIndexPath:fromNodeOutputIndexPath
                                                                             toNodeInputIndexPath:toNodeInputIndexPath];
    RGMNodeView *fromNode = [self nodeForIndex:fromNodeOutputIndexPath.node];
    RGMNodeView *toNode = [self nodeForIndex:toNodeInputIndexPath.node];
    
    fromNode.outputConnection = connectionView;
    toNode.inputConnection = connectionView;
    
    [self insertSubview:connectionView atIndex:0];
    [_connections addObject:connectionView];

    [self layoutIfNeeded];
}

#pragma mark - RGMNodeViewDelegate

- (void)nodeView:(RGMNodeView *)nodeView tappedSource:(RGMNodeSource)source index:(NSUInteger)idx
{
    // create popover
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Remove" // detect connection
                                              otherButtonTitles:@"input0", nil];

    [sheet showFromRect:nodeView.frame inView:self animated:YES];
}

@end
