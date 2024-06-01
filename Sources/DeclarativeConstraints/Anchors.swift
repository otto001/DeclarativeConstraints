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

/// A protocol that defines a type that represents an anchor in AutoLayout. An anchor is a position or dimension of a view or layout guide.
public protocol Anchor: LayoutEquationRightHandSide {
    // The type of the item (e.g., view or layoutGuide) that the anchor belongs to.
    associatedtype Owner: Constrainable
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    var owner: Owner { get }

    /// Returns the corresponding anchor of another item. This is used to support convenience functions. No offsets or similar should be applied to the returned anchor.
    /// - Example: `view.layout.top.correspondingAnchor(of: otherView)` returns `otherView.layout.top`.
    func correspondingAnchor(of other: Owner) -> Self

    /// Returns an array of attribute equations that express the layout equation. For simple anchors, this will return an array with a single equation. For more complex anchors (i.e., BoundsAnchor), this will return multiple equations.
    static func attributeEquations(for equation: LayoutEquation) -> [AttributeLayoutEquation]
}

extension Anchor where Self: AttributeConvertible {
    /// Converts the LayoutEquation to an array containing a single, equivalent AttributeLayoutEquations.
    /// - Paramerter equation: The equation to convert.
    /// - Returns: An array containing a single AttributeLayoutEquation.
    public static func attributeEquations(for equation: LayoutEquation) -> [AttributeLayoutEquation] {
        guard let lhs = equation.lhs as? Self,  let rhs = equation.rhs as? AttributeConvertible else { return [] }
        return [AttributeLayoutEquation(lhs: lhs, relation: equation.relation, rhs: rhs)]
    }
}

/// Copies the anchor and applies the closure to the copy, returning the modified copy.
/// - Parameter closure: The closure to apply to the copy.
/// - Returns: The modified copy.
fileprivate func modify<T: Anchor>(_ item: T, _ closure: (_ anchor: inout T) -> Void) -> T {
    var copy = item
    closure(&copy)
    return copy
}

// MARK: Anchor Additive and Multiplicative

/// A protocol that enables an anchor to be modified by adding or subtracting a constant value.
public protocol AnchorAdditiveProtocol: AttributeConvertible, Anchor {}

/// A protocol that enables an anchor to be modified by multiplying or dividing by a constant value.
public protocol AnchorMultiplicativeProtocol: AttributeConvertible, Anchor {
    var multiplier: CGFloat { get set }
}

/// Adds a constant value to the anchor's offset.
/// - Parameters: lhs: The anchor to modify. rhs: The value to add.
/// - Returns: The modified anchor.
public func +<AnchorType>(lhs: AnchorType, rhs: CGFloat) -> AnchorType where AnchorType: AnchorAdditiveProtocol {
    modify(lhs) { anchor in
        anchor.offset += rhs
    }
}

/// Subtracts a constant value from the anchor's offset.
/// - Parameters: lhs: The anchor to modify. rhs: The value to subtract.
/// - Returns: The modified anchor.
public func -<AnchorType>(lhs: AnchorType, rhs: CGFloat) -> AnchorType where AnchorType: AnchorAdditiveProtocol  {
    modify(lhs) { anchor in
        anchor.offset -= rhs
    }
}


/// Multiplies the anchor's multiplier by a constant value.
/// - Parameters: lhs: The anchor to modify. rhs: The value to multiply the multiplier by.
/// - Returns: The modified anchor.
public func *<AnchorType>(lhs: AnchorType, rhs: CGFloat) -> AnchorType where AnchorType: AnchorMultiplicativeProtocol {
    modify(lhs) { anchor in
        anchor.multiplier *= rhs
    }
}

/// Multiplies the anchor's multiplier by a constant value.
/// - Parameters: lhs: The value to multiply the multiplier by. rhs: The anchor to modify.
/// - Returns: The modified anchor.
public func *<AnchorType>(lhs: CGFloat, rhs: AnchorType) -> AnchorType  where AnchorType: AnchorMultiplicativeProtocol {
    modify(rhs) { anchor in
        anchor.multiplier *= lhs
    }
}

/// Divides the anchor's multiplier by a constant value.
/// - Parameters: lhs: The anchor to modify. rhs: The value to divide the multiplier by.
/// - Returns: The modified anchor.
public func /<AnchorType>(lhs: AnchorType, rhs: CGFloat) -> AnchorType where AnchorType: AnchorMultiplicativeProtocol  {
    modify(lhs) { anchor in
        anchor.multiplier /= rhs
    }
}

// MARK: Vertical Anchor

/// An Anchor that representing a vertical position of a view. Examples are top, bottom, centerY.
public struct VerticalAnchor<Owner: Constrainable>: Anchor, AttributeConvertible, LayoutEquationLeftHandSide, AnchorAdditiveProtocol {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    public var owner: Owner
    
    /// The item (e.g., view or layoutGuide) that the anchor belongs to. This is the same as `owner`. Never nil for vertical anchors.
    public var item: (any Constrainable)? { self.owner }

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
    public init(owner: Owner, attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0) {
        self.owner = owner
        self.attribute = attribute
        self.offset = offset
    }
    
    /// A function returning the corresponding anchor of another item. This is used to support convenience functions. No offsets or similar are be applied to the returned anchor.
    /// - Example: `view.layout.top.correspondingAnchor(of: otherView)` returns `otherView.layout.top`.
    public func correspondingAnchor(of other: Owner) -> Self {
        return .init(owner: other, attribute: attribute)
    }
}

// MARK: - Horizontal Anchor

/// An Anchor that representing a horizontal position of a view. Examples are leading, trailing, centerX.
public struct HorizontalAnchor<Owner: Constrainable>: Anchor, AttributeConvertible, LayoutEquationLeftHandSide, AnchorAdditiveProtocol {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    public var owner: Owner
    
    /// The item (e.g., view or layoutGuide) that the anchor belongs to. This is the same as `owner`. Never nil for horizontal anchors.
    public var item: (any Constrainable)? { self.owner }

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
    public init(owner: Owner, attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0) {
        self.owner = owner
        self.attribute = attribute
        self.offset = offset
    }
    
    /// A function returning the corresponding anchor of another item. This is used to support convenience functions. No offsets or similar are be applied to the returned anchor.
    /// - Example: `view.layout.leading.correspondingAnchor(of: otherView)` returns `otherView.layout.leading`.
    public func correspondingAnchor(of other: Owner) -> Self {
        return .init(owner: other, attribute: attribute)
    }
}

// MARK: Dimensional Anchor

/// An Anchor that representing a dimension of a view. Examples are width and height.
public struct DimensionalAnchor<Owner: Constrainable>: Anchor, AttributeConvertible, LayoutEquationLeftHandSide, AnchorAdditiveProtocol, AnchorMultiplicativeProtocol {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    public var owner: Owner
    
    /// The item (e.g., view or layoutGuide) that the anchor belongs to. This is the same as `owner`. Never nil for dimensional anchors.
    public var item: (any Constrainable)? { self.owner }

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
    public init(owner: Owner, attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0, multiplier: CGFloat = 1) {
        self.owner = owner
        self.attribute = attribute
        self.offset = offset
        self.multiplier = multiplier
    }

    /// A function returning the corresponding anchor of another item. This is used to support convenience functions. No offsets or similar are be applied to the returned anchor.
    /// - Example: `view.layout.width.correspondingAnchor(of: otherView)` returns `otherView.layout.width`.
    public func correspondingAnchor(of other: Owner) -> Self {
        return .init(owner: owner, attribute: attribute)
    }
}


// MARK: Bounds Anchor

/// An Anchor that representing the bounds of a view. 
/// It can be used to create multiple constraints at once, constraining all edges of a view to another view.
/// The anchor can be configured to constraint top, leading, bottom, and trailing edges.
/// The insets can be used to add a constant value to the constraints.
public struct BoundsAnchor<Owner: Constrainable>: Anchor, LayoutEquationLeftHandSide {
    /// The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Note: The owner is never nil for bounds anchors.
    public var owner: Owner

    /// The edges that the anchor represents. Default is all edges (top, leading, bottom, trailing).
    var edges: NSDirectionalRectEdge

    /// The insets that are added to the constraints. Default is no insets.
    var insets: NSDirectionalEdgeInsets
    
    /// Initializes a new bounds anchor.
    /// - Parameter owner: The item (e.g., view or layoutGuide) that the anchor belongs to.
    /// - Parameter edges: The edges that the anchor represents. Default is all edges (top, leading, bottom, trailing).
    /// - Parameter insets: The insets that are added to the constraints. Default is no insets.
    public init(owner: Owner, edges: NSDirectionalRectEdge = .all, insets: NSDirectionalEdgeInsets = .init()) {
        self.owner = owner
        self.edges = edges
        self.insets = insets
    }
    
    /// A function returning the corresponding anchor of another item. This is used to support convenience functions. No offsets or similar are be applied to the returned anchor.
    /// - Example: `view.layout.bounds.correspondingAnchor(of: otherView)` returns `otherView.layout.bounds`.
    public func correspondingAnchor(of other: Owner) -> Self {
        return .init(owner: other, edges: edges)
    }
    
    /// Sets the edges that the anchor represents.
    /// - Parameter edges: The edges that the anchor represents.
    /// - Returns: The modified anchor.
    public func edges(_ edges: NSDirectionalRectEdge) -> Self {
        modify(self) { anchor in
            anchor.edges = edges
        }
    }
    
    /// Adds a constant value to the insets for all edges.
    /// - Parameter value: The value to add to the insets.
    /// - Returns: The modified anchor.
    public func inset(_ value: CGFloat) -> Self {
        modify(self) { anchor in
            anchor.insets.add(value)
        }
    }
    
    /// Adds a constant value to the insets for specific edges.
    /// - Parameter edges: The edges to add the value to.
    /// - Parameter value: The value to add to the insets.
    /// - Returns: The modified anchor.
    public func inset(_ edges: NSDirectionalRectEdge, _ value: CGFloat) -> Self {
        modify(self) { anchor in
            anchor.insets.add(value, to: edges)
        }
    }
    
    /// Adds a constant value to the insets for all edges.
    /// - Parameter value: The value to add to the insets.
    /// - Returns: The modified anchor.
    public func inset(_ value: NSDirectionalEdgeInsets) -> Self {
        modify(self) { anchor in
            anchor.insets = .init(top: insets.top + value.top,
                                  leading: insets.leading + value.leading,
                                  bottom: insets.bottom + value.bottom,
                                  trailing: insets.trailing + value.trailing)
        }
    }
    
    /// Subtracts a constant value to the insets for all edges.
    /// - Parameter value: The value to subtract from the insets.
    /// - Returns: The modified anchor.
    public func padding(_ value: CGFloat) -> Self {
        modify(self) { anchor in
            anchor.insets.add(-value)
        }
    }
    
    /// Subtracts a constant value to the insets for specific edges.
    /// - Parameter edges: The edges to subtract the value to.
    /// - Parameter value: The value to subtract from the insets.
    /// - Returns: The modified anchor.
    public func padding(_ edges: NSDirectionalRectEdge, _ value: CGFloat) -> Self {
        modify(self) { anchor in
            anchor.insets.add(-value, to: edges)
        }
    }
    
    /// Subtracts a constant value to the insets for all edges.
    /// - Parameter value: The value to subtract from the insets.
    /// - Returns: The modified anchor.
    public func padding(_ value: NSDirectionalEdgeInsets) -> Self {
        modify(self) { anchor in
            anchor.insets = .init(top: insets.top - value.top,
                                  leading: insets.leading - value.leading,
                                  bottom: insets.bottom - value.bottom,
                                  trailing: insets.trailing - value.trailing)
        }
    }
    
    /// Offsets the insets by a constant value, moving the anchor's position up, down, left, or right without changing the size.
    /// - Parameter x: The value to add to the leading and trailing insets.
    /// - Parameter y: The value to add to the top and bottom insets.
    /// - Returns: The modified anchor.
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> Self {
        modify(self) { anchor in
            anchor.insets = .init(top: insets.top + y, leading: insets.leading + x, bottom: insets.bottom - y, trailing: insets.trailing - x)
        }
    }
    
    /// Offsets the insets by a constant value, moving the anchor's position up, down, left, or right without changing the size.
    /// - Parameter offset: The value to add to the insets.
    /// - Returns: The modified anchor.
    public func offset(_ offset: CGPoint) -> Self {
        return self.offset(x: offset.x, y: offset.y)
    }
    
    /// Returns up to four attribute equations that express the layout equation when both anchors are bounds anchors. Otherwise, an empty array is returned.
    /// - Parameter equation: The layout equation that should be converted to attribute equations.
    /// - Returns: An array of attribute equations that express the layout equation.
    public static func attributeEquations(for equation: LayoutEquation) -> [AttributeLayoutEquation] {
        guard let leftBoundsAnchor = equation.lhs as? BoundsAnchor,
              let rightBoundsAnchor = equation.rhs as? BoundsAnchor else { return [] }
        

        let leftOwner = leftBoundsAnchor.owner
        let rightOwner = rightBoundsAnchor.owner

        let edges = leftBoundsAnchor.edges.intersection(rightBoundsAnchor.edges)
        var result: [AttributeLayoutEquation] = []
        if edges.contains(.top) {
            result.append(.init(lhs: VerticalAnchor(owner: leftOwner, attribute: .top, offset: leftBoundsAnchor.insets.top),
                                           relation: equation.relation.inverted,
                                           rhs: VerticalAnchor(owner: rightOwner, attribute: .top, offset: rightBoundsAnchor.insets.top)))
        }
        if edges.contains(.leading) {
            result.append(.init(lhs: HorizontalAnchor(owner: leftOwner, attribute: .leading, offset: leftBoundsAnchor.insets.leading),
                                           relation: equation.relation.inverted,
                                           rhs: HorizontalAnchor(owner: rightOwner, attribute: .leading, offset: rightBoundsAnchor.insets.leading)))
        }
        if edges.contains(.bottom) {
            result.append(.init(lhs: VerticalAnchor(owner: leftOwner, attribute: .bottom, offset: -leftBoundsAnchor.insets.bottom),
                                           relation: equation.relation,
                                           rhs: VerticalAnchor(owner: rightOwner, attribute: .bottom, offset: -rightBoundsAnchor.insets.bottom)))
        }
        if edges.contains(.trailing) {
            result.append(.init(lhs: HorizontalAnchor(owner: leftOwner, attribute: .trailing, offset: -leftBoundsAnchor.insets.trailing),
                                           relation: equation.relation,
                                           rhs: HorizontalAnchor(owner: rightOwner, attribute: .trailing, offset: -rightBoundsAnchor.insets.trailing)))
        }
        return result
    }
}
