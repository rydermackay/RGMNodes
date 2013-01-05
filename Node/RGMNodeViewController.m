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

@interface RGMNodeViewController () <RGMGraphViewDatasource, RGMGraphViewDelegate>
- (IBAction)add:(id)sender;
@property (nonatomic, strong) RGMGraphView *graphView;
@end

@implementation RGMNodeViewController {
    NSUInteger _nodeCount;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _nodeCount = 2;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSParameterAssert([self.view isKindOfClass:[RGMGraphView class]]);
    self.graphView = (RGMGraphView *)self.view;
    
    [self.graphView addConnectionFromNodeOutput:[NSIndexPath indexPathForSource:0 inNode:0]
                                    toNodeInput:[NSIndexPath indexPathForSource:1 inNode:1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RGMGraphiViewDatasource

- (NSUInteger)graphViewNumberOfNodes:(RGMGraphView *)graphView
{
    return _nodeCount;
}

- (RGMNodeView *)graphView:(RGMGraphView *)graphView nodeForIndex:(NSUInteger)idx
{
    RGMNodeView *node = [[RGMNodeView alloc] init];
    [self configureNode:node forIndex:idx];

    return node;
}

- (void)configureNode:(RGMNodeView *)node forIndex:(NSUInteger)idx
{
    switch (idx) {
        case 0:
            node.title = @"Sine Generator";
            node.outputs = @[@"Output 0"];
            node.center = CGPointMake(100, 100);
            node.frame = CGRectIntegral(node.frame);
            [node sizeToFit];
            break;
        default:
            node.title = @"Remote IO Unit";
            node.inputs = @[@"Input 0", @"Input 1"];
            node.outputs = @[@"Output 0", @"Output 1"];
            node.center = CGPointMake(600, 300);
            node.frame = CGRectIntegral(node.frame);
            [node sizeToFit];
            break;
    }
}

#pragma mark - IBActions

- (IBAction)add:(id)sender
{
    _nodeCount++;
    [self.graphView insertNodeAtIndex:0 animated:YES];
}

@end
