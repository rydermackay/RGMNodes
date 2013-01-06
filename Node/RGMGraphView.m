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

@interface RGMGraphView () <RGMNodeViewDelegate, UIActionSheetDelegate>

@end

@implementation RGMGraphView {
    RGMNodeView *_heldNode;
    CGPoint _offset;
    NSMutableArray *_nodes;
    NSMutableArray *_connections;
    
    UIActionSheet *_connectionActionSheet;
    NSArray *_proposedConnections;
    RGMNodeSource _proposedConnectionSource;
    NSIndexPath *_proposedConnectionPort;
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
        [self requestNodeFromDatasourceAtIndex:i];
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

- (RGMNodeView *)requestNodeFromDatasourceAtIndex:(NSUInteger)idx
{
    RGMNodeView *node = [self.datasource graphView:self nodeForIndex:idx];
    node.delegate = self;
    [node sizeToFit];
    [_nodes addObject:node];
    [self addSubview:node];
    
    return node;
}

#pragma mark - Public methods

- (void)insertNodeAtIndex:(NSUInteger)idx animated:(BOOL)animated
{
    RGMNodeView *node = [self requestNodeFromDatasourceAtIndex:idx];
    node.center = self.center;
    
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
    
    [self insertSubview:connectionView atIndex:0];
    [_connections addObject:connectionView];

    [self layoutIfNeeded];
}

- (NSArray *)availableNodeSourcesForSource:(RGMNodeSource)source nodeSourceIndexPath:(NSIndexPath *)nodeSourceIndexPath
{
    // e.g. given node 1, sourcetype output, index 0, what are all the available inputs?
    
    // step 1. gather all ports of opposite type
    NSMutableArray *ports = [NSMutableArray new];
    [_nodes enumerateObjectsUsingBlock:^(RGMNodeView *node, NSUInteger idx, BOOL *stop) {
        NSArray *sourcePorts;
        switch (source) {
            case RGMNodeInput:
                sourcePorts = node.outputs;
                break;
            case RGMNodeOutput:
                sourcePorts = node.inputs;
                break;
            default:
                break;
        }
        
        for (int i = 0; i < sourcePorts.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForSource:i inNode:idx];
            [ports addObject:indexPath];
        }
    }];
    
    // step 2. prune
    for (RGMConnectionView *connection in _connections) {
        switch (source) {
            case RGMNodeInput:
                [ports removeObject:connection.fromNodeOutputIndexPath];
                break;
            case RGMNodeOutput:
                [ports removeObject:connection.toNodeInputIndexPath];
                break;
            default:
                break;
        }
    }
    
    return [ports copy];
}

- (BOOL)connectionExistsForNodeSourceIndexPath:(NSIndexPath *)nodeSourceIndexPath sourceType:(RGMNodeSource)sourceType
{
    for (RGMConnectionView *connection in _connections) {
        switch (sourceType) {
            case RGMNodeInput:
                if ([connection.toNodeInputIndexPath isEqual:nodeSourceIndexPath]) {
                    return YES;
                }
                break;
            case RGMNodeOutput:
                if ([connection.fromNodeOutputIndexPath isEqual:nodeSourceIndexPath]) {
                    return YES;
                }
                break;
            default:
                break;
        }
    }
    
    return NO;
}

- (void)removeConnectionFromNodeOutput:(NSIndexPath *)fromNodeOutputIndexPath toNodeInput:(NSIndexPath *)toNodeInputIndexPath
{
    RGMConnectionView *connection;
    for (RGMConnectionView *cnx in _connections) {
        if ([cnx.fromNodeOutputIndexPath isEqual:fromNodeOutputIndexPath] || [cnx.toNodeInputIndexPath isEqual:toNodeInputIndexPath]) {
            connection = cnx;
            break;
        }
    }
    
    [connection removeFromSuperview];
    [_connections removeObject:connection];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([_connectionActionSheet isEqual:actionSheet]) {
        
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        
        // remove existing connection
        if ([self connectionExistsForNodeSourceIndexPath:_proposedConnectionPort sourceType:_proposedConnectionSource]) {
            switch (_proposedConnectionSource) {
                case RGMNodeInput:
                    [self removeConnectionFromNodeOutput:nil toNodeInput:_proposedConnectionPort];
                    break;
                case RGMNodeOutput:
                    [self removeConnectionFromNodeOutput:_proposedConnectionPort toNodeInput:nil];
                    break;
                default:
                    break;
            }
            
            // if we only needed to disconnect we're done
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                return;
            }
        }
        
        // I hate UIActionSheet
        if (actionSheet.destructiveButtonIndex != -1) {
            buttonIndex--;
        }
        
        // create new connection
        NSIndexPath *destination = _proposedConnections[buttonIndex];
        switch (_proposedConnectionSource) {
            case RGMNodeInput:
                [self addConnectionFromNodeOutput:destination toNodeInput:_proposedConnectionPort];
                break;
            case RGMNodeOutput:
                [self addConnectionFromNodeOutput:_proposedConnectionPort toNodeInput:destination];
                break;
            default:
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _proposedConnectionPort = nil;
    _proposedConnections = nil;
    _proposedConnectionSource = 0;
    _connectionActionSheet = nil;
}

#pragma mark - RGMNodeViewDelegate

- (void)nodeView:(RGMNodeView *)nodeView tappedSource:(RGMNodeSource)source index:(NSUInteger)idx
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForSource:idx inNode:[_nodes indexOfObject:nodeView]];
    NSArray *ports = [self availableNodeSourcesForSource:source nodeSourceIndexPath:indexPath];
    BOOL connectionExistsAtPort = [self connectionExistsForNodeSourceIndexPath:indexPath sourceType:source];
    
    if (ports.count == 0 && connectionExistsAtPort == NO) {
        return;
    }
    
    NSMutableArray *strings = [NSMutableArray new];
    for (NSIndexPath *indexPath in ports) {
        RGMNodeView *node = [_nodes objectAtIndex:indexPath.node];
        NSString *name = (source == RGMNodeInput) ? node.outputs[indexPath.source] : node.inputs[indexPath.source];
        [strings addObject:[NSString stringWithFormat:@"%@: %@", node.title, name]];
    }
    
    // create popover
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    if (connectionExistsAtPort) {
        [sheet addButtonWithTitle:@"Disconnect"];
        sheet.destructiveButtonIndex = 0;
    }
    
    for (NSString *string in strings) {
        [sheet addButtonWithTitle:string];
    }
    
    CGRect rect = [self convertRect:[nodeView frameForSource:source index:idx] fromView:nodeView];
    
    [sheet showFromRect:rect inView:self animated:YES];
    
    _proposedConnectionSource = source;
    _proposedConnectionPort = indexPath;
    _proposedConnections = ports;
    _connectionActionSheet = sheet;
}

@end
