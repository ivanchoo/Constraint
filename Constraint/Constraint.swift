//
//  Constraint.swift
//  Constraint
//
//  Created by Ivan Choo on 9/10/14.
//  Copyright (c) 2014 ADD Creativeworks. All rights reserved.
//

import Foundation

/// Named tuple of constraint properties returned in `dump()`
public typealias ConstraintProperties = (
    firstItem: AnyObject,
    firstAttribute: NSLayoutAttribute,
    relation: NSLayoutRelation,
    secondItem: AnyObject?,
    secondAttribute: NSLayoutAttribute,
    multiplier: CGFloat,
    constant: CGFloat,
    identifier: String?,
    priority: Float
)

public struct Constraint: DebugPrintable {
    
    private let _firstItem: AnyObject
    private var _firstAttribute: NSLayoutAttribute = .NotAnAttribute
    private var _secondItem: AnyObject!
    private var _relation: NSLayoutRelation = .Equal
    private var _secondAttribute: NSLayoutAttribute = .NotAnAttribute
    private var _multiplier: CGFloat = 1
    private var _constant: CGFloat = 0
    private var _priority: Float = 1000 // defaults to UILayoutPriorityRequired/NSLayoutPriorityRequired
    private var _identifier: String?
    
    public var left: Constraint { return attribute(.Left) }
    public var right: Constraint { return attribute(.Right) }
    public var top: Constraint { return attribute(.Top) }
    public var bottom: Constraint { return attribute(.Bottom) }
    public var leading: Constraint { return attribute(.Leading) }
    public var trailing: Constraint { return attribute(.Trailing) }
    public var width: Constraint { return attribute(.Width) }
    public var height: Constraint { return attribute(.Height) }
    public var centerX: Constraint { return attribute(.CenterX) }
    public var centerY: Constraint { return attribute(.CenterY) }
    public var baseline: Constraint { return attribute(.Baseline) }
    public var firstBaseline: Constraint { return attribute(.FirstBaseline) }
    public var leftMargin: Constraint { return attribute(.LeftMargin) }
    public var rightMargin: Constraint { return attribute(.RightMargin) }
    public var topMargin: Constraint { return attribute(.TopMargin) }
    public var bottomMargin: Constraint { return attribute(.BottomMargin) }
    public var leadingMargin: Constraint { return attribute(.LeadingMargin) }
    public var trailingMargin: Constraint { return attribute(.TrailingMargin) }
    public var centerXWithinMargins: Constraint { return attribute(.CenterXWithinMargins) }
    public var centerYWithinMargins: Constraint { return attribute(.CenterYWithinMargins) }
    public var notAnAttribute: Constraint { return attribute(.NotAnAttribute) }
    
    // MARK: Static helper
    
    /// Returns `NSLayoutAttribute` in human readable format
    public static func readableLayoutAttribute(attribute: NSLayoutAttribute) -> String {
        switch attribute {
        case .Left: return "left"
        case .Right: return "right"
        case .Top: return "top"
        case .Bottom: return "bottom"
        case .Leading: return "leading"
        case .Trailing: return "trailing"
        case .Width: return "width"
        case .Height: return "height"
        case .CenterX: return "centerX"
        case .CenterY: return "centerY"
        case .Baseline: return "baseline"
        case .FirstBaseline: return "firstBaseline"
        case .LeftMargin: return "leftMargin"
        case .RightMargin: return "rightMargin"
        case .TopMargin: return "topMargin"
        case .BottomMargin: return "bottomMargin"
        case .LeadingMargin: return "leadingMargin"
        case .TrailingMargin: return "trailingMargin"
        case .CenterXWithinMargins: return "centerXWithinMargins"
        case .CenterYWithinMargins: return "centerYWithinMargins"
        case .NotAnAttribute: return "notAnAttribute"
        }
    }
    
    /// Returns `NSLayoutRelation` in human readable format
    public static func readableLayoutRelation(relation: NSLayoutRelation) -> String {
        switch relation {
        case .Equal: return "=="
        case .GreaterThanOrEqual: return ">="
        case .LessThanOrEqual: return "<="
        }
    }
    
    /// Helper method used to filter an array of `NSLayoutConstraint`.
    /// For example:
    ///
    ///     view.constraints.filter(Constraint.identifiedBy { $0 == "foo" })
    ///
    public static func identifiedBy(predicate: String -> Bool) -> AnyObject! -> Bool {
        return {
            if let constraint = $0 as? NSLayoutConstraint {
                if let identifier = constraint.identifier {
                    return predicate(identifier)
                }
            }
            return false
        }
    }
    
    public init(_ firstItem: AnyObject) {
        _firstItem = firstItem
    }
    
    // MARK: Modifiers
    
    /// Returns a new instance updated with `identifier` value
    public func identifier(identifier: String!) -> Constraint {
        var copy = self
        copy._identifier = identifier
        return copy
    }
    
    /// Returns a new instance updated with `multiplier` value
    public func multiplier(multiplier: CGFloat) -> Constraint {
        var copy = self
        copy._multiplier = multiplier
        return copy
    }
    
    /// Returns a new instance updated with `constant` value
    public func constant(constant: CGFloat) -> Constraint {
        var copy = self
        copy._constant = constant
        return copy
    }
    
    /// Returns a new instance updated with either `firstAttribute` or `secondAttribute` depending on the context.
    ///
    /// The given `attribute` parameter is applied to `firstAttribute` when
    ///  - `firstAttribute` is `.NotAnAttribute`, or
    ///  - `secondItem` is nil
    ///
    /// This is provided as a convenience to method chaining, for example
    ///
    ///     Constraint(view1).attribute(.Top).equalTo(view2).attribute(.Top)
    ///
    public func attribute(attribute: NSLayoutAttribute) -> Constraint {
        if _firstAttribute == .NotAnAttribute || _secondItem == nil {
            return firstAttribute(attribute)
        } else {
            return secondAttribute(attribute)
        }
    }
    
    /// Returns a new instance updated with `firstAttribute` value
    public func firstAttribute(attribute: NSLayoutAttribute) -> Constraint {
        var copy = self
        copy._firstAttribute = attribute
        return copy
    }
    
    /// Returns a new instance updated with `secondAttribute` value
    public func secondAttribute(attribute: NSLayoutAttribute) -> Constraint {
        var copy = self
        copy._secondAttribute = attribute
        return copy
    }
    
    /// Returns a new instance updated with `secondItem` value
    public func secondItem(secondItem: AnyObject) -> Constraint {
        var copy = self
        copy._secondItem = secondItem
        return copy
    }
    
    /// Returns a new instance updated with `relation` value
    public func relation(relation: NSLayoutRelation) -> Constraint {
        var copy = self
        copy._relation = relation
        return copy
    }
    
    /// Returns a new instance updated with `priority` value
    public func priority(priority: Float) -> Constraint {
        var copy = self
        copy._priority = priority
        return copy
    }
    
    /// Returns a new instance update with `.Equal` relation to the `secondItem`
    public func equalTo(secondItem: AnyObject) -> Constraint {
        return relation(.Equal).secondItem(secondItem)
    }
    
    /// Returns a new instance update with `.LessThanOrEqual` relation to the `secondItem`
    public func lessThanOrEqualTo(secondItem: AnyObject) -> Constraint {
        return relation(.LessThanOrEqual).secondItem(secondItem)
    }
    
    /// Returns a new instance update with `.GreaterThanOrEqual` relation to the `secondItem`
    public func greaterThanOrEqualTo(secondItem: AnyObject) -> Constraint {
        return relation(.GreaterThanOrEqual).secondItem(secondItem)
    }
    
    // MARK: Operations
    
    /// Returns a copy of `Constraint` instance reset to the default values
    public func reset() -> Constraint {
        return Constraint(_firstItem)
    }
    
    /// Returns an instance of `NSLayoutConstraint`
    public func build() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: _firstItem, attribute: _firstAttribute, relatedBy: _relation, toItem: _secondItem, attribute: _secondAttribute, multiplier: _multiplier, constant: _constant)
        constraint.identifier = _identifier
        constraint.priority = _priority
        return constraint
    }
    
    /// Returns an instance of `NSLayoutConstraint` after adding it to the `view`
    public func buildTo(view: UIView) -> NSLayoutConstraint {
        let constraint = build()
        view.addConstraint(constraint)
        return constraint
    }
    
    /// Compares two `Constraint` instances by its values
    public func isEqual(lhs: Constraint, rhs: Constraint) -> Bool {
        let a = lhs.dump(), b = rhs.dump()
        return (a.firstItem === b.firstItem) &&
            (a.firstAttribute == b.firstAttribute) &&
            (a.secondItem === b.secondItem) &&
            (a.secondAttribute == b.secondAttribute) &&
            (a.relation == b.relation) &&
            (a.multiplier == b.multiplier) &&
            (a.constant == b.constant) &&
            (a.identifier == b.identifier) &&
            (a.priority == b.priority)
    }
    
    // MARK: Debugging
    
    public var debugDescription: String {
        get {
            let firstAttribute = Constraint.readableLayoutAttribute(_firstAttribute)
            let relation = Constraint.readableLayoutRelation(_relation)
            let identifier = _identifier == nil ? "" : " '\(_identifier!)'"
            let multiplier = _multiplier == 1 ? "" : " \(_multiplier) *"
            let constant = _constant == 0 ? "" : " + \(_constant)"
            if _secondItem == nil {
                return "<Constraint\(identifier) firstItem.\(firstAttribute) \(relation)\(constant)>"
            } else {
                let secondAttribute = Constraint.readableLayoutAttribute(_secondAttribute)
                return "<Constraint\(identifier) firstItem.\(firstAttribute) \(relation)\(multiplier) secondItem.\(secondAttribute)\(constant)>"
            }
        }
    }
    
    /// Prints to console and returns `self`
    public func print() -> Constraint {
        println("\(self)")
        return self
    }
    
    /// Returns a named tuple of constraint properties
    public func dump() -> ConstraintProperties {
        return (firstItem: _firstItem, firstAttribute: _firstAttribute, relation: _relation, secondItem: _secondItem, secondAttribute: _secondAttribute, multiplier: _multiplier, constant: _constant, identifier: _identifier, priority: _priority)
    }
    
    // MARK: Compositions
    
    /// Returns a composited constraint that snaps the `firstItem` to the edges of `secondItem`
    public func snapToEdgesOf(secondItem: AnyObject) -> Constraints {
        return snapToEdgesOf(secondItem, offset: 0)
    }
    
    /// Returns a composited constraint that snaps the `firstItem` to the edges of `secondItem` offset with equal spacing for all edges
    public func snapToEdgesOf(secondItem: AnyObject, offset: CGFloat) -> Constraints {
        return snapToEdgesOf(secondItem, offset: UIEdgeInsets(top: offset, left: offset, bottom: offset, right: offset))
    }
    
    /// Returns a composited constraint that snaps the `firstItem` to the edges of `secondItem` offset with the respective values defined by `spacing`
    public func snapToEdgesOf(secondItem: AnyObject, offset: UIEdgeInsets) -> Constraints {
        let edges: [(NSLayoutAttribute, CGFloat)] = [
            (.Top, offset.top),
            (.Leading, offset.left),
            (.Bottom, -offset.bottom),
            (.Trailing, -offset.right),
        ]
        let children = edges.map { edge -> Constraint in
            return self.reset()
                .attribute(edge.0)
                .equalTo(secondItem)
                .attribute(edge.0)
                .constant(edge.1)
        }
        return Constraints(children)
    }
    
    /// Returns a composited constraint that snaps the `firstItem` to the margins of `secondItem`
    public func snapToMarginsOf(secondItem: AnyObject) -> Constraints {
        return snapToMarginsOf(secondItem, offset: 0)
    }
    
    /// Returns a composited constraint that snaps the `firstItem` to the margins of `secondItem` offset with equal spacing for all sides
    public func snapToMarginsOf(secondItem: AnyObject, offset: CGFloat) -> Constraints {
        return snapToMarginsOf(secondItem, offset: UIEdgeInsets(top: offset, left: offset, bottom: offset, right: offset))
    }
    
    /// Returns a composited constraint that snaps the `firstItem` to the margins of `secondItem` offset with the respective values defined by `spacing`
    public func snapToMarginsOf(secondItem: AnyObject, offset: UIEdgeInsets) -> Constraints {
        let sides: [(NSLayoutAttribute, NSLayoutAttribute, CGFloat)] = [
            (.Top, .TopMargin, offset.top),
            (.Leading, .LeadingMargin, offset.left),
            (.Bottom, .BottomMargin, -offset.bottom),
            (.Trailing, .TrailingMargin, -offset.right),
        ]
        let children = sides.map { side -> Constraint in
            return self.reset()
                .attribute(side.0)
                .equalTo(secondItem)
                .attribute(side.1)
                .constant(side.2)
        }
        return Constraints(children)
    }
    
    /// Returns a composited constraint where `firstItem` has equal width & height as `secondItem`
    public func equalSizeWith(secondItem: AnyObject) -> Constraints {
        return Constraints([
            reset().width.equalTo(secondItem).width,
            reset().height.equalTo(secondItem).height
        ])
    }
    
    /// Returns a composited constraint where `firstItem` has a constant width and height
    public func equalSize(size: CGSize) -> Constraints {
        return Constraints([
            reset().width.constant(size.width),
            reset().height.constant(size.height)
        ])
    }
    
    
    /// Returns a composited constraint where `firstItem` is aligned vertically and horizontally to the center of `secondItem`
    public func alignCenterWith(secondItem: AnyObject) -> Constraints {
        return Constraints([
            reset().centerY.equalTo(secondItem).centerY,
            reset().centerX.equalTo(secondItem).centerX
        ])
    }
    
}

// MARK: - Constraints

/// A structure that contains multiple `Constraint`
public struct Constraints: SequenceType, DebugPrintable {
    
    public typealias Generator = GeneratorOf<Constraint>
    
    public let children: [Constraint]
    
    public var debugDescription: String {
        var output = ["<ConstraintCompositeBuilder "]
        output += children.map { $0.debugDescription }
        output.append(">")
        return "\n".join(output)
    }
    
    init(_ children: [Constraint]) {
        self.children = children
    }
    
    public func generate() -> Generator {
        return GeneratorOf(children.generate())
    }
    
    /// Returns a new instance by applying the `transform` block to all children
    public func map(transform: Constraint -> Constraint) -> Constraints {
        return Constraints(children.map(transform))
    }

    /// Returns an array of `NSLayoutContstraint`
    public func build() -> [NSLayoutConstraint] {
        return children.map { $0.build() }
    }
    
    /// Returns an array of `NSLayoutConstraint` adding adding them to `view`
    public func buildTo(view: UIView) -> [NSLayoutConstraint] {
        let constraints = build()
        view.addConstraints(constraints)
        return constraints
    }
    
    /// Returns a new instance where all children are updated with `priority` value
    public func priority(priority: Float) -> Constraints {
        return map { $0.priority(priority) }
    }
    
    /// Returns a new instance where all children are updated with `identifier` value
    public func identifier(identifier: String?) -> Constraints {
        return map { $0.identifier(identifier) }
    }
    
    // MARK: Debugging
    
    public func print() -> Constraints {
        println("\(self)")
        return self
    }
    
    public func dump() -> [ConstraintProperties] {
        return children.map { $0.dump() }
    }
}

// MARK: Overload '==', equalTo expression

public func ==(lhs: Constraint, rhs: Constraint) -> Constraint {
    let n = rhs.dump()
    return lhs.equalTo(n.firstItem)
        .secondAttribute(n.firstAttribute)
        .multiplier(n.multiplier)
        .constant(n.constant)
        .identifier(n.identifier)
}

public func ==(lhs: Constraint, rhs: CGFloat) -> Constraint {
    return lhs.relation(.Equal).constant(rhs)
}

public func ==(lhs: Constraint, rhs: Double) -> Constraint {
    return lhs.relation(.Equal).constant(CGFloat(rhs))
}

public func ==(lhs: Constraint, rhs: Float) -> Constraint {
    return lhs.relation(.Equal).constant(CGFloat(rhs))
}

public func ==(lhs: Constraint, rhs: Int) -> Constraint {
    return lhs.relation(.Equal).constant(CGFloat(rhs))
}

// MARK: Overload '==', greaterThanOrEqualTo expression

public func >=(lhs: Constraint, rhs: Constraint) -> Constraint {
    let n = rhs.dump()
    return lhs.greaterThanOrEqualTo(n.firstItem)
        .secondAttribute(n.firstAttribute)
        .multiplier(n.multiplier)
        .constant(n.constant)
        .identifier(n.identifier)
}

public func >=(lhs: Constraint, rhs: CGFloat) -> Constraint {
    return lhs.relation(.GreaterThanOrEqual).constant(rhs)
}

public func >=(lhs: Constraint, rhs: Double) -> Constraint {
    return lhs.relation(.GreaterThanOrEqual).constant(CGFloat(rhs))
}

public func >=(lhs: Constraint, rhs: Float) -> Constraint {
    return lhs.relation(.GreaterThanOrEqual).constant(CGFloat(rhs))
}

public func >=(lhs: Constraint, rhs: Int) -> Constraint {
    return lhs.relation(.GreaterThanOrEqual).constant(CGFloat(rhs))
}

// MARK: Overload '<=', lessThanOrEqualTo expression

public func <=(lhs: Constraint, rhs: Constraint) -> Constraint {
    let n = rhs.dump()
    return lhs.lessThanOrEqualTo(n.firstItem)
        .secondAttribute(n.firstAttribute)
        .multiplier(n.multiplier)
        .constant(n.constant)
        .identifier(n.identifier)
}

public func <=(lhs: Constraint, rhs: CGFloat) -> Constraint {
    return lhs.relation(.LessThanOrEqual).constant(rhs)
}

public func <=(lhs: Constraint, rhs: Double) -> Constraint {
    return lhs.relation(.LessThanOrEqual).constant(CGFloat(rhs))
}

public func <=(lhs: Constraint, rhs: Float) -> Constraint {
    return lhs.relation(.LessThanOrEqual).constant(CGFloat(rhs))
}

public func <=(lhs: Constraint, rhs: Int) -> Constraint {
    return lhs.relation(.LessThanOrEqual).constant(CGFloat(rhs))
}

// MARK: Overload '+', Constraint + n -> Constraint.constant(n)

public func +(lhs: Constraint, rhs: CGFloat) -> Constraint {
    return lhs.constant(rhs)
}

public func +(lhs: Constraint, rhs: Double) -> Constraint {
    return lhs.constant(CGFloat(rhs))
}

public func +(lhs: Constraint, rhs: Float) -> Constraint {
    return lhs.constant(CGFloat(rhs))
}

public func +(lhs: Constraint, rhs: Int) -> Constraint {
    return lhs.constant(CGFloat(rhs))
}

// MARK: Overload '*', n * Constraint -> Constraint.multiplier(n)

public func *(lhs: CGFloat, rhs: Constraint) -> Constraint {
    return rhs.multiplier(lhs)
}

public func *(lhs: Double, rhs: Constraint) -> Constraint {
    return rhs.multiplier(CGFloat(lhs))
}

public func *(lhs: Float, rhs: Constraint) -> Constraint {
    return rhs.multiplier(CGFloat(lhs))
}

public func *(lhs: Int, rhs: Constraint) -> Constraint {
    return rhs.multiplier(CGFloat(lhs))
}

// MARK: Overload '|', Constraint | n -> Constraint.priority(n)

public func |(lhs: Constraint, rhs: CGFloat) -> Constraint {
    return lhs.priority(Float(rhs))
}

public func |(lhs: Constraint, rhs: Double) -> Constraint {
    return lhs.priority(Float(rhs))
}

public func |(lhs: Constraint, rhs: Float) -> Constraint {
    return lhs.priority(rhs)
}

public func |(lhs: Constraint, rhs: Int) -> Constraint {
    return lhs.priority(Float(rhs))
}

// MARK: Overload '|', Constraint | String -> Constraint.identifier(String)

public func |(lhs: Constraint, rhs: String) -> Constraint {
    return lhs.identifier(rhs)
}