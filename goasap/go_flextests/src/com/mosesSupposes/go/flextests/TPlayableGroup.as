
package com.mosesSupposes.go.flextests {
	import org.goasap.events.*;
	import org.goasap.items.*;
	import org.goasap.utils.*;
	
	import com.mosesSupposes.go.tutorials.SizeTweenMG;
	
	import mx.effects.easing.*;	

	// Extensions of Go should live in your personal classpath!
	
	/**
	 *  @author Moses Gunesch
	 */
	public class TPlayableGroup extends GoFlexTestBase {
		
		protected var group : PlayableGroup;
		
		/**
		PlayableGroup is a generic Parallel utility.
		You can use it to control a group of playable items, 
		like tweens, with a single set of play controls.
		 
		(It is also the foundation for the SequenceStep class.)
		 */
		public function TPlayableGroup() 
		{
			group = new PlayableGroup();
			group.addEventListener(GoEvent.START, super.traceEvent);
			group.addEventListener(GoEvent.STOP, super.traceEvent);
			group.addEventListener(GoEvent.COMPLETE, super.traceEvent);
			
			for (var i:Number=0; i<10; i++) {
	
				var t : SizeTweenMG = new SizeTweenMG();
				t.target = box(i * 20);
				t.startWidth = 10;
				t.width = 300;
				t.duration = 3;
				t.easing = Bounce.easeOut;

				// build the group
				group.addChild(t);
			}
			
			super.addHeaderText("PlayableGroup: provides a set of playable controls for a group of playable items.");
			super.addButtonUI(group, 1.5);
		}
	}
}
