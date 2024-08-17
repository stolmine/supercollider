(
SynthDef(\fm2op, { |out=0, freq=440, modFreq=100, modIndex=1, amp=0.3, pan=0, atk=0.01, rel=1|
    var carrier, modulator, env;

    // Modulator
    modulator = SinOsc.ar(modFreq) * modIndex * freq;

    // Carrier
    carrier = SinOsc.ar(freq + modulator);

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

// Play a sequence using the FM synth
(
Pbind(
    \instrument, \fm2op,
    \midinote, Pseq([60, 62, 64, 65, 67, 69, 71, 72], 1),
    \dur, 0.25,
    \modFreq, Pwhite(50, 200, inf),
    \modIndex, Pwhite(0.5, 3, inf),
    \amp, 0.3,
    \pan, Pwhite(-0.5, 0.5, inf),
    \atk, 0.01,
    \rel, 0.5
).play;
)
