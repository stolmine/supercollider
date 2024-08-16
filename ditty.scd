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
p = Pbind(
	// name the SynthDef to use for each note
	\instrument, \hat,
	// set up midi note numbers
	\midinote, Pseq([60], inf),
	// timing in seconds (by default 1 = 1 second)
	\dur, Pseq([0.1], inf),
	// control release
	\rel, Pseq([0.3, 0.1, 0.2, 0.05, 0.5], inf),
	// and amplitude
	\amp, Pseq([0.5, 0.2, 0.5, 0.3, 0.5, 0.3] * 0.5, inf),
	// and attack
	\atk, Pseq([[0.01].dup(4), 0.1], inf)
).play;

)



































// white space because i hate typing at the bottom of a page