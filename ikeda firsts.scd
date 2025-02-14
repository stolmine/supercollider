// Boot the server
s.reboot;

(
// Define a bass synth with proper gate handling
SynthDef(\bass, {
    arg freq=55, amp=0.5, pan=0, gate=1, lagRise=0.05, lagFall=0.2, out=0, rel=0.5;

    var sig, mod, env;
    mod = SinOsc.ar(56, mul: 20);

    // ADSR Envelope controlled by gate
    env = EnvGen.kr(Env.asr(0.01, 1, rel), gate, doneAction: 2);

    sig = SinOsc.ar(freq + mod) * env * amp;
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;

// Define a lead synth with proper gate handling
SynthDef(\lead, {
    arg freq=220, amp=0.5, pan=0, gate=1, lagRise=0.05, lagFall=0.2, out=0, rel=0.5;

    var sig, env;

    // ADSR Envelope controlled by gate
    env = EnvGen.kr(Env.asr(0.01, 1, rel), gate, doneAction: 2);

    sig = Saw.ar(freq) * env * amp;
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
)

(
// Initialize MIDI
MIDIClient.init;
MIDIIn.connectAll;
)

// Dictionary to store active synths (use string keys)
~notes = IdentityDictionary.new;

(
// MIDI Note On: Start Synth
MIDIdef.noteOn(\midiTrigger, { |vel, note, chan, src|
    var freq = note.midicps;
    var synthType = if(chan == 0, \bass, \lead); // Assign different SynthDefs per channel
    var key = (chan.asString ++ "-" ++ note.asString); // Unique key as a string

    // Start synth and store it in the dictionary
    ~notes[key] = Synth(synthType, [\freq, freq, \amp, vel / 127, \gate, 1, \out, 0]);
});
)

(
// MIDI Note Off: Release Synth
MIDIdef.noteOff(\midiRelease, { |vel, note, chan, src|
    var key = (chan.asString ++ "-" ++ note.asString); // Match key format
    if (~notes.includesKey(key)) {
        ~notes[key].set(\gate, 0);  // Properly release the envelope
        ~notes.removeAt(key);       // Remove the entry
    };
});
)
