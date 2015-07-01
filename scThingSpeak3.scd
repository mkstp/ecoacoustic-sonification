//this code demonstrates how to read data from thingspeak to sc via a small python script

/*
//open terminal, cd to this directory and run...
python scThingSpeak3.py 6123
//replace 6123 with your channel number
keep it running in the background
*/

//the code will read the data from the temporary file and put values into these variables...
~freq
~amp
~rate

(
SynthDef.new(\fm1, {
	arg freq, carPartial, modPartial, index, amp, freqmul, atkdur, sus, decdur;
	var car, mod, carenv, modenv, sum, phase;

	sum = 0;
	phase = 0;

	modenv = EnvGen.kr(
		Env.new([0.0001, 1, 1, 0.0001], [atkdur, sus, decdur], 'exp'), doneAction: 0);
	index = index * modenv;
	mod = SinOsc.ar(freq * modPartial, 0, freq * index);

	carenv = EnvGen.kr(
		Env.new([0.0001, 1, 1, 0.0001], [atkdur, sus, decdur], 'exp'), doneAction: 2);

	5.do{
		car = SinOsc.ar((freq * carPartial) + mod, phase, amp);
		sum = sum + car;
		freq = freq * freqmul;
		phase = phase + 0.2;
	};

	sum = sum * carenv;

	Out.ar(0, Pan2.ar(sum, 0));
}).add;
)

(
Routine.run({
	inf.do{
		var path= thisProcess.nowExecutingPath.dirname++"/thingspeak3DATA.txt";
		var f, str, note1, note2, note3;
		if(File.exists(path), {
			f= File(path, "r");
			str= f.readAllString;
			f.close;
			str.postln;
			str= str.split(Char.space).asFloat;
			~freq= str[0];
			note1 = Synth(\fm1, [
					\freq, ~freq*2,
					\carPartial, 1,
					\modPartial, 2,
					\index, 1,
					\amp, 0.05,
					\freqmul, 1.8,
					\atkdur, 0.01,
					\sus, 0.1,
					\decdur, 0.8]);
			0.1.wait;
			note2 = Synth(\fm1, [
					\freq, ~freq*2.5,
				    \carPartial, 1,
				    \modPartial, 2,
				    \index, 1,
				    \amp, 0.05,
				    \freqmul, 1.6,
				    \atkdur, 0.01,
				    \sus, 0.1,
				    \decdur, 0.8]);
			1.wait;
			note3 = Synth(\fm1, [
					\freq, ~freq*3,
					\carPartial, 1,
					\modPartial, 1,
					\index, 1,
					\amp, 0.1,
					\freqmul, 1.4,
					\atkdur, 0.05,
					\sus, 0,
					\decdur, 0.85]);
			2.wait;
		});
	};
});
)
