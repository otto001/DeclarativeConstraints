//
//  AttributeConvertible.swift
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

// MARK: AttributeConvertible

/// A protocol that defines a type that can be constrained using AutoLayout.
public protocol AttributeConvertible {
    /// The item that should be constrained. If `nil`, the value will be treated as a constant.
    var item: (any Constrainable)? { get }
    /// The attribute (i.e., anchor) of the item that should be constrained. If `item` is `nil`, this value should be `.notAnAttribute`.
    var attribute: NSLayoutConstraint.Attribute { get }
    /// The offset to apply to the anchor. If `item` is `nil`, this value will be treated as a constant.
    var offset: CGFloat { set get }
    /// The multiplier to apply to the anchor. Only used if `item` is not `nil`.
    var multiplier: CGFloat { get }
}


// MARK: LayoutConstant

/// A struct that represents a constant value that can be used on the right-hand side of a layout equation.
internal struct LayoutConstant: LayoutEquationRightHandSide, AttributeConvertible {
    public var item: (any Constrainable)? { nil }
    public var attribute: NSLayoutConstraint.Attribute { .notAnAttribute }
    public var offset: CGFloat
    public var multiplier: CGFloat { 1 }
}
