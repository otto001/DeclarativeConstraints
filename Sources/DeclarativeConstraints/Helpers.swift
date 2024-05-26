//
//  Helpers.swift
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

// MARK: - NSLayoutConstraint.Priority

extension NSLayoutConstraint {
#if canImport(UIKit)
    /// The priority of a constraint. This is a typealias for `UILayoutPriority`.
    public typealias Priority = UILayoutPriority
#endif
}

// MARK: - NSLayoutConstraint.Relation

extension NSLayoutConstraint.Relation {
    /// The inverse of the relation.
    var inverted: Self {
        switch self {
        case .lessThanOrEqual:
            return .greaterThanOrEqual
        case .equal:
            return .equal
        case .greaterThanOrEqual:
            return .lessThanOrEqual
        @unknown default:
            fatalError("Unknown relation")
        }
    }
}

// MARK: - NSDirectionalRectEdge

extension NSDirectionalRectEdge {
    /// A combination of the top and bottom edges.
    public static let vertical: Self = [.top, .bottom]

    /// A combination of the leading and trailing edges.
    public static let horizontal: Self = [.leading, .trailing]
}

// MARK: - NSDirectionalEdgeInsets

extension NSDirectionalEdgeInsets {
    /// Adds the same value to all edges.
    /// - Parameter value: The value to add.
    public mutating func add(_ value: CGFloat) {
        top += value
        leading += value
        bottom += value
        trailing += value
    }
    
    /// Adds the same value to the specified edges.
    /// - Parameter value: The value to add.
    /// - Parameter edges: The edges to add the value to.
    public mutating func add(_ value: CGFloat, to edges: NSDirectionalRectEdge) {
        if edges.contains(.top) { top += value }
        if edges.contains(.leading) { leading += value }
        if edges.contains(.bottom) { bottom += value }
        if edges.contains(.trailing) { trailing += value }
    }
}