# Constraint

Constraint is a light-weight wrapper for `NSLayoutConstraint` with a more concise and readable syntax. Constraint tries to stay true to the original AutoLayout API by using the same vocabulary and workflow, making it easy to learn and use. Constraint aims to be explicit and simple; it makes no assumption of your view's layout hierarchy, no behind-the-scene magic, no swizzling, no UIView/NSView extensions.

## Quick start

Simply wrap your view in a Constraint instance and declare the constraints via the familiar API.

```swift
// Calling build() at the end of the chain returns a NSLayoutConstraint
Constraint(childView).width.equalTo(view).width.build()
Constraint(childView).height.constant(100).build()
Constraint(childView).centerX.equalTo(view).centerX.build()
Constraint(childView).centerY.equalTo(view).centerY.build()
```

Constraint instances are immutable structures, so you can reuse them.

```swift
let c = Constraint(childView)
c.width.equalTo(view).width.build()
c.height.constant(100).build()
...
```

`build()` returns a `NSLayoutConstraint`, use `buildTo(view)` to add to the view before returning it.

```swift
let layout: NSLayoutConstraint = c.width.equalTo(view).width.buildTo(view)
```

Collect your Constraint instances in an array and perform batch operations/transformations.

```swift
let c = Constraint(childView)
let layouts: [NSLayoutConstraint] = [
		c.width.equalTo(view).width,
		c.height.constant(100),
		c.centerX.equalTo(view).centerX,
		c.centerY.equalTo(view).centerY
	].map { $0.buildTo(view) }
```

Or utilise overloaded operators to be more expressive.

```swift
let c = Constraint(childView), v = Constraint(view)
let layouts: [NSLayoutConstraint] = [
		c.width == v.width,
		c.height == 100,
		c.centerX == v.centerX,
		c.centerY == v.centerY
	].map { $0.buildTo(view) }
```

### Example

It is common to invalidate `NSLayoutConstraint` in the `updateViewConstraints` method when the ViewController detects a change in the layout. Using the `identifier` property, we can easily remove selective constraints and reapply them.

```swift
class ViewController: UIViewController {
	
	// viewDidLoad(..) and friends..
	
	override func updateViewConstraints() {
		let identifier = "childView.constraints"
		
		// remove old constraints
		let old: [NSLayoutConstraint] = view.constraints.filter(Constraint.identifiedBy { $0 == identifier })
		if old.count > 0 {
			view.removeConstraints(old)
		}
		
		// construct new constraints
		let c = Constraint(childView), v = Constraint(view)
		[   c.leading == v.leadingMargin,
			c.trailing == v.trailingMargin,
			c.height == 200,
			c.centerY == v.centerY
		].map { $0.identifier(identifier).buildTo(view) }
		
		super.updateViewConstraints()
	}
}
```


## Operator overload

Constraint provides some operator overload to enable more expressive declaration.

As per the `NSLayoutConstraint` documentation:

> The relationship involves a first attribute, a relationship type, and a modified second value formed by multiplying an attribute by a constant factor and then adding another constant factor to it. In other words, constraints look very much like linear equations of the following form:
>> attribute1 == multiplier × attribute2 + constant

Constraint tries to follow the same convention.

```swift
let c = Constraint(childView), v = Constraint(view)
c.width == 100                    // Defining a constant width
c.width >= v.width                // Defining a relationship
c.leading == 2 * v.leading        // Applying multiplier to a relationship
c.leading == v.leading + 100      // Applying constant
c.leading == 2 * v.leading + 100  // Applying both a multiplier and constant
```

## API

Constraint API should look somewhat familiar to you, as it follows the same convention as `NSLayoutConstraint`

### Initialisation

Constraint requires the `firstItem` (i.e. a view) to be defined. Constraints are immutable, any method calls that alters the state will always return a new instance.

```swift
let c = Constraint(view)
let c1 = c.width
c.isEqual(c1) // false
```
### Applying constraint attributes

Attributes can be applied to the Constraint instance by calling `firstAttribute(..)` and `secondAttribute(..)` methods.

```swift
c.firstAttribute(NSLayoutAttribute.CenterX).equalTo(view2).secondAttribute(NSLayoutAttribute.CenterX)
```

But it is often easier and more concise to simply call the corresponding attribute accessor.

```swift
c.leading.equalTo(view2).leading
c.trailing.equalTo(view2).trailing
c.top.equalTo(view2).top
c.bottom.equalTo(view2).bottom
```
The following attribute accessors are available:

| NSLayoutAttribute     | Constraint            |
|-----------------------|-----------------------|
| .Left                 | .left                 |
| .Right                | .right                |
| .Top                  | .top                  |
| .Bottom               | .bottom               |
| .Leading              | .leading              |
| .Trailing             | .trailing             |
| .Width                | .width                |
| .Height               | .height               |
| .CenterX              | .centerX              |
| .CenterY              | .centerY              |
| .Baseline             | .baseline             |
| .FirstBaseline        | .firstBaseline        |
| .LeftMargin           | .leftMargin           |
| .RightMargin          | .rightMargin          |
| .TopMargin            | .topMargin            |
| .BottomMargin         | .bottomMargin         |
| .LeadingMargin        | .leadingMargin        |
| .TrailingMargin       | .trailingMargin       |
| .CenterXWithinMargins | .centerXWithinMargins |
| .CenterYWithinMargins | .centerYWithinMargins |
| .NotAnAttribute       | .notAnAttribute       |

### Defining relationships

Autolayout often defines a relationship between two separate views. Constraint provides methods that corresponds to each `NSLayoutRelation` relation.

| NSLayoutRelation    | Constraint                                                                     |
|---------------------|--------------------------------------------------------------------------------|
| .Equal              | `func equalTo(secondItem: AnyObject!)`                                         |
| .LessThanOrEqual    | `func lessThanOrEqualTo(secondItem: AnyObject!)`                               |
| .GreaterThanOrEqual | `func greaterThanOrEqualTo(secondItem: AnyObject!)`                            |
| -                   | `func relation(relation: NSLayoutRelation).secondItem(secondItem: AnyObject!)` |

Or when using overloaded operators.

| NSLayoutRelation    | Overloaded Operators           |
|---------------------|--------------------------------|
| .Equal              | `[Constraint] == [Constraint]` |
| .LessThanOrEqual    | `[Constraint] <= [Constraint]` |
| .GreaterThanOrEqual | `[Constraint] >= [Constraint]` |

### Constant and Multiplier

Apply constant and multiplier to the second attribute for fine grain constraint tuning.

```swift
c.width.equalTo(view).width.constant(100)
c.width.equalTo(view).width.multiplier(2)
c.width.equalTo(view).width.constant(100).multiplier(2)
```
Constraint starts with sensible defaults so that you don't have to define them every time.

Constraint overloads the *Multiply* `*` operator, so you can express multipliers as such (Note: multipliers should be placed **before** the `*` operator)

```
[multiplier] * [Constraint]
```

Constants are expressed by overloading the *Add* `+` operator (Note: constants should be placed **after** the `+` operator).

```
[Constraint] + [constant]
```

You can combine these operators in a single expression.

```swift
c.leading == 2 * v.leading        // Applying multiplier to a relationship
c.leading == v.leading + 100      // Applying constant
c.leading == 2 * v.leading + 100  // Applying both a multiplier and constant
```

If the above looks too cryptic for your taste, you can do this:

```swift
(c.leading == v.leading).multiplier(2)
(c.leading == v.leading).constant(100)
(c.leading == v.leading).multiplier(2).constant(100)

```

### Priority and Identifier

Apply priorities to constraints to resolve conflicts in a complex AutoLayout.

```swift
c.width.greaterThanOrEqualTo(view).width.priority(1000)
```

Identifiers are attached to `NSLayoutConstraint`,

```swift
let layout = c.width.equalTo(view).width.identifier("width.constraint").build()
layout.identifier // "width.constraint"
```

Both priorities and identifiers can be expressed using the overloaded `|` operator.

```swift
c.width == v.width | 1000                   // Assigning a priority
c.width == v.width | "myConstraint"         // Assigning an identifier
c.width == v.width | 1000 | "myConstraint"  // Combining both
```

### Creating `NSLayoutConstraint` instances

Create `NSLayoutConstraint` instances using the `build()` or `buildTo(view)` API

```swift
let layout: NSLayoutConstraint = c.width.equalTo(view).width.build()
view.addConstraint(layout)

// Or do it in a single step
let layout: NSLayoutConstraint = c.width.equalTo(view).width.buildTo(view)
```

### Helper methods

- `func reset() -> Constraint`:  Returns a copy of `Constraint` instance reset to the default values
- `func print() -> Constraint`:  Prints to console and returns `self`
- `func isEqual(other: Constraint) -> Bool`: Checks if 2 Constraint instances have the same properties
	```swift
	let c1 = Constraint(view1), c2 = Constraint(view1)
	c1.isEqual(c2) // true
	```
- `func dump() -> ConstraintProperties`:  Returns a named tuple of constraint properties
	```swift
	let properties = Constraint(view).width.constant(100).dump()
	properties.firstItem        // view
	properties.firstAttribute   // .Width
	properties.constant         // 100
	properties.secondItem       // nil
	properties.secondAttribute  // .NotAnAttribute
	...
	```
- `static func identifiedBy(predicate: String -> Bool) -> AnyObject! -> Bool`: Helper method used to filter an array of `NSLayoutConstraint`
 	```swift
 	view.constraints.filter(Constraint.identifiedBy { $0 == "foo" })
 	view.constraints.filter(Constraint.identifiedBy { startsWith($0, "foo") })
 	view.constraints.filter(Constraint.identifiedBy { endsWith($0, "bar") })
 	```
 
## Constraint compositions

Constraint provides some convenience API to help generate multiple constraints for common use cases.

### Aligning to edges of another view

 - `func snapToEdgesOf(secondItem: AnyObject!) -> Constraints`
 - `func snapToEdgesOf(secondItem: AnyObject!, offset: CGFloat) -> Constraints`
 - `func snapToEdgesOf(secondItem: AnyObject!, offset: UIEdgeInsets) -> Constraints`

```swift
let c = Constraint(childView)
let layouts: [NSLayoutConstraints] = c.snapToEdgesOf(view).buildTo(view)

// is the same as  
c.top.equalTo(view).top.buildTo(view)
c.bottom.equalTo(view).bottom.buildTo(view)
c.leading.equalTo(view).leading.buildTo(view)
c.trailing.equalTo(view).trailing.buildTo(view)
```

### Aligning to margins of another view

 - `func snapToMarginsOf(secondItem: AnyObject!) -> Constraints`
 - `func snapToMarginsOf(secondItem: AnyObject!, offset: CGFloat) -> Constraints`
 - `func snapToMarginsOf(secondItem: AnyObject!, offset: UIEdgeInsets) -> Constraints`

```swift
let c = Constraint(childView)
let layouts: [NSLayoutConstraints] = c.snapToMarginsOf(view).buildTo(view)

// is the same as  
c.topMargin.equalTo(view).topMargin.buildTo(view)
c.bottomMargin.equalTo(view).bottomMargin.buildTo(view)
c.leadingMargin.equalTo(view).leadingMargin.buildTo(view)
c.trailingMargin.equalTo(view).trailingMargin.buildTo(view)
```

### Constraining sizes

 - `func equalSizeWith(secondItem: AnyObject!) -> Constraints`
 - `func equalSize(size: CGSize) -> Constraints`

```swift
let c = Constraint(childView)
let layouts: [NSLayoutConstraints] = c.equalSizeWith(view).buildTo(view)

// is the same as  
c.width.equalTo(view).width.buildTo(view)
c.height.equalTo(view).height.buildTo(view)

c.equalSize(CGSize(width: 200, height: 100)).buildTo(view)

// is the same as
c.width.constant(200).buildTo(view)
c.height.constant(100).buildTo(view)
```

### Align center horizontally and vertically

 - `func alignCenterWith(secondItem: AnyObject!) -> Constraints`

```swift
let c = Constraint(childView)
let layouts: [NSLayoutConstraints] = c.alignCenterWith(view).buildTo(view)

// is the same as  
c.centerX.equalTo(view).centerX.buildTo(view)
c.centerY.equalTo(view).centerY.buildTo(view)
```

### About composite constraints

The Constraint composition API returns a `Constraints` (note the trailing 's') instance, which consist of multiple `Constraint` instances in the `Constraints.children` property.

You can iterate a `Constraints` instance:

```swift
let constraints = Constraint(childView).snapToEdgesOf(view)
for constraint in constraints {
	constraint.print()
}
```

Or you can transform it:

```swift
let constraints = Constraint(childView).snapToEdgesOf(view)
constraints.map { $0.secondItem(view2) }
```

Or perform batch operations using the following API:

- `func build() -> [NSLayoutConstraint]`
- `func buildTo(view: UIView) -> [NSLayoutConstraint]`
- `func priority(priority: Float) -> Constraints`
- `func identifier(identifier: String?) -> Constraints`
- `func print() -> Constraints`
- `func dump() -> [ConstraintProperties]`

## Caveats

Constraint aims to be simple and bug-free. It avoids doing more than it should and makes no assumptions to your view hierarchy and workflow.

 - It does not call `func setTranslatesAutoresizingMaskIntoConstraints(flag: bool)`, you have to do it yourself
 - It does not check if your constraints are logical, instead it lets `NSLayoutConstraint` tell you what's wrong
 ```swift
 // The following will not generate any errors
 let constraint = c.top.constant(100)
 
 // However, NSLayoutConstraint will throw an exception 
 // as layout attributes are meant to work in pairs
 constraint.build() // throws exception
 ``` 

## TODO
 - Support OSX
 - Cocoapods
 - Installation instructions

## Contact

Ivan Choo

 - http://twitter.com/ivanchoo

## License

Constraint is available under the MIT license. See the LICENSE file for more info.