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
 
package com.mosesSupposes.benchmark.tweenbencher {	
	import flash.display.MovieClip;	
	import flash.display.Sprite;	
	import flash.events.Event;	
	import flash.events.MouseEvent;	
	import flash.text.TextFieldAutoSize;	
	
	import com.mosesSupposes.benchmark.BenchmarkEvent;	
//	import com.mosesSupposes.benchmark.tweenbencher.tests.AP3BetaBenchmark;		import com.mosesSupposes.benchmark.tweenbencher.tests.BenchmarkBase;	
//	import com.mosesSupposes.benchmark.tweenbencher.tests.BoostworthyBenchmark;		import com.mosesSupposes.benchmark.tweenbencher.tests.F9AnimatorBenchmark;	
	import com.mosesSupposes.benchmark.tweenbencher.tests.F9TweenClassBenchmark;	
	import com.mosesSupposes.benchmark.tweenbencher.tests.GoBenchmark;	
	import com.mosesSupposes.benchmark.tweenbencher.tests.GoBenchmark2;	
	import com.mosesSupposes.benchmark.tweenbencher.tests.SimpleAS3Bench;	
//	import com.mosesSupposes.benchmark.tweenbencher.tests.TweenLiteBenchmark;	//	import com.mosesSupposes.benchmark.tweenbencher.tests.TweenerBenchmark;		
	import fl.controls.Button;	
	import fl.controls.CheckBox;	
	import fl.controls.ComboBox;	
	import fl.controls.Label;	
	import fl.controls.TextInput;	
	import fl.data.DataProvider;
	
	/**
	 * @author Moses Gunesch / mosessupposes.com (c) 
	 * 
	 * An  optional extra included with the TweenBencher FLA to speed up 
	 * the process of setting up and running a series of benchmark tests.
	 * 
	 * The portions of this class you will want to actively modify are the 
	 * benchmarkClasses array, which defines the tests included, and the
	 * setDefaults method which defines which settings appear inially on 
	 * the panel. 
	 * 
	 * You can also include settings in your test classes which are optionally 
	 * brought into the panel by checking the Adopt Settings box, giving you
	 * more flexibility. 
	 * 
	 * It would be nice of course, to add further functionality such as a
	 * shared object to save and load settings and/or test results, a linked 
	 * comparison app, etc. If you do, please email them to me!
	 */
	public class TestingPanel extends MovieClip {
		
		/**
		 * Add all your benchmark classes here!
		 * (Customize panel defaults under setDefaults.)
		 */
		public var benchmarkClasses:Array = [
			SimpleAS3Bench,
			GoBenchmark,			GoBenchmark2,//			TweenLiteBenchmark,//			TweenerBenchmark,//			AP3BetaBenchmark,//			BoostworthyBenchmark,			F9TweenClassBenchmark,
			F9AnimatorBenchmark
		];
		
		protected var bench : BenchmarkBase;
		
		protected var bench_cb : ComboBox;		
		
		protected var adopt_ck : CheckBox;		
		
		protected var duration_txt : TextInput;		
		
		protected var sprites_txt : TextInput;		
		
		protected var loop_ck : CheckBox;		
		
		protected var mult_txt : TextInput;		
		
		protected var max_txt : TextInput;		
		
		protected var timeout_txt : TextInput;		
		
		protected var graph1_ck : CheckBox;		
		
		protected var graphRefresh_ck : CheckBox;		
		
		protected var graph2_ck : CheckBox;		
		
		protected var animateGraphs_ck : CheckBox;		
		
		protected var height_cb : ComboBox;		
		
		protected var show_ck : CheckBox;		
		
		protected var tweenBencher : TweenBencher;		
		
		protected var uiContainer_mc : Sprite;		
		
		protected var _hidden : Boolean;		
		
		/**
		 * Constructor. Passing a reference to the TweenBencher instance is 
		 * mandatory, but can optionally be done later via a setBencher call.
		 * @param tweenBencher	A reference to the TweenBencher to use to run tests.
		 */
		public function TestingPanel(tweenBencher:TweenBencher=null):void {
			if (tweenBencher)
				setBencher(tweenBencher);
			else
				visible = false;
			draw();
			setDefaults();
		}		
		
		/**
		 * Sets a reference to the TweenBencher instance, mandatory in order to
		 * activate and show the panel. This can also be done via the constructor.
		 * If a TweenBencher instance was already set, it is unlinked at this time.
		 * 
		 * @param tweenBencher	A reference to the TweenBencher to use to run tests.
		 */
		public function setBencher(tweenBencher:TweenBencher):void 
		{
			if (tweenBencher) {
				tweenBencher.removeEventListener(BenchmarkEvent.COMPLETE, onBenchmarkComplete);
			}
			this.tweenBencher = tweenBencher;
			tweenBencher.addEventListener(BenchmarkEvent.COMPLETE, onBenchmarkComplete);
			visible = true;
		}
		
		/**
		 * When benchmark is finished, the panel becomes visible again. The event object
		 * contains a BenchmarkResults instance containing all the benchmark settings and
		 * results data, which you could store for comparisons, chart in new ways, etc.
		 */
		protected function onBenchmarkComplete(event:BenchmarkEvent) : void {
			visible = true;
		}
		
		/**
		 * Customize panel defaults in this method.
		 * 
		 * TODO: Add a shared object to save settings?
		 */
		protected function setDefaults() : void 
		{
			/* FOR REFERENCE - copied from BenchmarkBase
			 * 
 			 * tweenDuration = 5;			// Seconds. 1 or less:inaccurate. 5:Recommended. 10:Accurate. (See also: showSprites)
 			 * 
 			 * numSprites = 125;			// (1) Start with this many sprites...
 			 * 
 			 * loopAndIncrement = true;		// (2) ...If true, repeat the benchmark test in a loop...
 			 * 
 			 * numSpritesMultiplier = 2; 	// (3) ...multiplying numSprites by this each time...
 			 * 
 			 * maxAllowableSprites = 16000; // (4) ..until this limit is reached. (Be careful - set this lower first!)
			 * 
 			 * startTimeout = 10;			// Seconds, max 15. Recommended: Slightly lower to prevent Flash Player timeout.
 			 * 								// (Try 10, but this might differ on your computer.)
 			 * 								// Set to 5 or 10 to limit long start start lags. 
 			 * 								// Player timeout cannot be prevented for tweens already in progress!
 			 * 								// See also: maxAllowableSprites
			 * 
 			 * graphFPS = true;				// Recommended: false for benchmarks; true for analysis. Actively graphs the framerate.
			 * 
 			 * refreshFPSGraph = true;		// If true, the FPS graph starts over each run.
			 * 
 			 * graphTotals = true;			// Recommended: true - doesn't affect results. Shows FPS averages & start-lag graph.
			 * 
 			 * showSprites = true;			// Turn this & graphs off for an abstract, but pure, engine code efficiency test.
			 * 
 			 * renderAreaHeight = 100;		// Pixels. Recommended: 100 for minimal view or 560 to block to screen.		
			 */
			
			bench_cb.selectedIndex = 0;
			adopt_ck.selected = false;
			duration_txt.text = "5";
			sprites_txt.text = "125";
			loop_ck.selected = true;
			mult_txt.text = "2";
			max_txt.text = "16000";
			timeout_txt.text = "10";
			graph1_ck.selected = false; 
			graphRefresh_ck.selected = true;
			graph2_ck.selected = true;
			animateGraphs_ck.selected = false;
			height_cb.selectedIndex = 0;
			show_ck.selected = true;
			
			// Set enabled states based on the defaults.
			onLoopSelect();
			onGraph1Select();
		}
		
		/**
		 * Factory method: generates a benchmark based on the current dropdown selection.
		 */
		protected function makeBenchInstance() : void {
			var benchClass:Class = (bench_cb.selectedItem["data"] as Class);
			bench = new benchClass(this.parent as TweenBencher);
		}
		
		/**
		 * Handler for the benchmark dropdown. This method implements "adopt settings" functionality. 
		 */
		protected function setBenchClass(e:Event=null) : void {
			if (!bench || (bench && !(bench is (bench_cb.selectedItem["data"] as Class)))) {
				makeBenchInstance();
			}
			if (adopt_ck.selected) {
				duration_txt.text = String(bench.tweenDuration);
				sprites_txt.text = String(bench.numSprites);
				loop_ck.selected = bench.loopAndIncrement;
				mult_txt.text = String(bench.numSpritesMultiplier);
				max_txt.text = String(bench.maxAllowableSprites);
				timeout_txt.text = String(bench.startTimeout);
				graph1_ck.selected = bench.graphFPS;
				graphRefresh_ck.selected = bench.refreshFPSGraph;
				graph2_ck.selected = bench.graphTotals;
				animateGraphs_ck.selected = bench.animateGraphs;
				height_cb.selectedIndex = (bench.renderAreaHeight>100 ? 1 : 0);
				show_ck.selected = bench.showSprites;
			}
		}		
		
		/**
		 * Button click handler: Begins the selected test.
		 */
		protected function begin(e:MouseEvent) : void 
		{
			if (!bench) {
				setBenchClass();
			}
			visible = false;
			showHide();
			bench.tweenDuration = (Number(duration_txt.text) || 0);
			bench.numSprites = (Number(sprites_txt.text) || 0);
			bench.loopAndIncrement = loop_ck.selected;
			bench.numSpritesMultiplier = (Number(mult_txt.text) || 1);
			bench.maxAllowableSprites = (Number(max_txt.text) || 0);
			bench.startTimeout = (Number(timeout_txt.text) || 0);
			bench.graphFPS = graph1_ck.selected;
			bench.refreshFPSGraph = graphRefresh_ck.selected;
			bench.renderAreaHeight = (Number(height_cb.selectedItem["data"]) || 100);
			bench.graphTotals = graph2_ck.selected;
			bench.animateGraphs = animateGraphs_ck.selected;
			bench.showSprites = show_ck.selected;
			bench.dump();
			(this.parent as TweenBencher).benchmark(bench);
			bench = null; // clear instance for next click.
		}
		
		/**
		 * Renders the panel.
		 */
		protected function draw():void
		{
			var cb:ComboBox;
			var dp:DataProvider;
			var btn:Button;
			var label:Label;
			var input:TextInput;
			var ck:CheckBox;
			var guide1:Number = 100;
			var guide2:Number = 150;
			var top:Number = 20;
			var left:Number = 25;
			var tfh:Number = 20;
			var runningY:Number = top;
			var yStep:Number = 27;
			var yStep2:Number = 35;
			
			// Show / hide panel button
			btn = new Button();
			btn.move(left + 15, runningY);
			btn.setSize(140, 25);
			btn.label = "TweenBencher Panel";
			btn.addEventListener(MouseEvent.CLICK, showHide);
			addChild(btn);
			
			runningY+=yStep2;
			
			// Panel UI container
			uiContainer_mc = new Sprite();
			addChild(uiContainer_mc);
			
			// Benchmark class (I decided against labeling this dropdown, it was a bit cluttery.)
			dp = new DataProvider();
			var tb:TweenBencher = (this.parent as TweenBencher);
			for each (var benchClass:Class in benchmarkClasses) {
				dp.addItem({ data:benchClass,
							 label: String( (new benchClass(tb) as BenchmarkBase).benchmarkName )
				});
			}
			
			cb = new ComboBox();
			cb.setSize(180,25);
			cb.move(left, runningY);
			cb.dataProvider = dp;
			cb.addEventListener(Event.CHANGE, setBenchClass);
			uiContainer_mc.addChild(cb);
			bench_cb = cb;
			
			runningY+=yStep;
			
			// adopt settings from class
			ck = new CheckBox();
			ck.label="Adopt settings from class";
			ck.scaleX = 2;
			ck.move(bench_cb.x, runningY);
			ck.addEventListener(Event.CHANGE, onLoopSelect);
			adopt_ck = ck;
			uiContainer_mc.addChild(ck);
			
			runningY+=yStep;
			
			uiContainer_mc.graphics.lineStyle(0, 0x333333);
			uiContainer_mc.graphics.moveTo(left+15, runningY);
			uiContainer_mc.graphics.lineTo(left+160, runningY);
			
			runningY+=15;
			
			// tweenDuration
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Tween duration";
			uiContainer_mc.addChild(label);
			
			input = new TextInput();
			input.width = 40;
			input.move(guide2, runningY);
			uiContainer_mc.addChild(input);
			duration_txt = input;
			
			runningY+=yStep;
					
			// numSprites
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Sprites at start";
			uiContainer_mc.addChild(label);
			
			input = new TextInput();
			input.width = 40;
			input.move(guide2, runningY);
			sprites_txt = input;
			uiContainer_mc.addChild(input);
			
			runningY+=yStep;
					
			// loopAndIncrement
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Loop & increment";
			uiContainer_mc.addChild(label);
			
			ck = new CheckBox();
			ck.label="";
			ck.move(guide2, runningY);
			ck.addEventListener(Event.CHANGE, onLoopSelect);
			loop_ck = ck;
			uiContainer_mc.addChild(ck);
			
			runningY+=yStep;
					
			// numSpritesMultiplier
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Sprites multiplier";
			uiContainer_mc.addChild(label);
			
			input = new TextInput();
			input.width = 30;
			input.move(guide2, runningY);
			mult_txt = input;
			uiContainer_mc.addChild(input);
			
			runningY+=yStep;
					
			// maxAllowableSprites
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Max allowable sprites";
			uiContainer_mc.addChild(label);
			
			input = new TextInput();
			input.width = 40;
			input.move(guide2, runningY);
			max_txt = input;
			uiContainer_mc.addChild(input);
			
			runningY+=yStep;
					
			// startTimeout
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Start-Lag timeout";
			uiContainer_mc.addChild(label);
			
			input = new TextInput();
			input.width = 40;
			input.move(guide2, runningY);
			timeout_txt = input;
			uiContainer_mc.addChild(input);
			
			runningY+=yStep;
					
			// graphFPS
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Graph active FPS";
			uiContainer_mc.addChild(label);
			
			ck = new CheckBox();
			ck.label="";
			ck.move(guide2, runningY);
			ck.addEventListener(Event.CHANGE, onGraph1Select);
			graph1_ck = ck;
			uiContainer_mc.addChild(ck);
			
			runningY+=yStep;
					
			// refreshFPSGraph
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Refresh FPS Graph";
			uiContainer_mc.addChild(label);
			
			ck = new CheckBox();
			ck.label="";
			ck.move(guide2, runningY);
			graphRefresh_ck = ck;
			uiContainer_mc.addChild(ck);
			
			runningY+=yStep;
					
			// graphTotals
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Graph totals";
			uiContainer_mc.addChild(label);
			
			ck = new CheckBox();
			ck.label="";
			ck.move(guide2, runningY);
			graph2_ck = ck;
			uiContainer_mc.addChild(ck);
			
			runningY+=yStep;
					
			// animateGraphs
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "Animate graphs";
			uiContainer_mc.addChild(label);
			
			ck = new CheckBox();
			ck.label="";
			ck.move(guide2, runningY);
			animateGraphs_ck = ck;
			uiContainer_mc.addChild(ck);
			
			runningY+=yStep;
					
			// renderAreaHeight
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "renderAreaHeight";
			uiContainer_mc.addChild(label);
			
			dp = new DataProvider();
			dp.addItem({label:"short", data:100});
			dp.addItem({label:"tall", data:560});
			cb = new ComboBox();
			cb.setSize(60,25);
			cb.move(guide2, runningY);
			cb.dataProvider = dp;
			height_cb = cb;
			uiContainer_mc.addChild(cb);
					
			runningY+=yStep;
					
			// showSprites
			label = new Label();
			label.move(left, runningY);
			label.setSize(guide1, tfh);
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.text = "showSprites";
			uiContainer_mc.addChild(label);
			
			ck = new CheckBox();
			ck.label="";
			ck.move(guide2, runningY);
			show_ck = ck;
			uiContainer_mc.addChild(ck);
			
			runningY+=yStep2;
					
			// Begin button
			btn = new Button();
			btn.move(left + 15, runningY);
			btn.setSize(140, 25);
			btn.label = "Begin Benchmark Test";
			btn.addEventListener(MouseEvent.CLICK, begin);
			uiContainer_mc.addChild(btn);
			
			runningY+=(btn.height + top);
			
			// Finally, stretch the panel to fit.
			(this["bg_mc"] as MovieClip).height = runningY;
		}		
		
		/**
		 * Handler for the Loop & Increment checkbox (loop_ck).
		 */
		protected function onLoopSelect(event:Event=null) : void {
			// Disable the settings that only apply to looped tests.
			mult_txt.enabled = max_txt.enabled = loop_ck.selected;
			onGraph1Select(); // updates graphRefresh_ck
		}		
		
		/**
		 * Hanlder for the Refresh FPS Graph checkbox (graphRefresh_ck).
		 */
		protected function onGraph1Select(event:Event=null) : void {
			// The refresh FPS graph setting only applies when loopAndIncrement & the FPS graph are on.
			graphRefresh_ck.enabled = (graph1_ck.selected && loop_ck.selected);
		}		
		
		/**
		 * Toggles the view state from full to minimized.
		 */
		protected function showHide(event:MouseEvent=null) : void {
			if (_hidden) {
				(this["bg_mc"] as MovieClip).scaleY = 1;
				uiContainer_mc.visible = true;
			} 
			else {
				uiContainer_mc.visible = false;
				(this["bg_mc"] as MovieClip).height = 80;
			} 
			_hidden = !_hidden;
		}		
	}
}
