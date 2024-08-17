(
SynthDef(\fm2op, { |out=0, freq=440, modFreq=100, modIndex=1, amp=0.3, pan=0, atk=0.01, rel=1, penvDepth=0.5|
    var carrier, modulator, env, penv;

	// pitch envelope
	penv = EnvGen.kr(Env.new([0,penvDepth,0], [atk, 0.1], \lin), doneAction: 0);

    // Modulator
    modulator = SinOsc.ar(modFreq) * modIndex * freq;

    // Carrier
	carrier = SinOsc.ar(freq + modulator + penv);

    // Envelope
    env = EnvGen.kr(Env.perc(atk, rel), doneAction: 2);

    // Output
    Out.ar(out, Pan2.ar(carrier * env * amp, pan));
}).add;
)

// Test the synth
(
Synth(\fm2op, [
    \freq, 440,
    \modFreq, 100,
    \modIndex, 2,
    \amp, 0.3,
    \atk, 0.01,
    \rel, 1
]);
)

(
SynthDef.new(\kick, {
	arg freqA=1000, freqB=50, freqC=10, freqDur1=0.01, freqDur2=0.2, freqC1=1, freqC2=(-1), atk=0.01, rel=1, c1=1, c2=(-12), amp=1, pan=0, out=0;
	var sig, env, freqSweep;
	freqSweep = Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqC1, freqC2]).ar; // haven't seen a construction like this yet, not sure it matters but we will see!
	env = Env([0, 1, 0], [atk, rel], [c1, c2]).kr(2);
	sig = SinOsc.ar(freqSweep, pi/2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)


(
SynthDef.new(\hat, {
	arg amp=0.8, atk=0.01, rel=0.3, c1=1, c2=(-12), bCutoff=13000, bQ=0.5, pan=0, out=0;
	var sig, env;
	env = Env(
		[0, 1, 0],
		[atk, rel],
		[c1, c2]
	).kr(2);
	sig = WhiteNoise.ar(0.5, 0);
	sig = sig * env;
	sig = RLPF.ar(sig, bCutoff, bQ, 0.75);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

( // failing here, need to work on how to convert this to a synthdef properly
SynthDef.new(\multiSine, {
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
	Out.ar(0, sig);
}.add;
)
)
// To play the synth:
Synth(\multiSine);

// Or with custom parameters:
Synth(\multiSine, [\numOscs, 30, \minFreq, 300, \maxFreq, 3000, \amp, 0.3]);

TempoClock.default = TempoClock.new(93/60);

~durList = [1/5, 1/10, 1/10, 1/2.5, 1/5, 1/10, 1/10, 1/5, 1/2.5];

// Play a sequence using the FM synth
(
Pbind(
	\instrument, Pseq([\fm2op, \fm2op, \fm2op, \kick, \kick, \hat, \hat, \fm2op, \kick, \fm2op, \hat, \kick, \hat], inf),
	\midinote, Pseq([20, 100, 10, 10, 250, 20], inf),
	\dur, Pseq(~durList, inf),
	\modFreq, Pseq(([1700, 1200, 100, 500, 2000, 9000] * (~durList + 5)), inf),
    \modIndex, Pseq([0, 0, 1, 0, 3, 0, 0, 2], inf),
    \amp, 0.3,
	\pan, Pseq([0, 0, 0, 0, 0, 0, (-1), 0, 1], inf),
    \atk, Pseq([0.01, 0.01, 0.01, 0.01, 0.01, 0.05], inf),
    \rel, Prand([1/5, 1/10, 1/10, 1/2.5, 1/5, 1/2.5, 1/10, 1], inf),
	\freqA, Pseq([1000, 1500, 1000, 750], inf),
	\bCutoff, Pwhite(300, 15000, inf),
	\penvDepth, Pseq([700, 0, 0, 1200, 0, 0, 0, 0] * ~durList, inf)
).play;
)
