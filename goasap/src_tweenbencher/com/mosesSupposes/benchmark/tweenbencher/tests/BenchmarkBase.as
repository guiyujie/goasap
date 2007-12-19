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
 
package com.mosesSupposes.benchmark.tweenbencher.tests {	
	import flash.display.Sprite;	
	import flash.events.Event;	
	
	import com.mosesSupposes.benchmark.BenchmarkEvent;	
	import com.mosesSupposes.benchmark.tweenbencher.TweenBencher;
	
	/**
	 * @author Moses Gunesch / mosessupposes.com (c) 
	 */
	public class BenchmarkBase {
		
		public var tweenDuration: Number = 5;	 		// Seconds. 1 or less:inaccurate. 5:Recommended. 10:Accurate. (See also: showSprites)
		public var benchmarkName: String;				// Required for display title.
		public var numSprites: Number = 125;				// (1) Start with this many sprites...
		public var loopAndIncrement: Boolean = true;		// (2) ...If true, repeat the benchmark test in a loop...
		public var numSpritesMultiplier: Number = 2; 	// (3) ...multiplying numSprites by this each time...
		public var maxAllowableSprites: Number = 16000;	// (4) ..until this limit is reached. (Be careful - set this lower first!)
		public var renderAreaHeight: Number = 100;		// Pixels. Recommended:  100 for minimal view or 560 to block to screen.
		public var showSprites: Boolean = true;			// Turn this & graphs off for an abstract, but pure, engine code efficiency test.
		public var graphFPS: Boolean = false;			// Recommended: false for benchmarks; true for analysis. Actively graphs the framerate.
		public var refreshFPSGraph: Boolean = false;	// If true, the FPS graph starts over each run.
		public var animateGraphs: Boolean = false;		// If true, the graphs are redrawn every frame. Not recommended for final tests.	
		public var graphTotals: Boolean = true;			// Recommended: true - doesn't affect results. Shows FPS averages & start-lag graph.
		public var startTimeout: Number = 10;			// Seconds, max 15. Recommended: Slightly lower to prevent Flash Player timeout.
								// (Try 10, but this might differ on your computer.)
								// Set to 5 or 10 to limit long start start lags. 
								// Player timeout cannot be prevented for tweens already in progress!
								// See also: maxAllowableSprites
		
		protected var _bencher : TweenBencher;					
		
		/**
		 * @param tweenBencher		Subclasses must require & pass a reference to the TweenBencher.
		 * @param benchmarkName	Subclasses must pass a title string.
		 */
		public function BenchmarkBase(tweenBencher:TweenBencher, benchmarkName:String ) 
		{
			this._bencher = tweenBencher;
			this.benchmarkName = benchmarkName;
			_bencher.addEventListener(BenchmarkEvent.COMPLETE, onBenchmarkComplete, false, 0, true);
		}
		
		// -== Required: All subclasses should override addTween & onMotionEnd. ==-
		
		/**
		 * Mandatory: Override this method to add a tween to the target passed in.
		 * Tween should be - width:760 tween, delay:0, duration:tweenDuration (var is above!), ease Exponential.easeInOut.
		 * @param target			The tween target
		 * @param CurrentTime		Not usually needed. The getTimer() clock time when the tween-adding loop starts.
		 * @param firstInNewSet		True if the target is the first in any new test cycle.
		 */
		public function addTween(target:Sprite, firstInNewSet:Boolean):void {
			// Add a tween to the target
		}
		
		/**
		 * Mandatory. Important! Subclasses MUST call super.onMotionEnd(), so _bencher can do its thing.
		 * Each tween added must trigger this event/callback as it completes. 
		 * Unsubscribe all listeners on the tween here.
		 */
		protected function onMotionEnd(event:Event=null):void
		{
			_bencher.onMotionEnd(); // Necessary!
		}
		
		// -== Optional ==-
		
		/**
		 * Optional - Event is fired when all cycles of the benchmark test are complete.
		 * 
		 * @param event				BenchmarkEvent contains params: benchDescription, fpsResults, startLagResults, timedOut.
		 * @see BenchmarkEvent
		 */ 
		protected function onBenchmarkComplete(event:BenchmarkEvent):void {
			
		}
				
		/**
		 * Optional - Provided as a convenience for subclasses.
		 * Dispatching events (start, update, and end) often affects tween engine performance.
		 * To test how much, subscribe events to this handler, which should remain empty.
		 */
		protected function anEvent(event:Event=null):void {
		}		
		
		/**
		 * Sends values to output window.
		 */
		public function dump() : void {
			trace("");
			trace("Benchmark Settings:"+benchmarkName);
			trace("-------------------");
			trace("tweenDuration: "+tweenDuration);
			trace("numSprites: "+numSprites);
			trace("loopAndIncrement: "+loopAndIncrement);
			trace("numSpritesMultiplier: "+numSpritesMultiplier);
			trace("maxAllowableSprites: "+maxAllowableSprites);
			trace("renderAreaHeight: "+renderAreaHeight);
			trace("showSprites: "+showSprites);
			trace("graphFPS:Boolean: "+graphFPS);
			trace("refreshFPSGraph: "+refreshFPSGraph);
			trace("graphTotals:Boolean: "+graphTotals);
			trace("startTimeout: "+startTimeout);
			trace("");
		}		
	}
}


