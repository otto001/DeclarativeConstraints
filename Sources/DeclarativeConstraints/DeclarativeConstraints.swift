//
//  DeclarativeConstraints.swift
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


public protocol ConstraintBuilderProtocol {
    func buildConstraints() -> [Constraint]
}

extension Constraint: ConstraintBuilderProtocol {
    public func buildConstraints() -> [Constraint] { [self] }
}


/// A result builder that can be used to create an array of constraints in a declarative way.
@resultBuilder public struct ConstraintBuilder {
    public static func buildBlock(_ components: (any ConstraintBuilderProtocol)...) -> [ConstraintBuilderProtocol] {
        components
    }
    public static func buildArray(_ components: [[ConstraintBuilderProtocol]]) -> [ConstraintBuilderProtocol] {
        components.flatMap {$0}
    }
}
