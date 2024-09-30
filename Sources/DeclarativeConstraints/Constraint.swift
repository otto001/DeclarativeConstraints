//
//  Constraint.swift
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

/// A constraint includes a layout equation and a priority. Additionally, it can be activated or deactivated. A constraint can be used to create one or multiple AutoLayout constraints, depending on the type of anchors used in the equation.
public struct Constraint {
    /// The equation that the constraint represents.
    public let equation: LayoutEquation
    /// The priority of the constraint.
    public let priority: NSLayoutConstraint.Priority
    
    /// Creates a new constraint.
    /// - Parameter equation: The equation that the constraint represents.
    /// - Parameter priority: The priority of the constraint. Defaults to `.required`.
    public init(_ equation: LayoutEquation, priority: NSLayoutConstraint.Priority = .required) {
        self.equation = equation
        self.priority = priority
    }
    
#if canImport(UIKit)
    /// Creates a new constraint between the owner of the given anchor and its superview. Any offsets or multipliers of the anchor will be applied to the constraint.
    /// - Parameter anchor: The anchor to constrain.
    /// - Parameter priority: The priority of the constraint. Defaults to `.required`.
    public init<AnchorType: LayoutEquationLeftHandSide>(_ anchor: AnchorType, priority: NSLayoutConstraint.Priority = .required) where AnchorType.Owner == UIView {
        guard let otherOwner = anchor.owner.layout.parent?.owner else {
            fatalError("Attempted to constrain a view without a superview to its superview.")
        }
        let rhs = anchor.correspondingAnchor(of: otherOwner)
        self.equation = LayoutEquation(lhs: anchor, relation: .equal, rhs: rhs)
        self.priority = priority
    }
#endif
    
#if canImport(AppKit)
    /// Creates a new constraint between the owner of the given anchor and its superview. Any offsets or multipliers of the anchor will be applied to the constraint.
    /// - Parameter anchor: The anchor to constrain.
    /// - Parameter priority: The priority of the constraint. Defaults to `.required`.
    public init<AnchorType: LayoutEquationLeftHandSide>(_ anchor: AnchorType, priority: NSLayoutConstraint.Priority = .required) where AnchorType.Owner == NSView {
        guard let otherOwner = anchor.owner.layout.parent?.owner else {
            fatalError("Attempted to constrain a view without a superview to its superview.")
        }
        let rhs = anchor.correspondingAnchor(of: otherOwner)
        self.equation = LayoutEquation(lhs: anchor, relation: .equal, rhs: rhs)
        self.priority = priority
    }
#endif
}


extension Constraint {
    /// The normalized constraints that this constraint represents.
    /// - Note: In the case of a constraint between two attribute convertible entities, exactly one normalized constraint is returned.
    internal var normalized: [NormalizedConstraint] {
        return self.equation.attributeEquations.map {
            NormalizedConstraint($0, priority: priority)
        }
    }
}

extension Constraint {
    /// Activate a set of constraints. This function does not support declarative deactivation of constraints. Consider constraints activated with this method as permanent.
    /// - Note: When using this method, the `translatesAutoresizingMaskIntoConstraints` property of the views involved in the constraints will not be updated.
    public static func activate(@ConstraintBuilder _ block: () -> any ConstraintBuilderProtocol) {
        let constraints = block().buildConstraints().flatMap {$0.normalized}
        for constraint in constraints {
            constraint.activate(updateTranslatesAutoresizingMaskIntoConstraints: false)
        }
    }
}
