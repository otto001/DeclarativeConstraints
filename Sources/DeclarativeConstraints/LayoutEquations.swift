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

// MARK: - AttributeLayoutEquation

/// A layout equation that can be used to create an AutoLayout constraint. Therefore, both sides of the equation must be AttributeConvertible. The equation has the form `(m1 * x1) + c1 [==|>=|<=] (m2 * x2) + c2`, where `m1` and `m2` are multipliers, `x1` and `x2` are the values to be set (e.g., anchor points or dimensions), and `c1` and `c2` are constants. The equation can also be written as `lhs [==|>=|<=] rhs`.
public struct AttributeLayoutEquation {
    /// The left-hand side of the equation.
    public let lhs: any (AttributeConvertible & Anchor)
    /// The relation between the left and right side of the equation.
    public let relation: NSLayoutConstraint.Relation
    /// The right-hand side of the equation.
    public let rhs: any AttributeConvertible
    
    /// Creates a new attribute equation.
    /// - Parameter lhs: The left-hand side of the equation.
    /// - Parameter relation: The relation between the left and right side of the equation.
    /// - Parameter rhs: The right-hand side of the equation.
    public init(lhs: any (AttributeConvertible & Anchor), relation: NSLayoutConstraint.Relation, rhs: any AttributeConvertible) {
        self.lhs = lhs
        self.relation = relation
        self.rhs = rhs
    }
}

// MARK: - LayoutEquation

/// A protocol that defines a type that can be used on the right-hand side of a layout equation. This protocol is used to provide type safety when creating layout equations. The right-hand side of a layout equation can be an anchor or a constant.
public protocol LayoutEquationRightHandSide {}

/// A protocol that defines a type that can be used on the left-hand side of a layout equation.  This protocol is used to provide type safety when creating layout equations. The left-hand side of a layout equation must be an anchor. Every entity that can be used on the left-hand side of a layout equation can also be used on the right-hand side.
public protocol LayoutEquationLeftHandSide: LayoutEquationRightHandSide, Anchor {}

/// A layout equation that can be used to create constraints. A layout equation consists of a left-hand side, a relation, and a right-hand side. The left-hand side must be an anchor, while the right-hand side can be an anchor or a constant value. The equation has the form `lhs relation rhs`.
public struct LayoutEquation {
    /// The left-hand side of the equation. This must be an anchor.
    public let lhs: any LayoutEquationLeftHandSide
    /// The relation between the left and right side of the equation.
    public let relation: NSLayoutConstraint.Relation
    /// The right-hand side of the equation. This can be an anchor or a constant value.
    public let rhs: any LayoutEquationRightHandSide
    
    /// Creates a new layout equation between two anchors of the same type.
    /// - Paramter lhs: The left-hand side of the equation.
    /// - Paramter relation: The relation between the left and right side of the equation.
    /// - Paramter rhs: The right-hand side of the equation.
    public init<AnchorType: LayoutEquationLeftHandSide>(lhs: AnchorType, relation: NSLayoutConstraint.Relation, rhs: AnchorType) {
        self.lhs = lhs
        self.relation = relation
        self.rhs = rhs
    }
    
    /// Creates a new layout equation between two vertical anchors.
    /// - Parameter lhs: The left-hand side of the equation.
    /// - Parameter relation: The relation between the left and right side of the equation.
    /// - Parameter rhs: The right-hand side of the equation.
    public init<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: VerticalAnchor<LeftOwner>, relation: NSLayoutConstraint.Relation, rhs: VerticalAnchor<RightOwner>) {
        self.lhs = lhs
        self.relation = relation
        self.rhs = rhs
    }
    
    /// Creates a new layout equation between two horizontal anchors.
    /// - Parameter lhs: The left-hand side of the equation.
    /// - Parameter relation: The relation between the left and right side of the equation.
    /// - Parameter rhs: The right-hand side of the equation.
    public init<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: HorizontalAnchor<LeftOwner>, relation: NSLayoutConstraint.Relation, rhs: HorizontalAnchor<RightOwner>) {
        self.lhs = lhs
        self.relation = relation
        self.rhs = rhs
    }
    
    /// Creates a new layout equation between two dimensional anchors.
    /// - Parameter lhs: The left-hand side of the equation.
    /// - Parameter relation: The relation between the left and right side of the equation.
    /// - Parameter rhs: The right-hand side of the equation.
    public init<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: DimensionalAnchor<LeftOwner>, relation: NSLayoutConstraint.Relation, rhs: DimensionalAnchor<RightOwner>) {
        self.lhs = lhs
        self.relation = relation
        self.rhs = rhs
    }
    
    /// Creates a new layout equation between a dimensional anchor and a constant value.
    /// - Parameter lhs: The left-hand side of the equation.
    /// - Parameter relation: The relation between the left and right side of the equation.
    /// - Parameter constant: The constant value on the right-hand side of the equation.
    public init<LeftOwner: Constrainable>(lhs: DimensionalAnchor<LeftOwner>, relation: NSLayoutConstraint.Relation, constant: CGFloat) {
        self.lhs = lhs
        self.relation = relation
        self.rhs = LayoutConstant(offset: constant)
    }
    
    /// Creates a new layout equation between two bounds anchors.
    /// - Parameter lhs: The left-hand side of the equation.
    /// - Parameter relation: The relation between the left and right side of the equation.
    /// - Parameter rhs: The right-hand side of the equation.
    public init<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: BoundsAnchor<LeftOwner>, relation: NSLayoutConstraint.Relation, rhs: BoundsAnchor<RightOwner>) {
        self.lhs = lhs
        self.relation = relation
        self.rhs = rhs
    }
    
    /// An array of attribute equations for the given layout equation.
    internal var attributeEquations: [AttributeLayoutEquation] {
        return type(of: lhs).attributeEquations(for: self)
    }
}


// MARK: - Equations Creation Helpers

/// Creates a layout equation with the equal relation between two vertical anchors.
public func ==<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: VerticalAnchor<LeftOwner>, rhs: VerticalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .equal, rhs: rhs)
}

/// Creates a layout equation with the equal relation between two horizontal anchors.
public func ==<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: HorizontalAnchor<LeftOwner>, rhs: HorizontalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .equal, rhs: rhs)
}

/// Creates a layout equation with the equal relation between two dimensional anchors.
public func ==<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: DimensionalAnchor<LeftOwner>, rhs: DimensionalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .equal, rhs: rhs)
}

/// Creates a layout equation with the equal relation between a dimensional anchor and a constant value.
public func ==<LeftOwner: Constrainable>(lhs: DimensionalAnchor<LeftOwner>, rhs: CGFloat) -> LayoutEquation {
    return .init(lhs: lhs, relation: .equal, constant: rhs)
}

/// Creates a layout equation with the equal relation between two bounds anchors.
public func ==<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: BoundsAnchor<LeftOwner>, rhs: BoundsAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .equal, rhs: rhs)
}

/// Creates a layout equation with the less than or equal relation between two vertical anchors.
public func <=<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: VerticalAnchor<LeftOwner>, rhs: VerticalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .lessThanOrEqual, rhs: rhs)
}

/// Creates a layout equation with the less than or equal relation between two horizontal anchors.
public func <=<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: HorizontalAnchor<LeftOwner>, rhs: HorizontalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .lessThanOrEqual, rhs: rhs)
}

/// Creates a layout equation with the less than or equal relation between two dimensional anchors.
public func <=<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: DimensionalAnchor<LeftOwner>, rhs: DimensionalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .lessThanOrEqual, rhs: rhs)
}

/// Creates a layout equation with the less than or equal relation between a dimensional anchor and a constant value.
public func <=<LeftOwner: Constrainable>(lhs: DimensionalAnchor<LeftOwner>, rhs: CGFloat) -> LayoutEquation {
    return .init(lhs: lhs, relation: .lessThanOrEqual, constant: rhs)
}

/// Creates a layout equation with the less than or equal relation between two bounds anchors.
public func <=<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: BoundsAnchor<LeftOwner>, rhs: BoundsAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .lessThanOrEqual, rhs: rhs)
}

/// Creates a layout equation with the greater than or equal relation between two vertical anchors.
public func >=<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: VerticalAnchor<LeftOwner>, rhs: VerticalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .greaterThanOrEqual, rhs: rhs)
}

/// Creates a layout equation with the greater than or equal relation between two horizontal anchors.
public func >=<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: HorizontalAnchor<LeftOwner>, rhs: HorizontalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .greaterThanOrEqual, rhs: rhs)
}

/// Creates a layout equation with the greater than or equal relation between two dimensional anchors.
public func >=<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: DimensionalAnchor<LeftOwner>, rhs: DimensionalAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .greaterThanOrEqual, rhs: rhs)
}

/// Creates a layout equation with the greater than or equal relation between a dimensional anchor and a constant value.
public func >=<LeftOwner: Constrainable>(lhs: DimensionalAnchor<LeftOwner>, rhs: CGFloat) -> LayoutEquation {
    return .init(lhs: lhs, relation: .greaterThanOrEqual, constant: rhs)
}

/// Creates a layout equation with the greater than or equal relation between two bounds anchors.
public func >=<LeftOwner: Constrainable, RightOwner: Constrainable>(lhs: BoundsAnchor<LeftOwner>, rhs: BoundsAnchor<RightOwner>) -> LayoutEquation {
    return .init(lhs: lhs, relation: .greaterThanOrEqual, rhs: rhs)
}
