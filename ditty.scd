// attempting to sequence some drum sounds

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

(
p = Pbind(
	// name the SynthDef to use for each note
	\instrument, \hat,
	// set up midi note numbers
	\midinote, Pseq([60], inf),
	// timing in seconds (by default 1 = 1 second)
	\dur, Pseq([0.05, Rest(0.05), 0.05, Rest(0.05)], inf),
	// control release
	\rel, Pseq([0.3, 0.1, 0.2, 0.05, 0.5], inf),
	// and amplitude
	\amp, Pseq([0.5, 0.2, 0.5, 0.3, 0.5, 0.3] * 0.5, inf),
	// and attack
	\atk, Pseq([[0.01].dup(4), 0.1], inf)
).play;
)

(
x = Pbind(
	\instrument, \kick,
	\midinote, Pseq([30], inf),
	\dur, Pseq([1, 0.25, 0.25, Rest(), 0.5, 1], inf),
	\amp, Pseq([0.8], inf)
).play;
)



































// white space because i hate typing at the bottom of a page