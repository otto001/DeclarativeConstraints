//
//  Anchor.swift
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

// MARK: Anchor

/// A protocol that represents a part of an item that can be constrained. Anchors can represent a single point (e.g., top, bottom, leading, trailing, centerX, centerY), a dimension (e.g., width, height) and also a combination of multiple points at once (e.g., bounds).
public protocol Anchor {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    var owner: Constrainable? { get }
}

public extension Anchor {
    /// Copies the anchor and applies the closure to the copy, returning the modified copy.
    /// - Parameter closure: The closure to apply to the copy.
    /// - Returns: The modified copy.
    func modify(_ closure: (_ anchor: inout Self) -> Void) -> Self {
        var copy = self
        closure(&copy)
        return copy
    }
}

// MARK: Base Anchor

/// A type that represents a single anchor point or dimension of a view. 
/// Examples are top, bottom, leading, trailing, centerX, centerY, width, height. 
/// Each anchor has a reference to the item it belongs to, unless it represents a constant value.
/// Depending on the anchor type, it can have an offset and a multiplier.
public protocol BaseAnchor: Anchor {
    var attribute: NSLayoutConstraint.Attribute { get }
    var offset: CGFloat { set get }
    var multiplier: CGFloat { get }
}

/// Adds a constant value to the anchor's offset.
/// - Parameters: lhs: The anchor to modify. rhs: The value to add.
/// - Returns: The modified anchor.
public func +<AnchorType: BaseAnchor>(lhs: AnchorType, rhs: CGFloat) -> AnchorType {
    lhs.modify { anchor in
        anchor.offset += rhs
    }
}

/// Subtracts a constant value from the anchor's offset.
/// - Parameters: lhs: The anchor to modify. rhs: The value to subtract.
/// - Returns: The modified anchor.
public func -<AnchorType: BaseAnchor>(lhs: AnchorType, rhs: CGFloat) -> AnchorType {
    lhs.modify { anchor in
        anchor.offset -= rhs
    }
}


// MARK: Vertical Anchor

/// An Anchor that representing a vertical position of a view. Examples are top, bottom, centerY.
public struct VerticalAnchor: BaseAnchor {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Note: The owner is never nil for horizontal anchors.
    public var owner: Constrainable?

    /// The layout attribute of the anchor. Must be an attribute that represents a dimension.
    public let attribute: NSLayoutConstraint.Attribute

    /// The offset applied to the anchor when creating a constraint.
    public var offset: CGFloat

    /// The multiplier applied to the anchor when creating a constraint. Always 1.0 for vertical anchors.
    public var multiplier: CGFloat { 1.0 }
    
    /// Initializes a new vertical anchor.
    /// - Parameter owner: The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Parameter attribute: The layout attribute of the anchor. Must be an attribute that represents a vertical position.
    /// - Parameter offset: The offset applied to the anchor when creating a constraint. Default is 0.
    public init(owner: Constrainable, attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0) {
        self.owner = owner
        self.attribute = attribute
        self.offset = offset
    }
}

// MARK: - Horizontal Anchor

/// An Anchor that representing a horizontal position of a view. Examples are leading, trailing, centerX.
public struct HorizontalAnchor: BaseAnchor {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Note: The owner is never nil for horizontal anchors.
    public var owner: Constrainable?

    /// The layout attribute of the anchor. Must be an attribute that represents a dimension.
    public let attribute: NSLayoutConstraint.Attribute

    /// The offset applied to the anchor when creating a constraint.
    public var offset: CGFloat

    /// The multiplier applied to the anchor when creating a constraint. Always 1.0 for horizontal anchors.
    public var multiplier: CGFloat { 1.0 }
    
    /// Initializes a new horizontal anchor.
    /// - Parameter owner: The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Parameter attribute: The layout attribute of the anchor. Must be an attribute that represents a horizontal position.
    /// - Parameter offset: The offset applied to the anchor when creating a constraint. Default is 0.
    public init(owner: Constrainable, attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0) {
        self.owner = owner
        self.attribute = attribute
        self.offset = offset
    }
}

// MARK: Dimensional Anchor

/// An Anchor that representing a dimension of a view. Examples are width and height.
public struct DimensionalAnchor: BaseAnchor {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Note: The owner is nil for dimensional anchors that represent a constant value.
    public var owner: Constrainable?

    /// The layout attribute of the anchor. Must be an attribute that represents a dimension.
    public let attribute: NSLayoutConstraint.Attribute

    /// The offset applied to the anchor when creating a constraint.
    public var offset: CGFloat

    /// The multiplier applied to the anchor when creating a constraint. This value is ignored for constant anchors.
    public var multiplier: CGFloat

    /// Initializes a new dimensional anchor.
    /// - Parameter owner: The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Parameter attribute: The layout attribute of the anchor. Must be an attribute that represents a dimension.
    /// - Parameter offset: The offset applied to the anchor when creating a constraint. Default is 0.
    /// - Parameter multiplier: The multiplier applied to the anchor when creating a constraint. Default is 1.
    public init(owner: Constrainable, attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0, multiplier: CGFloat = 1) {
        self.owner = owner
        self.attribute = attribute
        self.offset = offset
        self.multiplier = multiplier
    }

    init(owner: Constrainable?, attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0, multiplier: CGFloat = 1) {
        self.owner = owner
        self.attribute = attribute
        self.offset = offset
        self.multiplier = multiplier
    }
    
    /// Initializes a new dimensional anchor that represents a constant value.
    /// - Parameter value: The constant value that the anchor represents.
    /// - Returns: A new dimensional anchor that represents the constant value.
    public static func constant(_ value: CGFloat) -> Self {
        .init(owner: nil, attribute: .notAnAttribute, offset: value, multiplier: 1)
    }
}

/// Multiplies the anchor's multiplier by a constant value.
/// - Parameters: lhs: The anchor to modify. rhs: The value to multiply the multiplier by.
/// - Returns: The modified anchor.
public func *(lhs: DimensionalAnchor, rhs: CGFloat) -> DimensionalAnchor {
    lhs.modify { anchor in
        anchor.multiplier *= rhs
    }
}

/// Multiplies the anchor's multiplier by a constant value.
/// - Parameters: lhs: The value to multiply the multiplier by. rhs: The anchor to modify.
/// - Returns: The modified anchor.
public func *(lhs: CGFloat, rhs: DimensionalAnchor) -> DimensionalAnchor {
    rhs.modify { anchor in
        anchor.multiplier *= lhs
    }
}

// MARK: Bounds Anchor

/// An Anchor that representing the bounds of a view. 
/// It can be used to create multiple constraints at once, constraining all edges of a view to another view.
/// The anchor can be configured to constraint top, leading, bottom, and trailing edges.
/// The insets can be used to add a constant value to the constraints.
public struct BoundsAnchor: Anchor {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Note: The owner is never nil for bounds anchors.
    public var owner: Constrainable?

    /// The edges that the anchor represents. Default is all edges (top, leading, bottom, trailing).
    var edges: NSDirectionalRectEdge

    /// The insets that are added to the constraints. Default is no insets.
    var insets: NSDirectionalEdgeInsets
    
    /// Initializes a new bounds anchor.
    /// - Parameter owner: The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Parameter edges: The edges that the anchor represents. Default is all edges (top, leading, bottom, trailing).
    /// - Parameter insets: The insets that are added to the constraints. Default is no insets.
    public init(owner: Constrainable, edges: NSDirectionalRectEdge = .all, insets: NSDirectionalEdgeInsets = .init()) {
        self.owner = owner
        self.edges = edges
        self.insets = insets
    }
    
    /// Sets the edges that the anchor represents.
    /// - Parameter edges: The edges that the anchor represents.
    /// - Returns: The modified anchor.
    public func edges(_ edges: NSDirectionalRectEdge) -> Self {
        self.modify { anchor in
            anchor.edges = edges
        }
    }
    
    /// Adds a constant value to the insets for all edges.
    /// - Parameter value: The value to add to the insets.
    /// - Returns: The modified anchor.
    public func inset(_ value: CGFloat) -> Self {
        modify { anchor in
            anchor.insets.add(value)
        }
    }
    
    /// Adds a constant value to the insets for specific edges.
    /// - Parameter edges: The edges to add the value to.
    /// - Parameter value: The value to add to the insets.
    /// - Returns: The modified anchor.
    public func inset(_ edges: NSDirectionalRectEdge, _ value: CGFloat) -> Self {
        modify { anchor in
            anchor.insets.add(value, to: edges)
        }
    }
    
    /// Adds a constant value to the insets for all edges.
    /// - Parameter value: The value to add to the insets.
    /// - Returns: The modified anchor.
    public func inset(_ value: NSDirectionalEdgeInsets) -> Self {
        modify { anchor in
            anchor.insets = .init(top: insets.top + value.top,
                                  leading: insets.leading + value.leading,
                                  bottom: insets.bottom + value.bottom,
                                  trailing: insets.trailing + value.trailing)
        }
    }
    
    /// Offsets the insets by a constant value, moving the anchor's position up, down, left, or right without changing the size.
    /// - Parameter x: The value to add to the leading and trailing insets.
    /// - Parameter y: The value to add to the top and bottom insets.
    /// - Returns: The modified anchor.
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> Self {
        modify { anchor in
            anchor.insets = .init(top: insets.top + y, leading: insets.leading + x, bottom: insets.bottom - y, trailing: insets.trailing - x)
        }
    }
    
    /// Offsets the insets by a constant value, moving the anchor's position up, down, left, or right without changing the size.
    /// - Parameter offset: The value to add to the insets.
    /// - Returns: The modified anchor.
    public func offset(_ offset: CGPoint) -> Self {
        return self.offset(x: offset.x, y: offset.y)
    }
}
