
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
	 */
	public class FrameMarker extends Marker {
		
		public override function toString():String {
			return "[FrameMarker #"+_frame+"]";
		}
		
		/**
		 * Indicates this is the first FrameMarker in a cycle.
		 */
		public var firstFrameInCycle:Boolean = false;
		
		/**
		 * Indicates marker is the last FrameMarker in a cycle.
		 */
		public var lastFrameInCycle:Boolean = false;
		
		/**
		 * Frame id starting at 0.
		 * 
		 * @return	Frame count since test cycle started, starting with 0.
		 */
		public function get frame():int {
			return _frame;
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
		 * @return Elapsed time since the last FrameMarker in the test cycle.
		 */
		public function get timeSinceLastFrameMarker(): int {
			return _timeSinceLastFrameMarker;
		}
		
		protected var _frame : int;		
		protected var _timeSinceLastFrameMarker: Number=NaN;		
		
		public function FrameMarker(cycleMarker: CycleMarker, frameID:int, timeSinceLastMarker:Number=NaN, timeSinceLastFrameMarker:Number=NaN) {
			super(cycleMarker, timeSinceLastMarker);
			this._frame = frameID;
			this._timeSinceLastFrameMarker = timeSinceLastFrameMarker;
		}
	}
}
