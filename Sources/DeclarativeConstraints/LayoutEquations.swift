//
//  LayoutEquations.swift
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

// MARK: - AnyBaseLayoutEquation

/// A type-erased layout equation that can be used to create constraints between any base anchors. As only base anchors can be used to create constraints, this type is used to store the equations needed for the creation of constraints.
internal struct AnyBaseLayoutEquation {
    let leftAnchor: any BaseAnchor
    let relation: NSLayoutConstraint.Relation
    let rightAnchor: any BaseAnchor
    
    init(leftAnchor: any BaseAnchor, relation: NSLayoutConstraint.Relation, rightAnchor: any BaseAnchor) {
        self.leftAnchor = leftAnchor
        self.relation = relation
        self.rightAnchor = rightAnchor
    }
}

// MARK: - AnyLayoutEquation

/// A type-erased layout equation that can be used to create constraints between any anchors.
/// - Note: This type is used to store layout equations in a type-erased way. Be careful when using it, as it does not provide type safety or checks that the anchors are compatible. Never use this type directly, always use `LayoutEquation` instead.
public struct AnyLayoutEquation {
    let leftAnchor: any Anchor
    let relation: NSLayoutConstraint.Relation
    let rightAnchor: any Anchor
    
    fileprivate init(leftAnchor: any Anchor, relation: NSLayoutConstraint.Relation, rightAnchor: any Anchor) {
        self.leftAnchor = leftAnchor
        self.relation = relation
        self.rightAnchor = rightAnchor
    }
    
    internal var baseEquation: AnyBaseLayoutEquation? {
        guard let leftAnchor = leftAnchor as? BaseAnchor, let rightAnchor = rightAnchor as? BaseAnchor else { return nil }
        return .init(leftAnchor: leftAnchor, relation: relation, rightAnchor: rightAnchor)
    }
}

// MARK: - LayoutEquation

/// A layout equation is a struct that represents a constraint between two compatible anchors and therefore an equation that needs to be satisfied.
/// It is used to create constraints in a declarative way.
/// - Note: Equations have the form of `(m1*x1) + c1 [==|<=|>=] (m2*x2) + c2` where `m1` and `m2` are multipliers, `x1` and `x2` are the values to be set (e.g., anchor points or dimensions), and `c1` and `c2` are constants.
public struct LayoutEquation<AnchorType: Anchor> {
    /// The left anchor of the equation.
    let leftAnchor: AnchorType
    /// The relation between the left and right anchors.
    let relation: NSLayoutConstraint.Relation
    /// The right anchor of the equation.
    let rightAnchor: AnchorType
    
    /// Creates a new layout equation.
    /// - Parameter leftAnchor: The left anchor of the equation.
    /// - Parameter relation: The relation between the left and right anchors.
    /// - Parameter rightAnchor: The right anchor of the equation.
    public init(leftAnchor: AnchorType, relation: NSLayoutConstraint.Relation, rightAnchor: AnchorType) {
        self.leftAnchor = leftAnchor
        self.relation = relation
        self.rightAnchor = rightAnchor
    }
    
    /// The type-erased version of the equation. The user should generally not use this property.
    internal var typeErased: AnyLayoutEquation {
        .init(leftAnchor: leftAnchor, relation: relation, rightAnchor: rightAnchor)
    }
}

// MARK: - Equations Creation Helpers

/// Creates a layout equation with the equal relation.
public func ==(lhs: VerticalAnchor, rhs: VerticalAnchor) -> LayoutEquation<VerticalAnchor> {
    return .init(leftAnchor: lhs, relation: .equal, rightAnchor: rhs)
}

/// Creates a layout equation with the less than or equal relation.
public func <=(lhs: VerticalAnchor, rhs: VerticalAnchor) -> LayoutEquation<VerticalAnchor> {
    return .init(leftAnchor: lhs, relation: .lessThanOrEqual, rightAnchor: rhs)
}

/// Creates a layout equation with the greater than or equal relation.
public func >=(lhs: VerticalAnchor, rhs: VerticalAnchor) -> LayoutEquation<VerticalAnchor> {
    return .init(leftAnchor: lhs, relation: .greaterThanOrEqual, rightAnchor: rhs)
}
/// Creates a layout equation with the equal relation.
public func ==(lhs: HorizontalAnchor, rhs: HorizontalAnchor) -> LayoutEquation<HorizontalAnchor> {
    return .init(leftAnchor: lhs, relation: .equal, rightAnchor: rhs)
}

/// Creates a layout equation with the less than or equal relation.
public func <=(lhs: HorizontalAnchor, rhs: HorizontalAnchor) -> LayoutEquation<HorizontalAnchor> {
    return .init(leftAnchor: lhs, relation: .lessThanOrEqual, rightAnchor: rhs)
}

/// Creates a layout equation with the greater than or equal relation.
public func >=(lhs: HorizontalAnchor, rhs: HorizontalAnchor) -> LayoutEquation<HorizontalAnchor> {
    return .init(leftAnchor: lhs, relation: .greaterThanOrEqual, rightAnchor: rhs)
}

/// Creates a layout equation with the equal relation.
public func ==(lhs: DimensionalAnchor, rhs: DimensionalAnchor) -> LayoutEquation<DimensionalAnchor> {
    return .init(leftAnchor: lhs, relation: .equal, rightAnchor: rhs)
}

/// Creates a layout equation with the less than or equal relation.
public func <=(lhs: DimensionalAnchor, rhs: DimensionalAnchor) -> LayoutEquation<DimensionalAnchor> {
    return .init(leftAnchor: lhs, relation: .lessThanOrEqual, rightAnchor: rhs)
}

/// Creates a layout equation with the greater than or equal relation.
public func >=(lhs: DimensionalAnchor, rhs: DimensionalAnchor) -> LayoutEquation<DimensionalAnchor> {
    return .init(leftAnchor: lhs, relation: .greaterThanOrEqual, rightAnchor: rhs)
}

/// Creates a layout equation with the equal relation.
public func ==(lhs: BoundsAnchor, rhs: BoundsAnchor) -> LayoutEquation<BoundsAnchor> {
    return .init(leftAnchor: lhs, relation: .equal, rightAnchor: rhs)
}

/// Creates a layout equation with the less than or equal relation.
public func <=(lhs: BoundsAnchor, rhs: BoundsAnchor) -> LayoutEquation<BoundsAnchor> {
    return .init(leftAnchor: lhs, relation: .lessThanOrEqual, rightAnchor: rhs)
}

/// Creates a layout equation with the greater than or equal relation.
public func >=(lhs: BoundsAnchor, rhs: BoundsAnchor) -> LayoutEquation<BoundsAnchor> {
    return .init(leftAnchor: lhs, relation: .greaterThanOrEqual, rightAnchor: rhs)
}
