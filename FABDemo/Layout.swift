//
//  Layout.swift
//  FABDemo
//
//  Created by Gaurav Khanna on 5/23/15.
//  Copyright (c) 2015 Gaurav Khanna. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

internal enum LLLayoutItemAttribute: CustomStringConvertible {
    case verticalCenter
    case horizontalCenter
    case left
    case top
    case right
    case bottom
    case leftMargin
    case topMargin
    case rightMargin
    case bottomMargin
    case width
    case height
    case blank
    var description : String {
        switch self {
        case .verticalCenter: return "Attribute.VerticalCenter"
        case .horizontalCenter: return "Attribute.HorizontalCenter"
        case .left: return "Attribute.Left"
        case .top: return "Attribute.Top"
        case .right: return "Attribute.Right"
        case .bottom: return "Attribute.Bottom"
        case .leftMargin: return "Attribute.LeftMargin"
        case .topMargin: return "Attribute.TopMargin"
        case .rightMargin: return "Attribute.RightMargin"
        case .bottomMargin: return "Attribute.BottomMargin"
        case .width: return "Attribute.Width"
        case .height: return "Attribute.Height"
        case .blank: return "Attribute.Blank"
        }
    }
    var debugDescription : String {
        return self.description
    }
}

internal enum LLLayoutItemRelationship: CustomStringConvertible {
    case equals
    case greater
    case less
    case greaterOrEqual
    case lessOrEqual
    case none
    var description : String {
        switch self {
        case .equals: return "Relationship.Equals"
        case .greater: return "Relationship.Greater"
        case .less: return "Relationship.Less"
        case .greaterOrEqual: return "Relationship.GreaterOrEqual"
        case .lessOrEqual: return "Relationship.LessOrEqual"
        case .none: return "Relationship.None"
        }
    }
    var debugDescription : String {
        return self.description
    }
}

public enum LLLayoutItemPriority:Int, CustomStringConvertible, ExpressibleByIntegerLiteral {
    case required = 1000
    case high = 750
    case low = 250
    case placeholder = 0
    public init(integerLiteral rawValue: Int) {
        self = LLLayoutItemPriority(integerLiteral: rawValue)
    }
    public var description : String {
        switch self {
        case .required: return "Priority.Required(1000)"
        case .high: return "Priority.High(750)"
        case .low: return "Priority.Low(250)"
        case .placeholder: return "Priority.Placeholder(0)"
        default: return "Priority(\(self.rawValue))"
        }
    }
    var debugDescription : String {
        return self.description
    }
}

open class LLLayoutItem:NSObject, CustomStringConvertible {
    
    fileprivate weak var _referenceLayer:CALayer?
    fileprivate var _referenceConstant:CGFloat = 0
    fileprivate var _referenceMultiplier:CGFloat = 1
    fileprivate var _referenceAttribute:LLLayoutItemAttribute = .blank
    fileprivate var _relationshipType:LLLayoutItemRelationship = .none
    fileprivate var _relationship:LLLayoutItem?
    fileprivate var _priority:LLLayoutItemPriority = .placeholder
    
    fileprivate override init() {
        super.init()
        _referenceAttribute = .blank
    }
    convenience init(attribute: LLLayoutItemAttribute!, layer: CALayer!) {
        self.init()
        _referenceLayer = layer
        _referenceAttribute = attribute
    }
    
    fileprivate func descriptionWithIndent(_ indent: String) -> String! {
        let objClass:AnyClass! = object_getClass(self)
        let objPointer = NSString(format: "%p", self)
        let objProperties:NSMutableString = NSMutableString(capacity: 100)
        if (_referenceLayer != nil) {
            objProperties.append(indent + "  referenceLayer = \(_referenceLayer!)\n")
        }
        if (_referenceConstant != 0.0) {
            objProperties.append(indent + "  referenceConstant = \(_referenceConstant)\n")
        }
        if (_referenceMultiplier != 1) {
            objProperties.append(indent + " referenceMultiplier = \(_referenceMultiplier)")
        }
        if (_referenceAttribute != .blank) {
            objProperties.append(indent + "  referenceAttribute = \(_referenceAttribute)\n")
        }
        if (_relationshipType != .none) {
            objProperties.append(indent + "  relationshipType = \(_relationshipType)\n")
        }
        if (_relationship != nil) {
            objProperties.appendFormat(indent + "  relationship = %@\n", _relationship!.descriptionWithIndent(indent + "  "))
        }
        if (_priority != .placeholder) {
            objProperties.append(indent + "  priority = \(_priority)\n")
        }
        if objProperties.length > 0 {
            return "<\(objClass): \(objPointer)\n\(objProperties)\(indent)>"
        }
        return "<\(objClass): \(objPointer)>"
    }
    
    override open var description: String {
        return self.descriptionWithIndent("")
    }
    
    override open var debugDescription: String {
        return self.descriptionWithIndent("")
    }
    
    final func setReferenceConstraint() {
        switch _referenceAttribute {
        case .width:
            _referenceLayer?.widthConstraint = self
        case .height:
            _referenceLayer?.heightConstraint = self
        case .left:
            _referenceLayer?.leftConstraint = self
        case .top:
            _referenceLayer?.topConstraint = self
        case .right:
            _referenceLayer?.rightConstraint = self
        case .bottom:
            _referenceLayer?.bottomConstraint = self
        case .leftMargin:
            _referenceLayer?.leftMarginConstraint = self
        case .topMargin:
            _referenceLayer?.topMarginConstraint = self
        case .rightMargin:
            _referenceLayer?.rightMarginConstraint = self
        case .bottomMargin:
            _referenceLayer?.bottomMarginConstraint = self
        case .verticalCenter:
            _referenceLayer?.verticalCenterConstraint = self
        case .horizontalCenter:
            _referenceLayer?.horizontalCenterConstraint = self
        case .blank:
            break
        }
    }
    final var Required:LLLayoutItem! {
        get {
            _priority = .required
            return self
        }
        set {
            self.equals(newValue)
        }
    }
    
    final var High:LLLayoutItem! {
        get {
            _priority = .high
            return self
        }
        set {
            self.equals(newValue)
        }
    }
    
    final var Low:LLLayoutItem! {
        get {
            _priority = .low
            return self
        }
        set {
            self.equals(newValue)
        }
    }
    
    final var Placeholder:LLLayoutItem! {
        get {
            _priority = .placeholder
            return self
        }
        set {
            self.equals(newValue)
        }
    }
    
    final var priority:LLLayoutItemPriority! {
        get {
            return _priority
        }
        set {
            _priority = newValue
        }
    }
    
    final public var multiplier:CGFloat! {
        get {
            return _referenceMultiplier
        }
        set {
            _referenceMultiplier = newValue
        }
    }
    
    final fileprivate var attribute:LLLayoutItemAttribute! {
        get {
            return _referenceAttribute
        }
        set {
            _referenceAttribute = newValue
        }
    }
    
    final fileprivate var type:LLLayoutItemRelationship! {
        get {
            return _relationshipType
        }
        set {
            _relationshipType = newValue
        }
    }
    
    final public var constant:CGFloat! {
        get {
            return _referenceConstant
        }
        set {
            _referenceConstant = newValue
        }
    }
    
    final func equals(_ to: CGFloat!) {
        _referenceConstant = to
        _relationshipType = .equals
        setReferenceConstraint()
    }
    final func equals(_ to: LLLayoutItem!) {
        _priority = to._priority
        to._priority = .placeholder
        _relationship = to
        _relationshipType = .equals
        setReferenceConstraint()
    }
    final func greater(_ than: CGFloat!) {
        _referenceConstant = than
        _relationshipType = .greater
        setReferenceConstraint()
    }
    final func greater(_ than: LLLayoutItem!) {
        _priority = than._priority
        than._priority = .placeholder
        _relationship = than
        _relationshipType = .greater
        setReferenceConstraint()
    }
    final func less(_ than: CGFloat!) {
        _referenceConstant = than
        _relationshipType = .less
        setReferenceConstraint()
    }
    final func less(_ than: LLLayoutItem!) {
        _priority = than._priority
        than._priority = .placeholder
        _relationship = than
        _relationshipType = .less
        setReferenceConstraint()
    }
    final func greaterOrEqual(_ than: CGFloat!) {
        _referenceConstant = than
        _relationshipType = .greaterOrEqual
        setReferenceConstraint()
    }
    final func lessOrEqual(_ than: CGFloat!) {
        _referenceConstant = than
        _relationshipType = .lessOrEqual
        setReferenceConstraint()
    }
    final func greaterOrEqual(_ than: LLLayoutItem!) {
        _priority = than._priority
        than._priority = .placeholder
        _relationship = than
        _relationshipType = .greaterOrEqual
        setReferenceConstraint()
    }
    final func lessOrEqual(_ than: LLLayoutItem!) {
        _priority = than._priority
        than._priority = .placeholder
        _relationship = than
        _relationshipType = .lessOrEqual
        setReferenceConstraint()
    }
    final func related(_ to: LLLayoutItem!) {
        _relationship = to
    }
}

public func + (left: LLLayoutItem!, right: LLLayoutItem!) -> LLLayoutItem! {
    left.related(right)
    return left
}

///// Adds the RHS value to the operand's constant
public func + (left: LLLayoutItem!, right: CGFloat!) -> LLLayoutItem! {
    left.constant = left.constant + right
    return left
}

public func - (left: LLLayoutItem!, right: CGFloat!) -> LLLayoutItem! {
    left.constant = left.constant - right
    return left
}

//infix operator >= { associativity right precedence 90 }
public func >= (left: LLLayoutItem!, right: CGFloat!) -> LLLayoutItem! {
    left.greaterOrEqual(right)
    return left
}

//infix operator > { associativity right precedence 90 }
public func > (left: LLLayoutItem!, right: CGFloat!) -> LLLayoutItem! {
    left.greater(right)
    return left
}

//infix operator < { associativity right precedence 90 }
public func < (left: LLLayoutItem!, right: CGFloat!) -> LLLayoutItem! {
    left.less(right)
    return left
}

//infix operator <= { associativity right precedence 90 }
public func <= (left: LLLayoutItem!, right: CGFloat!) -> LLLayoutItem! {
    left.lessOrEqual(right)
    return left
}

//infix operator >= { associativity right precedence 90 }
public func >= (left: LLLayoutItem!, right: LLLayoutItem!) -> LLLayoutItem! {
    left.greaterOrEqual(right)
    return left
}

//infix operator > { associativity right precedence 90 }
public func > (left: LLLayoutItem!, right: LLLayoutItem!) -> LLLayoutItem! {
    left.greater(right)
    return left
}

//infix operator < { associativity right precedence 90 }
public func < (left: LLLayoutItem!, right: LLLayoutItem!) -> LLLayoutItem! {
    left.less(right)
    return left
}

//infix operator <= { associativity right precedence 90 }
public func <= (left: inout LLLayoutItem!, right: LLLayoutItem!) -> LLLayoutItem! {
    left.lessOrEqual(right)
    return left
}

extension CALayer {
    internal class ClosureWrapper {
        final var closure: (() -> Void)?
        
        init(closure: (() -> Void)?) {
            self.closure = closure
        }
    }
    
    fileprivate struct AssociatedKey {
        static var contentHugging = "contentHugging"
        static var contentCompressionResistance = "contentCompressionResistance"
        static var layout = "layout"
        static var performLayout = "performLayout"
        
        static var verticalCenterConstraintExists = "verticalCenterConstraintExists"
        static var horizontalCenterConstraintExists = "horizontalCenterConstraintExists"
        static var leftConstraintExists = "leftConstraintExists"
        static var topConstraintExists = "topConstraintExists"
        static var rightConstraintExists = "rightConstraintExists"
        static var bottomConstraintExists = "bottomConstraintExists"
        static var leftMarginConstraintExists = "leftMarginConstraintExists"
        static var topMarginConstraintExists = "topMarginConstraintExists"
        static var rightMarginConstraintExists = "rightMarginConstraintExists"
        static var bottomMarginConstraintExists = "bottomMarginConstraintExists"
        static var widthConstraintExists = "widthConstraintExists"
        static var heightConstraintExists = "heightConstraintExists"
        
        static var verticalCenterConstraint = "verticalCenterConstraint"
        static var horizontalCenterConstraint = "horizontalCenterConstraint"
        static var leftConstraint = "leftConstraint"
        static var topConstraint = "topConstraint"
        static var rightConstraint = "rightConstraint"
        static var bottomConstraint = "bottomConstraint"
        static var leftMarginConstraint = "leftMarginConstraint"
        static var topMarginConstraint = "topMarginConstraint"
        static var rightMarginConstraint = "rightMarginConstraint"
        static var bottomMarginConstraint = "bottomMarginConstraint"
        static var widthConstraint = "widthConstraint"
        static var heightConstraint = "heightConstraint"
    }
    
    final fileprivate var verticalCenterConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.verticalCenterConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.verticalCenterConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var horizontalCenterConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.horizontalCenterConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.horizontalCenterConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var widthConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.widthConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.widthConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var heightConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.heightConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.heightConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var leftMarginConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.leftMarginConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.leftMarginConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var topMarginConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.topMarginConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.topMarginConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var rightMarginConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.rightMarginConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.rightMarginConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var bottomMarginConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.bottomMarginConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.bottomMarginConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var leftConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.leftConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.leftConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var topConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.topConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.topConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var rightConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.rightConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.rightConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final fileprivate var bottomConstraint: LLLayoutItem! {
        get {
            if let value:LLLayoutItem? = objc_getAssociatedObject(self, &AssociatedKey.bottomConstraint) as? LLLayoutItem {
                if value != nil {
                    return value! as LLLayoutItem!
                }
            }
            return LLLayoutItem()
        }
        set {
            if let value:LLLayoutItem = newValue as LLLayoutItem? {
                objc_setAssociatedObject(self, &AssociatedKey.bottomConstraint, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final func pointToChild(_ C: CALayer!, P: CGPoint!) -> CGPoint! {
        var p:CGPoint = P
        
        let txa:CGFloat = -C.bounds.origin.x - C.bounds.size.width * C.anchorPoint.x;
        let tya:CGFloat = -C.bounds.origin.y - C.bounds.size.height * C.anchorPoint.y;
        
        let txb:CGFloat = C.position.x;
        let tyb:CGFloat = C.position.y;
        
        p.x -= txb;
        p.y -= tyb;
        
        p = p.applying(C.affineTransform().inverted());
        //p = CGPointApplyAffineTransform(p, C.affineTransform())
        //p = CGPointApplyAffineTransform(p, C.affineTransform());
        
        if (C.isGeometryFlipped) {
            var flip:CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: -1.0);
            flip = flip.translatedBy(x: 0.0, y: C.bounds.size.height * (2.0 * C.anchorPoint.y - 1.0));
            p = p.applying(flip.inverted());
        }
        
        p.x -= txa;
        p.y -= tya;
        
        return p;
    }
    
    final func pointFromChild(_ C: CALayer!, P: CGPoint!) -> CGPoint! {
        var p:CGPoint = P
        
        let txb:CGFloat = -C.bounds.origin.x - C.bounds.size.width * C.anchorPoint.x;
        let tyb:CGFloat = -C.bounds.origin.y - C.bounds.size.height * C.anchorPoint.y;
        
        let txa:CGFloat = C.position.x;
        let tya:CGFloat = C.position.y;
        
        p.x += txb;
        p.y += tyb;
        
        if (C.isGeometryFlipped) {
            var flip:CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: -1.0);
            flip = flip.translatedBy(x: 0, y: C.bounds.size.height * (2.0 * C.anchorPoint.y - 1.0));
            p = p.applying(flip);
        }
        
        p = p.applying(C.affineTransform());
        //p = CGPointApplyAffineTransform(p, CGAffineTransformInvert(C.affineTransform()))
        //        p = CGPointApplyAffineTransform(p, CGAffineTransformInvert(C.affineTransform()));
        
        
        p.x += txa;
        p.y += tya;
        
        return p;
    }
    
    final public var performLayout: (() -> Void)! {
        get {
            if let value:ClosureWrapper? = objc_getAssociatedObject(self, &AssociatedKey.performLayout) as? ClosureWrapper {
                if value != nil {
                    return value!.closure
                }
            }
            self.computeLayout()
            if let value:ClosureWrapper? = objc_getAssociatedObject(self, &AssociatedKey.performLayout) as? ClosureWrapper {
                if value != nil {
                    return value!.closure
                }
            }
            return { arg in }
        }
        set {
            if let value:() -> Void = newValue as (() -> Void)? {
                objc_setAssociatedObject(self, &AssociatedKey.performLayout, ClosureWrapper(closure: value), UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final public var layout: [LLLayoutItem]! {
        get {
            if let value:[LLLayoutItem]? = objc_getAssociatedObject(self, &AssociatedKey.layout) as? [LLLayoutItem] {
                if value != nil {
                    return value! as [LLLayoutItem]!
                }
            }
            return []
        }
        set {
            if let value:[LLLayoutItem] = newValue as [LLLayoutItem]? {
                objc_setAssociatedObject(self, &AssociatedKey.layout, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final public var contentHugging: LLLayoutItemPriority! {
        get {
            if let value:Int? = objc_getAssociatedObject(self, &AssociatedKey.contentHugging) as? Int {
                if value != nil {
                    return LLLayoutItemPriority(rawValue: value!)
                    //return value! as Int!
                }
            }
            return LLLayoutItemPriority.low
        }
        set {
            if let value:Int = newValue.rawValue as Int? {
                objc_setAssociatedObject(self, &AssociatedKey.contentHugging, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final public var contentCompressionResistance: LLLayoutItemPriority! {
        get {
            if let value:Int? = objc_getAssociatedObject(self, &AssociatedKey.contentCompressionResistance) as? Int {
                if value != nil {
                    return LLLayoutItemPriority(rawValue: value!)
                }
            }
            return LLLayoutItemPriority.high
        }
        set {
            if let value:Int = newValue.rawValue as Int? {
                objc_setAssociatedObject(self, &AssociatedKey.contentCompressionResistance, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
    
    final public var verticalCenter: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .verticalCenter, layer: self)
        }
        set {
            self.verticalCenter.equals(newValue)
        }
    }
    
    final public var horizontalCenter: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .horizontalCenter, layer: self)
        }
        set {
            self.horizontalCenter.equals(newValue)
        }
    }
    
    final public var left: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .left, layer: self)
        }
        set {
            self.left.equals(newValue)
        }
    }
    
    final public var top: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .top, layer: self)
        }
        set {
            self.top.equals(newValue)
        }
    }
    
    final public var right: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .right, layer: self)
        }
        set {
            self.right.equals(newValue)
        }
    }
    
    final public var bottom: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .bottom, layer: self)
        }
        set {
            self.bottom.equals(newValue)
        }
    }
    
    final public var leftMargin: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .leftMargin, layer: self)
        }
        set {
            self.leftMargin.equals(newValue)
        }
    }
    
    final public var topMargin: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .topMargin, layer: self)
        }
        set {
            self.topMargin.equals(newValue)
        }
    }
    
    final public var rightMargin: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .rightMargin, layer: self)
        }
        set {
            self.rightMargin.equals(newValue)
        }
    }
    
    final public var bottomMargin: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .bottomMargin, layer: self)
        }
        set {
            self.bottomMargin.equals(newValue)
        }
    }
    
    final public var width: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .width, layer: self)
        }
        set {
            self.width.equals(newValue)
        }
    }
    
    final public var height: LLLayoutItem! {
        get {
            return LLLayoutItem(attribute: .height, layer: self)
        }
        set {
            self.height.equals(newValue)
        }
    }
    
    final public func resetLayout() {
        self.layout = []
    }
    
    final fileprivate func computeLayout() {
        if self.superlayer != nil {
            let superBounds = self.superlayer?.bounds
            let bounds = superBounds?.size
            var px:CGFloat = 0
            var py:CGFloat = 0
            let anchor = self.anchorPoint
            let preferredSize = self.preferredFrameSize()
            var width:CGFloat = 0
            var height:CGFloat = 0
            var compression:Int = self.contentCompressionResistance.rawValue
            var hugging:Int = self.contentHugging.rawValue
            if (compression > hugging) {
                width = (superBounds?.width)!
                height = (superBounds?.height)!
            } else {
                width = preferredSize.width
                height = preferredSize.height
            }
            
            if self.rightConstraint.attribute != .blank {
                //if self.rightConstraint.attribute
                if self.rightConstraint.attribute == .right {
                    if self.rightConstraint.type == .equals {
                        if var relationship = self.rightConstraint._relationship {
                            if relationship._referenceAttribute == .right {
                                if var layer = relationship._referenceLayer {
                                    px = 1 - (layer.bounds.width - (width - relationship.constant) * relationship.multiplier)
                                }
                            }
                        } else {
                            px = (superBounds?.width)! - (width - self.rightConstraint.constant) * self.rightConstraint.multiplier
                        }
                    }
                }
            }
            
            
            //            let transform = self.transform
            //            let xTransform:CGFloat = transform.m11
            //            let yTransform:CGFloat = transform.m22
            //
            //            var size = self.contentCompressionResistance > self.contentHugging ? bounds : self.preferredFrameSize()
            //            let constraints = self.layout
            //            for constraint in constraints {
            //                NSLog("%@", constraint)
            //                if constraint._referenceAttribute == LLLayoutItemAttribute.Right && constraint._relationshipType == LLLayoutItemRelationship.Equals {
            //                    size.width = constraint._referenceConstant
            //                }
            //                if constraint._referenceAttribute == LLLayoutItemAttribute.Relationship && constraint._relationshipType == LLLayoutItemRelationship.Equals {
            //                    if let relationshipWidth = constraint._relationship?._referenceLayer?.bounds.size.width {
            //                        if self.contentCompressionResistance > self.contentHugging || size.width > bounds.width {
            //                            size.width = relationshipWidth
            //                            if let relationshipConstant = constraint._relationship?._referenceConstant {
            //                                size.width += relationshipConstant
            //                            }
            //                        } else {
            //                            position.x = relationshipWidth
            //                            if let relationshipConstant = constraint._relationship?._referenceConstant {
            //                                 position.x += relationshipConstant
            //                            }
            //                        }
            //                    }
            //                }
            //            }
            //
            //
            //            var px:CGFloat = position.x + anchor.x * size.width
            //
            //            if xTransform < 0 {
            //                let newPoint = size.width - (anchor.x * size.width)
            //                px = newPoint
            //            } else if xTransform < 1 || xTransform > 1 {
            //                let newPoint = size.width - (xTransform * size.width)
            //                px = newPoint
            //            }
            //
            //
            //            self.position = CGPointMake(px, position.y + anchor.y * size.height)
            //            NSLog("%@", NSStringFromCGPoint(self.position));
            //            let p = CGPointApplyAffineTransform(self.position, self.affineTransform())
            //
            //            NSLog("%@", NSStringFromCGPoint(p))
            //            NSLog("%@", NSStringFromCGPoint(CGPointApplyAffineTransform(p, CGAffineTransformInvert(self.affineTransform()))))
            //            self.bounds = CGRectMake(0, 0, size.width, size.height)
            
            println(self.rightConstraint)
            println(self.leftConstraint)
            println(self.topConstraint)
            
            weak var weakSelf = self
            func layoutSolver() {
                //println("hey")
                if let strongSelf = weakSelf {
                    let x:CGFloat = width - px - (anchor.x * width)
                    let y:CGFloat = height - py - (anchor.y * height)
                    strongSelf.position = CGPoint(x: x, y: y)
                    strongSelf.bounds = CGRect(x: 0, y: 0, width: width, height: height)
                }
            }
            layoutSolver()
            self.performLayout = layoutSolver
        } else {
            println("layer not part of hierarchy")
        }
    }
}

