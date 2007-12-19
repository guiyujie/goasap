
/**
 * Copyright (c) 2007 Moses Gunesch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
package com.mosesSupposes.benchmark.tweenbencher {
	import flash.display.Graphics;	
	import flash.display.MovieClip;	
	import flash.display.Sprite;	
	import flash.events.Event;	
	import flash.events.EventDispatcher;	
	import flash.events.MouseEvent;	
	import flash.events.TimerEvent;	
	import flash.system.System;	
	import flash.text.TextField;	
	import flash.text.TextFormat;	
	import flash.utils.Timer;	
	import flash.utils.describeType;	
	import flash.utils.getTimer;	
	
	import com.mosesSupposes.benchmark.BenchmarkEvent;	
	import com.mosesSupposes.benchmark.BenchmarkResults;	
	import com.mosesSupposes.benchmark.BenchmarkStatus;	
	import com.mosesSupposes.benchmark.CycleMarker;	
	import com.mosesSupposes.benchmark.FrameMarker;	
	import com.mosesSupposes.benchmark.InitializationCompleteMarker;	
	import com.mosesSupposes.benchmark.Marker;	
	import com.mosesSupposes.benchmark.SecondMarker;	
	import com.mosesSupposes.benchmark.tweenbencher.tests.BenchmarkBase;	
	
	import fl.controls.Button;	
	import fl.controls.TextInput;
	
	/**
	 * TweenBencher
	 * 
	 * AS3 SCRIPTED-MOTION BENCHMARK UTILITY
	 * -------------------------------------
	 * @version: 1.5 (1st public release) 
	 * (c) Moses Gunesch, MosesSupposes.com
	 * Please retain this full header block when modifying or redistributing this source.
	 * 
	 * EVENTS DISPATCHED
	 * -----------------
	 * BenchmarkEvent.COMPLETE (includes benchmarkResults:BenchmarkResults property)
	 * 
	 * DESCRIPTION
	 * -----------
	 * Use TweenBencher to test the efficiency of tween engines and their various features.
	 * 
	 * REQUIREMENTS
	 * ------------
	 * TweenBencher.fla. The included TestingPanel component is optional.
	 * 
	 * STATEMENT OF PURPOSE
	 * --------------------
	 * This utility was designed to help create the "Go" open standard for AS3 animation.
	 * 
	 * It works by providing a base benchmark called SimpleAS3Bench, that uses the bare minimum 
	 * of code in the structure of a typical tween engine. The results of that benchmark can be
	 * treated as a maximum (particular to the test environment of course), that you can compare
	 * other tween engine results against.
	 * 
	 * Go is not a competitor with other tween engines, it is a complementary library in that
	 * any engine could incorporate it. The idea behind Go (being created at the time of this 
	 * writing) is to provide a flexible and fast base system with the bare minimum of animation
	 * code. Besides helping us streamline the Go base classes, this utility can help you
	 * streamline the tools you build with Go, or improve other tween engines.
	 * 
	 * Remember that benchmarks are specific to the host computer, and numbers are useful only
	 * by comparing to SimpleAS3Bench results. Save all files and close other apps before testing!
	 * 
	 * ARCHITECTURE
	 * ------------
	 * TweenBencher has a very simple interface: A benchmark method and a completion event. 
	 * You can subclass BenchmarkBase very easily to create your own benchmark tests - a template 
	 * subclass is also provided. The TestingPanel, an optional extra in the FLA, just generates 
	 * a test-class instance and sends it to TweenBencher.benchmark. Test results are stored 
	 * in a BenchmarkResults instance, which uses a simple data format - a flat series of Marker 
	 * instances - and the results instance is passed in the completion event. Easy as pie!
	 * 
	 * SITE
	 * ----
	 * http://go.mosessupposes.com/
	 * 
	 */
	public class TweenBencher extends MovieClip {
		
		// In FLA, referenced in this file using array brackets. (There must be a better way?)
//		totals_mc : MovieClip		
//		fpsrecord_mc : MovieClip		
//		title_txt : TextField		
//		subtitle_txt : TextField		
//		numSprText : TextField		
//		fpsText : TextField

		// Flatline allowance (keep very low, like 0 or 1 second!)
		protected var maxFlatlineSeconds : uint = 1;

		
		// program settings
		protected var bench : BenchmarkBase;
		protected var results : BenchmarkResults;
		protected var busy : Boolean;
		protected var aborted : Boolean;		
		protected var timedOut:Boolean;
		protected var sprites:Array;
		protected var spritesDrawn : Number;
		protected var refreshTimer :Timer;
		protected var drawBufferTimer:Timer;
		protected var addTweenStartTime:Number;
		protected var numSprites:Number;
		protected var tweensDone:Number;
		protected var currentCycleMarker : CycleMarker;		
		protected var cycleFlag : int;		
		
		// charting
		protected var totalTxts:Array;
		protected var clipboardTxt:String = "";
		protected var drawTimeLimit:Number;
		protected var textTransfer:String = "";
		protected var dispatcher : EventDispatcher;		
		protected var textOutput : TextInput;		
		protected var textOutput2 : TextInput;		
		protected var chart1Graphics : Graphics;		
		protected var chart2Graphics : Graphics;		
		protected var totalsGraphY : Number;		
		protected var chartWidth : Number; // currently using similar sized charts.
		protected var chartHeight : Number;
		protected var chartHeightMult : Number;
		protected var chartHeightMult2 : Number;
		protected var millisecondStep : Number;		
		protected var chart1Title:String = "Active Framerate (sections=seconds)";
		protected var chart2Title:String = "Totals (sections=test cycles. dots=averages)";		
		protected var killSwitchBtn : Button;	
		
		
		public function TweenBencher() {
//			trace("TweenBencher instantiated.");
			this.addEventListener(Event.ENTER_FRAME, setup);
		}
		
		// -== Public Methods ==-
		
		/**
		 * Start a benchmark test. (Crash warning: save all files & close other apps before testing.)
		 * 
		 * @param bench		An instance of a benchmark class.
		 */
		public function benchmark(benchmarkInstance:BenchmarkBase):void
		{
			if (busy) {
				trace("Sorry, interrupting a benchmark in progress is not supported in this version.");
				return;
			}
			
			if (!killSwitchBtn) {
				this.bench = benchmarkInstance;
				return;
			}
			
			trace("Benchmark: "+benchmarkInstance.benchmarkName);
			
			// clear previous bench
			if (bench) {
				if (bench.showSprites)
					clearTestSprites();
				chart1Graphics.clear();
				chart2Graphics.clear();
				if (totalTxts) {
					for each (var tf:TextField in totalTxts)
						(this["totals_mc"] as MovieClip).removeChild(tf);
				}
			}
			
			// setup
			this.bench = benchmarkInstance;
			bench.startTimeout = Math.max(1, Math.min(15, bench.startTimeout)); // fix invalid timeout values
			results = new BenchmarkResults(describeType(bench));
			results.autoAddSecondsMarkers = true;
			busy = true;
			sprites = [];
			totalTxts = [];
			numSprites = bench.numSprites;
			aborted = false;
			millisecondStep = (chartWidth / (bench.tweenDuration*1000));
			drawTimeLimit = Math.ceil(bench.startTimeout);
			chartHeightMult2 = (chartHeight/drawTimeLimit);
			cycleFlag = -1;
			
			// UI
			(this["fpsrecord_mc"] as MovieClip).visible = bench.graphFPS;
			(this["totals_mc"] as MovieClip).y = ((bench.graphFPS) ? totalsGraphY : (this["fpsrecord_mc"] as MovieClip).y);
			(this["totals_mc"] as MovieClip).visible = bench.graphTotals;
			if (bench.graphFPS || bench.graphTotals) {
				(this["fpsrecord_mc"]["chartTitle_txt"] as TextField).text = chart1Title;
				(this["fpsrecord_mc"]["topLag_txt"] as TextField).text = String(drawTimeLimit);
				(this["fpsrecord_mc"]["midLag_txt"] as TextField).text = String(drawTimeLimit/2);
				(this["totals_mc"]["chartTitle_txt"] as TextField).text = chart2Title;
				(this["totals_mc"]["topLag_txt"] as TextField).text = String(drawTimeLimit);
				(this["totals_mc"]["midLag_txt"] as TextField).text = String(drawTimeLimit/2);
			}
			var header:String = "\nBenchmark results: "+bench.benchmarkName+"\n------------------";
			trace(header);
			clipboardTxt += header + "\n";
			(this["title_txt"] as TextField).text = "Benchmarking: " + bench.benchmarkName;
			(this["subtitle_txt"] as TextField).text = "(";
			if (bench.loopAndIncrement) {
				(this["subtitle_txt"] as TextField).appendText("Maximum "+bench.maxAllowableSprites +" sprites, at "
										+bench.numSpritesMultiplier+"X per cycle. ");
			}
			(this["subtitle_txt"] as TextField).appendText("Start lag will time out at: "+bench.startTimeout+" seconds.)");
			
			newCycle();			
		}		
		
		// -== Protected Methods ==-
		
		/**
		 * Completes constructor on SWF creation complete.
		 */
		protected function setup(event:Event) : void {
			
			// Don't boot until the swf is ready
			if (!(this["killSwitch_btn"] as Button))
				return;
			this.removeEventListener(Event.ENTER_FRAME, setup);
			
			textOutput = (this["numSprText"] as TextInput);
			textOutput2 = (this["fpsText"] as TextInput);
			chart1Graphics = (this["fpsrecord_mc"].holder_mc as MovieClip).graphics;
			chart2Graphics = (this["totals_mc"].holder_mc as MovieClip).graphics;
			chartWidth = (this["fpsrecord_mc"]["border_mc"] as MovieClip).width;
			chartHeight = (this["fpsrecord_mc"]["border_mc"] as MovieClip).height + 1;
			chartHeightMult = chartHeight/100;
			totalsGraphY = (this["totals_mc"] as MovieClip).y;
			
			killSwitchBtn = (this["killSwitch_btn"] as Button);
			
			killSwitchBtn.enabled = false;
			killSwitchBtn.addEventListener(MouseEvent.CLICK, onKillSwitchClick);
			
			refreshTimer = new Timer(1000);
			refreshTimer.addEventListener( TimerEvent.TIMER, refresh);
			drawBufferTimer = new Timer(1000, 1);
			drawBufferTimer.addEventListener( TimerEvent.TIMER, completeSpriteDraw);
			
			if (bench) { // a benchmark call was made before setup was complete, cached - run now.
				this.benchmark(bench);
			}
		}
		
		/**
		 * Start a new test cycle within an existing benchmark.
		 */
		protected function newCycle():void
		{
			spritesDrawn = 0;
			killSwitchBtn.enabled = true; // kill is allowed during sprite draw
			this.addEventListener(Event.ENTER_FRAME, spriteDraw); // buffer a frame
		}
		
		/**
		 * The first method called in creating a new cycle. Should be called onEnterFrame.
		 */
		protected function spriteDraw(e:Event=null):void 
		{
			textOutput.text = "Rendering Sprites... "+ spritesDrawn + " / "+numSprites;
			
			var mult:Number = (bench.renderAreaHeight/(numSprites-1));
			var start:Number = spritesDrawn+1;
			var end:Number = start + 2500; // max count to draw per frame.
			
			for (var i:Number=start; i<end; i++) {
				if (aborted) {
					this.removeEventListener(Event.ENTER_FRAME, spriteDraw);
					complete();
					return;					
				}
				var s:Sprite = makeSprite();
				s.x = 20;
				s.y = i * mult + 20;
				sprites.push(s);
				spritesDrawn++;
				if (bench.showSprites) {
					(this["bench_mc"] as MovieClip).addChild(s);
				}
				if (i==numSprites) {
					this.removeEventListener(Event.ENTER_FRAME, spriteDraw);
					textOutput.text = numSprites + " Sprites Rendered. Adding tweens...";
					drawBufferTimer.start();
					return;
				}
			}
		}
		
		/**
		 * spriteDraw helper method
		 */
		protected function makeSprite():Sprite {
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0x990000);
			s.graphics.drawRect(0, 0, 1, .5);
			s.graphics.endFill();
			return s;
		}
		
		/**
		 * Completes spriteDraw, after a 1-frame buffer during long draws.
		 */
		protected function completeSpriteDraw(e:TimerEvent) : void 
		{
			drawBufferTimer.reset();
			textOutput2.htmlText = textTransfer;
			
			beginCycle();
			addCycleTweens();
			
			if (!timedOut && !aborted) {
				refreshTimer.start();
				textOutput.text = String(numSprites) + " SPRITES.  ";
			}
		}
			
		/**
		 * The next step in creating a cycle after spriteDraw is done.
		 */
		protected function beginCycle():void {
			
			addTweenStartTime = getTimer();
			currentCycleMarker = results.createCycle();
			tweensDone = 0;
			if (bench.refreshFPSGraph) {
				cycleFlag = currentCycleMarker.id;
			}
			// Frame counter
			this.addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		/**
		 * Calls addTween on the benchmark instance.
		 * Times out based on the user setting.
		 */
		protected function addCycleTweens():void
		{
			timedOut = false;
			for (var i:String in sprites) {

				// User can theoretically press the kill switch during this loop but, in reality the player might not respond.
				if (aborted) {
					complete();
					return;					
				}
			
				if (getTimer()-addTweenStartTime > bench.startTimeout*1000) {
					timedOut = true;
					onMotionEnd();
					break;
				}
				bench.addTween(sprites[i], (Number(i)==0));
			}
			if (!timedOut) {
				// true for isInitializationMarker, meaning all tweens are now added & running.
				results.addFrame(true);
				currentCycleMarker.consecutiveFlatlines = 0; // Ignore flatlines during addCycleTweens - covered by startTimeout.
			}
		}
		
		// -== Frame & Second Handlers ==-
		
		/**
		 *  Add a frame marker, and all seconds markers since last frame, to results
		 *  as the flash player enters a new frame.
		 */
		protected function onFrame( event : Event ) : void 
		{
			results.addFrame();
			
			// monitor for flatlining
			if (currentCycleMarker.initializationMarker) { // Ignore flatlines during addCycleTweens - covered by startTimeout.
				if (currentCycleMarker.consecutiveFlatlines > maxFlatlineSeconds) {
					trace("Test flatlined! (0-FPS seconds:"+currentCycleMarker.consecutiveFlatlines+")");
					timedOut = true;
					onMotionEnd();
					return;
				}
			}
			// animated charting
			if (bench.animateGraphs) {
				if (bench.graphFPS) {
					chartActiveFramerate();
				}
				chartTotals();
			}
		}
							
		/**
		 * A simple timer is used to udpate the display.
		 */
		protected function refresh(event:TimerEvent=null) : void
		{
			if (currentCycleMarker.secondsCount>0) {
				// update the onscreen textfield display
					textOutput2.htmlText = "CURRENT FPS:"+ currentCycleMarker.averageFPS.toString()
											+ "  ::  MAX:" +currentCycleMarker.highestFPS.toString()
											+ "  ::  MIN:"+currentCycleMarker.lowestFPS.toString()
											+ "  ::  <b>CYCLE FPS:"+ currentCycleMarker.averageFPS.toString()+ "</b> / " + stage.frameRate
											+ "  ::  TOTAL FPS:"+ results.totalFPS.toString() + " / " + stage.frameRate;
				// chart
				if (!bench.animateGraphs && bench.graphFPS) {
					chartActiveFramerate();
				}
			}
		}
				
		/**
		 * Onscreen "stop after current test" button handler
		 */
		protected function onKillSwitchClick(event:MouseEvent=null) : void {
			(event.target as Button).enabled = false;
			aborted = true;
		}
		
		/**
		 * Helper used by several methods
		 */
		protected function clearTestSprites() : void 
		{
			if (!sprites) return;
			for each(var spr:Sprite in sprites) {
				(this["bench_mc"] as MovieClip).removeChild(spr);
			}
			sprites.splice(0, sprites.length);
		}		
		
		
		// -== End Test Cycle ==-
		
		/**
		 * Called by bench classes that extend BenchmarkBase as each tween completes.
		 * Also called prematurely from this class during timeouts.
		 */
		public function onMotionEnd():void
		{
			//trace("onMotionEnd :: "+(tweensDone+1));
			if ( !busy || (!timedOut && ++tweensDone < numSprites) ) 
				return;
			
			if (bench.graphFPS)
				chartActiveFramerate();
			
			// Clear
			refreshTimer.reset();
			this.removeEventListener(Event.ENTER_FRAME, onFrame);
		
			if (bench.graphTotals) // do not move
				chartTotals();
			
			// Results
			var result:String = (numSprites+" Sprites	::	Start Lag: "+ currentCycleMarker.initializationStatus
								+"	::	FPS: " + (currentCycleMarker.averageFPS || 0));
			trace(result);
			clipboardTxt += result + "\n";
			
			var done:Boolean = (!bench.loopAndIncrement || aborted || timedOut);
			
			// Loop
			if (!done && Math.ceil(numSprites * bench.numSpritesMultiplier) <= bench.maxAllowableSprites) {
				results.endCycle();
				if (bench.showSprites) 
					clearTestSprites();
				textTransfer = textOutput2.htmlText;
				numSprites = Math.ceil(numSprites * bench.numSpritesMultiplier);
				newCycle();
			}
			// Or End
			else {
				complete();
			}
		}
		
		/**
		 * Entire benchmark complete (all test cycles). 
		 * Used by onMotionEnd and also if kill switch clicked during cycle bootup.
		 */
		protected function complete():void
		{
			// Clear (safety in case called from a method other than onMotionEnd)
			refreshTimer.reset();
			this.removeEventListener(Event.ENTER_FRAME, onFrame);
			
			if (timedOut) {
				results.endCycle(BenchmarkStatus.TIMED_OUT, true);
				textOutput.htmlText = "<b>TEST TIMED OUT.</b>  Benchmark record copied to clipboard.";
			}
			else if (aborted) {
				results.endCycle(BenchmarkStatus.ABORTED, true);
				textOutput.htmlText = "<b>TEST ABORTED.</b>  Benchmark record copied to clipboard.";
			}
			else {
				results.endCycle(BenchmarkStatus.COMPLETED, true);
				textOutput.htmlText = "<b>TEST COMPLETED.</b>  Benchmark record copied to clipboard.";
			}
			
			dispatchEvent(new BenchmarkEvent(BenchmarkEvent.COMPLETE, results));
			
			System.setClipboard(clipboardTxt);
			busy = false;
			killSwitchBtn.enabled = false;
		}
		
		// -== Charting Methods ==-
		
		/**
		 * Renders the Totals chart.
		 */
		protected function chartTotals():void
		{
			var g:Graphics = chart2Graphics;
			g.clear();
			var cycleMarkers:Array = results.getCycleMarkers();
			var step:Number = (chartWidth / cycleMarkers.length);
			var step2:Number;
			var i:Number;
			var j:Number;
			var boxSize:Number = 4;
			var nsprites:Number = bench.numSprites;
			for (i=0; i<cycleMarkers.length; i++) {
				var marker:CycleMarker = (cycleMarkers[i] as CycleMarker);
				var prevmarker:CycleMarker = (cycleMarkers[i-1] as CycleMarker);
				if (!prevmarker) prevmarker = marker;
				var i_x:Number = i*step;
				var i1_x:Number = (i+1)*step;
				
				// section lines
				g.lineStyle(0,0xADB564); // matches the bars in the fla
				g.moveTo(i_x,0);
				g.lineTo(i_x,chartHeight);
				
				//text readouts
				var txt:TextField;
				if (cycleMarkers.length-i==1 && !totalTxts[i]) {
					txt = new TextField();
					txt.background = true;
					txt.autoSize = "center";
					txt.defaultTextFormat = new TextFormat("_typewriter", 10, 0x666666, false,false,false,null,null, "right");
					txt.y = chartHeight + 25 * (i%2) + 5;
					totalTxts[i] = txt;
					(this["totals_mc"] as MovieClip).addChild(txt);
				}
				else {
					txt = (totalTxts[i] as TextField);
				}
				if (txt.text.length==0 || bench.animateGraphs) {
					txt.text = String(marker.averageFPS || 0) 
								+ "fps @ "+String(nsprites) 
								+ "\n"
								+ "Start Lag: " + marker.initializationStatus;
				}
				txt.x = (i1_x - txt.width);
				nsprites *= bench.numSpritesMultiplier;
								
				// start lag graph
				var initMarker1:InitializationCompleteMarker = prevmarker.initializationMarker;
				var initMarker2:InitializationCompleteMarker = marker.initializationMarker;
				g.lineStyle(0,0x33cc00);
				var lag1:Number = (i==0) ? 0 : drawTimeLimit;
				if (i>0 && initMarker1)
					lag1 = Math.round(initMarker1.timeInCycle/10)/100;
				var lag2:Number = drawTimeLimit;
				if (initMarker2) lag2 = Math.round(initMarker2.timeInCycle/10)/100;
				g.moveTo(i_x, chartHeight - (lag1 * chartHeightMult2));
				g.lineTo(i1_x, chartHeight - (lag2 * chartHeightMult2));

				// totals graph straight-line between test averages
				if (i>0) {
					g.lineStyle(0,0x5FAEFE); // a shade lighter than 3399FF blue so it's more of a background element.
					g.moveTo(i_x, chartHeight - ((prevmarker.averageFPS || 0) * chartHeightMult));
					g.lineTo(i1_x, chartHeight - ((marker.averageFPS || 0) * chartHeightMult));
				}
				
				// totals graph line showing per second averages
				var fcounts:Array = marker.frameCountBySecond;
				g.lineStyle(2,0x3399FF);
				g.moveTo(i_x, chartHeight - (fcounts[0] * chartHeightMult));
				step2 = step / (fcounts.length);
				for (j=0; j<fcounts.length; j++) {
					g.lineTo(i_x + (j+1)*step2, chartHeight - (fcounts[j] * chartHeightMult));
				}
				
				// totals graph (box version)
				g.lineStyle(0,0x3399FF);
				var x:Number = i1_x;
				var y:Number = chartHeight - (marker.averageFPS * chartHeightMult);
				g.moveTo(x-boxSize/2, y-boxSize/2);
				g.beginFill(0x3399ff);
				g.lineTo(x+boxSize/2, y-boxSize/2);
				g.lineTo(x+boxSize/2, y+boxSize/2);
				g.lineTo(x-boxSize/2, y+boxSize/2);
				g.endFill();

			}
		}
		
		/**
		 * Renders the Active Framerate chart.
		 * 
		 * This version uses a custom format. Framerates are artificially projected from each frame's duration.
		 * The points are placed both vertically (as FPS) and also horizontally: spacing is uneven, based
		 * on the frame duration itself. For example, if only 5 frames fired in a second you only see 5 points
		 * stretched over the second.
		 */
		protected function chartActiveFramerate():void
		{
			var data:Array = results.getResults(cycleFlag);
			var duration:Number = (cycleFlag>0  ?  currentCycleMarker.timeInCycle  :  results.totalTime);
			var step:Number = chartWidth / duration;
			var g:Graphics = chart1Graphics;
			g.clear();
			var frameX:Number = 0;
			var frameY:Number = NaN;
			var divX:Number = 0;
			var lastCycleDivX:Number=0;
			var cyclesDrawn:Number = -1;
			
			for (var i:Number=0; i<data.length; i++) {
				
				var marker:Marker = (data[i] as Marker);
				var markerDuration:int = marker.timeSinceLastMarker;
				divX += (step * markerDuration);
				
				if (!(marker is FrameMarker)) {

					if (divX>chartWidth) {
						divX = chartWidth;
					}
					
					// Start Lag segment.
					if (marker is InitializationCompleteMarker) {
						g.moveTo(lastCycleDivX, 0);
						g.lineStyle(0,0x000000,0);
						g.beginFill(0x33cc00,.5);
						g.lineTo(divX, 0);
						g.lineTo(divX, chartHeight);
						g.lineTo(lastCycleDivX, chartHeight);
						g.lineTo(lastCycleDivX, 0);
						g.endFill();
					}
					else {
					
						// Cycle divider
						if (marker is CycleMarker) {
							g.lineStyle(2, 0xADB564); // matches the bars in the fla
							cyclesDrawn++;
							lastCycleDivX = divX;
						}
						
						// Second divider
						else if (marker is SecondMarker) {
							g.lineStyle(0, 0xADB564); // matches the bars in the fla
						}
						
						// ?
						else {
							g.lineStyle(2,0xFF0000); // red for Error
							trace("Marker not understood by chartActiveFramerate: "+marker.toString());
						}
						
						g.moveTo(divX, 0);
						g.lineTo(divX, chartHeight);
					}
				}
				
				// Graph line
				else {
					// switch to using Frame-based duration & tally.
					markerDuration = (marker as FrameMarker).timeSinceLastFrameMarker;

					if (isNaN(frameY))
						g.moveTo(0, getChartY(markerDuration));
					else
						g.moveTo(frameX, frameY);
					
					if ((cyclesDrawn==currentCycleMarker.id && (marker as FrameMarker).lastFrameInCycle) || data.length-i==1) // last
						frameX = chartWidth;
					else
						frameX += (step * markerDuration);
					
					frameY = getChartY(markerDuration);
					
					g.lineStyle(0,0x5FAEFE); // a shade lighter than 3399FF blue so it's more of a background element.
					g.lineTo(frameX, frameY);
				}
			}
		}
		
		/**
		 * Helper method. Calculates a chart Y position based on frame duration.
		 * To smooth the visual results, durations that imply an over-100 FPS are compressed 
		 * into a space of up to +10 above the chart, otherwise the division blows them out.
		 * The Flash Player doesn't actually run at over 100FPS but on this microscopic level
		 * does show a stutter effect where a delayed frame then skips quickly through the next
		 * frame. If you remove this, you still need a conditional to catch 1000/markerDuration
		 * to avoid division-by-0 (Infinity) values.
		 */
		protected function getChartY(time:int):Number {
			var chartY:Number = (time > 10  ?  1000/time  :  100 + (10-time));
			chartY = chartHeight - (chartY * chartHeightMult);
			return chartY;
		}
	}
}
