//
//  RGMGeometry.h
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#ifndef Node_RGMGeometry_h
#define Node_RGMGeometry_h

static inline CGPoint CGPointMidPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5f, (p1.y + p2.y) * 0.5f);
}

static inline CGPoint CGPointByApplyingTranslation(CGPoint p1, CGPoint translation) {
    return CGPointMake(p1.x + translation.x, p1.y + translation.y);
}

#endif
