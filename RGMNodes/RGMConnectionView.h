//
//  RGMConnectionView.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RGMConnection;

@interface RGMConnectionView : UIView

- (id)initWithConnection:(RGMConnection *)connection;

@property (nonatomic, readonly) RGMConnection *connection;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@end
