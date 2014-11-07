/*
Graphic Synthesizer #1 SinLFO
-- relation between sinwave and circular motion--

Made by Masahiro Yoshida(shikaimonjo technology)

2014/10/09
*/

(
s.waitForBoot{
	/*
	window processing
	*/
	var width= 800, height=800; //windows width and height
	var d= 40; //diameter
	var cx= width-d/2, cy= height-d/2; //first center point
	var x1, x2, y1, y2, radian, cnt1= 0, cnt2 = 0; //variables for animation

	var w= Window.new("SinLFO -- relation between sinwave and circular motion --", Rect(250, 100, width, height), false).front;
	var u= UserView(w, w.view.bounds);

	/*
	Synthdef
	*/
	var syn = SynthDef(\sin,{
		arg
		freq = 0,
		phase = 0,
		mul = 1,
		add = 0,
		pan = 0;

			Out.ar(0,
				Pan2.ar(
					SinOsc.ar(freq, phase, mul, add),
					pan,
					1
				)
	)
	}).play(s);

	/*
	valiables that can change
	*/
	~freq = 440;
	~spd= 2; //LFO speed
	~rds= 75; //radius

	/*
	animation
	*/
	u.drawFunc= {
		/*
		calculation
		*/
		cnt1= cnt1 + ~spd % 360; //Reset 0 when go around 360°
		cnt2 = cnt2 + ~spd;
		radian= pi/180*cnt1; //reset radian
		x1= sin(radian)*~rds;
		x2= cnt2;
		y1= cos(radian)*~rds;
		y2= sin(radian)*~rds;
		if((width/2) < (x2), {cnt2= -1 * width/2});

		/*
		circular motion
		*/
		Pen.translate(cx, cy);
		Pen.color= Color.white;
		Pen.width= 3;
		Pen.fillOval(Rect(x1, y1, d, d));
		Pen.fillOval(Rect(x2, y2, d, d));

		/*
		sound
		*/
		syn.set(
			\freq, ~freq + x1, //frequency modulation
			//\freq, ~freq * x1.abs / ~rds, //frequency modulation

			//\mul, (x1 / ~rds).abs //amplitude modulation

			//\pan, x1 / ~rds //pan modulation
		);

		/*
		measure
		*/
		Pen.translate(cx.neg, cy.neg); //".neg" is negative. e.g. x = 10, then, x.neg = -10.
		Pen.color= Color.red;
		Pen.stringAtPoint("x=sin=" + x1.asString, Point(10, 10));
		Pen.stringAtPoint("y=cos=" + y1.asString, Point(10, 20));
		Pen.stringAtPoint("fps" + u.frameRate.asString, Point(10, 30));

		/*
		graph
		*/
		Pen.translate(width/2 + (~rds.neg), height/2 + (~rds.neg));
		Pen.color = Color.white;
		Pen.width= 3;
		Pen.strokeOval(Rect(0, 0, ~rds * 2, ~rds * 2));//a unit circle
		Pen.translate(~rds, ~rds);
		Pen.line(width@0); //axes(x and y)
		Pen.line(0@height);
		Pen.line(-1 * width@0);
		Pen.line(0@height * -1);
		Pen.stroke;
		Pen.strokeRect(Rect(~rds.neg, ~rds.neg, 2 * ~rds, 2 * ~rds)); //threshold line
		Pen.stringAtPoint("0", Point(5, 5)); //the origin
		Pen.stringAtPoint(~rds.asString, Point(5, ~rds + 5)); //MAX value
		Pen.stringAtPoint((~rds.neg).asString, Point(5, (~rds - 5) * -1)); //MIN value
		Pen.stringAtPoint("-∞", Point(5, -1 * height/2 + 10)); //minuses
		Pen.stringAtPoint("-∞", Point(-1 * width/2 + 10, 5));
		Pen.stringAtPoint("∞", Point(5, height/2 - 10)); //pluses
		Pen.stringAtPoint("∞", Point(width/2 - 10, 5));
		Pen.stringAtPoint("y", Point(-15, height/2 - 15)); //y axis
		Pen.stringAtPoint("x", Point(width/2 - 15, -15)); //x axis
	};

	//Window Setting
	w.onClose= {syn.free}; //When Window is closed, free SynthDef
	u.background= Color.black;
	u.animate= true;
};
)

//change variables
~spd = 1;
~spd = 0.5;
~spd = 5;
~spd = 10;
~spd = 20;
~spd = 32;
~spd = 100;

~rds = 200;
~rds = 100*1pi;
~rds = 50;

~freq = 880;
~freq = 220;
~freq = 440;

//check net address
NetAddr.langPort;
NetAddr.localAddr;

//connection
~netaddr = NetAddr.new("127.0.0.1", NetAddr.langPort);

//easy way to test
OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off


(
~spd_osc = OSCFunc({ arg msg; ~spd = msg[1];}, '/var/spd');
~rds_osc = OSCFunc({ arg msg; ~rds = msg[1];}, '/var/rds');
~freq_osc = OSCFunc({ arg msg; ~freq = msg[1];}, '/var/freq');
)

(
~spd_osc.free;
~rds_osc.free;
~freq_osc.free;
)