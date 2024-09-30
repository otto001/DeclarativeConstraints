//
//  DeclarativeConstraintsTests.swift
//  DeclarativeConstraintsTests
//
//  Created by Matteo Ludwig on 26.05.24.
//  Licensend under GPLv3. Please refer to LICENSE file for more information.
//


import XCTest
@testable import DeclarativeConstraints

final class DeclarativeConstraintsTests: XCTestCase {
    
    func assertEquality<X: AnyObject>(_ constraint: NSLayoutConstraint, firstAnchor: NSLayoutAnchor<X>, secondAnchor: NSLayoutAnchor<X>, constant: CGFloat, multiplier: CGFloat, priority: NSLayoutConstraint.Priority, isActive: Bool = true, file: StaticString = #file, line: UInt = #line) {
        if constraint.firstAnchor == secondAnchor {
            XCTAssertEqual(constraint.firstAnchor, secondAnchor)
            XCTAssertEqual(constraint.secondAnchor, firstAnchor)
            XCTAssertEqual(constraint.constant, -constant)
            XCTAssertEqual(constraint.multiplier, 1/multiplier)
        } else {
            XCTAssertEqual(constraint.firstAnchor, firstAnchor)
            XCTAssertEqual(constraint.secondAnchor, secondAnchor)
            XCTAssertEqual(constraint.constant, constant)
            XCTAssertEqual(constraint.multiplier, multiplier)
        }
        
        XCTAssertEqual(constraint.priority, priority)
        XCTAssertEqual(constraint.isActive, isActive)
    }
    
    func testConstraints() throws {
        let parent = UIView()
        let child1 = UIView()
        let child2 = UIView()
        parent.addSubview(child1)
        parent.addSubview(child2)
        
        parent.constrain {
            child1.layout.top == parent.layout.top + 10
            child1.layout.leading == parent.layout.leading
            child1.layout.bottom == parent.layout.bottom
            child1.layout.trailing == parent.layout.trailing
            
            child2.layout.width == parent.layout.width
            
            child1.layout.height == parent.layout.width
            child1.layout.aspect == 0.5
        }
        
        let parentConstraints = parent.constraints.sorted { $0.firstAttribute.rawValue < $1.firstAttribute.rawValue }
        let child1Constraints = child1.constraints.sorted { $0.firstAttribute.rawValue < $1.firstAttribute.rawValue }
        
        XCTAssertEqual(parentConstraints.count, 6)
        XCTAssertEqual(child1Constraints.count, 1)
        
        assertEquality(parentConstraints[0], firstAnchor: child1.topAnchor, secondAnchor: parent.topAnchor, constant: 10, multiplier: 1, priority: .required)
        assertEquality(parentConstraints[1], firstAnchor: child1.bottomAnchor, secondAnchor: parent.bottomAnchor, constant: 0, multiplier: 1, priority: .required)
        assertEquality(parentConstraints[2], firstAnchor: child1.leadingAnchor, secondAnchor: parent.leadingAnchor, constant: 0, multiplier: 1, priority: .required)
        assertEquality(parentConstraints[3], firstAnchor: child1.trailingAnchor, secondAnchor: parent.trailingAnchor, constant: 0, multiplier: 1, priority: .required)
        
        assertEquality(parentConstraints[4], firstAnchor: parent.widthAnchor, secondAnchor: child2.widthAnchor, constant: 0, multiplier: 1, priority: .required)
        assertEquality(parentConstraints[5], firstAnchor: parent.widthAnchor, secondAnchor: child1.heightAnchor, constant: 0, multiplier: 1, priority: .required)
        
        
        assertEquality(child1Constraints[0], firstAnchor: child1.heightAnchor, secondAnchor: child1.widthAnchor, constant: 0, multiplier: 2, priority: .required)
    }
    
    func testReuse() throws {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        
        parent.constrain {
            Constraint(child.layout.top == parent.layout.top)
            Constraint(child.layout.leading == parent.layout.leading)
        }
        let parentConstraints1 = parent.constraints.sorted { $0.firstAttribute.rawValue < $1.firstAttribute.rawValue }
        
        parent.constrain {
            Constraint(child.layout.top == parent.layout.top)
            Constraint(child.layout.leading - 2 == parent.layout.leading + 4)
        }
        
        let parentConstraints2 = parent.constraints.sorted { $0.firstAttribute.rawValue < $1.firstAttribute.rawValue }
        
        for (pc1, pc2) in zip(parentConstraints1, parentConstraints2) {
            XCTAssertTrue(pc1 === pc2)
        }
    }
    
    func testDeactivate() throws {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        
        var x: Bool = true
        
        parent.constrain {
            if x {
                Constraint(child.layout.top == parent.layout.top)
            }
        }
        x = false
        parent.constrain {
            if x {
                Constraint(child.layout.top == parent.layout.top)
            }
        }
        
        XCTAssertEqual(parent.constraints.count, 0)
    }
    
    func testGarbageCollection() throws {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        
        
        weak var topConstaint: NSLayoutConstraint? = nil
        autoreleasepool {
            parent.constrain {
                Constraint(child.layout.top == parent.layout.top)
                Constraint(child.layout.leading == parent.layout.leading)
                Constraint(child.layout.bottom == parent.layout.bottom)
                Constraint(child.layout.trailing == parent.layout.trailing)
                
                Constraint(child.layout.centerX == parent.layout.centerX)
                Constraint(child.layout.centerY == parent.layout.centerY)
                
                Constraint(child.layout.width == parent.layout.width)
                Constraint(child.layout.height == parent.layout.height)
                
                Constraint(child.layout.width <= parent.layout.width)
                Constraint(child.layout.height <= parent.layout.height)
            }
            XCTAssertEqual(parent.constraints.count, 10)
            topConstaint = parent.constraints[0]
            parent.constrain {
            }
        }
        XCTAssertEqual(parent.constraints.count, 0)
        XCTAssertNil(topConstaint)
    }
    
    func testChangeConstant() throws {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        
        parent.constrain {
            Constraint(child.layout.top == parent.layout.top)
            Constraint(child.layout.bottom == parent.layout.bottom)
            Constraint(child.layout.leading == parent.layout.leading)
        }
        parent.constrain {
            Constraint(child.layout.top == parent.layout.top + 4)
            Constraint(child.layout.bottom - 3 == parent.layout.bottom)
            Constraint(child.layout.leading + 3 == parent.layout.leading + 5)
        }
        
        XCTAssertEqual(parent.constraints.count, 3)
        
        let constraints = parent.constraints.sorted { $0.firstAttribute.rawValue < $1.firstAttribute.rawValue }
        assertEquality(constraints[0], firstAnchor: parent.topAnchor, secondAnchor: child.topAnchor, constant: 4, multiplier: 1, priority: .required)
        assertEquality(constraints[1], firstAnchor: parent.bottomAnchor, secondAnchor: child.bottomAnchor, constant: 3, multiplier: 1, priority: .required)
        assertEquality(constraints[2], firstAnchor: parent.leadingAnchor, secondAnchor: child.leadingAnchor, constant: 2, multiplier: 1, priority: .required)
    }
    
    func testChangeMultiplierAndConstant() throws {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        
        autoreleasepool {
            parent.constrain {
                Constraint(child.layout.width == parent.layout.width)
                Constraint(child.layout.height == parent.layout.height)
            }
            parent.constrain {
                Constraint(4*child.layout.width == parent.layout.width + 8)
                Constraint(child.layout.height + 10 == 2*parent.layout.height + 10)
            }
        }
        
        XCTAssertEqual(parent.constraints.count, 2)
        
        let constraints = parent.constraints.sorted { $0.firstAttribute.rawValue < $1.firstAttribute.rawValue }
        assertEquality(constraints[0], firstAnchor: parent.widthAnchor, secondAnchor: child.widthAnchor, constant: 2, multiplier: 1/4, priority: .required)
        assertEquality(constraints[1], firstAnchor: parent.heightAnchor, secondAnchor: child.heightAnchor, constant: 0, multiplier: 2, priority: .required)
    }
    
    func testBoundsAnchor() throws {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        
        parent.constrain {
            Constraint(child.layout.bounds.edges(.horizontal) == parent.layout.bounds.inset(20))
            Constraint(child.layout.bounds == parent.layout.bounds.edges(.top))
        }
        
        let parentConstraints = parent.constraints.sorted { $0.firstAttribute.rawValue < $1.firstAttribute.rawValue }
        
        XCTAssertEqual(parentConstraints.count, 3)
        
        assertEquality(parentConstraints[0], firstAnchor: child.topAnchor, secondAnchor: parent.topAnchor, constant: 0, multiplier: 1, priority: .required)
        assertEquality(parentConstraints[1], firstAnchor: child.leadingAnchor, secondAnchor: parent.leadingAnchor, constant: 20, multiplier: 1, priority: .required)
        assertEquality(parentConstraints[2], firstAnchor: child.trailingAnchor, secondAnchor: parent.trailingAnchor, constant: -20, multiplier: 1, priority: .required)
    }
    
    func testConstraintStorageGarbageCollection() {
        var parent: UIView? = UIView()
        weak var storage: ConstraintStorage? = nil
        storage = autoreleasepool {
            let storage = ConstraintStorage()
            parent!.addLayoutGuide(storage)
            return storage
        }
        XCTAssertNotNil(parent)
        XCTAssertNotNil(storage)
        autoreleasepool {
            parent = nil
        }
        XCTAssertNil(parent)
        XCTAssertNil(storage)
    }
}
