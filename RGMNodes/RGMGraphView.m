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
#import "RGMAddress.h"
#import "RGMConnection.h"

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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_nodes == nil) {
        [self reloadData];
    }
    
    for (RGMConnectionView *connectionView in _connections) {
        
        RGMConnection *connection = connectionView.connection;
        RGMNodeView *fromNode = [self nodeForIndex:connection.fromAddress.node];
        RGMNodeView *toNode = [self nodeForIndex:connection.toAddress.node];
        
        CGRect fromFrame = [self convertRect:[fromNode frameForSource:RGMNodeOutput index:connection.fromAddress.port]
                                    fromView:fromNode];
        CGRect toFrame = [self convertRect:[toNode frameForSource:RGMNodeInput index:connection.toAddress.port]
                                  fromView:toNode];
        
        CGFloat minY = MIN(CGRectGetMinY(fromFrame), CGRectGetMinY(toFrame));
        CGFloat maxY = MAX(CGRectGetMaxY(fromFrame), CGRectGetMaxY(toFrame));
        connectionView.frame = CGRectMake(CGRectGetMaxX(fromFrame),
                                      minY,
                                      CGRectGetMinX(toFrame) - CGRectGetMaxX(fromFrame),
                                      maxY - minY);
        
        connectionView.startPoint = [self convertPoint:CGPointMake(CGRectGetMaxX(fromFrame), CGRectGetMidY(fromFrame))
                                            toView:connectionView];
        connectionView.endPoint = [self convertPoint:CGPointMake(CGRectGetMinX(toFrame), CGRectGetMidY(toFrame))
                                          toView:connectionView];
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

- (void)addConnection:(RGMConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(graphView:willConnect:)]) {
        [self.delegate graphView:self willConnect:connection];
    }
    
    RGMConnectionView *connectionView = [[RGMConnectionView alloc] initWithConnection:connection];
    
    [self insertSubview:connectionView atIndex:0];
    [_connections addObject:connectionView];

    [self layoutIfNeeded];
    
    if ([self.delegate respondsToSelector:@selector(graphView:didConnect:)]) {
        [self.delegate graphView:self didConnect:connection];
    }
}

- (NSArray *)availableAddressesForAddress:(RGMAddress *)address
{
    NSArray *nodePorts;
    RGMNodeSource destinationSource;
    
    // TODO: find better name for "source" on node. confusing when describing connections w/ source & destination!!
    
    switch (address.source) {
        case RGMNodeInput:
            nodePorts = [_nodes valueForKey:@"outputs"];
            destinationSource = RGMNodeOutput;
            break;
        case RGMNodeOutput:
            nodePorts = [_nodes valueForKey:@"inputs"];
            destinationSource = RGMNodeInput;
            break;
        default:
            break;
    }
    
    NSMutableArray *addresses = [NSMutableArray new];
    
    [nodePorts enumerateObjectsUsingBlock:^(NSArray *ports, NSUInteger nodeIndex, BOOL *stop) {
        
        // some nodes have no inputs/outputs
        if ([ports isEqual:[NSNull null]]) {
            return;
        }
        
        // disallow connections to self
        if (address.node == nodeIndex) {
            return;
        }
        
        NSArray *existingConnections = [_connections valueForKey:@"connection"];
        
        [ports enumerateObjectsUsingBlock:^(id obj, NSUInteger portIndex, BOOL *stop) {
            RGMAddress *destination = [RGMAddress addressWithNode:nodeIndex source:destinationSource port:portIndex];
            RGMConnection *connection;
            switch (address.source) {
                case RGMNodeInput:
                    connection = [RGMConnection connectionFrom:destination to:address];
                    break;
                case RGMNodeOutput:
                    connection = [RGMConnection connectionFrom:address to:destination];
                    break;
                default:
                    break;
            }
            
            if ([existingConnections containsObject:connection]) {
                return;
            }
            
            BOOL canConnect = YES;
            
            if ([self.delegate respondsToSelector:@selector(graphView:canConnect:)]) {
                canConnect = [self.delegate graphView:self canConnect:connection];
            }
            
            if (canConnect) {
                [addresses addObject:destination];
            }
        }];
    }];
    
    return [addresses copy];
}

- (RGMConnection *)connectionForAddress:(RGMAddress *)address
{
    for (RGMConnection *connection in [_connections valueForKey:@"connection"]) {
        switch (address.source) {
            case RGMNodeInput:
                if ([connection.toAddress isEqual:address]) {
                    return connection;
                }
                break;
            case RGMNodeOutput:
                if ([connection.fromAddress isEqual:address]) {
                    return connection;
                }
                break;
            default:
                break;
        }
    }
    
    return nil;
}

- (void)removeAllConnectionsFromNode:(NSUInteger)node
{
    for (RGMConnection *connection in [_connections valueForKey:@"connection"]) {
        if (connection.fromAddress.node == node || connection.toAddress.node == node) {
            [self removeConnection:connection];
        }
    }
}

- (void)removeConnection:(RGMConnection *)connection
{
    if (connection == nil) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(graphView:willDisconnect:)]) {
        [self.delegate graphView:self willDisconnect:connection];
    }
    
    RGMConnectionView *connectionView;
    for (RGMConnectionView *cnx in _connections) {
        if ([cnx.connection isEqual:connection]) {
            connectionView = cnx;
            break;
        }
    }
    
    [connectionView removeFromSuperview];
    [_connections removeObject:connectionView];
    
    if ([self.delegate respondsToSelector:@selector(graphView:didDisconnect:)]) {
        [self.delegate graphView:self didDisconnect:connection];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([_connectionActionSheet isEqual:actionSheet]) {
        
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        
        [self removeConnection:[self connectionForAddress:_selectedAddress]];
        
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            return;
        }
        
        // I hate UIActionSheet
        if (actionSheet.destructiveButtonIndex != -1) {
            buttonIndex--;
        }
        
        RGMAddress *address = _possibleAddresses[buttonIndex];
        [self removeConnection:[self connectionForAddress:address]];
        
        // create new connection
        switch (_selectedAddress.source) {
            case RGMNodeInput:
                [self addConnection:[RGMConnection connectionFrom:address to:_selectedAddress]];
                break;
            case RGMNodeOutput:
                [self addConnection:[RGMConnection connectionFrom:_selectedAddress to:address]];
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
    RGMConnection *existingConnection = [self connectionForAddress:address];
    BOOL canDisconnect = existingConnection != nil;
    
    if (canDisconnect && [self.delegate respondsToSelector:@selector(graphView:canDisconnect:)]) {
        canDisconnect = [self.delegate graphView:self canDisconnect:existingConnection];
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
