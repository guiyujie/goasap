
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
	import flash.utils.getTimer;
	
	/**
	 * @author Moses Gunesch / mosessupposes.com (c) 
	 * 
	 * Generic marker used to store test data.
	 */
	public class Marker {
		
		public function toString():String {
			return "[Marker]";
		}
		
		/**
		 * read-only. 
		 * 
		 * @return	CycleMarker defining the test cycle that this Marker belongs to.
		 */
		public function get cycle():CycleMarker {
			return _cycle;
		}
		
		/**
		 * read-only.
		 * 
		 * @return	The getTimer() value at the time this marker was created.
		 */
		public function get time(): int {
			return _time;
		}
		
		/**
		 * read-only.
		 * 
		 * @return	Creation time as milliseconds into the current cycle. 
		 */
		public function get timeInCycle(): int {
			return (_time - _cycle.time);
		}
		
		/**
		 * read-only. Should be added to the marker at instantiation if this information
		 * is available. 
		 * 
		 * (Note that it is preferable in a benchmark system to calc the  difference 
		 * between getTimer and a running tally of these numbers, than to use the
		 * timeInCycle to generate this value. Although timeInCycle is accurate, using
		 * a running tally provides a dataset whose sum is consistent over long stretches.)
		 * 
		 * @return Elapsed time since the last Marker in the test cycle.
		 */
		public function get timeSinceLastMarker(): int {
			return _timeSinceLastMarker;
		}
		
		protected var _time : int;
		protected var _timeSinceLastMarker: Number=NaN;
		protected var _cycle : CycleMarker;		
		
		public function Marker(cycleMarker: CycleMarker, timeSinceLastMarker: Number=NaN) {
		 	this._cycle = cycleMarker;
			this._time = getTimer();
			_timeSinceLastMarker = timeSinceLastMarker;
		}
	}
}
