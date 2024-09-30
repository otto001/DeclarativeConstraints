//
//  ConstraintBuilder.swift
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

extension LayoutEquation: ConstraintBuilderProtocol {
    public func buildConstraints() -> [Constraint] { [Constraint(self, priority: .required)] }
}

internal struct OptionalConstraintBuilder: ConstraintBuilderProtocol {
    var builder: any ConstraintBuilderProtocol
    
    init(_ builder: any ConstraintBuilderProtocol) {
        self.builder = builder
    }
    
    public func buildConstraints() -> [Constraint] {
        builder.buildConstraints()
    }
}

extension Array: ConstraintBuilderProtocol where Element == ConstraintBuilderProtocol {
    public func buildConstraints() -> [Constraint] {
        self.flatMap { $0.buildConstraints() }
    }
}


/// A result builder that can be used to create an array of constraints in a declarative way.
@resultBuilder public struct ConstraintBuilder {
    public static func buildBlock(_ components: (ConstraintBuilderProtocol)...) -> any ConstraintBuilderProtocol {
        return Array(components)
    }

    public static func buildArray(_ components: [any ConstraintBuilderProtocol]) -> any ConstraintBuilderProtocol {
        components
    }
    
    public static func buildOptional(_ component: (any ConstraintBuilderProtocol)?) -> any ConstraintBuilderProtocol {
        component.map { OptionalConstraintBuilder($0) } ?? []
    }
    
    public static func buildEither(first component: any ConstraintBuilderProtocol) -> any ConstraintBuilderProtocol {
        OptionalConstraintBuilder(component)
    }
    
    public static func buildEither(second component: any ConstraintBuilderProtocol) -> any ConstraintBuilderProtocol {
        OptionalConstraintBuilder(component)
    }
}

