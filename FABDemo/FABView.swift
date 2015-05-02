//
//  FABView.swift
//  FABDemo
//
//  Created by Gaurav Khanna on 4/27/15.
//  Copyright (c) 2015 Gaurav Khanna. All rights reserved.
//

import Foundation
import UIKit

internal class SingleEventQueue:NSOperationQueue {
    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }
}

internal class ContentLayer: CALayer {
    let _buttonSpacing = CGFloat(20)
    let _firstButtonInset = CGFloat(30)
    let _contentFont = UIFont.systemFontOfSize(18.0)
    let _contentColor = UIColor.whiteColor()
    
    var _web:NSAttributedString?
    var _image:NSAttributedString?
    var _video:NSAttributedString?
    var _shopping:NSAttributedString?
    var _map:NSAttributedString?
    var _webRect:CGRect?
    var _imageRect:CGRect?
    var _videoRect:CGRect?
    var _shoppingRect:CGRect?
    var _mapRect:CGRect?
    
    override init!() {
        super.init()
        
        let attrs = [NSFontAttributeName: _contentFont,
            NSForegroundColorAttributeName: _contentColor]
        
        _web = NSAttributedString(string: "Web", attributes: attrs)
        let webSize = _web!.size()
        _webRect = CGRectMake(_firstButtonInset, 0, webSize.width, webSize.height)
        
        _image = NSAttributedString(string: "Images", attributes: attrs)
        let imageSize = _image!.size()
        _imageRect = CGRectMake(CGRectGetMaxX(_webRect!) + _buttonSpacing, 0, imageSize.width, imageSize.height)
        
        
        _video = NSAttributedString(string: "Videos", attributes: attrs)
        let videoSize = _video!.size()
        _videoRect = CGRectMake(CGRectGetMaxX(_imageRect!) + _buttonSpacing, 0, videoSize.width, videoSize.height)
        
        
        _shopping = NSAttributedString(string: "Shopping", attributes: attrs)
        let shoppingSize = _shopping!.size()
        _shoppingRect = CGRectMake(CGRectGetMaxX(_videoRect!) + _buttonSpacing, 0, shoppingSize.width, shoppingSize.height)
        
        
        _map = NSAttributedString(string: "Maps", attributes: attrs)
        let mapSize = _map!.size()
        _mapRect = CGRectMake(CGRectGetMaxX(_shoppingRect!) + _buttonSpacing, 0, mapSize.width, mapSize.height)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func preferredFrameSize() -> CGSize {
        return CGSizeMake(floor(CGRectGetMaxX(_mapRect!)), floor(CGRectGetMaxY(_mapRect!)))
    }
    
    override func drawInContext(ctx: CGContext!) {
        UIGraphicsPushContext(ctx)
        _web!.drawInRect(_webRect!)
        _image!.drawInRect(_imageRect!)
        _video!.drawInRect(_videoRect!)
        _shopping!.drawInRect(_shoppingRect!)
        _map!.drawInRect(_mapRect!)
        UIGraphicsPopContext()
    }
}

internal class ContentScrollContainerLayer: CALayer {
    let _scrollContainerLayer = CALayer()
    let _maskContainerLayer = CALayer()
    let _maskFillLayer = CALayer()
    let _maskGradientLayer = CALayer()
    
    var _gradientWidth:CGFloat?
    var _contentSize:CGSize?
    var _fabSize:CGFloat?
    var _fabMargin:CGFloat?
    func setup(contentSize: CGSize, gradientWidth: CGFloat, fabSize: CGFloat, fabMargin: CGFloat) {
        self.addSublayer(_scrollContainerLayer)
        
        let gradientSize = CGSizeMake(gradientWidth, contentSize.height)
        let mask = self.setupRightGradientMaskImage(gradientSize)
        
        _maskGradientLayer.contents = mask.CGImage
        _maskGradientLayer.backgroundColor = UIColor.clearColor().CGColor
        _maskGradientLayer.opaque = false
        _maskGradientLayer.contentsScale = UIScreen.mainScreen().scale
        _maskGradientLayer.frame = CGRectMake(0, 0, gradientSize.width, gradientSize.height)
        _maskContainerLayer.opaque = false
        _maskContainerLayer.backgroundColor = UIColor.clearColor().CGColor
        _maskContainerLayer.frame = CGRectMake(0, 0, gradientWidth, contentSize.height)
        _maskFillLayer.backgroundColor = UIColor.whiteColor().CGColor
        _maskFillLayer.opaque = true
        _maskFillLayer.frame = CGRectMake(gradientWidth, 0, 0, contentSize.height)
        
        _maskContainerLayer.addSublayer(_maskFillLayer)
        _maskContainerLayer.addSublayer(_maskGradientLayer)
        
        _scrollContainerLayer.mask = _maskContainerLayer
        
        _gradientWidth = gradientWidth
        _contentSize = contentSize
        _fabMargin = fabMargin
        _fabSize = fabSize
    }
    func setupRightGradientMaskImage(gradientSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(gradientSize, false, 0)
        var ctx = UIGraphicsGetCurrentContext()
        
        let locs: [CGFloat] = [0.0, 1.0]
        let colors: [CGColorRef] = [UIColor.clearColor().CGColor, UIColor.whiteColor().CGColor]
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, locs)
        CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(gradientSize.width, 0), CGGradientDrawingOptions(0))
        
        let mask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return mask
    }
    override func layoutSublayers() {
        super.layoutSublayers()
        
        let gradientWidth = _gradientWidth!
        var fabSize = _fabSize!
        var fabMargin = _fabMargin!
        _maskContainerLayer.frame.origin.x = self.bounds.origin.x + gradientWidth + (fabMargin*2) + fabSize + 160
        _maskFillLayer.frame.size.width = self.bounds.size.width - fabSize - (fabMargin*2)
    }
}


enum FABViewState {
    case Normal
    case Expanded
    case Expanding
    case Contracting
}

@IBDesignable
class FABView: UIView, UIGestureRecognizerDelegate,POPAnimationDelegate  {
    let _fabSize:CGFloat = 75
    let _fabMargin:CGFloat = 28
    let _fabIconToContentMargin:CGFloat = 10
    let _fabAntialias = true
    let _normalStateColor = UIColor(red:0.205, green:0.487, blue:1, alpha:1)
    let _activeStateColor = UIColor(red:0.327, green:0.624, blue:1, alpha:1)
    
    let _mainContainerLayer = ContentScrollContainerLayer()
    let _contentLayer = ContentLayer.init()
    let _contentScrollLayer = CAScrollLayer()
    let _contentLeftGradientMaskLayer = CALayer()
    let _iconLayer = CALayer()
    
    let _scrollContainerLayer = CALayer()
    let _scrollContainerRightGradientMaskLayer = CALayer()
    let _scrollContainerMaskLayer = CALayer()
    let _scrollContainerFillMaskLayer = CALayer()
    var _scrollMaskGradientWidth:CGFloat?

    let _longTouchExpandRecognizer = UILongPressGestureRecognizer()
    let _touchHighlightRecognizer = UILongPressGestureRecognizer()
    let _longTouchContractRecognizer = UILongPressGestureRecognizer()
    let _doubleTapIconContractRecognizer = UILongPressGestureRecognizer()
    let _panGestureRecognizer = UIPanGestureRecognizer()
    
    var _eventQueue:SingleEventQueue? = SingleEventQueue()
    var _highlightStateQueue:SingleEventQueue? = SingleEventQueue()
    var _lastHighlightOperation:NSOperation?
    
    var _state:FABViewState = FABViewState.Normal
    
    var _rightMarginConstraint:NSLayoutConstraint?
    var _bottomMarginConstraint:NSLayoutConstraint?
    var _widthConstraint:NSLayoutConstraint?
    
    var _normalImage:UIImage?
    var _highlightImage:UIImage?
    
    var _expandAnimationCompletionBlock:NSBlockOperation?
    var _contractAnimationCompletionBlock:NSBlockOperation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func alignmentRectInsets() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func setup() {
        self.preservesSuperviewLayoutMargins = false
        setTranslatesAutoresizingMaskIntoConstraints(false)
        self.layoutMargins = UIEdgeInsetsZero
        
//        _touchHighlightRecognizer.minimumPressDuration = 0.01
//        _touchHighlightRecognizer.delegate = self
//        _touchHighlightRecognizer.addTarget(self, action: Selector("touchHighlightAction:"))
//        self.addGestureRecognizer(_touchHighlightRecognizer)
//        
//        _longTouchExpandRecognizer.minimumPressDuration = 0.5
//        _longTouchExpandRecognizer.delegate = self
//        _longTouchExpandRecognizer.addTarget(self, action: Selector("expandRecognizerAction:"))
//        self.addGestureRecognizer(_longTouchExpandRecognizer)
//        
//        _longTouchContractRecognizer.minimumPressDuration = 0.5
//        _longTouchContractRecognizer.delegate = self
//        _longTouchContractRecognizer.addTarget(self, action: Selector("contractRecognizerAction:"))
//        _longTouchContractRecognizer.enabled = false
//        self.addGestureRecognizer(_longTouchContractRecognizer)
//        
//        _doubleTapIconContractRecognizer.minimumPressDuration = 0.01
//        _doubleTapIconContractRecognizer.numberOfTapsRequired = 1
//        _doubleTapIconContractRecognizer.delegate = self
//        _doubleTapIconContractRecognizer.addTarget(self, action: Selector("contractRecognizerAction:"))
//        _doubleTapIconContractRecognizer.enabled = false
//        self.addGestureRecognizer(_doubleTapIconContractRecognizer)
        
        _panGestureRecognizer.addTarget(self, action: Selector("panGestureAction:"))
        self.addGestureRecognizer(_panGestureRecognizer)

        self.setupNormalAndHighlightBackgroundImages()
        self.layer.contentsScale = UIScreen.mainScreen().scale
        
        self.layer.addSublayer(_mainContainerLayer)
        _mainContainerLayer.anchorPoint = CGPointMake(0, 0)
        self.transform = CGAffineTransformMakeScale(-1, -1)
        
        let contentSize = _contentLayer.preferredFrameSize()
        _contentLayer.frame = CGRectMake(0, 0, contentSize.width, contentSize.height)
        _contentLayer.setNeedsDisplay()
        _contentLayer.needsDisplayOnBoundsChange = false
        _contentLayer.contentsScale = UIScreen.mainScreen().scale

        let (mask, gradientWidth) = self.createLeftGradientMaskImage(contentSize)
        _contentLeftGradientMaskLayer.contents = mask.CGImage
        _contentLeftGradientMaskLayer.contentsScale = UIScreen.mainScreen().scale
        _contentLeftGradientMaskLayer.frame = CGRectMake(0, 0, contentSize.width, contentSize.height)
        
        let contentTranslate = CGAffineTransformMakeTranslation(0, contentSize.height)
        let contentInvert = CGAffineTransformScale(contentTranslate, -1, -1)
        _contentScrollLayer.mask = _contentLeftGradientMaskLayer
        _contentScrollLayer.frame = CGRectMake(0, -contentSize.height, contentSize.width, contentSize.height)
        _contentScrollLayer.contentsScale = UIScreen.mainScreen().scale
        _contentScrollLayer.addSublayer(_contentLayer)
        _contentScrollLayer.transform = CATransform3DMakeAffineTransform(contentInvert)
        _mainContainerLayer._scrollContainerLayer.addSublayer(_contentScrollLayer)
        
        _mainContainerLayer.setup(contentSize, gradientWidth: gradientWidth, fabSize: _fabSize, fabMargin: _fabMargin)
        _mainContainerLayer._scrollContainerLayer.frame = CGRectMake(-(contentSize.width - _fabSize/2 - _fabMargin) - _fabIconToContentMargin, ((_fabSize + _fabMargin*2)/2 - contentSize.height/2), contentSize.width, contentSize.height)
        
        _iconLayer.contents = self.createIconImage()?.CGImage
        _iconLayer.contentsGravity = kCAGravityCenter
        _iconLayer.contentsScale = UIScreen.mainScreen().scale
        _mainContainerLayer.addSublayer(_iconLayer)
        
    }
    
    func setupNormalAndHighlightBackgroundImages() {
        
        let size = CGSizeMake(_fabSize, _fabSize)
        let bound = CGSizeMake(_fabSize + (_fabMargin*2), _fabSize + (_fabMargin*2))
        let path = UIBezierPath(roundedRect: CGRectMake(floor(bound.width/2 - size.width/2), floor(bound.height/2 - size.height/2), size.width, size.height), cornerRadius: size.width/2)
        path.flatness = 0.0
        
        let scale = _fabAntialias ? CGFloat(4) : UIScreen.mainScreen().scale
        
        UIGraphicsBeginImageContextWithOptions(bound, false, (_fabAntialias ? 4 : 0))
        var ctx = UIGraphicsGetCurrentContext()
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -7), 9, UIColor(white: 0.0, alpha: 0.3).CGColor)
        CGContextSetFillColorWithColor(ctx, _normalStateColor.CGColor)
        CGContextAddPath(ctx, path.CGPath)
        CGContextDrawPath(ctx, kCGPathFill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        _normalImage = image
        
        _mainContainerLayer.contents = image.CGImage
        _mainContainerLayer.contentsScale = scale
        _mainContainerLayer.allowsEdgeAntialiasing = true
        _mainContainerLayer.edgeAntialiasingMask = CAEdgeAntialiasingMask.LayerBottomEdge | CAEdgeAntialiasingMask.LayerLeftEdge | CAEdgeAntialiasingMask.LayerRightEdge | CAEdgeAntialiasingMask.LayerTopEdge
        let imageXOffset = (image.size.width-1)/2
        _mainContainerLayer.contentsCenter = CGRectMake((imageXOffset * scale)/(bound.width * scale),0.0/(bound.height * scale),1.0/(bound.width * scale),1.0/(bound.height * scale))
        
        UIGraphicsBeginImageContextWithOptions(bound, false, (_fabAntialias ? 4 : 0))
        ctx = UIGraphicsGetCurrentContext()
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -10), 9, UIColor(white: 0.0, alpha: 0.3).CGColor)
        CGContextSetFillColorWithColor(ctx, _activeStateColor.CGColor)
        CGContextAddPath(ctx, path.CGPath)
        CGContextDrawPath(ctx, kCGPathFill)
        _highlightImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    func createIconImage() -> UIImage? {
        let loadedImage = UIImage(named:"ic_add_black_ios_24dp")
        if loadedImage == nil {
            return nil
        }
        let image = loadedImage!
        var ctx:CGContextRef? = nil
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0)
        ctx = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextClipToMask(ctx, imageRect, image.CGImage)
        CGContextFillRect(ctx, imageRect)
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
    
    func createLeftGradientMaskImage(maskSize: CGSize) -> (UIImage, CGFloat) {
        
        let gradientWidth:CGFloat = 0.2
        UIGraphicsBeginImageContextWithOptions(maskSize, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        
        let locs: [CGFloat] = [0.0, gradientWidth]
        let colors: [CGColorRef] = [UIColor.clearColor().CGColor, UIColor.whiteColor().CGColor]
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, locs)
        CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(maskSize.width, 0), CGGradientDrawingOptions(0))
        
        let mask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let maskGradientWidth = floor(gradientWidth * maskSize.width)
        _scrollMaskGradientWidth = maskGradientWidth
        return (mask, maskGradientWidth)
    }
    
    override func intrinsicContentSize() -> CGSize {
        if self._state == FABViewState.Expanded {
            return CGSizeMake(375, 131)
        } else {
            return CGSizeMake(131, 131)
        }
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (self._state == FABViewState.Expanding || self._state == FABViewState.Contracting) {
            return
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        
        if (self._state == FABViewState.Expanded) {
            
        } else {
            _mainContainerLayer.bounds = self.bounds
            _iconLayer.frame = self.bounds
        }
        
        CATransaction.commit()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    func setNormalAppearance() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        _mainContainerLayer.contents = self._normalImage!.CGImage
        CATransaction.commit()
    }
    
    func setHighlightedAppearance() {
        if (self._state != FABViewState.Normal) {
            fatalError("FABView cannot display highlighted appearance if not in normal state")
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        _mainContainerLayer.contents = self._highlightImage!.CGImage
        CATransaction.commit()
    }
    
    func touchHighlightAction(gc: UILongPressGestureRecognizer) {
        
        if gc.state == UIGestureRecognizerState.Began {
            
            let blockOperation = NSBlockOperation()
            weak var weakSelf = self
            weak var weakBlockOperation = blockOperation
            
            blockOperation.addExecutionBlock({() in
                if weakBlockOperation != nil && weakBlockOperation!.cancelled {
                    return
                }
                
                if var strongSelf = weakSelf {
                    strongSelf._highlightStateQueue?.cancelAllOperations()
                    strongSelf._highlightStateQueue = nil
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    weakSelf?.setHighlightedAppearance()
                }
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    if weakBlockOperation != nil && weakBlockOperation!.cancelled {
                        return
                    }
                    weakSelf?.setNormalAppearance()
                }
            })
            _highlightStateQueue?.addOperations([blockOperation], waitUntilFinished: true)
                
        } else if gc.state == UIGestureRecognizerState.Ended || gc.state == UIGestureRecognizerState.Cancelled {
            self.setNormalAppearance()
            
            _lastHighlightOperation?.cancel()
            _highlightStateQueue = SingleEventQueue()
        }
        
    }
    
    func updateGestureRecognizersState() {
        switch self._state {
        case FABViewState.Normal:
            self._touchHighlightRecognizer.enabled = true
            self._longTouchExpandRecognizer.enabled = true
            self._longTouchContractRecognizer.enabled = false
            self._doubleTapIconContractRecognizer.enabled = false
            break;
        case FABViewState.Expanded:
            self._touchHighlightRecognizer.enabled = false
            self._longTouchExpandRecognizer.enabled = false
            self._longTouchContractRecognizer.enabled = true
            self._doubleTapIconContractRecognizer.enabled = true
            break;
        default:
            break;
        }
    }
    
    func setContractedWidthAppearanceAnimated(animated: Bool, completion: (() -> Void)?) {
        self._state = FABViewState.Normal
        self.updateGestureRecognizersState()
        
        let size = self.intrinsicContentSize()
        let toRect = CGRectIntegral(CGRectMake(abs(-(size.width-self._iconLayer.frame.size.width)), 0, size.width, size.height))
        
        self.invalidateIntrinsicContentSize()
        
        if (animated) {
            
            self._state = FABViewState.Contracting

            let pop = POPSpringAnimation(propertyNamed: kPOPLayerBounds)
            pop.toValue = NSValue(CGRect: toRect)
            pop.removedOnCompletion = false
            //pop.springBounciness = 25.1
            //pop.springSpeed = 25.4
//            pop.dynamicsTension = 150
//            pop.dynamicsFriction = 10
//            pop.dynamicsMass = 1
            pop.delegate = self
            if completion != nil {
                _contractAnimationCompletionBlock = NSBlockOperation(block: completion!)
            }
            
            self._mainContainerLayer.pop_addAnimation(pop, forKey: "contract")
        } else {
            self._mainContainerLayer.bounds = toRect
        }
    }
    func setExpandedWidthAppearanceAnimated(animated: Bool, completion: (() -> Void)?) {
        self._state = FABViewState.Expanded
        self.updateGestureRecognizersState()
        
        let size = self.intrinsicContentSize()
        let toRect = CGRectIntegral(CGRectMake(-(size.width-self._iconLayer.frame.size.width), 0, size.width, size.height))

        self.invalidateIntrinsicContentSize()
        
        if (animated) {
            
            self._state = FABViewState.Expanding
            
            let pop = POPSpringAnimation(propertyNamed: kPOPLayerBounds)
            pop.toValue = NSValue(CGRect: toRect)
            pop.removedOnCompletion = false
            //pop.springBounciness = 25.1
            //pop.springSpeed = 25.4
//            pop.dynamicsTension = 150
//            pop.dynamicsFriction = 10
//            pop.dynamicsMass = 1
            pop.delegate = self
            if completion != nil {
                _expandAnimationCompletionBlock = NSBlockOperation(block: completion!)
            }

            self._mainContainerLayer.pop_addAnimation(pop, forKey: "widen")
        } else {
            self._mainContainerLayer.bounds = toRect
        }
    }
    func expandRecognizerAction(gc: UILongPressGestureRecognizer) {

        if gc.state != UIGestureRecognizerState.Began {
            return
        }
        
        let blockOperation = NSBlockOperation()
        weak var weakSelf = self
        weak var weakBlockOperation = blockOperation
        
        blockOperation.addExecutionBlock({() in
            if weakBlockOperation != nil {
                if weakBlockOperation!.cancelled {
                    return
                }
            }
            
            if var strongSelf = weakSelf {
                strongSelf._eventQueue?.cancelAllOperations()
                strongSelf._eventQueue = nil
            }
            
            var expandWidth:() -> Void = {() in
                weakSelf?.setExpandedWidthAppearanceAnimated(true, completion: {() in
                    if var strongSelf = weakSelf {
                        strongSelf._eventQueue = SingleEventQueue()
                    }
                })
            }
            
            if NSThread.isMainThread() {
                expandWidth()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    expandWidth()
                }
            }
            
        })
        _eventQueue?.addOperations([blockOperation], waitUntilFinished: true)
        
    }
    
    func contractRecognizerAction(gc: UILongPressGestureRecognizer) {
        if gc.state != UIGestureRecognizerState.Began {
            return
        }
        
        let gcPoint = gc.locationInView(self)
        let layerPoint = self.layer.convertPoint(gcPoint, toLayer: self._mainContainerLayer)
        let iconPoint = self._mainContainerLayer.convertPoint(layerPoint, toLayer: self._iconLayer)
        if (!self._iconLayer.containsPoint(iconPoint)) {
            return
        }
        
        let blockOperation = NSBlockOperation()
        weak var weakSelf = self
        weak var weakBlockOperation = blockOperation
        
        blockOperation.addExecutionBlock({() in
            if weakBlockOperation != nil {
                if weakBlockOperation!.cancelled {
                    return
                }
                
            }
            if var strongSelf = weakSelf {
                strongSelf._eventQueue?.cancelAllOperations()
                strongSelf._eventQueue = nil
            }
            
            var contractWidth:() -> Void = {() in
                weakSelf?.setContractedWidthAppearanceAnimated(true) {() in
                    if var strongSelf = weakSelf {
                        strongSelf._eventQueue = SingleEventQueue()
                    }
                }
            }
            
            if NSThread.isMainThread() {
                contractWidth()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    contractWidth()
                }
            }
        })
        _eventQueue?.addOperations([blockOperation], waitUntilFinished: true)
    }
    
    override func didMoveToSuperview() {
        if (self.superview != nil) {
            let superview = self.superview!
            let size = self.intrinsicContentSize()
            
            let width = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size.width)
            _widthConstraint = width
            
            let rightTrailMargin = NSLayoutConstraint(item: superview, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant:0)
            _rightMarginConstraint = rightTrailMargin
            
            let bottomTrailMargin = NSLayoutConstraint(item: superview, attribute: NSLayoutAttribute.Baseline, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1, constant:0)
            _bottomMarginConstraint = bottomTrailMargin
            
            
            superview.addConstraints([rightTrailMargin, bottomTrailMargin, width])
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if self.superview != nil {
            let superview = self.superview!
            if _rightMarginConstraint != nil {
                superview.removeConstraint(_rightMarginConstraint!)
            }
            if _bottomMarginConstraint != nil {
                superview.removeConstraint(_bottomMarginConstraint!)
            }
            if _widthConstraint != nil {
                superview.removeConstraint(_widthConstraint!)
            }
        }
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == _touchHighlightRecognizer && otherGestureRecognizer == _longTouchExpandRecognizer) || (gestureRecognizer == _longTouchExpandRecognizer && otherGestureRecognizer == _touchHighlightRecognizer) {
            return true
        }
        if (gestureRecognizer == _doubleTapIconContractRecognizer && otherGestureRecognizer == _longTouchContractRecognizer) ||
            (gestureRecognizer == _longTouchContractRecognizer && otherGestureRecognizer == _doubleTapIconContractRecognizer) {
            return true
        }
        return false
    }
    
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        let hit = super.hitTest(point, withEvent: event)
//        if hit != nil {
//            NSLog("%@", hit!)
//        } else {
//            NSLog("nope")
//        }
//        return hit
//    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let inside = super.pointInside(point, withEvent: event)
        let convertedPoint = self.layer.convertPoint(point, toLayer: self._mainContainerLayer)
        let hit = self._mainContainerLayer.containsPoint(convertedPoint)
    
        //NSLog("%@ hit", NSNumber(bool: hit))
        //NSLog("%@ hitP", NSStringFromCGPoint(point))
        //NSLog("%@", NSNumber(bool: inside))
        //NSLog("%@ %@", self._mainContainerLayer, NSStringFromCGRect(self._mainContainerLayer.frame))
        
        return hit
    }
    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {
        if anim == self._mainContainerLayer.pop_animationForKey("widen") as? POPAnimation {
            if finished {
                weak var weakSelf = self
                if self._expandAnimationCompletionBlock != nil {
                    let completion = self._expandAnimationCompletionBlock!
                    completion.completionBlock = {() -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            if var strongSelf = weakSelf {
                                strongSelf._state = FABViewState.Expanded
                                strongSelf._mainContainerLayer.pop_removeAllAnimations()
                                strongSelf._expandAnimationCompletionBlock = nil
                            }
                        }
                    }
                    completion.start()
                }
            }
        }
        if anim == self._mainContainerLayer.pop_animationForKey("contract") as? POPAnimation {
            if finished {
                weak var weakSelf = self
                if self._contractAnimationCompletionBlock != nil {
                    let completion = self._contractAnimationCompletionBlock!
                    completion.completionBlock = {() -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            if var strongSelf = weakSelf {
                                strongSelf._state = FABViewState.Normal
                                strongSelf._mainContainerLayer.pop_removeAllAnimations()
                                strongSelf._contractAnimationCompletionBlock = nil
                            }
                        }
                    }
                    completion.start()
                }
            }
        }
    }
    
}