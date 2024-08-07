/* produce some code here mister */

// initial learning about objects and methods

4.squared;
squared(4);
4.squared.reciprocal;
16.reciprocal;
3.pow(4);
pow(3, 4);

// multi line code blocks
//

(
var num;
num = 4;
num = num.squared;
num = num.reciprocal;
)

// var declaration multi

(
var thingA = 7, thingB = 5, result;
thingA = thingA.squared;
thingB = thingB.reciprocal;
result = thingA + thingB;
)

// interpreter vars

(
n = 4;
n = n.squared;
n = n.reciprocal;
)

// environment vars

(
~num = 4;
~num = ~num.squared;
~num = ~num.reciprocal;
)

// postln will print the eval of the given object to the post window

(
~num = 4;
~num = ~num.squared.postln;
~num = ~num.reciprocal;
)

// whitespace
// both of the following statements are syntactically valid

4.squared+2;
4 . squared + 2;

// search docs with cmd + d, search implementations with cmd + i
// .browse method calls class browser, useful for seeing methods and args relevant to the given class
Integer.browse;

// the class method returns the class of a given instance

4.class;
4.0.class;
4.3.ceil.class;
ceil(4.3);

2.pow(3);
2*2*2;

// useful method here

"I'm a string.".reverse;

Symbol.browse;

// CE 1.28 - .do for iteration

[30, 40, 50, 60].do({"this is a test".postln})

4.do({"this is a test".postln});

[30, 40, 50, 60].do({|item, index| [item, index].postln});

// for .do and .collect we can declare two optional arguments at the beginning of our function, representing each item in the collection and its index per iteration. By declaring these args we can expose the items in the collection and their places in it.

// CE 1.29 - collect

x = [30, 40, 50, 60].collect({|item, index| item * index});

// .collect returns the array [0, 40, 100, 180] here

// collect allows us to return a modified array instead of simply doing a function using the array repeatedly.










