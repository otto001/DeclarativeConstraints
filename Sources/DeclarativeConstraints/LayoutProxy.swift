//
//  LayoutProxy.swift
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

public protocol LayoutProxyProtocol {
    associatedtype Owner: Constrainable
}

/// A proxy that provides access to the anchors of a constrainaible object.
public struct LayoutProxy<Owner: Constrainable>: LayoutProxyProtocol {
    /// The owner of the layout proxy.
    public let owner: Owner
}

public extension LayoutProxy {
    /// The top anchor of the owner.
    var top: VerticalAnchor<Owner> { .init(owner: owner, attribute: .top) }
    /// The centerY anchor of the owner.
    var centerY: VerticalAnchor<Owner> { .init(owner: owner, attribute: .centerY) }
    /// The bottom anchor of the owner.
    var bottom: VerticalAnchor<Owner> { .init(owner: owner, attribute: .bottom) }
    
    /// The left anchor of the owner.
    /// - Note: Do not use this anchor in combination with leading/trailing anchors.
    /// - Note: Use the leading/trailing anchors instead of the left/right anchors to support right-to-left languages.
    var left: HorizontalAnchor<Owner> { .init(owner: owner, attribute: .left) }
    /// The leading anchor of the owner.
    var leading: HorizontalAnchor<Owner> { .init(owner: owner, attribute: .leading) }
    /// The centerX anchor of the owner.
    var centerX: HorizontalAnchor<Owner> { .init(owner: owner, attribute: .centerX) }
    /// The trailing anchor of the owner.
    var trailing: HorizontalAnchor<Owner> { .init(owner: owner, attribute: .trailing) }
    /// The right anchor of the owner.
    /// - Note: Do not use this anchor in combination with leading/trailing anchors.
    /// - Note: Use the leading/trailing anchors instead of the left/right anchors to support right-to-left languages.
    var right: HorizontalAnchor<Owner> { .init(owner: owner, attribute: .right) }
    
    /// The width anchor of the owner.
    var width: DimensionalAnchor<Owner> { .init(owner: owner, attribute: .width) }
    /// The height anchor of the owner.
    var height: DimensionalAnchor<Owner> { .init(owner: owner, attribute: .height) }
    
    /// The bounds anchor of the owner. This anchor represents the top, leading, bottom, and trailing anchors of the owner.
    var bounds: BoundsAnchor<Owner> { .init(owner: owner) }

    /// The vertical bounds anchor of the owner. This anchor represents the top and bottom anchors of the owner.
    /// - Note: The returned anchor is a `BoundsAnchor` with vertical edges set. Function wise it is equivalent to `bounds.edges(.vertical)`.
    var verticalBounds: BoundsAnchor<Owner> { .init(owner: owner).edges(.vertical) }

    /// The horizontal bounds anchor of the owner. This anchor represents the leading and trailing anchors of the owner.
    /// - Note: The returned anchor is a `BoundsAnchor` with horizontal edges set. Function wise it is equivalent to `bounds.edges(.horizontal)`.
    var horizontalBounds: BoundsAnchor<Owner> { .init(owner: owner).edges(.horizontal) }
}

#if canImport(AppKit)
extension NSLayoutGuide: Constrainable {
    /// A layout proxy for the layout guide, providing access to its anchors.
    public var layout: LayoutProxy<NSLayoutGuide> { .init(owner: self) }
}

extension NSView: Constrainable {
    /// A layout proxy for the view, providing access to its anchors.
    public var layout: LayoutProxy<NSView> { .init(owner: self) }
}

public extension LayoutProxy where Owner == NSView {
    /// The first baseline anchor of the owner.
    var firstBaseline: VerticalAnchor<Owner> { .init(owner: owner, attribute: .firstBaseline) }
    /// The last baseline anchor of the owner.
    var lastBaseline: VerticalAnchor<Owner> { .init(owner: owner, attribute: .lastBaseline) }
    
    /// A layout proxy for the layout margins guide of the owner.
    var withMargins: LayoutProxy<NSLayoutGuide> { .init(owner: owner.layoutMarginsGuide) }
    /// A layout proxy for the safe area layout guide of the owner.
    var safeArea: LayoutProxy<NSLayoutGuide> { .init(owner: owner.safeAreaLayoutGuide) }
    
    /// The parent of the owner. This is the layout proxy of the superview, if the owner has a superview.
    var parent: LayoutProxy<NSView>? { owner.superview.map { .init(owner: $0) }}
}
#endif

#if canImport(UIKit)
extension UILayoutGuide: Constrainable {
    /// A layout proxy for the layout guide, providing access to its anchors.
    public var layout: LayoutProxy<UILayoutGuide> { .init(owner: self) }
}

extension UIView: Constrainable {
    /// A layout proxy for the view, providing access to its anchors.
    public var layout: LayoutProxy<UIView> { .init(owner: self) }
}

public extension LayoutProxy where Owner == UIView {
    /// The first baseline anchor of the owner.
    var firstBaseline: VerticalAnchor<Owner> { .init(owner: owner, attribute: .firstBaseline) }
    /// The last baseline anchor of the owner.
    var lastBaseline: VerticalAnchor<Owner> { .init(owner: owner, attribute: .lastBaseline) }
    
    /// A layout proxy for the layout margins guide of the owner.
    var withMargins: LayoutProxy<UILayoutGuide> { .init(owner: owner.layoutMarginsGuide) }
    /// A layout proxy for the safe area layout guide of the owner.
    var safeArea: LayoutProxy<UILayoutGuide> { .init(owner: owner.safeAreaLayoutGuide) }
    
    /// The parent of the owner. This is the layout proxy of the superview, if the owner has a superview.
    var parent: LayoutProxy<UIView>? { owner.superview.map { .init(owner: $0) }}
}
#endif
