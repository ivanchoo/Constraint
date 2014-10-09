//
//  ConstraintTests.swift
//  ConstraintTests
//
//  Created by Ivan Choo on 9/10/14.
//  Copyright (c) 2014 ADD Creativeworks. All rights reserved.
//

import UIKit
import XCTest
import Constraint

let layoutAttributes: [NSLayoutAttribute] = [
    .Left,
    .Right,
    .Top,
    .Bottom,
    .Leading,
    .Trailing,
    .CenterX,
    .CenterY,
    .Baseline,
    .FirstBaseline,
    .LeftMargin,
    .RightMargin,
    .TopMargin,
    .BottomMargin,
    .LeadingMargin,
    .TrailingMargin,
    .CenterXWithinMargins,
    .CenterYWithinMargins
]

let dimensionAttributes: [NSLayoutAttribute] = [
    .Width,
    .Height
]

class ConstraintTests: XCTestCase {
    
    let firstItem = UIView()
    let secondItem = UIView()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAttribute() {
        let c1 = Constraint(firstItem), c2 = Constraint(secondItem)
        for attributes in [layoutAttributes, dimensionAttributes] {
            for firstAttribute in attributes {
                for secondAttribute in attributes {
                    let layoutConstraints = [
                        c1.firstAttribute(firstAttribute).equalTo(secondItem).secondAttribute(secondAttribute),
                        c1.attribute(firstAttribute).equalTo(secondItem).attribute(secondAttribute),
                        c1.attribute(firstAttribute) == c2.attribute(secondAttribute)
                        ].map { $0.build() }
                    for layoutConstraint in layoutConstraints {
                        XCTAssertEqual(layoutConstraint.firstItem as UIView, firstItem, "`firstItem` does not match")
                        XCTAssertEqual(layoutConstraint.secondItem as UIView, secondItem, "`secondItem` does not match")
                        XCTAssertEqual(layoutConstraint.firstAttribute, firstAttribute, "`firstAttribute` does not match")
                        XCTAssertEqual(layoutConstraint.secondAttribute, secondAttribute, "`secondAttribute` does not match")
                    }
                }
            }
        }
    }
    
    func testConstant() {
        let c1 = Constraint(firstItem), c2 = Constraint(secondItem)
        let constant: CGFloat = 100
        for firstAttribute in dimensionAttributes {
            let layoutConstraints = [
                c1.firstAttribute(firstAttribute).constant(constant),
                c1.attribute(firstAttribute) == constant
                ].map { $0.build() }
            for layoutConstraint in layoutConstraints {
                XCTAssertEqual(layoutConstraint.firstItem as UIView, firstItem, "`firstItem` does not match")
                XCTAssertEqual(layoutConstraint.firstAttribute, firstAttribute, "`firstAttribute` does not match")
                XCTAssertEqual(layoutConstraint.constant, constant, "`constant` does not match")
            }
        }
        for firstAttribute in dimensionAttributes {
            for secondAttribute in dimensionAttributes {
                let layoutConstraints = [
                    c1.firstAttribute(firstAttribute).equalTo(secondItem).secondAttribute(secondAttribute).constant(constant),
                    c1.attribute(firstAttribute).equalTo(secondItem).attribute(secondAttribute).constant(constant),
                    c1.attribute(firstAttribute) == c2.attribute(secondAttribute) + constant
                    ].map { $0.build() }
                for layoutConstraint in layoutConstraints {
                    XCTAssertEqual(layoutConstraint.firstItem as UIView, firstItem, "`firstItem` does not match")
                    XCTAssertEqual(layoutConstraint.secondItem as UIView, secondItem, "`secondItem` does not match")
                    XCTAssertEqual(layoutConstraint.firstAttribute, firstAttribute, "`firstAttribute` does not match")
                    XCTAssertEqual(layoutConstraint.secondAttribute, secondAttribute, "`secondAttribute` does not match")
                    XCTAssertEqual(layoutConstraint.constant, constant, "`constant` does not match")
                }
            }
        }
    }
    
    func testMultiplier() {
        let c1 = Constraint(firstItem), c2 = Constraint(secondItem)
        let multiplier: CGFloat = 2.3
        let layoutConstraints = [
            c1.width.equalTo(secondItem).width.multiplier(multiplier),
            c1.width == multiplier * c2.width
            ].map { $0.build() }
        for layoutConstraint in layoutConstraints {
            XCTAssertEqual(layoutConstraint.firstItem as UIView, firstItem, "`firstItem` does not match")
            XCTAssertEqual(layoutConstraint.secondItem as UIView, secondItem, "`secondItem` does not match")
            XCTAssertEqual(layoutConstraint.firstAttribute, NSLayoutAttribute.Width, "`firstAttribute` does not match")
            XCTAssertEqual(layoutConstraint.secondAttribute, NSLayoutAttribute.Width, "`secondAttribute` does not match")
            XCTAssertEqual(layoutConstraint.multiplier, multiplier, "`multiplier` does not match")
        }
    }
    
    func testPriority() {
        let c1 = Constraint(firstItem), c2 = Constraint(secondItem)
        let priority: Float = 1000
        let layoutConstraints = [
            c1.width.equalTo(secondItem).width.priority(priority),
            c1.width == c2.width | priority,
            ].map { $0.build() }
        for layoutConstraint in layoutConstraints {
            XCTAssertEqual(layoutConstraint.firstItem as UIView, firstItem, "`firstItem` does not match")
            XCTAssertEqual(layoutConstraint.secondItem as UIView, secondItem, "`secondItem` does not match")
            XCTAssertEqual(layoutConstraint.firstAttribute, NSLayoutAttribute.Width, "`firstAttribute` does not match")
            XCTAssertEqual(layoutConstraint.secondAttribute, NSLayoutAttribute.Width, "`secondAttribute` does not match")
            XCTAssertEqual(layoutConstraint.priority, priority, "`priority` does not match")
        }
    }
    
    func testIdentifier() {
        let c1 = Constraint(firstItem), c2 = Constraint(secondItem)
        let identifier = "TestIdentifier"
        let layoutConstraints = [
            c1.width.equalTo(secondItem).width.identifier(identifier),
            c1.width == c2.width | identifier,
            ].map { $0.build() }
        for layoutConstraint in layoutConstraints {
            XCTAssertEqual(layoutConstraint.firstItem as UIView, firstItem, "`firstItem` does not match")
            XCTAssertEqual(layoutConstraint.secondItem as UIView, secondItem, "`secondItem` does not match")
            XCTAssertEqual(layoutConstraint.firstAttribute, NSLayoutAttribute.Width, "`firstAttribute` does not match")
            XCTAssertEqual(layoutConstraint.secondAttribute, NSLayoutAttribute.Width, "`secondAttribute` does not match")
            XCTAssertEqual(layoutConstraint.identifier!, identifier, "`identifier` does not match")
        }
    }
    
    func testRelation() {
        let c1 = Constraint(firstItem), c2 = Constraint(secondItem)
        let l1 = (c1.width == c2.width).build()
        let l2 = (c1.width >= c2.width).build()
        let l3 = (c1.width <= c2.width).build()
        XCTAssertEqual(l1.relation, NSLayoutRelation.Equal, "`relation` does not match")
        XCTAssertEqual(l2.relation, NSLayoutRelation.GreaterThanOrEqual, "`relation` does not match")
        XCTAssertEqual(l3.relation, NSLayoutRelation.LessThanOrEqual, "`relation` does not match")
    }
    
    func testReset() {
        let c = Constraint(firstItem).width.equalTo(secondItem).width.priority(1000).constant(2).multiplier(2).identifier("Test").reset().dump()
        XCTAssertEqual(c.firstItem as UIView, firstItem, "`firstItem` does not match")
        XCTAssertEqual(c.firstAttribute, NSLayoutAttribute.NotAnAttribute, "`firstAttribute` does not match")
        XCTAssertNil(c.secondItem, "`secondItem` is not nil")
        XCTAssertEqual(c.secondAttribute, NSLayoutAttribute.NotAnAttribute, "`secondAttribute` does not match")
        XCTAssertEqual(c.priority, Float(1000), "`priority` does not match")
        XCTAssertEqual(c.constant, CGFloat(0), "`constant` does not match")
        XCTAssertEqual(c.multiplier, CGFloat(1), "`multiplier` does not match")
        XCTAssertNil(c.identifier, "`identifier` is not nil")
    }
    
}
