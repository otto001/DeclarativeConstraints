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
public protocol Constrainable: AnyObject {
    /// The type of the layout proxy that can be used to create constraints.
    associatedtype LayoutProxyType: LayoutProxyProtocol
    
    /// The layout proxy that can be used to create constraints.
    var layout: LayoutProxyType { get }
}

// MARK: Apply Constraints

fileprivate let constraintIdentifier: String = "Declarative"

extension NativeView {
    
    /// Constrain the view with the given constraint.
    /// - Parameter constraint: The constraint to apply to the view.
    @discardableResult private func constrain(_ constraint: NormalizedConstraint, updateTranslatesAutoresizingMaskIntoConstraints: Bool) -> NSLayoutConstraint {
        constraint.activate(updateTranslatesAutoresizingMaskIntoConstraints: updateTranslatesAutoresizingMaskIntoConstraints, doNotUpdateFor: self)
    }
    
    /// Constrain the view with the given constraint.
    /// - Parameter constraint: The constraint to apply to the view.
    public func constrain(_ constraint: Constraint) {
        for normalizedConstraint in constraint.normalized {
            self.constrain(normalizedConstraint, updateTranslatesAutoresizingMaskIntoConstraints: true)
        }
    }

    /// Constrain the view with the given equation.
    /// - Parameter equation: The equation to apply to the view.
    /// - Parameter priority: The priority of the constraint. Defaults to `.required`.
    public func constrain(_ equation: LayoutEquation, priority: NSLayoutConstraint.Priority = .required) {
        self.constrain(Constraint(equation, priority: priority))
    }
    
    private func constraintStorage() -> ConstraintStorage {
        for layoutGuide in self.layoutGuides {
            if let storage = layoutGuide as? ConstraintStorage {
                return storage
            }
        }
        let storage = ConstraintStorage()
        self.addLayoutGuide(storage)
        return storage
    }
    
    /// Constrain the view and its subviews with the given constraints.
    /// - Parameter block: A block that returns an array of constraints.
    /// - Warning: Only constain views that are subviews of the receiver and the receiver itself, but never reach outside of the receiver's view hierarchy!
    public func constrain(@ConstraintBuilder _ block: () -> any ConstraintBuilderProtocol) {
        let constraints = block().buildConstraints().flatMap {$0.normalized}

        let constraintStorage = self.constraintStorage()
        var currentConstraintsMap = constraintStorage.storedConstraints
        
        // Update or create constraints
        for constraint in constraints {
            let constraintID = constraint.reuseID
            if let currentConstraint = currentConstraintsMap.removeValue(forKey: constraintID) {
                // Update the existing constraint
                if currentConstraint.constant != constraint.constant {
                    currentConstraint.constant = constraint.constant
                }
                if currentConstraint.priority != constraint.priority {
                    currentConstraint.priority = constraint.priority
                }
                if !currentConstraint.isActive {
                    currentConstraint.isActive = true
                }
            } else {
                // Set the identifier to identify the constraint as a declarative constraint
                let newConstraint = self.constrain(constraint, updateTranslatesAutoresizingMaskIntoConstraints: true)
                newConstraint.identifier = constraintIdentifier
                constraintStorage.storedConstraints[constraintID] = newConstraint
            }
        }
        
        // Deactivate all remaining constraints that were not reused
        if currentConstraintsMap.count >= 10 {
            // If more ten or more are deactivated, purge to save memory
            for (reuseID, constraint) in currentConstraintsMap {
                constraintStorage.storedConstraints.removeValue(forKey: reuseID)
                constraint.isActive = false
            }
        } else {
            for constraint in currentConstraintsMap.values {
                constraint.isActive = false
            }
        }
    }
}

// MARK: Convenience

extension NativeView {
    
#if canImport(UIKit)
    /// Constrain the view by constraining the given anchor to its superview.
    /// - Parameter anchor: A KeyPath that points to the anchor to constrain.
    /// - Parameter priority: The priority of the constraint. Defaults to `.required`.
    /// - Parameter modifyAnchor: A closure that can be used to modify the anchor before creating the constraint. Use this to apply offsets or multipliers to the anchor.
    public func constrain<AnchorType: LayoutEquationLeftHandSide>(anchorToParent anchor: KeyPath<LayoutProxy<AnchorType.Owner>, AnchorType>, with priority: NSLayoutConstraint.Priority = .required, modifyAnchor: ((_ anchor: AnchorType) -> AnchorType)? = nil) where AnchorType.Owner == UIView {
        var anchor = self.layout[keyPath: anchor]
        anchor = modifyAnchor?(anchor) ?? anchor
        for normalizedConstraint in Constraint(anchor, priority: priority).normalized {
            self.constrain(normalizedConstraint, updateTranslatesAutoresizingMaskIntoConstraints: false)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
#endif
    
#if canImport(AppKit)
    /// Constrain the view by constraining the given anchor to its superview.
    /// - Parameter anchor: A KeyPath that points to the anchor to constrain.
    /// - Parameter priority: The priority of the constraint. Defaults to `.required`.
    /// - Parameter modifyAnchor: A closure that can be used to modify the anchor before creating the constraint. Use this to apply offsets or multipliers to the anchor.
    public func constrain<AnchorType: LayoutEquationLeftHandSide>(anchorToParent anchor: KeyPath<LayoutProxy<AnchorType.Owner>, AnchorType>, with priority: NSLayoutConstraint.Priority = .required, modifyAnchor: ((_ anchor: AnchorType) -> AnchorType)? = nil) where AnchorType.Owner == NSView {
        var anchor = self.layout[keyPath: anchor]
        anchor = modifyAnchor?(anchor) ?? anchor
        for normalizedConstraint in Constraint(anchor, priority: priority).normalized {
            self.constrain(normalizedConstraint, updateTranslatesAutoresizingMaskIntoConstraints: false)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
#endif
}
