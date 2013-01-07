//
//  RGMNodeViewController.m
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMNodeViewController.h"
#import "RGMNodeDefines.h"
#import "RGMGraphView.h"
#import "RGMNodeView.h"
#import "NSIndexPath+RGMNodeSource.h"
#import "RGMAddress.h"

@interface RGMNodeViewController () <RGMGraphViewDatasource, RGMGraphViewDelegate>
- (IBAction)add:(id)sender;
@property (nonatomic, strong) RGMGraphView *graphView;
@end

@implementation RGMNodeViewController {
    NSMutableArray *_nodes;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _nodes = [NSMutableArray new];
        [_nodes addObject:@{
             @"title" : @"Sine Generator",
             @"outputs" : @[@"Output 0"],
         }];
        [_nodes addObject:@{
             @"title" : @"Remote IO Unit",
             @"inputs" : @[@"Input 0", @"Input 1"],
             @"outputs" : @[@"Output 0", @"Output 1"],
         }];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSParameterAssert([self.view isKindOfClass:[RGMGraphView class]]);
    self.graphView = (RGMGraphView *)self.view;
    
    [self.graphView addConnectionFromAddress:[RGMAddress addressWithNode:0 source:RGMNodeOutput port:0]
                                   toAddress:[RGMAddress addressWithNode:1 source:RGMNodeInput port:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RGMGraphViewDelegate

- (BOOL)graphView:(RGMGraphView *)graphView canConnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress
{
    return YES;
}

- (void)graphView:(RGMGraphView *)graphView willConnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress
{
    
}

- (void)graphView:(RGMGraphView *)graphView didConnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress
{
    
}

- (BOOL)graphView:(RGMGraphView *)graphView canDisconnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress
{
    return YES;
}

- (void)graphView:(RGMGraphView *)graphView willDisconnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress
{
    
}

- (void)graphView:(RGMGraphView *)graphView didDisconnectFromAddress:(RGMAddress *)fromAddress toAddress:(RGMAddress *)toAddress
{
    
}

#pragma mark - RGMGraphViewDatasource

- (NSUInteger)graphViewNumberOfNodes:(RGMGraphView *)graphView
{
    return _nodes.count;
}

- (RGMNodeView *)graphView:(RGMGraphView *)graphView nodeForIndex:(NSUInteger)idx
{
    RGMNodeView *node = [[RGMNodeView alloc] init];
    [self configureNode:node forIndex:idx];

    return node;
}

- (void)configureNode:(RGMNodeView *)node forIndex:(NSUInteger)idx
{
    [node setValuesForKeysWithDictionary:[_nodes objectAtIndex:idx]];
}

#pragma mark - IBActions

- (IBAction)add:(id)sender
{
    [_nodes insertObject:@{
         @"title" : @"Generic IO",
         @"inputs" : @[@"Input 0"],
         @"outputs" : @[@"Output 0"],
     }
                 atIndex:0];
    [self.graphView insertNodeAtIndex:0 animated:YES];
}

@end
