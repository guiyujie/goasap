
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
 
package com.mosesSupposes.benchmark {	
	
	/**
	 * @author Moses Gunesch / mosessupposes.com (c) 
	 * 
	 * Second id is automatically generated using the creation time and the CycleMarker's startTime.
	 */
	public class SecondMarker extends Marker {
		
		public override function toString():String {
			return "[SecondMarker #"+_second+"]";
		}
		
		/**
		 * read-only.
		 * 
		 * @return The tick id this marker represents, e.g. 1 for "1 second elapsed".
		 */
		public function get second():Number {
			return _second;
		}
		
		protected var _second : Number;		
		
		public function SecondMarker(cycleMarker: CycleMarker, secondID:int, timeSinceLastMarker:Number=NaN) {
			super(cycleMarker, timeSinceLastMarker);
			_second = secondID;
			_time = _cycle.time + secondID*1000; // set specific time.
		}
	}
}
