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

// CE 5.4 - using routine.play; to automatically advance a routine

(
~eventA = {SinOsc.ar(60.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};
~eventB = {SinOsc.ar(70.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};
~eventC = {SinOsc.ar(75.midicps ! 2) * Line.kr(0.1, 0, 1, 2)};

f = { // using default conditions treats yield values as pause durations, measured in seconds. Knowing this we can build simple melodies with irregular timing.
	~eventA.play;
	0.5.yield;
	~eventB.play;
	1.5.yield;
	~eventC.play;
	1.yield;
};
r = Routine(f);
)
r.play;

// CE 5.5 - iteraion inside of routine for repetition

(
~playTone = { |freq|
	{SinOsc.ar(freq ! 2) * Line.kr(0.1, 0, 1, 2)}.play;
};
f = {
	3.do({
		~playTone.(72.midicps);
		0.2.yield;
		~playTone.(62.midicps);
		0.4.yield;
	});
};
r = Routine(f);
)
r.play;
r.reset;

// CE 5.6 - infinite length routines

(
~playTone = { |freq| // this notation produces an argument that later gets filled by each portion of our routine's loop. ~playTone.(freq).
	{SinOsc.ar(freq ! 2) * Line.kr(0.1, 0, 0.2, 2)}.play;
};
r = Routine({
	loop({ // placing a loop inside the routine allows it to produce a sequence of infinite length, we do need to remember to always place at least one .yield in every routine or we run the risk of producing a hang
		~playTone.(72.midicps);
		0.4.yield;
		[62, 63, 64].do({ |n|
			~playTone.(n.midicps);
			(0.4 / 3).yield;
		});
		~playTone.(87.midicps);
		(0.4).yield;
		[77, 84].do({ |n|
			~playTone.(n.midicps);
			(0.4 / 2).yield;
		});
	});
});
)

r.play;
r.stop;





















// white space because i'd like to type in the middle of the page