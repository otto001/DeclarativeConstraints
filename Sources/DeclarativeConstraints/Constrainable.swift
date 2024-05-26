//
//  Constrainable.swift
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

/// A protocol that defines a type that can be constrained.
public protocol Constrainable: AnyObject {}

#if canImport(UIKit)
extension UIView: Constrainable {}
extension UILayoutGuide: Constrainable {}
typealias NativeView = UIView
#endif

#if canImport(AppKit)
extension NSView: Constrainable {}
extension NSLayoutGuide: Constrainable {}
typealias NativeView = NSView
#endif


fileprivate let constraintIdentifier: String = "Declarative"

extension NativeView {
    
    /// Constrain the view and its subviews with the given constraints.
    /// - Parameter block: A block that returns an array of constraints.
    /// - Warning: Only constain views that are subviews of the receiver and the receiver itself, but never reach outside of the receiver's view hierarchy!
    public func constrain(@ConstraintBuilder _ block: () -> [Constraint]) {
        let constraints = block().flatMap {$0.normalized}
        
        // Create a map of all items that are involved in the constraints
        let items: [ObjectIdentifier: any Constrainable] = constraints.reduce(into: [:]) { partialResult, constraint in
            partialResult[.init(constraint.leftItem)] = constraint.leftItem
            if let rightItem = constraint.rightItem {
                partialResult[.init(rightItem)] = rightItem
            }
        }
        
        // Create a map of all constraints of current items that may be reused
        var currentContraints: [ConstraintReuseID: NSLayoutConstraint] = items.values.compactMap {$0 as? NativeView}.flatMap {$0.constraints}.reduce(into: [:]) { partialResult, constraint in
            guard constraint.identifier == constraintIdentifier, let reuseID = constraint.reuseID else { return }
            partialResult[reuseID] = constraint
        }
        
        // Update or create constraints
        for constraint in constraints {
            let constraintID = constraint.reuseID
            if let currentConstraint = currentContraints.removeValue(forKey: constraintID) {
                // Update the existing constraint
                if currentConstraint.constant != constraint.constant {
                    currentConstraint.constant = constraint.constant
                }
                if currentConstraint.priority != constraint.priority {
                    currentConstraint.priority = constraint.priority
                }
                if currentConstraint.isActive != constraint.isActive {
                    currentConstraint.isActive = constraint.isActive
                }
            } else if constraint.isActive {
                // Create a new constraint
                let newConstraint = NSLayoutConstraint(item: constraint.leftItem, attribute: constraint.leftAttribute,
                                                       relatedBy: constraint.relation,
                                                       toItem: constraint.rightItem, attribute: constraint.rightAttribute,
                                                       multiplier: constraint.multiplier,
                                                       constant: constraint.constant)
                
                // Setup the items for AutoLayout (not applied to self for to prevent conflicts)
                if constraint.rightItem !== self, let view = constraint.rightItem as? NativeView {
                    view.translatesAutoresizingMaskIntoConstraints = false
                }
                if constraint.leftItem !== self, let view = constraint.leftItem as? NativeView {
                    view.translatesAutoresizingMaskIntoConstraints = false
                }
                // Set the identifier to identify the constraint as a declarative constraint
                newConstraint.identifier = constraintIdentifier

                newConstraint.priority = constraint.priority
                newConstraint.isActive = true
            }
        }
        
        // Deactivate all remaining constraints that were not reused
        for constraint in currentContraints.values {
            constraint.isActive = false
        }
    }
}
