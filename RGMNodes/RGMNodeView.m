//
//  RGMNodeView.m
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMNodeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RGMNodeView {
    UILabel *_titleLabel;
    NSMutableArray *_inputControls;
    NSMutableArray *_outputControls;
}

static CGFloat kRowHeight = 44.0f;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.layer.cornerRadius = 5;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor yellowColor];
    self.clipsToBounds = YES;
    _inputControls = [NSMutableArray new];
    _outputControls = [NSMutableArray new];
}

- (void)setTitle:(NSString *)title
{
    if ([_title isEqualToString:title]) {
        return;
    }
    
    _title = [title copy];
    
    [self reloadData];
}

- (void)setInputs:(NSArray *)inputs
{
    if ([_inputs isEqualToArray:inputs]) {
        return;
    }
    
    _inputs = [inputs copy];
    
    [self reloadData];
}

- (void)setOutputs:(NSArray *)outputs
{
    if ([_outputs isEqualToArray:outputs]) {
        return;
    }
    
    _outputs = [outputs copy];
    
    [self reloadData];
}

- (void)removeInOutControls
{
    for (UIView *control in _inputControls) {
        [control removeFromSuperview];
    }
    [_inputControls removeAllObjects];
    
    for (UIView *control in _outputControls) {
        [control removeFromSuperview];
    }
    [_outputControls removeAllObjects];
}

- (void)setupControlsWithSource:(NSArray *)source storage:(NSMutableArray *)storage
{
    for (NSString *string in source) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:string forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(sourceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.titleLabel.minimumScaleFactor = 0.5;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:button];
        [storage addObject:button];
    }
}

- (IBAction)sourceButtonTapped:(UIButton *)sender
{
    NSParameterAssert([_inputControls containsObject:sender] || [_outputControls containsObject:sender]);
    
    NSUInteger idx = NSNotFound;
    RGMNodeSource source = RGMNodeUnknown;
    
    if ([_inputControls containsObject:sender]) {
        idx = [_inputControls indexOfObject:sender];
        source = RGMNodeInput;
    }
    else if ([_outputControls containsObject:sender]) {
        idx = [_outputControls indexOfObject:sender];
        source = RGMNodeOutput;
    }
    
    [self.delegate nodeView:self tappedSource:source index:idx];
}

- (void)reloadData
{
    [self removeInOutControls];
    
    if (self.title.length > 0) {
        if (_titleLabel == nil) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _titleLabel.backgroundColor = [UIColor blackColor];
            _titleLabel.opaque = YES;
            _titleLabel.textColor = [UIColor yellowColor];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.font = [UIFont boldSystemFontOfSize:17];
            [self addSubview:_titleLabel];
        }
        _titleLabel.text = self.title;
    }
    else {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }
    
    [self setupControlsWithSource:self.inputs storage:_inputControls];
    [self setupControlsWithSource:self.outputs storage:_outputControls];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    _titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), kRowHeight);
    
    [_inputControls enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.frame = [self frameForSource:RGMNodeInput index:idx];
    }];
    
    [_outputControls enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.frame = [self frameForSource:RGMNodeOutput index:idx];
    }];
}

- (CGRect)frameForSource:(RGMNodeSource)source index:(NSUInteger)idx
{
    NSParameterAssert((source == RGMNodeInput && idx < _inputs.count) ||
                      source == RGMNodeOutput && idx < _outputs.count);
    
    CGFloat inset = CGRectGetMaxY(_titleLabel.frame);
    CGRect bounds = [self bounds];
    
    CGRect frame = CGRectMake(0,
                              inset + idx * kRowHeight,
                              floorf(CGRectGetWidth(bounds) * 0.5f),
                              kRowHeight);
    
    if (source == RGMNodeOutput) {
        frame.origin.x = floorf(CGRectGetWidth(bounds) * 0.5f);
    }
    
    return frame;
}

- (CGSize)sizeThatFits:(__unused CGSize)size
{
    CGFloat inputHeight = self.inputs.count * kRowHeight;
    CGFloat outputHeight = self.outputs.count * kRowHeight;
    CGFloat maxHeight = MAX(inputHeight, outputHeight);
    
    if (self.title.length > 0) {
        maxHeight += kRowHeight;
    }
    
    const CGFloat minWidth = 200;
    CGFloat width = floorf([self.title sizeWithFont:_titleLabel.font].width) + 20;
    width = MAX(width, minWidth);
    
    return CGSizeMake(width, maxHeight);
}

@end
