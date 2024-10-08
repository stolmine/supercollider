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

// section 2.6 - multichannel signals
// 2.6.1 multichannel expansion

{SinOsc.ar(300, mul: 0.1)}.play; // demonstrating a simple one channel ugen

{SinOsc.ar(300, mul: 0.1)!2}.play; // demonstrating the dup method (symbolically shortcutted via !X) which outputs our two UGen instances on contiguous channels

s.meter; // easy way to call up the server meter!

// CE 2.21 - step by step depiction of multichannel expansion, an array argument produces an array of UGens

{SinOsc.ar([350, 353]) * 0.2}.play // we call an array inside of the SinOsc's freq arg, which produces two UGen's distributed across our left and right outputs

{[SinOsc.ar(350), SinOsc.ar(353)] * 0.2}.play; // same effect, point taken

// Code example 2.22 - multichannel expanded UGen arrays with modulation

(
{
	var sig, mod;
	sig = SinOsc.ar([450, 800]); // when applying MC expansion we can dupe an arg or the whole UGen. However, with stochastic UGens like noise, we need to dupe args in order to produce different signals per output channel, duping the whole UGen will result in copies of the same signal being produced at each successive output
	mod = SinOsc.kr([0.2, 9]).range(0,1);
	sig = sig * mod; // we are modulating amplitude here? I believe that's the case'
	sig = sig * 0.2;
}.play;
)

// CE 2.23 - duping UGen vs duping UGen arg for stochastic signals

// these will produce the same signal across both outputs
{SinOsc.ar(300!2, mul:0.1)}.play;
{SinOsc.ar(300, mul: 0.1)!2}.play;

// these will produce multiple distinct signals
{PinkNoise.ar(mul:0.2)!2}.play; // 'point' source between speakers (close stereo image)
{PinkNoise.ar(mul: 0.2 ! 2)}.play; // 'wide' source between the speakers

// an aside, this behavior is essentially due to the nature of functions and *where we tell SC to perform MCE*
rrand(1,9)!8; // produces 8 of the same random number
{rrand(1,9)}!8; // eight differet numbers, this is because we are duplicating the function containing rrand and not running the rrand and then duplicating the output itself

// CE 2.24 - common mistake of applying MCE to an already expanded signal

(
{
	var sig;
	sig = [SinOsc.ar(300), PinkNoise.ar];
	sig = sig * 0.1;
	sig = sig!2;
}.play;
)

// this expands our expanded signal and actually just generates a 2 channel output with the UGen array summed and then copied per channel e.g. [[SinOsc + PinkNoise]. [SinOsc + PinkNoise]]

// CE 2.25 - pan2 moving a sound in the stereo field

(
{
	var sig, pan;
	pan = SinOsc.kr(0.5) * 0.8;
	sig = PinkNoise.ar * 0.2;
	sig = Pan2.ar(sig, pan); // we use that control rate SinOsc as an LFO here with a freq of 0.5 hz, assign it a variable, then pass the variable as an arg to our Pan2 UGen. The first arg is our input, PinkNoise held in var sig. Pan2 should always receive a single channel of signal, otherwise you produce an array of arrays
}.play;
)

// CE 2.26 - attempting to play a 50 channel signal, only 2 channels will be heard

(
{
	var sig, freq;
	freq = {exprand(200, 2000)} ! 50;
	sig = SinOsc.ar(freq) * 0.1;
}.play;
)

// CE 2.27 - we can use splay to mix these 50 channels down to our intended two

(
{
	var sig, freq;
	freq = {exprand(200, 2000)}!50;
	sig = SinOsc.ar(freq)*0.1;
	sig = Splay.ar(sig); // Splays first arg is an input array, in this case we have effectively expanded sig into a 50 index array via MCE on the freq arg/variable
}.play;
)

// attempting to build a lil MCE synth, we generate 50 sinusoids and envelope each of their VCAs with a unique timing defined by the attack and release vars
(
{
	var sig, freq, env, attack, release;
	freq = {exprand(200, 3500)}!50;
	env = EnvGen.kr(
		Env.new(
			attack = {exprand(0.0001,4)}!50;
			release = {exprand(0.001,8)}!50;
			[0,0.2,0],
			[attack, release],
			'lin'
		);
	);
	sig = SinOsc.ar(freq) * env;
	sig = Splay.ar(sig);
	sig
}.play;
)

// section 2.7 - synth and synthdef
// CE 2.28 - UGen fucntion conversion to synthdef, the following is a simple function-dot-play construction

(
x = {
	var sig;
	sig = SinOsc.ar([350, 353]);
	sig = sig*0.2;
}.play;
)

x.free;

// a synthdef construction is a pretty simple conversion here, we simply call the SynthDef class, provide a name for the following UGen function, specify the output signal and destination, and then add the synthdef by evaluating the code

// CE 2.29 - converting CE 2.28 into a SynthDef

(
SynthDef(\test, { // we add our name as a symbol
	var sig;
	sig = SinOsc.ar([350,353]);
	sig = sig * 0.2;
	Out.ar(0, sig); // here we direct the signal to an output using the Out UGen arguments being destination bus and channel array (our signal defined via the UGen graph var sig)
}).add;
)

// NB: there can only be one SynthDef added with a given name, unique synthdefs require unique names. If we call a SynthDef more than once, each new instance replaces the previous one.

// 2.7.2 - creating a synth
// CE 2.30 - creatinga nd freeing a synth from an added SynthDef

x = Synth(\test); // case matters! I tried calling 'synth' instead of 'Synth' and got an error for an undefined object
x.free; // we cannot use the release method with a SynthDef without specifying exactly a gated envelope, likewise for Out, we need to specify or else we will hear nothing

// CE 2.31 - creating a SynthDef with arguments, so we can control its characteristics each time we play it
// we use the arg portion of the synthedef to define variable which can be called later in the recipe and modified while the SynthDef is added and playing via the .set lines below.

(
SynthDef.new(\test, {
	arg freq = 350, amp = 0.2, atk = 0.01, dec = 0.3, slev = 0.4, rel = 1, gate = 1, out = 0;
	var sig, env;
	env = EnvGen.kr(
		Env.adsr(atk, dec, slev, rel),
		gate,
		doneAction: 2
	);
	sig = SinOsc.ar(freq + [0, 1]);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\test);
x.set(\freq, 450);
x.set(\amp, 0.5);
x.set(\gate, 0, \rel, 3);

// CE 2.32 - a synth with custom initial arg values

x = Synth(\test, [freq: 800, amp: 0.1, atk: 4, slev: 1]);
x.set(\gate, 0);

// CE 2.33 - expressions to produce a tone cluster, and then fade it out

(
// return an array of four Synths, assigned to variable x
x = [205, 310, 525, 700].collect({|f| // we use collect here to produce an array tied to variable f? not sure i understand this construction
	Synth.new(\test, [\freq, f, \amp, 0.1]); // call our synths, the use of f as the freq arg produces an array of four synths with frequencies corresponding to our specified values
});
)

// fade out each synth
x.do({|n| n.set(\gate, 0, \rel, 5)}); // what is happening here? x.do allows us to iterate over each of our 4 synths, i think. n defines our function that is iterated over the indices in the collection

// CE 2.34 - freq and amp conversion

(
SynthDef.new(\test, {
	arg freq = 350, amp = 0.2, atk = 0.01, dec = 0.3, slev = 0.4, rel = 1, gate = 1, out = 0;
	var sig, env;
	env = EnvGen.kr(
		Env.adsr(atk, dec, slev, rel),
		gate,
		doneAction: 2
	);
	sig = SinOsc.ar(freq + [0, 1]);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\test, [freq: 60.midicps, amp: -20.dbamp]);
x.set(\freq, 62.midicps); // increase pitch by two semitones
x.set(\amp, -12.dbamp); // increase level by 8 db
x.set(\gate, 0);

// section 2.9 - helpful server tools

// CE 2.35 - polling a UGen

(
x = {
	var sig, freq;
	freq = SinOsc.kr(0.2).exprange(200, 800).poll(20); // we should rarely use a vaule greater than 20 for .poll, large numbers may hang the application
	sig = SinOsc.ar(freq);
	sig = sig * 0.2;
	sig = sig ! 2;
}.play;
)

// server tools
FreqScope.new;
s.scope;
s.volume.gui;
s.makeGui;
s.plotTree;

// CE 2.36 - plotting UGen functions

{SinOsc.ar(110)}.plot(0.05); // 0.05 seconds of the given UGen's output

{SinOsc.ar([110, 220, 330, 440])}.plot(0.05); // multichannel plot, useful!

// CE 3.1 - summing sines for additive synthesis
(
{
	var sig;
	sig = SinOsc.ar(200, mul:0.2);
	sig = sig + SinOsc.ar(400, mul: 0.1);
	sig = sig + SinOsc.ar(600, mul: 0.05);
	sig = sig + SinOsc.ar(800, mul: 0.025); // we manually add partials by mixing additively to the sig var
	sig = sig!2;
}.play;
)

// CE 3.2 - using .do to iterate additive partials

(
{
	var sig = 0, freqs = [200, 400, 600, 800];
	freqs.do({ |f, i| // ok, now i get .do, it's something like loop in TT. you call the method on a collection (like an array), define your arguments (f and i in this case), and then it iterates the function following with sequentially re the input collection. Not sure why the mul postln is returning whole numbers here but i am probably just applying in the wrong spot: this is the case, you need to encapsulate the whole mul arg, as the postln method was only addressing 2.pow(i)
		sig = sig + SinOsc.ar(f, mul: (0.2 / 2.pow(i)).postln);
	});
	sig = sig!2;
}.play;
)

// i did misunderstand .do above. the names of the arguments stand for 'freqs' and 'index', so we are taking the freqs to MCE our UGen, and then appling 0.2 / 2 to the power of each index to define amplitude for each.

2.pow(0); // any non zero number to the power of 0 will evaluate to 1

// CE 3.3 - using collect to iterate our additive signal

(
{
	var sig, freqs = [200, 400, 600, 800];
	sig = freqs.collect({ |f, i|
		SinOsc.ar(f, mul: 0.2 / 2.pow(i));
	});
	sig = sig.sum;
	sig = sig!2;
}.play;
)

// .collect is the cleanest option here because it returns a new collection of UGens, each with a frequency defined by f. then we simply call sum on the collection to mix them together, freqs and amps have already been handled as necessary

// using .do necessitates explicitly summing each successive UGen produced by iteration inside of its function, as it will not alter the contents of our initial collection

// section 3.2.2 - additive UGens

// CE 3.4 - Blip

(
{
	var sig, harm;
	harm = LFTri.kr(0.1,3).range(1,50);
	sig = Blip.ar([80,81], harm); // we are unable to control the amplitude of individual harmonics, just frequency and number. we use MCE to generate a stereo image across two close fundamentals, and then define the number of harmonics via the harm variable which is a range limited triangle LFO
	sig = sig * 0.1;
}.play;
)

s.plotTree;
s.scope;

// CE 3.5 - Klang for additive synthesis

(
{
	var sig;
	sig = Klang.ar(
		`[ // <- backtick used to delineate our ref array
			Array.exprand(40, 50, 8000),
			Array.exprand(40, 0.001, 0.05).sort.reverse,
			Array.rand(40, 0, 2pi)
		] // we create 3 arrays for freqs, amps, and phase via UGens instead of manually. the .exprand method fills each array with values according to the given arguments: size, minVal, maxVal. We can then sort, reverse, etc those values to manipulate the distribution of our harmonics
	);
	sig = sig!2;
}.play;
)

// CE 3.6 additive synth using DynKlang

(
{
	var sig, freqs, amps, phases;
	freqs = Array.exprand(40, 50, 8000).sort;
	amps = Array.exprand(40, 0.005, 0.2).sort.reverse;
	phases = Array.rand(40, 0, 2pi); // got an error here originally because i used a 0 minVal
	sig = DynKlang.ar(`[ // backtick to indicate an ArrayRef
		freqs * LFNoise1.kr(0.02!40).exprange(0.25, 2),
		amps * LFNoise1.kr(1!40).exprange(0.02, 1),
		phases
	]);
	sig = sig!2;
}.play;
)

// Section 3.3 - modulation synthesis, or supplying UGens as input values for other UGens

// CE 3.7 - subtractive modulation synthesis, using an LFO to modulate the cutoff of an LPF

(
	{
		var sig, mod;
	mod = SinOsc.kr(0.25, 3pi/2).range(0, 3000); // at such a low frequency it's probably more efficient to use control rate rather than audio, but either will do. There is no audible difference. Sines are favored for modulation purposes as they work predictably when frequency approaches 0 or a negative number. Other waveforms may produce very strange or extremely loud results.
		sig = Pulse.ar([90,91]);
		sig = LPF.ar(sig, 200 + mod); // applying a lowpass is simple, we define it as the value of sig and also pass sig in as its input, other args include freq, mul, and add for cutoff and scaling purposes
		sig = sig * 0.1;
	}.play
)

sig = Limiter.ar(sig); // apply a limiter with a default normalized output level of 1 to a given signal
sig = LeakDC.ar(sig); // apply DC offset filtering to a given signal
// both of these UGens can be applied liberally to any dubious code to ensure some audiitary safety

// CE 3.8 - amp modulation synthesis

(
{
	var sig, mod, modHz;
	modHz = XLine.kr(1, 150, 10); // defines this var as an exponential curve with duration of 10 seconds
	mod = SinOsc.ar(modHz).range(0, 1);
	sig = SinOsc.ar(750, mul: mod);
	sig = sig * 0.2!2;
}.play;
)

s.scope;
s.sampleRate(44100);

// CE 3.9 - ring modulation (bipolar AM)

(
{
	var sig, mod, modHz;
	modHz = XLine.kr(1, 150, 10);
	mod = SinOsc.ar(modHz).range(-1,1);
	sig = SinOsc.ar(750, mul: mod);
	sig = sig * 0.2 ! 2;
}.play;
)

// CE 3.10 - differenecs in audio quality between audio and control rate modulators

(
{
	var sig, mod;
	mod = SinOsc.kr(1050).range(0,1); // switch ar and kr here to hear differences in output. kr produces stepped modulation. Accd to feldsteel we typically want to use ar modulators despite the modest cost in computational efficiency
	sig = SinOsc.ar(750);
	sig = sig * mod * 0.2 ! 2;
}.play;
)

// CE 3.11 - simple FM

(
{
	var sig, mod, modHz;
	modHz = XLine.kr(1, 150, 10);
	mod = SinOsc.ar(modHz, mul: 300);
	sig = SinOsc.ar(750 + mod);
	sig = sig * 0.2 ! 2;
}.play;
)

FreqScope.new;

// CE 3.12 - FM modulators in series and parallel

(
{
	var sig, mod1, mod2;
	mod2 = SinOsc.ar(0.2, mul: 450);
	mod1 = SinOsc.ar(500 + mod2, mul:800); // we use mod2 to offset the frequency of mod1 here, a serial configuration
	sig = SinOsc.ar(1000 + mod1);
	sig = sig * 0.2 ! 2;
}.play;
)

(
{
	var sig, mod1, mod2;
	mod2 = SinOsc.ar(0.2, mul: 450);
	mod1 = SinOsc.ar(500, mul:800);
	sig = SinOsc.ar(1000 + mod1 + mod2); // this is a parellel construction, we offset the carrier with both mod1 and mod2 'independently'
	sig = sig * 0.2 ! 2;
}.play;
)

// 3.3.3 additional modulation ideas

// CE 3.13 - pulse width modulation

(
{
	var sig, mod;
	mod = LFTri.ar(0.3).range(0.1,0.95);
	sig = Pulse.ar(100, width: mod); // modulating the Pulse's width parameter with LFTri assigned to mod and a normalized range method
	sig = sig * 0.2!2;
}.play;
)

(
{
	var sig, mod;
	mod = LFTri.ar(0.3).range(0,1);
	sig = VarSaw.ar(200, width: mod); // modulating the saw's width param morphs the shape from saw to triangle
	sig = sig * 0.2!2;
}.play;
)

// CE 3.14 - aliasing vs non aliasing UGens
// some UGens come in LF and non LF pairs, some have only an LF version (LFTri) or a non LF version (SinOsc). LF UGens are designed to run at low frequencies and are intended as modulators; they are not antialiased and so produce precise representations of their shapes throughout the audible spectrum but can alias and produce unintended harmonics and fluttering at higher frequencies

(
{
	var sig, freq;
	freq = XLine.kr(20, 8000, 10, doneAction: 2);
	sig = LFPulse.ar(freq); // replace with LFPulse to notice the difference
	sig = sig * 0.2!2;
}.play
)

// 3.4.1 - wavetables; creating and playing

// CE 3.15 - wavetable creation and reading via Osc

(
~wt = Signal.sineFill(8192, [1], [0]).asWavetable;
b = Buffer.loadCollection(s, ~wt);
)
{Osc.ar(b, 200)*0.2!2}.play;
b.free;

// 3.4.2 - blended wavetables

// CE 3.16 - multiple wavetables, stored in consecutive buffers

(
b = Buffer.allocConsecutive(4, s, 16384);
~wt = [
	Signal.sineFill(8192, 1 ! 4, 0 ! 4),
	Signal.sineFill(8192, 1 / (1..50), 0!50),
	Signal.sineFill(
		8192,
		[1 / (1, 3..50), 0!25].lace(50),
		0 ! 50
	),
	Signal.sineFill(
		8192,
		Array.exprand(50, 0.001, 1).sort.reverse,
		{rrand(0, 2pi)} ! 50
	),
];
b.do({ |buf, i| buf.loadCollection(~wt[i].asWavetable) });
)

~wt.plot; // optional visualization

// CE 3.17 - wavetable morphing, we assume 3.16 has already been executed

(
{
	var sig, bufmod;
	bufmod = SinOsc.kr(0.05, 3pi/2).unipolar(2.999);
	sig = VOsc.ar(b[0].bufnum + bufmod, 200);
	sig = sig *0.1!2;
}.play;
)

s.scope;

// there is so much happening here, need to come back and break it down

// CE 3.18 - waveshaping with an S-curve transfer function derived from Env

(
~wt = Env.new([-1, 0, 1], [1, 1], [4, 4]).asSignal(8193);
b = Buffer.loadCollection(s, ~wt.asWavetableNoWrap);
)

~wt.plot;

(
{
	var sig, index;
	index = SinOsc.ar(200);
	sig = Shaper.ar(b, index);
	sig = sig *0.2!2;
}.play;
)

b.free;

// section 3.5 - filters and subtractive synthesis

// CE 3.19 - various examples of noise functions

{WhiteNoise.ar(0.1 ! 2)}.play;
{PinkNoise.ar(0.1 ! 2)}.play;
{BrownNoise.ar(0.1 ! 2)}.play;

// CE 3.20 - LFNoise0 - sample and hold/stepped random

(
{
	var sig, freq;
	freq = LFNoise0.kr(8).exprange(150, 2000);
	sig = SinOsc.ar(freq) * 0.2!2;
}.play;
)

// CE 3.21 - non dynamic vs dynamic LF noise gens

{LFNoise0.ar(XLine.kr(100, s.sampleRate, 8)) * 0.1 ! 2}.play;

{LFNoise1.ar(XLine.kr(100, s.sampleRate, 8)) * 0.1 ! 2}.play;

{LFNoise2.ar(XLine.kr(100, s.sampleRate, 8)) * 0.1 ! 2}.play;

{LFDNoise0.ar(XLine.kr(100, s.sampleRate, 8)) * 0.1 ! 2}.play;

{LFDNoise1.ar(XLine.kr(100, s.sampleRate, 8)) * 0.1 ! 2}.play;

{LFDNoise3.ar(XLine.kr(100, s.sampleRate, 8)) * 0.1 ! 2}.play;

// CE 3.22 - basic filter UGens processing pink noise

(
{
	var sig, cutoff, fmod;
	fmod = LFNoise2.kr(0.1, 1).exprange(0.01, 0.2);
	cutoff = LFTri.kr(fmod, 3).exprange(100, 7500);
	sig = PinkNoise.ar(1);
	sig = sig + SinOsc.ar([350, 705, 1410], mul: 0.1);
	sig = LPF.ar(sig, cutoff) * 0.25 ! 2; // replace with HPF
}.play;
)

s.scope;
s.reboot;
FreqScope.new;

(
{
	var sig, cutoff;
	cutoff = LFTri.kr(0.1, 3).exprange(100, 10000);
	sig = PinkNoise.ar(1);
	sig = HPF.ar(sig, cutoff) * 0.25 ! 2;
}.play;
)

(
{
	var sig, cutoff, rq;
	cutoff = LFTri.kr(0.1, 3).exprange(100, 10000);
	rq = MouseY.kr(0.1, 1, 1).clip(0.1, 1);
	sig = PinkNoise.ar(1);
	sig - BPF.ar(sig, cutoff, rq) * 0.25 ! 2; // replace with BPRF
}.play;
)

FreqScope.new;

// CE 3.33 - amplitude compensation for filtering

(
{
	var sig, cutoff, rq;
	cutoff = LFTri.kr(0.1, 3).exprange(100, 10000);
	rq = MouseY.kr(0.01, 1, 1).clip(0.01, 1);
	sig = PinkNoise.ar(1);
	sig = BPF.ar(sig, cutoff, rq, mul: 1 / rq.sqrt) * 0.5 ! 2; // using a mul value of the reciprocal of the square root of our resonance to compensate for gain reduction
}.play;
)

// CE 3.24 - iteration to apply copies of filters in series

(
{
	var sig;
	sig = WhiteNoise.ar(1 ! 2);
	2.do({sig = LPF.ar(sig, 1000)});
	sig = sig * 0.25;
}.play;
)

// CE 3.25 - modulating a resonant lpf

(
{
	var sig, cutoff, freq;
	freq = LFNoise0.kr(1).range(25, 49).round(1).midicps;
	cutoff = VarSaw.kr(6, width: 0.1).exprange(50, 10000);
	sig = Pulse.ar(freq * [0.99, 1.01]);
	sig = RLPF.ar(sig, cutoff, 0.1);
	sig = sig * 0.1;
}.play;
)

// CE 3.26 - ringz and resonz

(
{
	var sig, exc;
	exc = Impulse.ar(1);
	sig = Ringz.ar(
		exc,
		freq: 800,
		decayTime: 1/3
	);
	sig = sig * 0.2 ! 2;
}.play;
)

// getting an error for non audio rate input to ringz, hmmmm
// Ringz does not want us to name the first argument, if we use 'In:' it assumes the input is a float number and not an audio rate signal

(
{
	var sig, exc;
	exc = PinkNoise.ar(10);
	sig = Resonz.ar(
		exc,
		freq: 800,
		bwr: 0.001,
		mul: 1 / 0.001.sqrt
	);
	sig = sig * 0.5 ! 2;
}.play;
)

// attempting a kick drum, did not go as planned, analyze why

(
SynthDef.new(\kick, {
	arg freq = 100, amp = 0.2, atk = 0.001, dec = 0.3, slev = 0.4, rel = 1, gate = 0, out = 0;
	var sig, env, penv;
	env = EnvGen.kr(
		Env.adsr(atk, dec, slev, rel),
		doneAction: 1
	);
	freq = freq + penv;
	sig = SinOsc.ar(freq);
	sig = sig * env;
	sig = sig * amp;
	sig = sig ! 2;
	Out.ar(out, sig);
}).add;
)

x = Synth(\kick);
x.set(\freq, 450);
x.set(\amp, 0.5);
x.set(\gate, 0, \rel, 3);

// trying again, i think i just over complicated it a bit. this is soundengraver's recipe
s.reboot;
(
SynthDef.new(\kick, {
	arg freqA=1000, freqB=50, freqC=10, freqDur1=0.01, freqDur2=0.2, freqC1=1, freqC2=(-1), atk=0.01, rel=1, c1=1, c2=(-12), amp=0.8, pan=0, out=0;
	var sig, env, freqSweep;
	freqSweep = Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqC1, freqC2]).ar; // haven't seen a construction like this yet, not sure it matters but we will see!
	env = Env([0, 1, 0], [atk, rel], [c1, c2]).kr(2);
	sig = SinOsc.ar(freqSweep, pi/2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\kick, [\freqA, 1000, \amp, 1]);

// let's try a noise hat

(
SynthDef.new(\hat, {
	arg amp=0.8, atk=0.01, rel=0.3, c1=1, c2=(-12), pan=0, out=0;
	var sig, env;
	env = Env(
		[0, 1, 0],
		[atk, rel],
		[c1, c2]
	).kr(2);
	sig = WhiteNoise.ar(0.5, 0);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

y = Synth.new(\hat, [\atk, 0.01, \rel, 0.05]);

// success!













// white space because I want to type in the middle of my screen instead of the gd bottom