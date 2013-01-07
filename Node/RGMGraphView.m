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
#import "RGMAddress.h"

@interface RGMGraphView () <RGMNodeViewDelegate, UIActionSheetDelegate>

@end

@implementation RGMGraphView {
    RGMNodeView *_heldNode;
    CGPoint _offset;
    NSMutableArray *_nodes;
    NSMutableArray *_connections;
    
    UIActionSheet *_connectionActionSheet;
    NSArray *_possibleAddresses;
    RGMAddress *_selectedAddress;
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
        RGMNodeView *fromNode = [self nodeForIndex:connection.fromAddress.node];
        RGMNodeView *toNode = [self nodeForIndex:connection.toAddress.node];
        
        CGRect fromFrame = [self convertRect:[fromNode frameForSource:RGMNodeOutput index:connection.fromAddress.port]
                                    fromView:fromNode];
        CGRect toFrame = [self convertRect:[toNode frameForSource:RGMNodeInput index:connection.toAddress.port]
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

- (void)addConnectionFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress
{
    NSParameterAssert(fromAddress.source == RGMNodeOutput);
    NSParameterAssert(toAddress.source == RGMNodeInput);
    
    if ([self.delegate respondsToSelector:@selector(graphView:willConnectFromAddress:toAddress:)]) {
        [self.delegate graphView:self willConnectFromAddress:fromAddress toAddress:toAddress];
    }
    
    RGMConnectionView *connectionView = [[RGMConnectionView alloc] initWithFromAddress:fromAddress toAddress:toAddress];
    
    [self insertSubview:connectionView atIndex:0];
    [_connections addObject:connectionView];

    [self layoutIfNeeded];
    
    if ([self.delegate respondsToSelector:@selector(graphView:didConnectFromAddress:toAddress:)]) {
        [self.delegate graphView:self didConnectFromAddress:fromAddress toAddress:toAddress];
    }
}

- (NSArray *)availableAddressesForAddress:(RGMAddress *)address
{
    // e.g. given node 1, sourcetype output, index 0, what are all the available inputs?
    
    // step 1. gather all ports of opposite type
    NSMutableArray *ports = [NSMutableArray new];
    __block RGMNodeSource destinationSource;
    
    [_nodes enumerateObjectsUsingBlock:^(RGMNodeView *node, NSUInteger idx, BOOL *stop) {
        
        // disallow connections to self
        if (address.node == idx) {
            return;
        }
        
        NSArray *sourcePorts;
        switch (address.source) {
            case RGMNodeInput:
                sourcePorts = node.outputs;
                destinationSource = RGMNodeOutput;
                break;
            case RGMNodeOutput:
                sourcePorts = node.inputs;
                destinationSource = RGMNodeInput;
                break;
            default:
                break;
        }
        
        for (int i = 0; i < sourcePorts.count; i++) {
            RGMAddress *destination = [RGMAddress addressWithNode:idx source:destinationSource port:i];
            
            if ([self.delegate respondsToSelector:@selector(graphView:canConnectFromAddress:toAddress:)]) {
                if ([self.delegate graphView:self canConnectFromAddress:address toAddress:destination] == NO) {
                    continue;
                }
            }

            [ports addObject:destination];
        }
    }];
    
    // step 2. prune
    for (RGMConnectionView *connection in _connections) {
        switch (address.source) {
            case RGMNodeInput:
                [ports removeObject:connection.fromAddress];
                break;
            case RGMNodeOutput:
                [ports removeObject:connection.toAddress];
                break;
            default:
                break;
        }
    }
    
    return [ports copy];
}

- (BOOL)connectionExistsForAddress:(RGMAddress *)address
{
    for (RGMConnectionView *connection in _connections) {
        switch (address.source) {
            case RGMNodeInput:
                if ([connection.toAddress isEqual:address]) {
                    return YES;
                }
                break;
            case RGMNodeOutput:
                if ([connection.fromAddress isEqual:address]) {
                    return YES;
                }
                break;
            default:
                break;
        }
    }
    
    return NO;
}

- (void)removeAllConnectionsFromNode:(NSUInteger)node
{
    for (RGMConnectionView *cnx in _connections.copy) {
        if (cnx.toAddress.node == node) {
            [self removeConnectionFromAddress:nil toAddress:cnx.toAddress];
        } else if (cnx.fromAddress.node == node) {
            [self removeConnectionFromAddress:cnx.fromAddress toAddress:nil];
        }
    }
}

- (void)removeConnectionFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress
{
    if ([self.delegate respondsToSelector:@selector(graphView:willDisconnectFromAddress:toAddress:)]) {
        [self.delegate graphView:self willDisconnectFromAddress:fromAddress toAddress:toAddress];
    }
    
    RGMConnectionView *connection;
    for (RGMConnectionView *cnx in _connections) {
        if ([cnx.fromAddress isEqual:fromAddress] || [cnx.toAddress isEqual:toAddress]) {
            connection = cnx;
            break;
        }
    }
    
    [connection removeFromSuperview];
    [_connections removeObject:connection];
    
    if ([self.delegate respondsToSelector:@selector(graphView:didDisconnectFromAddress:toAddress:)]) {
        [self.delegate graphView:self didDisconnectFromAddress:fromAddress toAddress:toAddress];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([_connectionActionSheet isEqual:actionSheet]) {
        
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        
        // remove existing connection
        if ([self connectionExistsForAddress:_selectedAddress]) {
            switch (_selectedAddress.source) {
                case RGMNodeInput:
                    [self removeConnectionFromAddress:nil toAddress:_selectedAddress];
                    break;
                case RGMNodeOutput:
                    [self removeConnectionFromAddress:_selectedAddress toAddress:nil];
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
        RGMAddress *address = _possibleAddresses[buttonIndex];
        switch (_selectedAddress.source) {
            case RGMNodeInput:
                [self addConnectionFromAddress:address toAddress:_selectedAddress];
                break;
            case RGMNodeOutput:
                [self addConnectionFromAddress:_selectedAddress toAddress:address];
                break;
            default:
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _selectedAddress = nil;
    _possibleAddresses = nil;
    _connectionActionSheet = nil;
}

#pragma mark - RGMNodeViewDelegate

- (void)nodeView:(RGMNodeView *)nodeView tappedSource:(RGMNodeSource)source index:(NSUInteger)idx
{
    RGMAddress *address = [RGMAddress addressWithNode:[_nodes indexOfObject:nodeView] source:source port:idx];
    NSArray *addresses = [self availableAddressesForAddress:address];
    BOOL canDisconnect = [self connectionExistsForAddress:address];
    
    if (canDisconnect && [self.delegate respondsToSelector:@selector(graphView:canDisconnectFromAddress:toAddress:)]) {
        canDisconnect = [self.delegate graphView:self
                        canDisconnectFromAddress:address.source == RGMNodeOutput ? address : nil
                                       toAddress:address.source == RGMNodeInput ? address : nil];
    }
    
    if (addresses.count == 0 && canDisconnect == NO) {
        return;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    NSMutableArray *strings = [NSMutableArray new];
    for (RGMAddress *adr in addresses) {
        RGMNodeView *node = [_nodes objectAtIndex:adr.node];
        NSString *name = (source == RGMNodeInput) ? node.outputs[adr.port] : node.inputs[adr.port];
        [strings addObject:[NSString stringWithFormat:@"%@: %@", node.title, name]];
    }
    
    if (canDisconnect) {
        [sheet addButtonWithTitle:@"Disconnect"];
        sheet.destructiveButtonIndex = 0;
    }
    
    for (NSString *string in strings) {
        [sheet addButtonWithTitle:string];
    }
    
    CGRect rect = [self convertRect:[nodeView frameForSource:source index:idx] fromView:nodeView];
    
    [sheet showFromRect:rect inView:self animated:YES];
    
    _selectedAddress = address;
    _possibleAddresses = addresses;
    _connectionActionSheet = sheet;
}

@end
