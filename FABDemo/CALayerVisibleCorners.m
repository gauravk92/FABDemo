//
//  CALayerVisibleCorners.m
//  FABDemo
//
//  Created by Gaurav Khanna on 5/3/15.
//  Copyright (c) 2015 Gaurav Khanna. All rights reserved.
//

#import "CALayerVisibleCorners.h"

@implementation CALayerVisibleCorners

@end



@interface CGCorners : NSObject {
    CGPoint bottomLeft;
    CGPoint bottomRight;
    CGPoint topRight;
    CGPoint topLeft;
}
@end

@implementation CGCorners

struct A3DPoint {
    CGFloat x;
    CGFloat y;
    CGFloat z;
    CGFloat w;
};
typedef struct A3DPoint A3DPoint;

union CG3DPoint {
    struct A3DPoint tdp;
    struct CGPoint cgp;
};
typedef union CG3DPoint CG3DPoint;

CG3DPoint CGPointTo3DPoint(CGPoint aCGpoint) {
    CG3DPoint point = {0};
    point.tdp.z = 0;
    point.tdp.w = 1;
    point.cgp = aCGpoint;
    return point;
}

- (id) initWithCGRect:(CGRect)frame {
    self = [super init];
    if (self != nil) {
        bottomLeft = frame.origin;
        
        bottomRight = frame.origin;
        bottomRight.x += frame.size.width;
        
        topRight = frame.origin;
        topRight.x += frame.size.width;
        topRight.y += frame.size.height;
        
        topLeft = frame.origin;
        topLeft.y += frame.size.height;
    }
    return self;
}

- (CG3DPoint) perspectiveTransform:(CATransform3D)trans point: (CG3DPoint)p {
    CG3DPoint q = {0};
    q.tdp.w = p.tdp.x * trans.m14 + p.tdp.y * trans.m24 + p.tdp.z * trans.m34 + trans.m44;
    q.tdp.x = (p.tdp.x * trans.m11 + p.tdp.y * trans.m21 + p.tdp.z * trans.m31 + p.tdp.w * trans.m41) / q.tdp.w;
    q.tdp.y = (p.tdp.x * trans.m12 + p.tdp.y * trans.m22 + p.tdp.z * trans.m32 + p.tdp.w * trans.m42) / q.tdp.w;
    q.tdp.z = (p.tdp.w * trans.m13 + p.tdp.y * trans.m23 + p.tdp.z * trans.m33 + p.tdp.w * trans.m43) / q.tdp.w;
    return q;
}

- (CATransform3D) mapChildToParent:(CALayer*)child {
    float zPosition = 0;
    CGPoint position = child.position;
    
    CGPoint childAnchor = [child anchorPosition];
    CATransform3D m = CATransform3DMakeTranslation(-childAnchor.x, - childAnchor.y, 0);
    m = CATransform3DConcat(m, child.transform);
    m = CATransform3DConcat(m, CATransform3DMakeTranslation(position.x, position.y, zPosition));
    
    if(child.superlayer) {
        CGPoint anchor = [child.superlayer anchorPosition];
        m = CATransform3DConcat(m, CATransform3DMakeTranslation(-anchor.x, - anchor.y, 0));
        m = CATransform3DConcat(m, child.superlayer.sublayerTransform);
        m = CATransform3DConcat(m, CATransform3DMakeTranslation(anchor.x, anchor.y, 0));
    }
    return m;
}

- (void) apply3DTransform:(CATransform3D)threeDTransform zPosition: (float)zPosition {
    bottomLeft = [self perspectiveTransform:threeDTransform point:CGPointTo3DPoint(bottomLeft)].cgp;
    bottomRight = [self perspectiveTransform:threeDTransform point:CGPointTo3DPoint(bottomRight)].cgp;
    topRight = [self perspectiveTransform:threeDTransform point:CGPointTo3DPoint(topRight)].cgp;
    topLeft = [self perspectiveTransform:threeDTransform point:CGPointTo3DPoint(topLeft)].cgp;
}

- (void) apply3DStartingFrom:(CALayer*)layer {
    CALayer *start = layer;
    CATransform3D transform = CATransform3DIdentity;
    while(start) {
        transform = [self mapChildToParent:start];
        [self apply3DTransform:transform zPosition:0];
        start = start.superlayer;
    }
}

- (CGCorners*) visibleCorners {
    // Rotate, translate and scale through all layers
    CGCorners *corners = [[CGCorners alloc] initWithCGRect:self.bounds];
    [corners applyAllLayerTransforms:self];
    return corners;
}