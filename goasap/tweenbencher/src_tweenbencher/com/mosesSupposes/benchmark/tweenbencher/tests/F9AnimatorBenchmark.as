
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
	
	import fl.motion.Animator;	
	import fl.motion.FunctionEase;	
	import fl.motion.Keyframe;	
	import fl.motion.Motion;	
	import fl.motion.MotionEvent;	
	import fl.motion.easing.Exponential;
	
	/**
	 * @author Moses Gunesch / mosessupposes.com (c) 
	 * 
	 * 
	 * IMPORTANT: This test does NOT run on seconds, it runs on frames, so
	 * actual durations can vary quite a bit. (See addTween)
	 * 
	 */
	public class F9AnimatorBenchmark extends BenchmarkBase {
		
		private var motions : Array;		
		
		private var stage : Number;		
		
		public function F9AnimatorBenchmark(tweenBencher : TweenBencher) 
		{
			super(tweenBencher, "fl.motion.Animator");
			
			motions = [];
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
				var f1:Keyframe = new Keyframe();
				f1.index = 0;
				var ease1:FunctionEase = new FunctionEase();
				ease1.easingFunction = Exponential.easeInOut;
				f1.tweens.push(ease1);
						  
				var f2:Keyframe = new Keyframe();
				
				// Note: Motion works by frames, here I am using 30 fps.
				// (You can't set an accurate time based duration since it works like the timeline.)
				f2.index = tweenDuration * 30;//stage.frameRate;
				
				f2.scaleX = 760;
				
				var m1:Motion = new Motion();
				m1.addKeyframe(f1);
				m1.addKeyframe(f2);
				
				var a1:Animator = new Animator();
				a1.motion = m1;
				a1.target = target;
//				a1.addEventListener( MotionEvent.MOTION_START, super.anEvent);
//				a1.addEventListener( MotionEvent.MOTION_UPDATE, super.anEvent);
				a1.addEventListener( MotionEvent.MOTION_END, onMotionEnd);
				a1.play();
				
				motions.push(a1);

		}
		
		/**
		 * Important! Subclasses MUST call super.onMotionEnd(), so _bencher can do its thing.
		 * Each tween added must trigger this event/callback as it completes. 
		 * Unsubscribe all listeners on the tween here.
		 */
		protected override function onMotionEnd(event:Event=null):void
		{
			var a1:Animator = (event.target as Animator);
//			a1.removeEventListener( MotionEvent.MOTION_START, super.anEvent);
//			a1.removeEventListener( MotionEvent.MOTION_UPDATE, super.anEvent);
			a1.removeEventListener( MotionEvent.MOTION_END, onMotionEnd );
			
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
			motions = [];
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
