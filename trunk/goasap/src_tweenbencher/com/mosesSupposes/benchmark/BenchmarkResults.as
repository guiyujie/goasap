
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
	 * BenchmarkResults is a storage & test-building utility. When a benchmark is complete it 
	 * enters a read-only mode, and offers a number of convenient query methods to get the data.
	 * 
	 * The additional TweenBencher utility creates an instance of this class for each benchmark, 
	 * which it uses to actively store and chart data. When all cycles are done it then sends that 
	 * BenchmarkResults out in its completion event, providing a full dataset for charting, storage, 
	 * cross-comparison, etc.
	 * 
	 * For simplicity, test data is stored in a single flatfile Array. The array is composed of various
	 * children of the Marker class. 
	 * 
	 * So, two 2-second test cycles that achieved 2 FPS then 1 FPS might be ordered like this:
	 * 
	 * 		CycleMarker, InitializationCompleteMarker, 
	 * 		 FrameMarker, FrameMarker, SecondsMarker,  
	 * 		 FrameMarker, FrameMarker, SecondsMarker,
	 * 		CycleMarker, InitializationCompleteMarker, 
	 * 		 FrameMarker, SecondsMarker,  
	 * 		 FrameMarker, SecondsMarker.
	 * 
	 * Each test-cycle begins with a CycleMarker: a key element that retains extra info about the cycle 
	 * like its duration and FPS. Each of the other markers contains info as well, such as elapsed time
	 * since the previous marker in the series, and a reference to its parent CycleMarker.
	 * 
	 * The special InitializationCompleteMarker may appear anywhere in the series and is used to indicate
	 * any set of processes that's finished initializing during the test. For example, TweenBencher uses
	 * this marker to indicate that all tweens in a test cycle have been added and are running.  
	 * 
	 * To complete the package, the test's user-settings are stored as an XML object. Currently this is 
	 * just a describeType result on the BenchmarkBase subclass instance used in the test, a feature 
	 * that could probably use some refining.
	 * 
	 * You'll find that because a lot of information is provided a simple linear flatfile format, you can 
	 * draw detailed charts in a single loop. A nice little app could be created to store this data locally 
	 * or via a webservice, to compare test results. (hint, hint!)
	 */
	public class BenchmarkResults {
		
		/**
		 * When true, SecondsMarker instances are automatically 
		 * inserted into results as frames are added.
		 */
		public var autoAddSecondsMarkers: Boolean = true;
		
		/**
		 * Convenience: Use describeType on the benchmark instance and pass it
		 * to the constructor or write it to this variable for later use. This
		 * way a record of the benchmark settings are stored with the results.
		 */
		public var benchmarkDescription: XML;
		
		protected var _results : Array;
		protected var _cycleMarkers : Array;		
		protected var _currentCycle : int = -1;	
		protected var _currentCycleMarker : CycleMarker;	
		protected var _currentFrames: Array;		
		protected var _cycleTimeTally : int;
		protected var _framesTimeTally : int;
		protected var _oneSecondTally : int;
		protected var _oneSecondFrameTally : int;
		protected var _readOnlyMode : Boolean = false;
		protected var readOnlyError : Error = new Error("** Error: BenchmarkResults instance is now read-only, all test cycles are complete. **");
		
		/**
		 * Constructor.
		 * 
		 * @param benchmarkDescription	Optionally, use describeType on the benchmark 
		 * 								instance and pass the XML here.
		 */
		public function BenchmarkResults(benchmarkDescription:XML=null) {
			this._results = [];
			this._cycleMarkers = [];
			this.benchmarkDescription = benchmarkDescription;
		}
		
		
		// -== CycleMarker Query Methods ==-
		
		/**
		 * read-only.
		 * @return	The number of test cycles in the benchmark.
		 */
		public function get cycles():int {
			return _cycleMarkers.length;
		}
		
		/**
		 * read-only. The CycleMarker instance of the currently running cycle, if one is active.
		 * 
		 * @return	The currently running cycle's CycleMarker
		 */
		public function get currentCycleMarker():CycleMarker {
			return _currentCycleMarker;
		}
		
		/**
		 * Retrieves a CycleMarker instance by its id.
		 * 
		 * @param cycleID	The cycle's id, starting at 0.
		 * @return			The reqeusted CycleMarker instance.
		 */
		public function getCycleMarker(cycleID:int):CycleMarker {
			return (_cycleMarkers[cycleID] as CycleMarker);
		}
		
		/**
		 * Retrieves an Array of all CycleMarkers in the benchmark.
		 * 
		 * @return			Array of all CycleMarkers in the benchmark.
		 */
		public function getCycleMarkers():Array {
			return (_cycleMarkers.slice());
		}
		
		// -== Results Queries ==-
		
		/**
		 * Returns one of the BenchmarkStatus constants indicating the state of the 
		 * current or last test cycle, which can be treated as the general state of 
		 * the entire Benchmark. Note that each cycle keeps a record of its own status
		 * in its starting CycleMarker.
		 */
		public function get status():String {
			return (_cycleMarkers[ _cycleMarkers.length-1 ] as CycleMarker).status;
		}
		
		/**
		 * read-only. You can retrieve the time of a specific cycle directly using its
		 * timeInCycle property, this method gets a sum of all.
		 * 
		 * @return 	A sum of all cycle times.
		 */
		public function get totalTime():int {
			var time:int = 0;
			for each (var cycle:CycleMarker in _cycleMarkers) {
				time += cycle.timeInCycle;
			}
			return time;
		}
		
		/**
		 * read-only. You can retrieve the frame-count of a specific cycle directly using its
		 * frameCount property, this method gets a sum of all.
		 * 
		 * @return 	A sum of all FrameMarker instances in all cycles.
		 */
		public function get totalFrames():int {
			var frames:int = 0;
			for each (var cycle:CycleMarker in _cycleMarkers) {
				frames += cycle.frameCount;
			}
			return frames;
		}
		
		/**
		 * read-only. You can retrieve average-frames-per-second value of a specific cycle directly 
		 * using its averageFPS property, this method gets an average of all.
		 * 
		 * @return			A rounded average FPS for the entire benchmark including all cycles.
		 */
		public function get totalFPS():int {
			var sum:Number = 0;
			for each (var cycle:CycleMarker in _cycleMarkers)
				sum += cycle.averageFPS;
			return Math.round(sum / _cycleMarkers.length);
		}
		
		/**
		 * Returns the full flatfile Array of markers in a specific cycle or for the entire benchmark.
		 * 
		 * @param cycleID	ID of the cycle to query, or -1 for all cycles in series.
		 * @return			Array of markers in a specific cycle
		 */
		public function getResults(cycleID:int=-1):Array {
			if (cycleID==-1)
				return _results;
			var startIndex:int = _results.indexOf(getCycleMarker(cycleID));
			var endIndex:int = _results.indexOf(getCycleMarker(cycleID+1), startIndex+1);
			if (endIndex==-1)
				endIndex = _results.length; 
			return ( _results.slice(startIndex,endIndex) );
		}
		
		/**
		 * Retrieves an array of FrameMarker instances for a specific cycle or the entire benchmark.
		 * 
		 * When working with frame durations, be sure to use FrameMarker.timeSinceLastFrameMarker
		 * (as opposed to FrameMarker.timeSinceLastMarker) values.
		 * 
		 * @param cycleID	ID of the cycle to query, or -1 for all.
		 * @return			An array of FrameMarker instances for the cycle specified
		 */
		public function getFrames(cycleID:int=-1):Array {
			var frames:Array = [];
			var span:Array = getResults(cycleID);
			for each (var marker:Object in span) {
				if (marker is FrameMarker)
					frames.push(marker);
			}
			return frames;
		}
		
		/**
		 * read-only.
		 * @return		The most-recently-added Marker instance (the last as of yet) in the series.
		 */
		public function get mostRecentMarker():Marker {
			return (_results[_results.length-1] as Marker);
		}
		
		// -== Test-building methods ==-
		
		/**
		 * Start a new test cycle in the results record.
		 * @return		The CycleMarker created, which now represents the current cycle.
		 */
		public function createCycle(startNow:Boolean=true):CycleMarker {
			
			if (_readOnlyMode)
				return null;
				
			if (_currentCycleMarker)
				endCycle();
			
			_currentFrames = [];
			_currentCycle++;
			_cycleTimeTally = 0;
			_framesTimeTally = 0;
			_oneSecondTally = 0;
			_oneSecondFrameTally = 0;
			_currentCycleMarker = new CycleMarker(_currentCycle, startNow);
			_results.push( _currentCycleMarker ); // CycleMarkers appear in the flatfile in series with other markers.
			_cycleMarkers.push( _currentCycleMarker );
			return _currentCycleMarker;
		}
		
		/**
		 * Starts a waiting test cycle that was created but not started using createCycle(false). 
		 */
		public function beginUnstartedCycle():void {
			
			if (_readOnlyMode)
				return;
				
			if (_currentCycleMarker.status==BenchmarkStatus.UNSTARTED) {
				_currentCycleMarker.status = BenchmarkStatus.RUNNING;
			}
		}
		
		/**
		 * Adds a FrameMarker or InitializationCompleteMarker to the currently active cycle.
		 * If autoAddSecondsMarkers is set to true, SecondsMarker instances are automatically
		 * inserted in the results array.
		 * 
		 * @param isInitializationMarker	There should only be one InitializationCompleteMarker per series, indicating the point
		 * 									in the cycle where all items are added and running.
		 */
		public function addFrame(isInitializationMarker:Boolean=false):void {
			
			if (_readOnlyMode)
				return;
				
			if (_currentCycle==-1) {
				createCycle();
			}
			
			// Actively update the number of 0-FPS ("flatlined") seconds that may have passed.
			var fullSecondsSinceLastMarker:int = Math.floor(_currentCycleMarker.timeInCycle - _cycleTimeTally)/1000; 
			if (fullSecondsSinceLastMarker > 0) {
				_currentCycleMarker.consecutiveFlatlines += fullSecondsSinceLastMarker;
			}
			else { // reset consecutive count
				_currentCycleMarker.consecutiveFlatlines = 0;
			}
			
			// auto-add seconds markers
			if (autoAddSecondsMarkers) { 
				addSecondsSinceLastMarker();
			}
			
			// Lookback. Using a running tally is more accurate in the long haul - see note @ Marker.timeSinceLastMarker.
			var timeSinceLastMarker:int = (_currentCycleMarker.timeInCycle - _cycleTimeTally); 
			
			var marker:Marker;
			
			// InitializationCompleteMarker
			if (isInitializationMarker) {
				marker = new InitializationCompleteMarker(_currentCycleMarker, timeSinceLastMarker);
				_currentCycleMarker.initializationMarker = (marker as InitializationCompleteMarker);
			}
			
			// FrameMarker
			else {
				var timeSinceLastFrameMarker:int = _currentCycleMarker.timeInCycle - _framesTimeTally; // running tally is more accurate in the long haul.
				marker = new FrameMarker(_currentCycleMarker, _currentFrames.length, timeSinceLastMarker, timeSinceLastFrameMarker);
				_framesTimeTally += timeSinceLastFrameMarker;
				_currentCycleMarker.frameCount ++;
				_oneSecondFrameTally++;
				// ** first & last frame flags are auto-marked, last frame flag sticks to the end of the array as it's built. **
				if ( _currentFrames.push( marker ) == 1) {
					(marker as FrameMarker).firstFrameInCycle = true;
					(marker as FrameMarker).lastFrameInCycle = true;
				}
				else {
					(_currentFrames[_currentFrames.length-2] as FrameMarker).lastFrameInCycle = false;
					(_currentFrames[_currentFrames.length-1] as FrameMarker).lastFrameInCycle = true;
				}
			}
			
			_results.push( marker );
			_cycleTimeTally += timeSinceLastMarker; // now this marker will be factored in the next marker's lookback.
		}
		
		/**
		 * Automatically insert SecondMarker instances between the last marker and the
		 * moment this method is called. If the autoAddSecondsMarkers property of this
		 * BenchmarkResults instance is true, this process is automated.
		 * 
		 * @return	Number of seconds markers added to results.
		 */
		public function addSecondsSinceLastMarker() : int {
			
			if (_readOnlyMode)
				return 0;
			
			var timeSinceLastMarker:int = (_currentCycleMarker.timeInCycle - _cycleTimeTally); // Lookback. (Using a running tally is more accurate in the long haul - see note @ Marker.timeSinceLastMarker)
			
			_oneSecondTally += timeSinceLastMarker;
			
			if (_oneSecondTally < 1000) {
				return 0; // no markers are needed yet.
			}
			
			// actively update the running CycleMarker's FPS values for use during testing.
			var fps:Number = Math.round(_currentCycleMarker.frameCount / (_currentCycleMarker.timeInCycle/1000));
			_currentCycleMarker.averageFPS = fps;
			if (_currentCycleMarker.secondsCount==0) {
				_currentCycleMarker.highestFPS = _currentCycleMarker.lowestFPS = fps;
			}
			else {
				_currentCycleMarker.highestFPS = Math.max(fps, _currentCycleMarker.highestFPS);
				_currentCycleMarker.lowestFPS = Math.min(fps, _currentCycleMarker.lowestFPS);
			}
			
			// One or more markers are needed.
			
			_oneSecondTally %= 1000; // crop to just the overage.
			
			if (timeSinceLastMarker > 1000) {
				
				// First deal with the possibility that 1 or more whole seconds could have elapsed.
				while (timeSinceLastMarker > 1000) {
					
					var secondsToInsert: int = Math.floor(timeSinceLastMarker/1000);
					
					for (var i:int=0; i<secondsToInsert; i++) {
						_results.push( new SecondMarker(_currentCycleMarker, ++_currentCycleMarker.secondsCount, 1000));
						timeSinceLastMarker -= 1000;
						_cycleTimeTally += 1000;
						_currentCycleMarker.frameCountBySecond.push(_oneSecondFrameTally);
						_oneSecondFrameTally = 0;
					}
				}
				return secondsToInsert;
			}
			
			// If caught up to most recent second, insert marker to exact position.
			
			_results.push( new SecondMarker(_currentCycleMarker, ++_currentCycleMarker.secondsCount, _oneSecondTally));
			_cycleTimeTally += _oneSecondTally; // now this marker will be factored in the next marker's lookback.
			_currentCycleMarker.frameCountBySecond.push(_oneSecondFrameTally);
			_oneSecondFrameTally = 0;
			return 1;
		}
		
		/**
		 * End the currently active cyle. If starting another cycle right away, you can call
		 * createCycle without calling this method first. Call this method to end the last cycle or
		 * specify that the cycle ending timed out or was aborted.
		 * 
		 * @param status			Default is CycleMarker.BenchmarkStatus.COMPLETED, other values accepted 
		 * 							are CycleMarker.BenchmarkStatus.TIMED_OUT and CycleMarker.BenchmarkStatus.ABORTED.
		 * @param allCyclesDone		Pass true to disable any further use of test-building methods in this instance.
		 */
		public function endCycle(status:String="TESTCYCLE_COMPLETED", allCyclesDone: Boolean=false):void {
			
			if (_readOnlyMode) {
				throw readOnlyError;
				return;
			}
			
			// Finalize Cycle
			if (_currentCycleMarker) {
				_currentCycleMarker.status = status;
				
				// add final average FPS to CycleMarker
				_currentCycleMarker.averageFPS = Math.round(_currentCycleMarker.frameCount / (_currentCycleMarker.timeInCycle/1000));
				
				// NOTE: decided against this strategy. The partial seconds affect results too much. Chuck 'em.
				/*// add final partial frame-tally to the CycleMarker if it was close to a second's worth of data, otherwise discard.
				if (_oneSecondTally>=750) {
					_currentCycleMarker.frameCountBySecond.push(_oneSecondFrameTally);
				}*/
			}
			_currentCycleMarker = null;
			_cycleTimeTally = 0;
			_framesTimeTally = 0;
			_currentFrames = null;
			if (allCyclesDone) {
				_readOnlyMode = true;
			}
		}
	}
}
