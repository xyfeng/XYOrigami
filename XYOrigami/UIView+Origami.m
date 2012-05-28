//
//  UIView+Origami.m
//  origami
//
//  Created by XY Feng on 4/6/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "UIView+Origami.h"

KeyframeParametricBlock openFunction = ^double(double time) {
    return sin(time*M_PI_2);
};
KeyframeParametricBlock closeFunction = ^double(double time) {
    return -cos(time*M_PI_2)+1;
};

static XYOrigamiTransitionState XY_Origami_Current_State = XYOrigamiTransitionStateIdle;

@implementation CAKeyframeAnimation (Parametric)

+ (id)animationWithKeyPath:(NSString *)path function:(KeyframeParametricBlock)block fromValue:(double)fromValue toValue:(double)toValue 
{
    // get a keyframe animation to set up
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
    // break the time into steps (the more steps, the smoother the animation)
    NSUInteger steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double time = 0.0;
    double timeStep = 1.0 / (double)(steps - 1);
    for(NSUInteger i = 0; i < steps; i++) {
        double value = fromValue + (block(time) * (toValue - fromValue));
        [values addObject:[NSNumber numberWithDouble:value]];
        time += timeStep;
    }
    // we want linear animation between keyframes, with equal time steps
    animation.calculationMode = kCAAnimationLinear;
    // set keyframes and we're done
    [animation setValues:values];
    return(animation);
}

@end

@implementation UIView (Origami)

- (CATransformLayer *)transformLayerFromImage:(UIImage *)image Frame:(CGRect)frame Duration:(CGFloat)duration AnchorPiont:(CGPoint)anchorPoint StartAngle:(double)start EndAngle:(double)end;
{
    CATransformLayer *jointLayer = [CATransformLayer layer];
    jointLayer.anchorPoint = anchorPoint;
    CGFloat layerWidth;
    if (anchorPoint.x == 0) //from left to right
    {
        layerWidth = image.size.width - frame.origin.x;
        jointLayer.frame = CGRectMake(0, 0, layerWidth, frame.size.height);
        if (frame.origin.x) {
            jointLayer.position = CGPointMake(frame.size.width, frame.size.height/2);
        }
        else {
            jointLayer.position = CGPointMake(0, frame.size.height/2);
        }
    }
    else { //from right to left
        layerWidth = frame.origin.x + frame.size.width;
        jointLayer.frame = CGRectMake(0, 0, layerWidth, frame.size.height);
        jointLayer.position = CGPointMake(layerWidth, frame.size.height/2);
    }

    //map image onto transform layer
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    imageLayer.anchorPoint = anchorPoint;
    imageLayer.position = CGPointMake(layerWidth*anchorPoint.x, frame.size.height/2);
    [jointLayer addSublayer:imageLayer];
    CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
    imageLayer.contents = (__bridge id)imageCrop;
    imageLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    //add shadow
    NSInteger index = frame.origin.x/frame.size.width;
    double shadowAniOpacity;
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    shadowLayer.frame = imageLayer.bounds;
    shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.opacity = 0.0;
    shadowLayer.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    if (index%2) {
        shadowLayer.startPoint = CGPointMake(0, 0.5);
        shadowLayer.endPoint = CGPointMake(1, 0.5);
        shadowAniOpacity = (anchorPoint.x)?0.24:0.32;
    }
    else {
        shadowLayer.startPoint = CGPointMake(1, 0.5);
        shadowLayer.endPoint = CGPointMake(0, 0.5);
        shadowAniOpacity = (anchorPoint.x)?0.32:0.24;
    }
    [imageLayer addSublayer:shadowLayer];
    
    //animate open/close animation
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:start]];
    [animation setToValue:[NSNumber numberWithDouble:end]];
    [animation setRemovedOnCompletion:NO];
    [jointLayer addAnimation:animation forKey:@"jointAnimation"];
    
    //animate shadow opacity
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:(start)?shadowAniOpacity:0]];
    [animation setToValue:[NSNumber numberWithDouble:(start)?0:shadowAniOpacity]];
    [animation setRemovedOnCompletion:NO];
    [shadowLayer addAnimation:animation forKey:nil];
    
    return jointLayer;
}

- (void)showOrigamiTransitionWith:(UIView *)view 
                    NumberOfFolds:(NSInteger)folds 
                         Duration:(CGFloat)duration
                        Direction:(XYOrigamiDirection)direction
                       completion:(void (^)(BOOL finished))completion
{
    if (XY_Origami_Current_State != XYOrigamiTransitionStateIdle) {
        return;
    }
    XY_Origami_Current_State = XYOrigamiTransitionStateUpdate;
    
    //add view as parent subview
    if (![view superview]) {
        [[self superview] insertSubview:view belowSubview:self];
    }
    //set frame
    CGRect selfFrame = self.frame;
    CGPoint anchorPoint;
    if (direction == XYOrigamiDirectionFromRight) {
        selfFrame.origin.x = self.frame.origin.x - view.bounds.size.width;
        view.frame = CGRectMake(self.frame.origin.x+self.frame.size.width-view.frame.size.width, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
        
        anchorPoint = CGPointMake(1, 0.5);
    }
    else {
        selfFrame.origin.x = self.frame.origin.x + view.bounds.size.width;
        view.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
        
        anchorPoint = CGPointMake(0, 0.5);
    }
    
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //set 3D depth
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/800.0;
    CALayer *origamiLayer = [CALayer layer];
    origamiLayer.frame = view.bounds;
    origamiLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    origamiLayer.sublayerTransform = transform;
    [view.layer addSublayer:origamiLayer];
    
    //setup rotation angle
    double startAngle;
    CGFloat frameWidth = view.bounds.size.width;
    CGFloat frameHeight = view.bounds.size.height;
    CGFloat foldWidth = frameWidth/(folds*2);
    CALayer *prevLayer = origamiLayer;
    for (int b=0; b < folds*2; b++) {
        CGRect imageFrame;
        if (direction == XYOrigamiDirectionFromRight) {
            if(b == 0)
                startAngle = -M_PI_2;
            else {
                if (b%2)
                    startAngle = M_PI;
                else
                    startAngle = -M_PI;
            }
            imageFrame = CGRectMake(frameWidth-(b+1)*foldWidth, 0, foldWidth, frameHeight);
        }
        else {
            if(b == 0)
                startAngle = M_PI_2;
            else {
                if (b%2)
                    startAngle = -M_PI;
                else
                    startAngle = M_PI;
            }
            imageFrame = CGRectMake(b*foldWidth, 0, foldWidth, frameHeight);
        }
        CATransformLayer *transLayer = [self transformLayerFromImage:viewSnapShot Frame:imageFrame Duration:duration AnchorPiont:anchorPoint StartAngle:startAngle EndAngle:0];
        [prevLayer addSublayer:transLayer];
        prevLayer = transLayer;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.frame = selfFrame;
        [origamiLayer removeFromSuperlayer];
        XY_Origami_Current_State = XYOrigamiTransitionStateShow;
        
		if (completion)
			completion(YES);
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    CAAnimation *openAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x" function:openFunction fromValue:self.frame.origin.x+self.frame.size.width/2 toValue:selfFrame.origin.x+self.frame.size.width/2];
    openAnimation.fillMode = kCAFillModeForwards;
    [openAnimation setRemovedOnCompletion:NO];
    [self.layer addAnimation:openAnimation forKey:@"position"];
    [CATransaction commit];
}


- (void)hideOrigamiTransitionWith:(UIView *)view
                    NumberOfFolds:(NSInteger)folds
                         Duration:(CGFloat)duration
                        Direction:(XYOrigamiDirection)direction
                       completion:(void (^)(BOOL finished))completion
{
    if (XY_Origami_Current_State != XYOrigamiTransitionStateShow) {
        return;
    }
    
    XY_Origami_Current_State = XYOrigamiTransitionStateUpdate;
    
    //set frame
    CGRect selfFrame = self.frame;
    CGPoint anchorPoint;
    if (direction == XYOrigamiDirectionFromRight) {
        selfFrame.origin.x = self.frame.origin.x + view.bounds.size.width;
        anchorPoint = CGPointMake(1, 0.5);
    }
    else {
        selfFrame.origin.x = self.frame.origin.x - view.bounds.size.width;
        anchorPoint = CGPointMake(0, 0.5);
    }
    
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //set 3D depth
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/800.0;
    CALayer *origamiLayer = [CALayer layer];
    origamiLayer.frame = view.bounds;
    origamiLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    origamiLayer.sublayerTransform = transform;
    [view.layer addSublayer:origamiLayer];
    
    //setup rotation angle
    double endAngle;
    CGFloat frameWidth = view.bounds.size.width;
    CGFloat frameHeight = view.bounds.size.height;
    CGFloat foldWidth = frameWidth/(folds*2);
    CALayer *prevLayer = origamiLayer;
    for (int b=0; b < folds*2; b++) {
        CGRect imageFrame;
        if (direction == XYOrigamiDirectionFromRight) {
            if(b == 0)
                endAngle = -M_PI_2;
            else {
                if (b%2)
                    endAngle = M_PI;
                else
                    endAngle = -M_PI;
            }
            imageFrame = CGRectMake(frameWidth-(b+1)*foldWidth, 0, foldWidth, frameHeight);
        }
        else {
            if(b == 0)
                endAngle = M_PI_2;
            else {
                if (b%2)
                    endAngle = -M_PI;
                else
                    endAngle = M_PI;
            }
            imageFrame = CGRectMake(b*foldWidth, 0, foldWidth, frameHeight);
        }
        CATransformLayer *transLayer = [self transformLayerFromImage:viewSnapShot Frame:imageFrame Duration:duration AnchorPiont:anchorPoint StartAngle:0 EndAngle:endAngle];
        [prevLayer addSublayer:transLayer];
        prevLayer = transLayer;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.frame = selfFrame;
        [origamiLayer removeFromSuperlayer];
        XY_Origami_Current_State = XYOrigamiTransitionStateIdle;
        
		if (completion)
			completion(YES);
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    CAAnimation *openAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x" function:closeFunction fromValue:self.frame.origin.x+self.frame.size.width/2 toValue:selfFrame.origin.x+self.frame.size.width/2];
    openAnimation.fillMode = kCAFillModeForwards;
    [openAnimation setRemovedOnCompletion:NO];
    [self.layer addAnimation:openAnimation forKey:@"position"];
    [CATransaction commit];
}
 
@end
