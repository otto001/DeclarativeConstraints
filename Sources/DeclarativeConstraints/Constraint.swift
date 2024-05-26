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
    public let equation: AnyLayoutEquation
    /// The priority of the constraint.
    public let priority: NSLayoutConstraint.Priority
    /// Whether the constraint is active.
    public var isActive: Bool = true
    
    /// Creates a new constraint.
    /// - Parameter equation: The equation that the constraint represents.
    /// - Parameter priority: The priority of the constraint. Defaults to `.required`.
    public init<AnchorType: Anchor>(_ equation: LayoutEquation<AnchorType>, priority: NSLayoutConstraint.Priority = .required) {
        self.equation = equation.typeErased
        self.priority = priority
    }
    
    /// Sets the active state of the constraint.
    /// - Parameter active: Whether the constraint is active.
    /// - Returns: A modified constraint with the new active state.
    public func active(_ active: Bool) -> Self {
        var copy = self
        copy.isActive = active
        return copy
    }
}


extension Constraint {
    /// The normalized constraints that this constraint represents.
    /// - Note: In the case of a constraint between two base anchors, exactly one normalized constraint is returned.
    internal var normalized: [NormalizedConstraint] {
        
        if let leftBoundsAnchor = equation.leftAnchor as? BoundsAnchor,
            let rightBoundsAnchor = equation.rightAnchor as? BoundsAnchor,
           let leftOwner = leftBoundsAnchor.owner,
           let rightOwner = rightBoundsAnchor.owner {
            
            let edges = leftBoundsAnchor.edges.intersection(rightBoundsAnchor.edges)
            var constraints: [NormalizedConstraint] = []
            if edges.contains(.top) {
                constraints.append(.init(.init(leftAnchor: VerticalAnchor(owner: leftOwner, attribute: .top, offset: leftBoundsAnchor.insets.top),
                                               relation: equation.relation.inverted,
                                               rightAnchor: VerticalAnchor(owner: rightOwner, attribute: .top, offset: rightBoundsAnchor.insets.top)),
                                         priority: priority, isActive: isActive))
            }
            if edges.contains(.leading) {
                constraints.append(.init(.init(leftAnchor: HorizontalAnchor(owner: leftOwner, attribute: .leading, offset: leftBoundsAnchor.insets.leading),
                                               relation: equation.relation.inverted,
                                               rightAnchor: HorizontalAnchor(owner: rightOwner, attribute: .leading, offset: rightBoundsAnchor.insets.leading)),
                                         priority: priority, isActive: isActive))
            }
            if edges.contains(.bottom) {
                constraints.append(.init(.init(leftAnchor: VerticalAnchor(owner: leftOwner, attribute: .bottom, offset: -leftBoundsAnchor.insets.bottom),
                                               relation: equation.relation,
                                               rightAnchor: VerticalAnchor(owner: rightOwner, attribute: .bottom, offset: -rightBoundsAnchor.insets.bottom)),
                                         priority: priority, isActive: isActive))
            }
            if edges.contains(.trailing) {
                constraints.append(.init(.init(leftAnchor: HorizontalAnchor(owner: leftOwner, attribute: .trailing, offset: -leftBoundsAnchor.insets.trailing),
                                               relation: equation.relation,
                                               rightAnchor: HorizontalAnchor(owner: rightOwner, attribute: .trailing, offset: -rightBoundsAnchor.insets.trailing)),
                                         priority: priority, isActive: isActive))
            }
            return constraints
        }
        guard let baseEquation = self.equation.baseEquation else { return [] }
        return [NormalizedConstraint(baseEquation, priority: priority, isActive: isActive)]
    }
}
