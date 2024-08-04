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

// CE 2.11 - use of binary operators as an alternative to specifying mul and add

(
x = {
	var sig; // declare our signal var, something to get used to
	sig = SinOsc.ar(300)*0.15; // a variable can hold a whole UGen!
	sig = sig + (PinkNoise.ar*0.1); // and combine them together with simple mathematical operators! this is the equivalent of mixing
	sig = sig!2; // we then use the multichannel expansion shortcut to send a copy of the signal to each of our first two outputs
}.play; // we can also just go for }; here and call our UGen function inside of another interpreter var externally
)
x.release(2);

// CE 2.12 - modulating the amplitude of pink noise with a low frequency osc

(
x = {
	var sig, lfo; // we can declare several variables at once
	lfo = SinOsc.kr(freq: 1/5, phase: 3pi/2, mul: 0.1, add: 0.1); // defining our first control rate UGen!
	/* I am trying to understand how the signal scaling works with mul and add here: the UGen must be bipolar, add is an offset, scales the signal to within 0.1 of that offset in either direction, resulting in an overall throw of modulation from 0.0 to 0.2 */
	sig = PinkNoise.ar * lfo; // the * operator stands in for mult, essentially a VCA!
	sig = sig!2; // MC expansion as usual
};
)

y = x.play;
y.release(10); // finally we wrap the function var in a new interpreter variable (these do not have to be declared) to play and release


// instead of using mul and add to scale and offset our signal we can simply pass the .range method to a UGen and scale it to an arbitrary min and max
//CE 2.13, described above! one important thing: .range maps linearly between min and max

(
x = {
	var sig,lfo;
	lfo = SinOsc.kr(freq: 0.2, phase: 3pi/2).range(0, 0.2); // same result as using mul and add, much easier to conceptualize
	sig = PinkNoise.ar * lfo;
	sig = sig!2;
}.play;
)

x.release(2);

/* some range options (table 2.2):
.range(x,y) - simple, maps linearly between x and y
.exprange(x,y) - map exponentially between given values, they must be either positive or negative, neither can be 0. not sure why
.curverange(x,y,n) - very interesting, map between x and y using a warp value of n. n positive produces expo curves, n negative more log
.unipolar(x) - map between 0 and x
.bipolar(x) - map the output range between positive and negative x! */

// range mapping assumes you are not using mul and add, use one or the other

// section 2.5 - envelopes

// relevant UGens: Line, XLine. These are very basic, either a linear shape moving from x to y, or an expo shape
// CE 2.14 usage of line and xline as simple amp egs

( // linear EG
{
	var sig, env;
	env = Line.kr(start: 0.3, end: 0, dur: 0.5);
	sig = SinOsc.ar(350)*env;
	sig = sig!2;
}.play;
)
( // expo EG, note that we cannot end on 0
{
	var sig, env;
	env = XLine.kr(start: 0.3, end: 0.0001, dur: 0.5);
	sig = SinOsc.ar(350)*env;
	sig = sig!2;
}.play;
)

// I think I am finally getting the hang of the basic UGen function setup and using variables to contain UGens and to make them available for interaction. Patching!

// CE 2.15 - use of a terminating doneaction to remove a sound process when its eg is complete
// donaction 2 frees the containing synth automatically

(
{
	var sig, env;
	env = XLine.kr(start: 0.3, end: 0.0001, dur: 0.5, doneAction: 2);
	sig = SinOsc.ar(350)*env;
	sig = sig!2;
}.play;
)

// section 2.5.3 - ENV and ENVGEN

// CE 2.16 - creating and plotting an instance of env

(
e = Env.new(
	levels: [0, 1, 0], // level control per stage, the first stage will never repeat
	times: [2, 6], // always an array of values, should be one index shorter than the number of levels
	curve: 'lin' // can be an array (curves per stage), a symbol or string (assign same curve to all stages), or an integer (similar to a string or symbol, numbers are assigned to the available cruves)
);
e.plot;
)

// CE 2.17 - usage of Env and EnvGen to create a custom amplitude envelope signal

(
{
	var sig, env;
	env = EnvGen.kr( // this is kind of a weird construction, EnvGen plays back Env, which is the UGen actually producing our curve. Could be that Env simply produces the curve and EnvGen converts it to audio or control rate signal?
		envelope: Env.new(
			levels: [0,1,0],
			times: [1,3],
			curve: [0,0] // positive values cause a segment to be more horizontal at first, and more vertical toward the end, opposite for negative values
		),
		doneAction: 2
	);
	sig = SinOsc.ar(350)*0.3;
	sig = sig *env;
	sig = sig!2;
}.play;
)

// CE 2.18 - we add a fourth parameter to Env.new, an index into the levels array representing the node at which the EG will sustain. In this case we indicate 2, meaning our sustain node/level will be 0.2, the third index. We also need to add gate as an arg to our function, because it needs to be changed at runtime

(
f = { |gate = 1|
	var sig, env;
	env = EnvGen.kr(
		envelope: Env.new(
			[0, 1, 0.2, 0], // 0.2 is our sustain level!
			[0.02, 0.3, 1],
			[0, -1, -4],
			2 // release node index
		),
		gate: gate,
		doneAction: 2
	);
	sig = SinOsc.ar(350)*0.3;
	sig = sig *env;
	sig = sig!2;
};
)
x = f.play;
x.set(\gate, 0);


Server.default.options.numInputBusChannels=0; // set number of inputs by force
s.reboot; // boot server

// a zero to positive gate transition causes the envelope to move from its current level to the second level in the levels array, using its first duration and first curve value. The envelope never revisits its first level, which is used only for initialization.
// a positive to zero gate transition causes the envelope to move from its current value to the value immediately after the release node, using the duration and curve values at the same index as the release node.

// CE 2.19 - a retriggerable gated envelope

(
f = {|gate = 1|
	var sig, env;
	env = EnvGen.kr(
		Env.new(
			[0, 1, 0.2, 0],
			[0.02, 0.3, 1],
			[0, -1, -4],
			2
		),
		gate
	);
	sig = SinOsc.ar(350)*0.3;
	sig = sig * env;
	sig = sig!2;
};
)

x = f.play;
x.set(\gate, 0); // fade to silence but do not free
x.set(\gate, 1); // reopen the gate to restart the envelope
x.set(\gate, 0); // fade to silence again
x.free; // free when finished

// CE 2.20 - trigger-type args to create retriggerable fixed-duration EG

(
x = {|t_gate = 0|
	var sig, env;
	env = EnvGen.kr(
		Env.new(
			[0, 1, 0],
			[0.02, 0.3],
			[0, -4],
		),
		t_gate,
	);
	sig = SinOsc.ar(350)*0.3;
	sig = sig * env;
	sig = sig!2;
}.play;
)

x.set(\t_gate, 1); // evaluate repeatedly
x.free; // free when finished





















// white space because I want to type in the middle of my screen instead of the gd bottom