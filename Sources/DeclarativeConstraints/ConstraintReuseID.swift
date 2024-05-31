//
//  ConstraintReuseID.swift
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

/// A unique identifier for a constraint that can be reused. Since the items, attributes, relation, and multiplier of an AutoLayout constraint are immutable, this struct contains exactly these properties in order to identify a constraint.
/// Therefore, two constraints with the same reuse ID can be turned into each other by modification of the constant, priority, and isActive properties.
internal struct ConstraintReuseID: Equatable, Hashable {
    
    let leftItem: ObjectIdentifier
    let leftAttribute: NSLayoutConstraint.Attribute
    let rightItem: ObjectIdentifier?
    let rightAttribute: NSLayoutConstraint.Attribute
    let relation: NSLayoutConstraint.Relation
    let multiplier: CGFloat
    
    init(leftItem: any Constrainable, leftAttribute: NSLayoutConstraint.Attribute,
         rightItem: (any Constrainable)?, rightAttribute: NSLayoutConstraint.Attribute,
         relation: NSLayoutConstraint.Relation, multiplier: CGFloat) {
        
        self.leftItem = ObjectIdentifier(leftItem)
        self.leftAttribute = leftAttribute
        self.rightItem = rightItem.map { ObjectIdentifier($0) }
        self.rightAttribute = rightAttribute
        self.relation = relation
        self.multiplier = multiplier
    }
}


internal extension NSLayoutConstraint {
    var reuseID: ConstraintReuseID? {
        guard let firstItem = self.firstItem as? any Constrainable else { return nil }
        return ConstraintReuseID(leftItem: firstItem, leftAttribute: firstAttribute,
                                 rightItem: secondItem as? any Constrainable, rightAttribute: secondAttribute,
                                 relation: relation, multiplier: multiplier)
    }
}
