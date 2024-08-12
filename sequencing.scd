// skipping ahead temporarily to sequencing because i want to make some things happen over time!

// chapter 5 - sequencing

// section 5.2 - routines and clocks

// CE 5.1 - producing a triad. all of this code is executed line by line, in order, but the execution happens so quickly that it appears instantaneous. Our goal is to play this in sequence as an arp.

(
~eventA = {SinOsc.ar(60.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};
~eventB = {SinOsc.ar(70.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};
~eventC = {SinOsc.ar(75.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};

f = {
	~eventA.play;
	~eventB.play;
	~eventC.play;
};
)

f.();

// CE 5.2 - routine, .next, .reset

(
~eventA = {SinOsc.ar(60.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};
~eventB = {SinOsc.ar(70.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};
~eventC = {SinOsc.ar(75.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};

f = {
	~eventA.play;
	1.yield;
	~eventB.play;
	1.yield;
	~eventC.play;
	1.yield;
};
r = Routine(f);
)

r.next;
r.reset;
f.value;

// CE 5.3 - routine with while loop for random incrementing of midi note numbers

(
~noteFunc = {
	var num = 48;
	while({num < 84}, {
		num.yield;
		num = num + rrand(1, 4);
	});
};
~noteGen = Routine(~noteFunc);
)

~noteGen.next;
~noteGen.reset;























// white space because i'd like to type in the middle of the page