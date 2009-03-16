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
	import flash.display.DisplayObject;
	
	public class SimplestTween {
	
		public var target:DisplayObject;
		public var startTime:Number;
		public var duration:Number;
		
		public function SimplestTween(currentTime:Number, target:DisplayObject, duration:Number) {
			this.target = target;
			startTime = currentTime;
			this.duration = duration*1000;
		}
		
		public function update(currentTime:Number) : Boolean {
			var time:Number = currentTime - this.startTime;
			if (time >= this.duration) {
				target.width = 760;
				return true;
			}
			target.width = easeInOut( time, 0, 760, duration );
			return false;
		}
		
		/**
		 * Copied from: fl.motion.easing.Exponential
		 * (c) Adobe Systems, Inc.
		 */
		public static function easeInOut(t:Number, b:Number,
										 c:Number, d:Number):Number
		{
			if (t == 0)
				return b;
	
			if (t == d)
				return b + c;
	
			if ((t /= d / 2) < 1)
				return c / 2 * Math.pow(2, 10 * (t - 1)) + b;
	
			return c / 2 * (-Math.pow(2, -10 * --t) + 2) + b;
		}
	}
}