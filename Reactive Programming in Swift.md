# Reactive Programming in Swift

## Introduction

In this article we will learn how to use some of Swift's functional features to write more concise and expressive code using *RxSwift*, a reactive programming framework, to manage application state and concurrent tasks.

## Swift and its functional features

Swift can be described as a modern object-oriented language with native support for generic programming. Although it is not a functional language, it has some features that allows us to programme using a functional approach, like [closures](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html#//apple_ref/doc/uid/TP40014097-CH11-ID94), functions as [first-class types](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Functions.html#//apple_ref/doc/uid/TP40014097-CH10-ID158) and immutable [value types](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ClassesAndStructures.html#//apple_ref/doc/uid/TP40014097-CH13-ID82). 

Nevertheless, Cocoa Touch is an object-oriented framework and bares the constraints that this paradigm enforces. Typical issues that arise in software development projects include managing shared application state and concurrent asynchronous tasks that compete for the data that resides there.

Functional programming solves these problems by priviliging immutable state and defining application logic as expressions that do not change during the application's lifecycle. By defining self-contained functions, computations can be easily parallelized and concurrency issues minimized.

## The Reactive Mindset

The reactive programming model has its roots in [FRP (functional reactive programming)](https://en.wikipedia.org/wiki/Functional_reactive_programming) which shifts the paradigm from discrete, imperative, command-driven programming to a series of transformations that can be applied to a stream of inputs continously over time.

While that might sound like a mouthful, there's nothing quite like a simple example to get a feel for what this means.

### Expressing a relationship between variables

Let's say you have two variables (A and B) whose value changes over the running time of an application and a third one (C) that derives it's own value based on the previous two.

	1. var A = 10
	2. var B = 20
	3. let C = A * 2 + B
	4. 
	5. // Current Values
	6. // A = 10, B = 20, C = 40
	7. 
	8. A = 0
	9.
	10. // Current Values
	11. // A = 0, B = 20, C = 40
	
The definition of C with regards to A and B is evaluated only once, when the assignment operation is executed. The relationship between them is lost immediatly after that. Changing A or B from then on, will have no effect on the value of C. 

At any given moment, to evaluate that expression you must reassign the value of C and calculate it once again, based on the current values of A and B.

How would we do this in a reactive programming approach? 

In the reactive mindset, we would create two streams that propagate changes in the values of either A or B over time. Each value change is represented as a signal in its corresponding stream. We then combine both streams and assign a transformation that we want to perform on each signal emitted, thus creating a new stream that will emit only transformed values.

The usual way to demonstrate this is using [marbles diagrams](http://rxmarbles.com/), where each line represents the continuity of time and each marble an event that occurs at a determined point in time:

![](https://raw.githubusercontent.com/mgcm/ReactiveProgrammingSwift/master/CombineDiagram.png)

## Reacting in Cocoa Touch

To address this in Cocoa Touch, you could use *[Key-Value Observing](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html)* to add observers to the changing variables and handle them when the KVO system notifies you: 

	self.addObserver(self, forKeyPath:"valueA", options: .New, context: nil)
	self.addObserver(self, forKeyPath:"valueB", options: .New, context: nil)
	 
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
   		let C = valueA * 2 + valueB
    }


If your variables are tied to the user interface, in `UIKit`you could define a handler that is invoked when change events are triggered:

	sliderA.addTarget(self, action: "update", forControlEvents: UIControlEvents.ValueChanged)
	sliderB.addTarget(self, action: "update", forControlEvents: UIControlEvents.ValueChanged)
	
	func update() {
   		let C = sliderA.value * 2 + sliderB.value
    }

But none of these approaches defines a persistent and explicit relationship between the variables involved, their lifecycle and the events that change their value.

We can overcome this with a reactive programming model. There are a couple of different implementations currently available for OS X and iOS development such as [RxSwift](https://github.com/ReactiveX/RxSwift) and [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).

We will focus on *RxSwift* but the basic concepts we will address are similar in both frameworks.

### RxSwift

*RxSwift* extends the *[Observer](https://en.wikipedia.org/wiki/Observer_pattern)* pattern to simulate asynchronous streams of data flowing out of your typical Cocoa Touch objects. By extending some of Cocoa's classes with  *observable streams*, you are able to subscribe to their output and use them in [composable operations](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/API.md), such as `filter()`, `merge()`, `map()`, `reduce()` and others. 

Returning to our previous example, let's say we have an iOS application with two sliders (`sliderA` and `sliderB`) and we wish to continously update a label (`labelC`) with the same expression we used before (`A * 2 + B`):

	1. combineLatest(sliderA.rx_value, sliderB.rx_value) {
	2.		$0 * 2 + $1
	3. }.map {
	4.	    "Sum of slider values is \($0)"
	5.	}.bindTo(labelC.rx_text)
       
We take advantage of the `rx_value` extension of the `UISlider` class that transforms the slider's `value` property into an *observable type* that emits an item when its value changes. By applying the [`combineLatest()`](http://reactivex.io/documentation/operators/combinelatest.html) operation on both slider's observable types, we create a new observable type that emits items whenever any of its source streams emits an item. The resulting emission is a tuple with both slider's values that can be transformed in the operation callback (line 2). Then, we map the transformed value into an informative string (line 4) and bind its value to our label (line 5).

By composing three independent operations (`combineLatest()`, `map()` and `bindTo()`) we were able to concisely express a relationship between three objects and continuously update our application's UI, reacting accordingly to changes in the application state.

# What's next?

We are only scratching the surface on what you can do with *RxSwift*.

In the [sample source code](https://github.com/mgcm/ReactiveProgrammingSwift), you will 
find an example on how to download online resources using chainable asynchronous tasks. Be sure to check it out if this article sparked your curiosity. 

Then take some time to read [the documentation](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/API.md) and learn about the several other Cocoa API extensions that will help you develop iOS apps in a more functional and expressive way.
