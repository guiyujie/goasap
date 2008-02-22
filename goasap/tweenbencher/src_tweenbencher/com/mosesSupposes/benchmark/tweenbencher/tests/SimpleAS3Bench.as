
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
	import flash.events.Event;	
	import flash.display.Sprite;	
	import flash.events.TimerEvent;	
	import flash.utils.Timer;	
	import flash.utils.getTimer;	
	
	import com.mosesSupposes.benchmark.BenchmarkEvent;	
	import com.mosesSupposes.benchmark.tweenbencher.TweenBencher;
	
	/**
	 * Use to determine a standard "maximum efficiency" chart for your test system.
	 * Mimics a typical tween engine's arrangement using the thinnest code possible.
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * Developers: Except that it shows onBenchmarkComplete, this file is not a
	 * good example of a typical benchmark -- use BenchmarkTemplate instead!
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * @see tweenBencher	Reference to the TweenBencher movieclip (root of FLA).
	 */
	public class SimpleAS3Bench extends BenchmarkBase {
		
		protected var tweens : Array;		
		protected var pulse:Timer = new Timer(33);		
		
		protected var currentTime : int;
		
		public function SimpleAS3Bench(tweenBencher:TweenBencher) {
			
			super(tweenBencher, "Simple AS3 Tween");
			
			tweens = new Array();
			
			// Use Timer
			pulse = new Timer(33);
			pulse.addEventListener(TimerEvent.TIMER, update);
			pulse.start();

			// Or: Use ENTER_FRAME
//			tweenBencher.stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		public override function addTween(target:Sprite, firstInNewSet:Boolean):void {
			if (firstInNewSet)
				currentTime = getTimer();
			tweens.push( new SimplestTween(currentTime, target, tweenDuration) );
		}		
		
		protected override function onBenchmarkComplete(event:BenchmarkEvent) : void {
			pulse.stop();
		}		
		
		// atypical - specific to this test.
		protected function update(event:Event):void {
			var time:Number = getTimer();
			var i:Number = tweens.length;
			while (--i>-1) {
				var tween:SimplestTween = (tweens[i] as SimplestTween);
				if (tween.update(time)==true) {
					tweens.splice(i,1);
					// This line is mandatory, don't remove it.
					super.onMotionEnd();
				}
			}
		}		
		
	}
}
