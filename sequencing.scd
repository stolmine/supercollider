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





























// white space because i'd like to type in the middle of the page