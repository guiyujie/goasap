
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
	 * CycleMarkers appear in the flatfile results array at the beginning of each
	 * new cycle, and store an active status of that cycle.  
	 * Other properties include id, status, time and duration.
	 * In this Marker subclass, time refers to the start time of the cycle.
	 */
	public class CycleMarker extends Marker {
		
		public override function toString():String {
			return "[CycleMarker #"+_id+"]";
		}
		
		/**
		 * read only.
		 * 
		 * @return	The cycle id, starting with 0 for the first cycle.
		 */
		public function get id():int {
			return _id;
		}		
		
		/**
		 * Get or set the marker's status.
		 * 
		 * @return	The current test status, using the constants in this class.
		 */
		public function get status():String {
			return _status;
		}
		public function set status( statusConst: String):void {
			if (statusConst==BenchmarkStatus.UNSTARTED || statusConst==BenchmarkStatus.RUNNING || statusConst==BenchmarkStatus.COMPLETED || statusConst==BenchmarkStatus.ABORTED || statusConst==BenchmarkStatus.TIMED_OUT) {
				if (_status == statusConst || statusConst == BenchmarkStatus.UNSTARTED || !isNaN(_endTime)) { // CycleMarkers instances are one-time-use only.
					return;
				}
				_status = statusConst;
				if (_status == BenchmarkStatus.RUNNING) {
					_time = getTimer();
				}
				else if (statusConst==BenchmarkStatus.COMPLETED || statusConst==BenchmarkStatus.ABORTED || statusConst==BenchmarkStatus.TIMED_OUT) {
					_endTime = getTimer();
				}
			}
			else {
				trace("** CycleMarker status \""+status+"\" not found. **");
			}
		}
		
		/**
		 * read only.
		 * @return		The getTimer() value when the test cycle finished.
		 */
		public function get endTime():int {
			return _endTime;
		}
		
		/**
		 * Convenience, can be used to store the number of SecondsMarker instances in a cycle.
		 */
		public var frameCount: Number = 0;
		
		/**
		 * Convenience, can be used to store the number of FrameMarker instances in a cycle.
		 */
		public var secondsCount: Number = 0;
		
		/**
		 * Convenience, can be used to store the average frames-per-second for the cycle.
		 */
		public var averageFPS: Number;
		
		/**
		 * Convenience, can be used to store the highest frames-per-second for the cycle.
		 */
		public var highestFPS: Number;
		
		/**
		 * Convenience, can be used to store the lowest frames-per-second for the cycle.
		 */
		public var lowestFPS: Number;		
		
		/**
		 * Convenience, can be used to tally the number of 0-FPS seconds in a row.
		 */
		public var consecutiveFlatlines : int = 0;
		
		/**
		 * Convenience, can be used to store the frameCount each second.
		 */
		public var frameCountBySecond: Array = [];
		
		/**
		 * read only.
		 * @return		A running or final duration based on status.
		 */
		public override function get timeInCycle():int 
		{
			if (_status == BenchmarkStatus.UNSTARTED) 
				return 0;
				
			if (_status == BenchmarkStatus.RUNNING) 
				return (getTimer() - _time);
			
			return (_endTime - _time); // final fixed duration value.
		}
		
		/**
		 * Once all tweens have been added, a InitializationCompleteMarker instance is inserted
		 * into the series, and a reference of it is stored in this variable.
		 */
		public var initializationMarker: InitializationCompleteMarker;
		
		/**
		 * read-only.
		 * @return		A formatted string describing initialization-marker status.
		 */
		public function get initializationStatus():String {
			// initialized
			if (initializationMarker) {
				var lag:Number = Math.round(initializationMarker.timeInCycle/10)/100;
				return (String(lag) + (lag==1 ? " second" : " seconds"));
			}
			// never initialized
			switch (_status) {
				case BenchmarkStatus.TIMED_OUT: return "Timed out";
				case BenchmarkStatus.UNSTARTED: return "Waiting...";
				case BenchmarkStatus.ABORTED: return "Test aborted";
				case BenchmarkStatus.COMPLETED: return "Did not initialize";
			}
			return "Unknown";
		}
		
		protected var _id: int;
		protected var _status: String = BenchmarkStatus.UNSTARTED;
		protected var _endTime : Number = NaN;
		
		public function CycleMarker(cycleID: int, startNow: Boolean=false) {
			
			super(this, 0);
			
			_id = cycleID;
			
			if (startNow)
				status = BenchmarkStatus.RUNNING;
		}
	}
}
