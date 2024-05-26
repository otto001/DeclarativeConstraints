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

/// A proxy that provides access to the anchors of a constrainaible object.
public struct LayoutProxy<OwnerType: Constrainable> {
    /// The owner of the layout proxy.
    fileprivate let owner: OwnerType
}

public extension LayoutProxy {
    /// The top anchor of the owner.
    var top: VerticalAnchor { .init(owner: owner, attribute: .top) }
    /// The centerY anchor of the owner.
    var centerY: VerticalAnchor { .init(owner: owner, attribute: .centerY) }
    /// The bottom anchor of the owner.
    var bottom: VerticalAnchor { .init(owner: owner, attribute: .bottom) }
    
    /// The left anchor of the owner.
    /// - Note: Do not use this anchor in combination with leading/trailing anchors.
    /// - Note: Use the leading/trailing anchors instead of the left/right anchors to support right-to-left languages.
    var left: HorizontalAnchor { .init(owner: owner, attribute: .left) }
    /// The leading anchor of the owner.
    var leading: HorizontalAnchor { .init(owner: owner, attribute: .leading) }
    /// The centerX anchor of the owner.
    var centerX: HorizontalAnchor { .init(owner: owner, attribute: .centerX) }
    /// The trailing anchor of the owner.
    var trailing: HorizontalAnchor { .init(owner: owner, attribute: .trailing) }
    /// The right anchor of the owner.
    /// - Note: Do not use this anchor in combination with leading/trailing anchors.
    /// - Note: Use the leading/trailing anchors instead of the left/right anchors to support right-to-left languages.
    var right: HorizontalAnchor { .init(owner: owner, attribute: .right) }
    
    /// The width anchor of the owner.
    var width: DimensionalAnchor { .init(owner: owner, attribute: .width) }
    /// The height anchor of the owner.
    var height: DimensionalAnchor { .init(owner: owner, attribute: .height) }
    
    /// The bounds anchor of the owner. This anchor represents the top, leading, bottom, and trailing anchors of the owner.
    var bounds: BoundsAnchor { .init(owner: owner) }
}

#if canImport(AppKit)
extension NSLayoutGuide {
    /// A layout proxy for the layout guide, providing access to its anchors.
    public var layout: LayoutProxy<NSLayoutGuide> { .init(owner: self) }
}

extension NSView {
    /// A layout proxy for the view, providing access to its anchors.
    public var layout: LayoutProxy<NSView> { .init(owner: self) }
}

public extension LayoutProxy where OwnerType == NSView {
    /// The first baseline anchor of the owner.
    var firstBaseline: VerticalAnchor { .init(owner: owner, attribute: .firstBaseline) }
    /// The last baseline anchor of the owner.
    var lastBaseline: VerticalAnchor { .init(owner: owner, attribute: .lastBaseline) }
    
    /// A layout proxy for the layout margins guide of the owner.
    var withMargins: LayoutProxy<NSLayoutGuide> { .init(owner: owner.layoutMarginsGuide) }
    /// A layout proxy for the safe area layout guide of the owner.
    var safeArea: LayoutProxy<NSLayoutGuide> { .init(owner: owner.safeAreaLayoutGuide) }
}
#endif

#if canImport(UIKit)
extension UILayoutGuide {
    /// A layout proxy for the layout guide, providing access to its anchors.
    public var layout: LayoutProxy<UILayoutGuide> { .init(owner: self) }
}

extension UIView {
    /// A layout proxy for the view, providing access to its anchors.
    public var layout: LayoutProxy<UIView> { .init(owner: self) }
}

public extension LayoutProxy where OwnerType == UIView {
    /// The first baseline anchor of the owner.
    var firstBaseline: VerticalAnchor { .init(owner: owner, attribute: .firstBaseline) }
    /// The last baseline anchor of the owner.
    var lastBaseline: VerticalAnchor { .init(owner: owner, attribute: .lastBaseline) }
    
    /// A layout proxy for the layout margins guide of the owner.
    var withMargins: LayoutProxy<UILayoutGuide> { .init(owner: owner.layoutMarginsGuide) }
    /// A layout proxy for the safe area layout guide of the owner.
    var safeArea: LayoutProxy<UILayoutGuide> { .init(owner: owner.safeAreaLayoutGuide) }
}
#endif
