//
//  ConstraintBuilder.swift
//  DeclarativeConstraints
//
//  Created by Matteo Ludwig on 01.06.24.
//  Licensend under GPLv3. Please refer to LICENSE file for more information.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// A class used to store constraints that are created in a declarative way. This allows to reuse constraints and avoid creating new ones, even for conditional constraints.
// The class is a subclass of `UILayoutGuide` to allow it to be used in a view hierarchy without interfering with the layout.
// Adding it as a layout guide to a view will also ensure that it is garbage collected when the view is deallocated.
internal class ConstraintStorage: NativeLayoutGuide {
    var storedConstraints: [ConstraintReuseID: NSLayoutConstraint] = [:]
    #if canImport(UIKit)
    override var identifier: String { get { "DeclarativeConstraints.ConstraintStorage" } set {} }
    #else
    override var identifier: NSUserInterfaceItemIdentifier { get {  NSUserInterfaceItemIdentifier("DeclarativeConstraints.ConstraintStorage") } set {} }
    #endif
}
