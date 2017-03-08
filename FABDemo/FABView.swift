//
//  FABView.swift
//  FABDemo
//
//  Created by Gaurav Khanna on 4/27/15.
//  Copyright (c) 2015 Gaurav Khanna. All rights reserved.
//

import Foundation
import UIKit
import pop

internal class SingleEventQueue:OperationQueue {
    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }
}

// MARK: - Contents Layer
internal class ContentLayer: CALayer {
    // MARK: - Contents Appearance Parameters
    internal let _buttonSpacing:CGFloat = 20
    internal let _firstButtonInset:CGFloat = 50
    internal let _lastButtonInset:CGFloat = 50
    internal let _contentFont = UIFont.systemFont(ofSize: 18.0)
    internal let _contentColor = UIColor.white
    
    // MARK: Contents
    internal var _web:NSAttributedString?
    internal var _image:NSAttributedString?
    internal var _video:NSAttributedString?
    internal var _shopping:NSAttributedString?
    internal var _map:NSAttributedString?
    internal var _webRect:CGRect?
    internal var _imageRect:CGRect?
    internal var _videoRect:CGRect?
    internal var _shoppingRect:CGRect?
    internal var _mapRect:CGRect?
    
    override init!() {
        super.init()
        
        self.allowsGroupOpacity = false
        
        let attrs = [NSFontAttributeName: _contentFont,
            NSForegroundColorAttributeName: _contentColor] as [String : Any]
        
        _web = NSAttributedString(string: "Web", attributes: attrs)
        let webSize = _web!.size()
        _webRect = CGRect(x: _firstButtonInset, y: 0, width: webSize.width, height: webSize.height)
        
        _image = NSAttributedString(string: "Images", attributes: attrs)
        let imageSize = _image!.size()
        _imageRect = CGRect(x: _webRect!.maxX + _buttonSpacing, y: 0, width: imageSize.width, height: imageSize.height)
        
        
        _video = NSAttributedString(string: "Videos", attributes: attrs)
        let videoSize = _video!.size()
        _videoRect = CGRect(x: _imageRect!.maxX + _buttonSpacing, y: 0, width: videoSize.width, height: videoSize.height)
        
        
        _shopping = NSAttributedString(string: "Shopping", attributes: attrs)
        let shoppingSize = _shopping!.size()
        _shoppingRect = CGRect(x: _videoRect!.maxX + _buttonSpacing, y: 0, width: shoppingSize.width, height: shoppingSize.height)
        
        let clearAttr = [NSFontAttributeName: _contentFont,
            NSForegroundColorAttributeName: UIColor.clear] as [String : Any]
        _map = NSAttributedString(string: "Maps", attributes: clearAttr)
        let mapSize = _map!.size()
        _mapRect = CGRect(x: _shoppingRect!.maxX + _buttonSpacing, y: 0, width: mapSize.width + _lastButtonInset, height: mapSize.height)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func preferredFrameSize() -> CGSize {
        return CGSize(width: ceil(_mapRect!.maxX), height: ceil(_mapRect!.maxY))
    }
    
    override func draw(in ctx: CGContext!) {
        UIGraphicsPushContext(ctx)
        _web!.draw(in: _webRect!)
        _image!.draw(in: _imageRect!)
        _video!.draw(in: _videoRect!)
        _shopping!.draw(in: _shoppingRect!)
        _map!.draw(in: _mapRect!)
        UIGraphicsPopContext()
    }
}

// MARK: - Contents Scroll Container Layer
internal class ContentScrollContainerLayer: CAShapeLayer {
    internal let _gradientWidth:CGFloat = 40
    internal let _leftGradientInset:CGFloat = 88
    internal let _rightGradientInset:CGFloat = 95
    
    // MARK: Container Mask Layers
    internal let _scrollContainerLayer = CAShapeLayer()
    internal let _maskContainerLayer = CAShapeLayer()
    internal let _maskFillLayer = CAShapeLayer()
    internal let _maskLeftGradientLayer = CALayer()
    internal let _maskRightGradientLayer = CALayer()
    
    // MARK: Contents Passed Parameters
    internal var _gradientSize:CGSize?
    internal var _contentSize:CGSize?
    internal var _fabSize:CGFloat?
    internal var _fabMargin:CGFloat?
    internal var _expandedSize:CGFloat?
    internal func setup(_ contentSize: CGSize, fabSize: CGFloat, fabMargin: CGFloat, expandedSize: CGFloat) {
        self.addSublayer(_scrollContainerLayer)
    
        self.allowsGroupOpacity = false
        
        //let gradientWidth = contentSize.width * _gradientPointWidth
        //self.anchorPoint = CGPointMake(1, 0.5)
        self._maskContainerLayer.anchorPoint = CGPoint(x: 1, y: 0.5)
        
        let gradientSize = CGSize(width: _gradientWidth, height: ceil(contentSize.height))
        let leftGradientMask = self.createLeftGradientMaskImage(gradientSize)
        //let rightGradientMask = self.createRightGradientMaskImage(gradientSize)
        
        _maskLeftGradientLayer.contents = leftGradientMask.cgImage
        //_maskLeftGradientLayer.backgroundColor = UIColor.clearColor().CGColor
        _maskLeftGradientLayer.allowsGroupOpacity = false
        //_maskLeftGradientLayer.opaque = false
        _maskLeftGradientLayer.contentsScale = UIScreen.main.scale
        _maskLeftGradientLayer.frame = CGRect(x: 0, y: 0, width: gradientSize.width, height: gradientSize.height)
        
        let translateTransform = CGAffineTransform(translationX: 0, y: 0)
        let invertTransform = CATransform3DMakeAffineTransform(translateTransform.scaledBy(x: -1, y: 1))
        
        _maskRightGradientLayer.contents = leftGradientMask.cgImage
        _maskRightGradientLayer.isOpaque = false
        _maskRightGradientLayer.contentsScale = UIScreen.main.scale
        _maskRightGradientLayer.allowsGroupOpacity = false
        _maskRightGradientLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        _maskRightGradientLayer.transform = invertTransform
        _maskRightGradientLayer.frame = CGRect(x: gradientSize.width + _rightGradientInset, y: 0, width: -gradientSize.width, height: gradientSize.height)
        
        _maskFillLayer.backgroundColor = UIColor.red.cgColor
        _maskFillLayer.isOpaque = true
        _maskFillLayer.frame = CGRect(x: 0, y: 0, width: 0, height: contentSize.height)
        
        //_maskContainerLayer.opaque = false
        //_maskContainerLayer.backgroundColor = UIColor.clearColor().CGColor
        _maskContainerLayer.frame = CGRect(x: expandedSize + fabSize + fabMargin*2, y: 0, width: -gradientSize.width, height: contentSize.height)

        _maskContainerLayer.addSublayer(_maskFillLayer)
        _maskContainerLayer.addSublayer(_maskLeftGradientLayer)
        _maskContainerLayer.addSublayer(_maskRightGradientLayer)
        
        //_scrollContainerLayer.addSublayer(_maskContainerLayer)
        _scrollContainerLayer.mask = _maskContainerLayer
        
        _gradientSize = gradientSize
        _contentSize = contentSize
        _fabMargin = fabMargin
        _fabSize = fabSize
        _expandedSize = expandedSize
    }
    final internal func createLeftGradientMaskImage(_ gradientSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(gradientSize, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        
        let locs: [CGFloat] = [0.0, 1.0]
        let colors: [CGColor] = [UIColor.white.cgColor, UIColor.clear.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locs)
        ctx?.drawLinearGradient(gradient!, start: CGPoint.zero, end: CGPoint(x: gradientSize.width, y: 0), options: CGGradientDrawingOptions(0))
        
        let mask = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return mask
    }
    final override func layoutSublayers() {
        super.layoutSublayers()
        let gradientSize = _gradientSize!
        let fabSize = _fabSize!
        let fabMargin = _fabMargin!
        let contentSize = _contentSize!
        let expandedSize = _expandedSize!
        
        var maskContainerWidth = self.bounds.width
        if (maskContainerWidth > expandedSize) {
            maskContainerWidth = expandedSize
        }
        _maskContainerLayer.bounds.size.width = maskContainerWidth
        
        _maskFillLayer.frame.origin.x = _maskRightGradientLayer.frame.maxX
        let fillCalcWidth = self.bounds.size.width - fabSize/2 - fabMargin - _gradientWidth - _leftGradientInset
        let fillWidth = (fillCalcWidth < 0) ? 0 : fillCalcWidth
        _maskFillLayer.frame.size.width = fillWidth
        _maskLeftGradientLayer.frame.origin.x = _maskRightGradientLayer.frame.maxX + fillWidth
    }
}

// MARK: - FABView

var layout = true

internal enum FABViewState {
    case normal
    case expanded
    case expanding
    case contracting
    case panning
}

internal let FABViewPOPAnimationExpandingKey = "FABViewPOPAnimationExpandingKey"
internal let FABViewPOPAnimationContractingKey = "FABViewPOPAnimationContractingKey"

@IBDesignable
open class FABView: UIView, UIGestureRecognizerDelegate,POPAnimationDelegate  {
    
    // MARK: - FABView Appearance Parameters
    internal let _fabSize:CGFloat = 75
    internal let _fabMargin:CGFloat = 28
    internal let _fabIconToContentMargin:CGFloat = 10
    internal let _fabExpandedMaxWidth:CGFloat = 375
    internal let _fabAntialias = true
    internal let _normalStateColor = UIColor(red:0.205, green:0.487, blue:1, alpha:1)
    internal let _activeStateColor = UIColor(red:0.327, green:0.624, blue:1, alpha:1)
    
    // MARK: Appearance Layers
    internal let _mainContainerLayer = ContentScrollContainerLayer()
    internal let _contentScrollLayer = UIScrollView()
    internal let _contentLayer = ContentLayer.init()
    internal let _iconLayer = CALayer()

    // MARK: Gesture Recognizers
    internal let _longTouchExpandRecognizer = UILongPressGestureRecognizer()
    internal let _touchHighlightRecognizer = UILongPressGestureRecognizer()
    internal let _longTouchContractRecognizer = UILongPressGestureRecognizer()
    internal let _doubleTapIconContractRecognizer = UILongPressGestureRecognizer()
    internal let _panGestureRecognizer = UIPanGestureRecognizer()
    internal let _scrollGestureRecognizer = UIPanGestureRecognizer()
    
    internal var _panBeginOffset:CGFloat?
    
    // MARK: Operation Queues
    internal var _eventQueue:SingleEventQueue? = SingleEventQueue()
    internal var _highlightStateQueue:SingleEventQueue? = SingleEventQueue()
    internal var _lastHighlightOperation:Operation?
    
    internal var _state:FABViewState = FABViewState.normal
    
    // MARK: AutoLayout Constraints
    internal var _rightMarginConstraint:NSLayoutConstraint?
    internal var _bottomMarginConstraint:NSLayoutConstraint?
    internal var _widthConstraint:NSLayoutConstraint?
    
    // MARK: Generated Appearance Images
    internal var _normalImage:UIImage?
    internal var _highlightImage:UIImage?
    
    // MARK: Animation Completion Blocks
    internal var _expandAnimationCompletionBlock:BlockOperation?
    internal var _contractAnimationCompletionBlock:BlockOperation?
    
    // MARK: FABView Initializer Methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - FABView Setup Methods
    internal func setup() {
        self.preservesSuperviewLayoutMargins = false
        setTranslatesAutoresizingMaskIntoConstraints(false)
        self.layoutMargins = UIEdgeInsets.zero
        
        _touchHighlightRecognizer.minimumPressDuration = 0.01
        _touchHighlightRecognizer.delegate = self
        _touchHighlightRecognizer.addTarget(self, action: #selector(FABView.touchHighlightAction(_:)))
        self.addGestureRecognizer(_touchHighlightRecognizer)
        
        _longTouchExpandRecognizer.minimumPressDuration = 0.5
        _longTouchExpandRecognizer.delegate = self
        _longTouchExpandRecognizer.addTarget(self, action: #selector(FABView.expandRecognizerAction(_:)))
        self.addGestureRecognizer(_longTouchExpandRecognizer)
        
        _longTouchContractRecognizer.minimumPressDuration = 0.5
        _longTouchContractRecognizer.delegate = self
        _longTouchContractRecognizer.addTarget(self, action: #selector(FABView.contractRecognizerAction(_:)))
        _longTouchContractRecognizer.isEnabled = false
        self.addGestureRecognizer(_longTouchContractRecognizer)
        
        _doubleTapIconContractRecognizer.minimumPressDuration = 0.01
        _doubleTapIconContractRecognizer.numberOfTapsRequired = 1
        _doubleTapIconContractRecognizer.delegate = self
        _doubleTapIconContractRecognizer.addTarget(self, action: #selector(FABView.contractRecognizerAction(_:)))
        _doubleTapIconContractRecognizer.isEnabled = false
        self.addGestureRecognizer(_doubleTapIconContractRecognizer)
        
        _panGestureRecognizer.addTarget(self, action: #selector(FABView.panGestureAction(_:)))
        _panGestureRecognizer.delegate = self
        self.addGestureRecognizer(_panGestureRecognizer)

        self.setupNormalAndHighlightBackgroundImages()
        self.layer.contentsScale = UIScreen.main.scale
        self.layer.allowsGroupOpacity = false
        
        self.layer.addSublayer(_mainContainerLayer)
        _mainContainerLayer.anchorPoint = CGPoint(x: 0, y: 0)
        self.transform = CGAffineTransform(scaleX: -1, y: -1)
        
        let contentSize = _contentLayer?.preferredFrameSize()
        _contentLayer?.contentHugging = .required
        _contentLayer?.performLayout()
        //_contentLayer.frame = CGRectMake(0, 0, contentSize.width, contentSize.height)
        _contentLayer?.setNeedsDisplay()
        _contentLayer?.allowsGroupOpacity = false
        _contentLayer?.needsDisplayOnBoundsChange = false
        _contentLayer?.contentsScale = UIScreen.main.scale

        let contentTranslate = CGAffineTransform(translationX: (contentSize?.width)!, y: (contentSize?.height)!)
        let contentInvert = contentTranslate.scaledBy(x: -1, y: -1)
        _contentScrollLayer.showsHorizontalScrollIndicator = false
        _contentScrollLayer.showsVerticalScrollIndicator = false
        _contentScrollLayer.contentSize = contentSize!
        _contentScrollLayer.layer.allowsGroupOpacity = false
        let contentScrollMaxSize = _fabExpandedMaxWidth
        
        _contentScrollLayer.layer.frame = CGRect(x: -contentScrollMaxSize + _fabMargin, y: -contentSize?.height, width: contentScrollMaxSize , height: (contentSize?.height)!)
        _contentScrollLayer.layer.addSublayer(_contentLayer!)
        _contentScrollLayer.layer.transform = CATransform3DMakeAffineTransform(contentInvert)
        _mainContainerLayer._scrollContainerLayer.addSublayer(_contentScrollLayer.layer)
        
        self.addGestureRecognizer(_contentScrollLayer.panGestureRecognizer)
        
        _contentScrollLayer.panGestureRecognizer.require(toFail: _panGestureRecognizer)
        
        _mainContainerLayer.allowsGroupOpacity = false
        _mainContainerLayer.setup(contentSize!, fabSize: _fabSize, fabMargin: _fabMargin, expandedSize: _fabExpandedMaxWidth)
        _mainContainerLayer._scrollContainerLayer.frame = CGRect(x: -((contentSize?.width)! - _fabSize/2 - _fabMargin) - _fabIconToContentMargin, y: ((_fabSize + _fabMargin*2)/2 - (contentSize?.height)!/2), width: (contentSize?.width)!, height: (contentSize?.height)!)
        
        _iconLayer.contents = self.createIconImage()?.cgImage
        _iconLayer.contentsGravity = kCAGravityCenter
        _iconLayer.allowsGroupOpacity = false
        _iconLayer.contentsScale = UIScreen.main.scale
        _mainContainerLayer.addSublayer(_iconLayer)
        
    }
    
    internal func setupNormalAndHighlightBackgroundImages() {
        
        let size = CGSize(width: _fabSize, height: _fabSize)
        let bound = CGSize(width: _fabSize + (_fabMargin*2), height: _fabSize + (_fabMargin*2))
        let path = UIBezierPath(roundedRect: CGRect(x: floor(bound.width/2 - size.width/2), y: floor(bound.height/2 - size.height/2), width: size.width, height: size.height), cornerRadius: size.width/2)
        path.flatness = 0.0
        
        let scale = _fabAntialias ? CGFloat(4) : UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(bound, false, (_fabAntialias ? 4 : 0))
        var ctx = UIGraphicsGetCurrentContext()
        ctx?.setShadow(offset: CGSize(width: 0, height: -7), blur: 9, color: UIColor(white: 0.0, alpha: 0.3).cgColor)
        ctx?.setFillColor(_normalStateColor.cgColor)
        ctx?.addPath(path.cgPath)
        ctx.drawPath(using: kCGPathFill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        _normalImage = image
        
        _mainContainerLayer.contents = image?.cgImage
        _mainContainerLayer.contentsScale = scale
        _mainContainerLayer.allowsEdgeAntialiasing = true
        _mainContainerLayer.edgeAntialiasingMask = CAEdgeAntialiasingMask.LayerBottomEdge | CAEdgeAntialiasingMask.LayerLeftEdge | CAEdgeAntialiasingMask.LayerRightEdge | CAEdgeAntialiasingMask.LayerTopEdge
        let imageXOffset = ((image?.size.width)!-1)/2
        _mainContainerLayer.contentsCenter = CGRect(x: (imageXOffset * scale)/(bound.width * scale),y: 0.0/(bound.height * scale),width: 1.0/(bound.width * scale),height: 1.0/(bound.height * scale))
        
        UIGraphicsBeginImageContextWithOptions(bound, false, (_fabAntialias ? 4 : 0))
        ctx = UIGraphicsGetCurrentContext()
        ctx?.setShadow(offset: CGSize(width: 0, height: -10), blur: 9, color: UIColor(white: 0.0, alpha: 0.3).cgColor)
        ctx?.setFillColor(_activeStateColor.cgColor)
        ctx?.addPath(path.cgPath)
        ctx.drawPath(using: kCGPathFill)
        _highlightImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    internal func createIconImage() -> UIImage? {
        let loadedImage = UIImage(named:"ic_add_black_ios_24dp")
        if loadedImage == nil {
            return nil
        }
        let image = loadedImage!
        var ctx:CGContext? = nil
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0)
        ctx = UIGraphicsGetCurrentContext()!
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.clip(to: imageRect, mask: image.cgImage!)
        ctx?.fill(imageRect)
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
    
    // MARK: - UIView Override Methods
    
    override open var alignmentRectInsets : UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    override open var intrinsicContentSize : CGSize {
        let fabBoundSize = _fabSize + _fabMargin*2
        if self._state == FABViewState.expanded {
            return CGSize(width: _fabExpandedMaxWidth, height: fabBoundSize)
        } else {
            return CGSize(width: fabBoundSize, height: fabBoundSize)
        }
    }
    
    override open class var requiresConstraintBasedLayout : Bool {
        return true
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if (self._state == FABViewState.expanding || self._state == FABViewState.contracting || self._state == FABViewState.panning) {
            return
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        
        if (self._state == FABViewState.expanded) {
            
        } else {
            _mainContainerLayer.bounds = self.bounds
            _iconLayer.frame = self.bounds
        }
        
        CATransaction.commit()
    }
    
    // MARK: AutoLayout Constraint Management
    
    override open func didMoveToSuperview() {
        if (self.superview != nil) {
            let superview = self.superview!
            let size = self.intrinsicContentSize
            
            let width = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: size.width)
            _widthConstraint = width
            
            let rightTrailMargin = NSLayoutConstraint(item: superview, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant:0)
            _rightMarginConstraint = rightTrailMargin
            
            let bottomTrailMargin = NSLayoutConstraint(item: superview, attribute: NSLayoutAttribute.lastBaseline, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant:0)
            _bottomMarginConstraint = bottomTrailMargin
            
            
            superview.addConstraints([rightTrailMargin, bottomTrailMargin, width])
        }
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
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
    
    // MARK: Touch Recognition
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        let convertedPoint = self.layer.convert(point, to: self._mainContainerLayer)
        let hit = self._mainContainerLayer.contains(convertedPoint)
        
        //NSLog("%@ hit", NSNumber(bool: hit))
        //NSLog("%@ hitP", NSStringFromCGPoint(point))
        //NSLog("%@", NSNumber(bool: inside))
        //NSLog("%@ %@", self._mainContainerLayer, NSStringFromCGRect(self._mainContainerLayer.frame))
        
        return hit
    }
    
    // MARK: - State Methods
    
    internal func setNormalAppearance() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        _mainContainerLayer.contents = self._normalImage!.cgImage
        CATransaction.commit()
    }
    
    internal func setHighlightedAppearance() {
        if (self._state != FABViewState.normal) {
            return
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        _mainContainerLayer.contents = self._highlightImage!.cgImage
        CATransaction.commit()
    }
    
    internal func updateGestureRecognizersState() {
        switch self._state {
        case FABViewState.normal:
            self._touchHighlightRecognizer.isEnabled = true
            self._longTouchExpandRecognizer.isEnabled = true
            self._longTouchContractRecognizer.isEnabled = false
            self._doubleTapIconContractRecognizer.isEnabled = false
            break;
        case FABViewState.expanded:
            self._touchHighlightRecognizer.isEnabled = false
            self._longTouchExpandRecognizer.isEnabled = false
            self._longTouchContractRecognizer.isEnabled = true
            self._doubleTapIconContractRecognizer.isEnabled = true
            break;
        default:
            break;
        }
    }
    
    // MARK: - Animation Methods
    
    internal func setExpandedWidthAppearanceAnimated(_ animated: Bool, velocity: CGPoint, completion: (() -> Void)?) {
        self._state = FABViewState.expanded
        self.updateGestureRecognizersState()
        
        let size = self.intrinsicContentSize
        let toRect = CGRect(x: -(size.width-self._iconLayer.frame.size.width), y: 0, width: size.width, height: size.height).integral
        
        self.invalidateIntrinsicContentSize()
        
        if (animated) {
            
            self._state = FABViewState.expanding
            
            let pop = POPSpringAnimation(propertyNamed: kPOPLayerBounds)
            pop?.toValue = NSValue(cgRect: toRect)
            pop?.removedOnCompletion = false
            pop?.velocity = NSValue(cgRect: CGRect(x: 0, y: 0, width: velocity.x, height: 0))
            //pop.springBounciness = 0.01
            //pop.springSpeed = 0.1
            pop?.springBounciness = 12
            pop?.springSpeed = 10
            //            pop.dynamicsTension = 150
            //            pop.dynamicsFriction = 10
            //            pop.dynamicsMass = 1
            pop?.delegate = self
            if completion != nil {
                _expandAnimationCompletionBlock = BlockOperation(block: completion!)
            }
            
            self._mainContainerLayer.pop_add(pop, forKey: FABViewPOPAnimationExpandingKey)
        } else {
            self._mainContainerLayer.bounds = toRect
        }
    }
    
    internal func setContractedWidthAppearanceAnimated(_ animated: Bool, velocity: CGPoint, completion: (() -> Void)?) {
        self._state = FABViewState.normal
        self.updateGestureRecognizersState()
        
        let size = self.intrinsicContentSize
        let toRect = CGRect(x: abs(-(size.width-self._iconLayer.frame.size.width)), y: 0, width: size.width, height: size.height).integral
        
        self.invalidateIntrinsicContentSize()
        
        self._contentScrollLayer.setContentOffset(CGPoint.zero, animated: false)
        
        if (animated) {
            
            self._state = FABViewState.contracting
            
            let pop = POPSpringAnimation(propertyNamed: kPOPLayerBounds)
            pop?.toValue = NSValue(cgRect: toRect)
            pop?.removedOnCompletion = false
            pop?.velocity = NSValue(cgRect:CGRect(x: 0, y: 0, width: velocity.x, height: 0))
            //pop.springBounciness = 0.1
            //pop.springSpeed = 0.1
            pop?.springBounciness = 12
            pop?.springSpeed = 10
            //            pop.dynamicsTension = 150
            //            pop.dynamicsFriction = 10
            //            pop.dynamicsMass = 1
            pop?.delegate = self
            if completion != nil {
                _contractAnimationCompletionBlock = BlockOperation(block: completion!)
            }
            
            self._mainContainerLayer.pop_add(pop, forKey: FABViewPOPAnimationContractingKey)
        } else {
            self._mainContainerLayer.bounds = toRect
        }
    }
    
    // MARK: - Gesture Recognizer methods
    
    func touchHighlightAction(_ gc: UILongPressGestureRecognizer) {
        
        if gc.state == UIGestureRecognizerState.began {
            
            let blockOperation = BlockOperation()
            weak var weakSelf = self
            weak var weakBlockOperation = blockOperation
            
            blockOperation.addExecutionBlock({() in
                if weakBlockOperation != nil && weakBlockOperation!.isCancelled {
                    return
                }
                
                if let strongSelf = weakSelf {
                    strongSelf._highlightStateQueue?.cancelAllOperations()
                    strongSelf._highlightStateQueue = nil
                }
                
                DispatchQueue.main.async {
                    weakSelf?.setHighlightedAppearance()
                }
                
                let delayTime = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    if weakBlockOperation != nil && weakBlockOperation!.isCancelled {
                        return
                    }
                    weakSelf?.setNormalAppearance()
                }
            })
            _highlightStateQueue?.addOperations([blockOperation], waitUntilFinished: true)
                
        } else if gc.state == UIGestureRecognizerState.ended || gc.state == UIGestureRecognizerState.cancelled {
            self.setNormalAppearance()
            
            _lastHighlightOperation?.cancel()
            _highlightStateQueue = SingleEventQueue()
        }
    }
    
    func panGestureAction(_ gc: UIPanGestureRecognizer) {
        switch gc.state {
        case UIGestureRecognizerState.began:
            
            self._state = FABViewState.expanded
            
            let gcPoint = gc.location(in: gc.view)
            let containerPoint = self.layer.convert(gcPoint, to: self._mainContainerLayer)
            let iconPoint = self._mainContainerLayer.convert(containerPoint, to: self._iconLayer)
            if (!self._iconLayer.contains(iconPoint)) {
                gc.isEnabled = false
                gc.isEnabled = true
            }
            
            break;
        case UIGestureRecognizerState.changed:
            
            let point = gc.location(in: self)
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.1)
            
            let fromRect = self._mainContainerLayer.bounds
            var toRect = fromRect
            toRect.origin.x = -(point.x - self._iconLayer.frame.size.width)
            toRect.size.width = point.x
            self._mainContainerLayer.bounds = toRect
            
            CATransaction.commit()
  
            break;
        case UIGestureRecognizerState.ended:
            
            let velocity = gc.velocity(in: gc.view)
            if (velocity.x > 0) {
                self.setExpandedWidthAppearanceAnimated(true, velocity: velocity, completion: nil)
            } else {
                self.setContractedWidthAppearanceAnimated(true, velocity: velocity, completion: nil)
            }
            
            break;
        case UIGestureRecognizerState.cancelled, UIGestureRecognizerState.failed:
            NSLog("pan gc failed or cancelled")
            break;
        default:
            break;
        }
    }
    
    func expandRecognizerAction(_ gc: UILongPressGestureRecognizer) {

        if gc.state != UIGestureRecognizerState.began {
            return
        }
        
        let blockOperation = BlockOperation()
        weak var weakSelf = self
        weak var weakBlockOperation = blockOperation
        
        blockOperation.addExecutionBlock({() in
            if weakBlockOperation != nil {
                if weakBlockOperation!.isCancelled {
                    return
                }
            }
            
            if let strongSelf = weakSelf {
                strongSelf._eventQueue?.cancelAllOperations()
                strongSelf._eventQueue = nil
            }
            
            let expandWidth:() -> Void = {() in
                weakSelf?.setExpandedWidthAppearanceAnimated(true, velocity: CGPoint.zero, completion: {() in
                    if let strongSelf = weakSelf {
                        strongSelf._eventQueue = SingleEventQueue()
                    }
                })
            }
            
            if Thread.isMainThread {
                expandWidth()
            } else {
                DispatchQueue.main.async {
                    expandWidth()
                }
            }
            
        })
        _eventQueue?.addOperations([blockOperation], waitUntilFinished: true)
        
    }
    
    func contractRecognizerAction(_ gc: UILongPressGestureRecognizer) {
        if gc.state != UIGestureRecognizerState.began {
            return
        }
        
        let gcPoint = gc.location(in: self)
        let layerPoint = self.layer.convert(gcPoint, to: self._mainContainerLayer)
        let iconPoint = self._mainContainerLayer.convert(layerPoint, to: self._iconLayer)
        if (!self._iconLayer.contains(iconPoint)) {
            return
        }
        
        let blockOperation = BlockOperation()
        weak var weakSelf = self
        weak var weakBlockOperation = blockOperation
        
        blockOperation.addExecutionBlock({() in
            if weakBlockOperation != nil {
                if weakBlockOperation!.isCancelled {
                    return
                }
                
            }
            if let strongSelf = weakSelf {
                strongSelf._eventQueue?.cancelAllOperations()
                strongSelf._eventQueue = nil
            }
            
            let contractWidth:() -> Void = {() in
                weakSelf?.setContractedWidthAppearanceAnimated(true, velocity: CGPoint.zero) {() in
                    if let strongSelf = weakSelf {
                        strongSelf._eventQueue = SingleEventQueue()
                    }
                }
            }
            
            if Thread.isMainThread {
                contractWidth()
            } else {
                DispatchQueue.main.async {
                    contractWidth()
                }
            }
        })
        _eventQueue?.addOperations([blockOperation], waitUntilFinished: true)
    }
    
    // MARK: - Gesture Recognizer Delegate Methods
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if (gestureRecognizer == _touchHighlightRecognizer && otherGestureRecognizer == _longTouchExpandRecognizer) || (gestureRecognizer == _longTouchExpandRecognizer && otherGestureRecognizer == _touchHighlightRecognizer) {
//            return true
//        }
//        if (gestureRecognizer == _doubleTapIconContractRecognizer && otherGestureRecognizer == _longTouchContractRecognizer) ||
//            (gestureRecognizer == _longTouchContractRecognizer && otherGestureRecognizer == _doubleTapIconContractRecognizer) {
//            return true
//        }
//        if gestureRecognizer == self._panGestureRecognizer || otherGestureRecognizer == self._panGestureRecognizer {
//            return false
//        }
        return true
    }
    
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        let hit = super.hitTest(point, withEvent: event)
//        let containerPoint = self.convertPoint(point, toView: self._contentScrollLayer)
//        //let scrollPoint = self._mainContainerLayer.convertPoint(point, toLayer: self._contentScrollLayer.layer)
//        if (self._contentScrollLayer.pointInside(containerPoint, withEvent: event)) {
//            return self._contentScrollLayer
//        }
////        if hit != nil {
////            NSLog("%@", hit!)
////        } else {
////            NSLog("nope")
////        }
//        return hit
//    }
    
    // MARK: - CAAnimation Delegate Methods
//    override public func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
//        NSLog("%@", anim)
//    }
    
    // MARK: - POP Delegate Methods
    
    open func pop_animationDidStop(_ anim: POPAnimation!, finished: Bool) {
        if anim == self._mainContainerLayer.pop_animation(forKey: FABViewPOPAnimationExpandingKey) as? POPAnimation {
            if finished {
                weak var weakSelf = self
                if self._expandAnimationCompletionBlock != nil {
                    let completion = self._expandAnimationCompletionBlock!
                    completion.completionBlock = {() -> Void in
                        DispatchQueue.main.async {
                            if let strongSelf = weakSelf {
                                strongSelf._state = FABViewState.expanded
                                strongSelf._mainContainerLayer.pop_removeAllAnimations()
                                strongSelf._expandAnimationCompletionBlock = nil
                            }
                        }
                    }
                    completion.start()
                }
            }
        }
        if anim == self._mainContainerLayer.pop_animation(forKey: FABViewPOPAnimationContractingKey) as? POPAnimation {
            if finished {
                weak var weakSelf = self
                if self._contractAnimationCompletionBlock != nil {
                    let completion = self._contractAnimationCompletionBlock!
                    completion.completionBlock = {() -> Void in
                        DispatchQueue.main.async {
                            if let strongSelf = weakSelf {
                                strongSelf._state = FABViewState.normal
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
