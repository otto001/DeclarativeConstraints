//
//  NormalizedConstraint.swift
//  DeclarativeConstraints
//
//  Created by Matteo Ludwig on 26.05.24.
//  Licensend under GPLv3. Please refer to LICENSE file for more information.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

/// A normalized constraint that can be used to create a AutoLayout constraint.
/// - Note: This struct represents a layout equation in the form of `x1 [==|<=|>=] (m2/m1)*x2 + (c2-c1)/m1` where `m1` and `m2` are multipliers, `x1` and `x2` are the values to be set (e.g., anchor points or dimensions), and `c1` and `c2` are constants.
internal struct NormalizedConstraint {
    /// The left item of the constraint.
    let leftItem: any Constrainable
    /// The attribute of the left item.
    let leftAttribute: NSLayoutConstraint.Attribute
    /// The right item of the constraint.
    let rightItem: (any Constrainable)?
    /// The attribute of the right item.
    let rightAttribute: NSLayoutConstraint.Attribute
    
    /// The relation between the left and right items.
    let relation: NSLayoutConstraint.Relation
    
    /// The constant of the constraint.
    let constant: CGFloat
    /// The multiplier of the constraint.
    let multiplier: CGFloat
    
    /// The priority of the constraint.
    let priority: NSLayoutConstraint.Priority
    
    /// Whether the constraint is active.
    let isActive: Bool
    
    /// The reuse ID of the constraint. Used to identify existing constraints that can be reused.
    var reuseID: ConstraintReuseID {
        return .init(leftItem: leftItem, leftAttribute: leftAttribute, rightItem: rightItem, rightAttribute: rightAttribute, relation: relation, multiplier: multiplier)
    }
    
    /// Creates a new normalized constraint.
    /// - Parameter equation: The equation that the constraint represents.
    /// - Parameter priority: The priority of the constraint.
    /// - Parameter isActive: Whether the constraint is active.
    init(_ equation: AnyBaseLayoutEquation, priority: NSLayoutConstraint.Priority, isActive: Bool) {
#if canImport(UIKit)
        guard let leftItem = equation.leftAnchor.owner as? UIView else {
            fatalError("The left side of a LayoutEquation must correspond to a UIView")
        }
#endif
#if canImport(AppKit)
        guard let leftItem = equation.leftAnchor.owner as? NSView else {
            fatalError("The left side of a LayoutEquation must correspond to a NSView")
        }
#endif
        self.leftItem = leftItem
        self.leftAttribute = equation.leftAnchor.attribute
        
        self.rightItem = equation.rightAnchor.owner
        self.rightAttribute = equation.rightAnchor.attribute
        
        self.relation = equation.relation
        
        // (a1*x1) + b1 = (a2*x2) + b2
        // (a1*x1) = (a2*x2) + b2 - b1
        // x1 = ((a2*x2) + b2 - b1)/a1 = (a2/a1)*x2 + (b2-b1)/a1
        self.constant = (equation.rightAnchor.offset-equation.leftAnchor.offset)/equation.leftAnchor.multiplier
        self.multiplier = (equation.rightAnchor.multiplier)/equation.leftAnchor.multiplier
        
        self.priority = priority
        self.isActive = isActive
    }
}
