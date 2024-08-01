// I just want to make some shit actually happen, skipping ahead in Eli

// mul always occurs before add when instantiating UGens
// stereo pink noise for volume calibration
// {function}.play; - functions are anything wrapped in { }
{PinkNoise.ar(mul: 1) !2}.play;

// mono SinOsc UGen
{SinOsc.ar(300, 0, 0.1, 0)}.play;

// multichannel SinOsc UGen
// this arrangement is known as an object duplication shortcut
{SinOsc.ar(300, 0, 0.1, 0)!2}.play;

// verbose specfication of args to the UGen
{SinOsc.ar(freq: 300, phase: 0, mul: 0.1, add: 0)!2}.play;

// playing a UGen function and using set to change the sound
/* “When calling play, we must assign the resulting sound process to a variable, so that we can communicate with it later”*/
(
x = {|freq = 300|
	SinOsc.ar(freq, mul: 0.1)!2;
}.play;
)

// then we can call the declared variable with the .set method to adjust our arg
x.set(\freq, 400);

// multiple args exposed as components of the function which we can .set
(
x = {|freq = 300, amp = 0.1|
	SinOsc.ar(freq, mul: amp)!2; //calling the SinOsc using variables declared in the instantion of our function
}.play
)

// declaring new values for out args via varaiable.set
x.set(\freq, 400, \amp, 0.4); // modify both args

x.set(\amp, 0.05, \freq, 500); //order doesn't matter

x.set(\freq, 600); // modify only one arg

 // code example 2.6, separating sound definition and play
/* “we define a UGen function and store it in the interpreter variable f. Then, we play it, storing the resulting sound process in the interpreter variable x.”*/
(
// define the sound
f = {|freq = 300, amp = 0.1|
	SinOsc.ar(freq, mul: amp)!2;
}; // this is followed by .play above, but given that we're separating out the sound definition we just want to call the function
)

x = f.play;
x.set(\freq, 400, \amp, 0.3); //change the sound
f.set(\freq, 400, \amp, 0.05); // no effect if applied to the function

// we can use a nested variable structure to distinguish our UGen function from our playback function, and then use playbackVariable.release(time in seconds); to gradually fade our UGen playback out to silence

(
f = {|freq = 300, amp = 0.1|
	SinOsc.ar(freq, mul: amp)!2;
};
)
x = f.play;
x.release(2);

// we can use math to manipulate signal operations, like addition for mixing. our sig variable can be expressed a literal combination of two UGens, then we can use multichannel expansion to spread two copies in the stereo field

(
f = {
	var sig;
	sig = SinOsc.ar(300, mul: 0.15);
	sig = sig + PinkNoise.ar(mul: 0.1);
	sig = sig!2;
};
)

x = f.play;
x.release(4);

// CE 2.7 overriding arg values when calling play on a UGen function

(
f = {|freq = 300, amp = 0.1|
	SinOsc.ar(freq, mul:amp)!2;
};
)

x = f.play(args: [freq:800, amp: 0.2]); // overide default args when calling .play method

x.set(\freq, 600, \amp, 0.05); // set messages work normally

// section 2.4.3 stopping sounds
// CE 2.8
(
f = {|freq = 300, amp = 0.1|
	SinOsc.ar(freq, mul: amp)!2;
};
)

x = f.play(args: [freq: 350]);
y = f.play(args: [freq: 450]);
y.free;
x.free;

// free produces a hard stop, we can use release instead for a smooth fade with duration defined in seconds

x.release(3);