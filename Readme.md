# Declarative Constraints
![iOS 13+](https://img.shields.io/badge/iOS-13%2B-blue.svg)
![macOS 11+](https://img.shields.io/badge/macOS-11%2B-blue.svg)
![Swift 5.7+](https://img.shields.io/badge/Swift-5.7%2B-orange.svg)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)


**Declarative Constraints** is a library that simplifies the process of defining AutoLayout constraints by allowing you to write them in a concise and declarative manner.

## Features

- **Concise Syntax:** Define constraints with fewer lines of code.
- **Declarative Style:** Write constraints in a readable and maintainable way.
- **Flexibility:** Easily create complex layouts with clear and intuitive syntax.
- **Less Boilerplate:** Never type `translatesAutoresizingMaskIntoConstraints = false` again.

## Examples

### Simple Constraint

Constraining a child to the bounds of its parent can be accomplished with way fewer lines:

```swift
parent.constrain {
    child.layout.bounds == parent.layout.bounds
}
```

#### Traditional Approach

Compare this with the traditional approach:

```swift
child.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: padding),
    child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -padding),
    child.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding),
    child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding)
])
```

### Complex Layouts

More complex layouts can also be realized with ease:

```swift
parent.constrain {
    child.layout.bounds.edges(.horizontal) == parent.layout.bounds.edges(.horizontal).inset(20)
    child.layout.top == parent.layout.top + 10
    Constraint(child.layout.height == 2 * child.layout.width, priority: .defaultHigh)
    child.layout.height + 10 <= parent.layout.height
}
```

In this example, the child is horizontally constrained within the parent with a spacing of 20 on each side. It is also constrained to the top of the parent with a spacing of 10. The child's height should be twice its width but not exceed the height of the parent (subtracting the top spacing).

## Installation

To install **Declarative Constraints**, we recommend using Swift Package Manager (SwiftPM).

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/otto001/DeclarativeConstraints.git", from: "1.0.0")
]
```

Then, in your target, add **Declarative Constraints** as a dependency:

```swift
.target(
    name: "YourApp",
    dependencies: ["DeclarativeConstraints"]
)
```

## Usage

Import **Declarative Constraints** in your Swift files:

```swift
import DeclarativeConstraints
```

Now you can start defining your AutoLayout constraints in a declarative manner.
