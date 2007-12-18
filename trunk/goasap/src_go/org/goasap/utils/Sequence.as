/** * Copyright (c) 2007 Moses Gunesch *  * Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE. */package org.goasap.utils {	import org.goasap.PlayableBase;	/**	 * Simple playable sequence, composed of groups of playable items.	 * 	 * <p>A sequence can be built by passing any item that extends PlayableBase.	 * Sequences are composed of SequenceStep instances, which can contain any 	 * number of child items such as LinearGo or PlayableGroup instances.	 * Sequences dispatch SequenceEvent.ADVANCE each time a step completes and	 * the play index advances to the next one. Other events dispatched include	 * GoItem.START, GoItem.STOP, and GoItem.COMPLETE.</p>	 * 	 * <p>All items in each step must dispatch COMPLETE or STOP before a Sequence	 * will advance. This simple behavior can be limiting. A Sequence extension 	 * called SequenceCA is provided in the <i>customadvance</i> package, which allows	 * you to define different ways a sequence can advance: after a particular 	 * item in a step, a particular duration, after an event fires, etc.</p>	 * 	 * @see SequenceBase	 * @see SequenceCA	 * @author Moses Gunesch	 */	public class Sequence extends SequenceBase {		// -== Public Properties ==-				// Also in super:		// length : uint   [Read-only.]		// playIndex : int [Read-only.]		// steps : Array		// start() : Boolean		// stop() : Boolean		// pause() : Boolean		// resume() : Boolean		// skipTo(index:Number) : Boolean				/**		 * Returns the currently-playing SequenceStep.		 * @return The currently-playing SequenceStep.		 * @see #getStepAt()		 * @see #getStepByID()		 * @see #steps		 * @see #lastStep		 */		public function get currentStep() : SequenceStep {			return (super._getCurrentStep());		}				/**		 * Returns the last SequenceStep in the current sequence.		 * @return The last SequenceStep in the current sequence.		 * @see #getStepAt()		 * @see #getStepByID()		 * @see #steps		 * @see #currentStep		 */		public function get lastStep() : SequenceStep {			return (super._getLastStep());		}				// -== Public Methods ==-				/**		 * Constructor.		 * 		 * @param items		Any number of PlayableBase-derived instances (e.g. LinearGo, PlayableGroup,		 * 					SequenceStep) as separate arguments, or a single array of them.		 */		public function Sequence(...items) {			super((items[ 0 ] is Array) ? items[ 0 ] : items);		}				/**		 * Retrieves any SequenceStep from the steps array.		 * @param index		An array index starting at 0.		 * @return			The SequenceStep instance at this index.		 * @see #getStepByID()		 * @see #currentStep		 * @see #lastStep		 */		public function getStepAt(index:int) : SequenceStep {			return (super._getStepAt(index) as SequenceStep);		}				/**		 * Locates a step with the specified id. To search within a step for a		 * child by id, use the step instance's <code>getChildByID</code> method.		 *  		 * @param id			The step instance's id to search for.		 * @return				The SequenceStep with the matching id.		 * @see #getStepAt()		 */		public function getStepByID(id:*) : SequenceStep {			return (super._getStepByID(id) as SequenceStep);		}				/**		 * Adds a single PlayableBase-derived instance (e.g. LinearGo, 		 * PlayableGroup, SequenceStep) to the end of the steps array,		 * or optionally adds the instance into the last SequenceStep		 * instead of adding it as a new step.		 * 		 * <p>To remove a step use the <code>removeStepAt</code> method.</p>		 * 		 * @param item			The playable item to add to the sequence. Note		 * 						that when new steps are added, any PlayableBase		 * 						instance of a type other than SequenceStep is 		 * 						automatically wrapped in a new SequenceStep.		 * 								 * @param addToLastStep	If true is passed the item is added to the last		 * 						existing SequenceStep in the steps array. This		 * 						option should be used with individual items that		 * 						you want added as children to the SequenceStep.		 * 						If there are no steps yet this option ignored and		 * 						a new step is created.		 * 								 * @return New length of the steps array.		 */		public function addStep(item:PlayableBase, addToLastStep:Boolean=false): int {			return (super._addStep(item, addToLastStep, SequenceStep));		}				/**		 * Adds a single PlayableBase-derived instance (e.g. LinearGo, PlayableGroup, 		 * SequenceStep) at a specific index in the steps array. Calling this method 		 * stops any sequence play currently in progress.		 * 		 * @param index		Position in the array starting at 0, or a negative 		 * 					index like Array.splice.		 * 							 * @param item		The playable item to splice into the sequence.		 * 		 * @return 			New length of the steps array.		 */		public function addStepAt(index:int, item:PlayableBase): int {			return (super._addStepAt(index, item, SequenceStep));		}		/**		 * Removes and returns the SequenceStep at a specific index from the steps 		 * array. Calling this method stops any sequence play currently in progress.		 * 		 * @param index		Position in the array starting at 0, or a negative 		 * 					index like Array.splice.		 * 							 * @return 			The SequenceStep instance removed from the steps array.		 */		public function removeStepAt(index:int): SequenceStep {			return (super._removeStepAt(index) as SequenceStep);		}				// Also in super:		// length : uint   [Read-only.]		// playIndex : int [Read-only.]		// steps : Array		// start() : Boolean		// stop() : Boolean		// pause() : Boolean		// resume() : Boolean		// skipTo(index:Number) : Boolean	}}