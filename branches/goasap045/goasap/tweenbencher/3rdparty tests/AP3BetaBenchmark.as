
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
	
	import de.alex_uhlmann.animationpackage.animation.AnimationCore;	
	import de.alex_uhlmann.animationpackage.animation.AnimationEvent;	
	import de.alex_uhlmann.animationpackage.animation.Scale;	
	import de.alex_uhlmann.animationpackage.utility.TimeTween;	
	
	import fl.motion.easing.Exponential;
	
	/**
	 * @author Moses Gunesch / mosessupposes.com (c) 
	 * 
	 * Crash Warning! This package can lock the player as tweens complete
	 * when high numbers of tweens are running. The following mod catches
	 * error 1502, the 15-second player timeout, but there's no easy way 
	 * to prevent the player from hanging.
	 * 
	 * Package: de.alex_uhlmann.animationpackage.utility.TimeTween
	 * Method: dispatch()
	 * Mod: Wrap the code inside the for-loop in a try/catch block.
	 * 
	 * <pre>
	 * for (i = 0; i < len; i++) {
	 * 	try {
	 * 		// existing code
	 * 	}
	 * 	catch(e:Error) {
	 * 		trace("TimeTween.dispatch: "+e.message);
	 * 	}
	 * }
	 * </pre>
	 */
	public class AP3BetaBenchmark extends BenchmarkBase {
		
		protected var tweens : Array;		

		public function AP3BetaBenchmark(tweenBencher : TweenBencher) 
		{
			super(tweenBencher, "AnimationPackage 3 Beta");
			
			tweens = [];
			
			// If the engine gives an interval option (vs. enterframe), 33ms is usally smoothest.
			TimeTween.interval = 33; // requires changing this to public in the class.
			
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
			var myScale:Scale = new Scale( target );
			myScale.scaleWithPixels(true);
			myScale.setOptimizationMode(true);
			myScale.animationStyle(tweenDuration*1000, Exponential.easeInOut);
//			myScale.addEventListener(AnimationEvent.START, anEvent);
//			myScale.addEventListener(AnimationEvent.UPDATE, anEvent);
			myScale.addEventListener(AnimationEvent.END, onMotionEnd);
			myScale.run(760,1);
			tweens.push(myScale);
		}
		
		/**
		 * Important! Subclasses MUST call super.onMotionEnd(), so _bencher can do its thing.
		 * Each tween added must trigger this event/callback as it completes. 
		 * Unsubscribe all listeners on the tween here.
		 */
		protected override function onMotionEnd(event:Event=null):void
		{
			var scale:Scale = (event.target as Scale);
//			scale.removeEventListener( AnimationEvent.START, anEvent);
//			scale.removeEventListener( AnimationEvent.UPDATE, anEvent);
			scale.removeEventListener( AnimationEvent.END, onMotionEnd);
			
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
