
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
	
	import caurina.transitions.Tweener;
	
	//	import fl.motion.easing.Exponential; // standard easing function for benchmarks
	
	/**
	 * @author Moses Gunesch / mosessupposes.com (c) 
	 */
	public class TweenerBenchmark extends BenchmarkBase {
		
		public function TweenerBenchmark(tweenBencher : TweenBencher) 
		{
			super(tweenBencher, "Tweener");
			
			// If the engine gives an interval option (vs. enterframe), 33ms is usally smoothest.
		}

		/**
		 * Mandatory: Override this method to add a tween to the target passed in.
		 * Tween should be - width:760 tween, delay:0, duration:tweenDuration (var is above!), ease Exponential.easeInOut.
		 * 
		 * @param target			The tween target
		 * @param CurrentTime		Not usually needed. The getTimer() clock time when the tween-adding loop starts.
		 * @param firstInNewSet		True if the target is the first in any new test cycle.
		 */
		public override function addTween(target:Sprite, firstInNewSet:Boolean):void
		{
			// each tween fires onMotionEnd on completion.
			// @param		(first-n param)		Object				Object that should be tweened: a movieclip, textfield, etc.. OR an array of objects
			// @param		(last param)		Object				Object containing the specified parameters in any order, as well as the properties that should be tweened and their values
			// @param		.time				Number				Time in seconds or frames for the tweening to take (defaults 2)
			// @param		.delay				Number				Delay time (defaults 0)
			// @param		.useFrames			Boolean				Whether to use frames instead of seconds for time control (defaults false)
			// @param		.transition			String/Function		Type of transition equation... (defaults to "easeoutexpo")
			// @param		.onStart			Function			* Direct property, See the TweenListObj class
			// @param		.onUpdate			Function			* Direct property, See the TweenListObj class
			// @param		.onComplete			Function			* Direct property, See the TweenListObj class
			// @param		.onOverwrite		Function			* Direct property, See the TweenListObj class
			// @param		.onStartParams		Array				* Direct property, See the TweenListObj class
			// @param		.onUpdateParams		Array				* Direct property, See the TweenListObj class
			// @param		.onCompleteParams	Array				* Direct property, See the TweenListObj class
			// @param		.onOverwriteParams	Array				* Direct property, See the TweenListObj class
			// @param		.rounded			Boolean				* Direct property, See the TweenListObj class
			// @param		.skipUpdates		Number				* Direct property, See the TweenListObj class
			// @return							Boolean				TRUE if the tween was successfully added, FALSE if otherwise
			
				Tweener.addTween(target, {	width:760, 
								 			time:tweenDuration, 
											transition:"easeinoutexpo", 
											onComplete:onMotionEnd
											//, onStart:function():void{}, onUpdate:function():void{}
											});
		}
		
		/**
		 * Important! Subclasses MUST call super.onMotionEnd(), so _bencher can do its thing.
		 * Each tween added must trigger this event/callback as it completes. 
		 * Unsubscribe all listeners on the tween here.
		 */
		protected override function onMotionEnd(event:Event=null):void
		{
			// This line is mandatory!
			super.onMotionEnd(event);
		}
		
		// -== Optional ==-
		
		/**
		 * Optional - Event is fired when all cycles of the benchmark test are complete.
		 * 
		 * @param event				BenchmarkEvent contains params: benchDescription, fpsResults, startLagResults, timedOut.
		 * @see BenchmarkEvent
		 */ 
		protected override function onBenchmarkComplete(event:BenchmarkEvent) : void {
			// no action necessary
		}
		
/* ALSO IN SUPER (no need to subclass these)
		
		 /**
		 * Optional - Provided as a convenience for subclasses.
		 * Dispatching events (start, update, and end) often affects tween engine performance.
		 * To test how much, subscribe events to this handler, which should remain empty.
		 * /
		protected function anEvent(event:Event=null):void
		
		/**
		 * Sends values to output window.
		 * /
		public function dump() : void
*/
	}
}
