(
SynthDef(\sixTapDelayRandLFO, {
    |in=0, baseFreq=440, spreadMin=10, spreadMax=1000, lfoRate=0.2, delayTime=0.01, feedback=0.3, mix=1, amp=0.6|

    var input, taps, freqRatios, spread, spreadHz, output;

    input = WhiteNoise.ar * amp;

    // LFO to modulate spreadHz dynamically between spreadMin and spreadMax
    spreadHz = LinLin.kr(SinOsc.kr(lfoRate).range(-1, 1), -1, 1, spreadMin, spreadMax);

    // Generate 6 random frequency shifts, updated per synth instance
    spread = Array.fill(6, { Rand(-1, 1) * spreadHz });

    // Compute frequency ratios correctly
    freqRatios = spread.collect { |s| (baseFreq + s) / baseFreq };

    // Create delay taps with random pitch shifting
    taps = Array.fill(6, { |i|
        var tap = DelayC.ar(input, delayTime * 1.5, (i+1) * (delayTime/6));
        PitchShift.ar(tap, 0.1, freqRatios[i]) // Apply pitch shift
    });

    // Mix original + delayed signal
    output = Mix(taps) * mix + (input * (1 - mix));

    // Feedback
    output = output + (LocalIn.ar(1) * feedback);
    LocalOut.ar(output);

	Out.ar([0,1], output);
}).add;
)

// Start the patch
x = Synth(\sixTapDelayRandLFO, [\baseFreq, 200, \spreadMin, 10, \spreadMax, 10000, \lfoRate, 0.05]);
x.free;