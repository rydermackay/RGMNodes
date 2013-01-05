//
//  NSIndexPath+RGMNodeSource.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (RGMNodeSource)

// synonyms for section and row

+ (NSIndexPath *)indexPathForSource:(NSInteger)source inNode:(NSInteger)node;

- (NSInteger)node;
- (NSInteger)source;

@end
