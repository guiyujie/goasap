﻿/** * Copyright (c) 2007 Moses Gunesch *  * Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE. */package org.goasap {	import flash.display.Sprite;	import flash.events.Event;	import flash.events.TimerEvent;	import flash.utils.Dictionary;	import flash.utils.Timer;	import flash.utils.getQualifiedClassName;	import flash.utils.getTimer;		import org.goasap.errors.DuplicateManagerError;	import org.goasap.interfaces.IManageable;	import org.goasap.interfaces.IManager;	import org.goasap.interfaces.IUpdatable;		/**	 * Provides <code>update</code> calls to <code>IUpdatable</code> instances on their specified <code>pulseInterval</code>.	 * 	 * <p><b>Using these Docs</b></p>	 * 	 * <p><i>Protected methods and properties have been excluded in almost all 	 * cases, but are documented in the classes. Exceptions include key protected	 * methods or properties that are integral for writing subclasses or understanding 	 * the basic mechanics of the system. Many Go classes can be used as is without 	 * subclassing, so the documentation offers an uncluttered view of their public	 * usage.</i></p>	 * 	 * <p><b>Introduction to Go</b></p>	 * 	 * <p>The Go ActionScript Animation Platform ("GOASAP") is a lightweight, portable 	 * set of generic base classes for buliding AS3 animation tools. It provides structure 	 * and core functionality, but does not define the specifics of animation-handling 	 * classes like tweens.</p>	 * 	 * <p><i>Important: Store your custom Go classes in a package bearing your 	 * own classpath, not in the core package! This will help avoid confusion 	 * with other authors' work.</i></p>	 * 	 * 	 * <p><b>GoEngine</b></p>	 * 	 * <p>GoEngine sits at the center of the Go system, and along with the IUpdatable 	 * interface is the only required element for using Go. GoEngine references two other 	 * interfaces for adding system-wide managers, IManager and IManageable.	 * All other classes in the go package are merely one suggestion of how a 	 * system could be structured within Go, and may be considered optional 	 * elements. To create an API using the provided classes, you simply need 	 * to extend the item classes LinearGo and PhysicsGo to create animation items.</p>	 * 	 * <p>GoEngine serves two purposes: first, it keeps a large system efficient 	 * by stacking and running updates on blocks of items. Note that any IUpdatable 	 * instance may specify its own pulseInterval; items with matching pulses 	 * are grouped into queues for efficiency. Its second purpose is centralization. 	 * By using a single hub for pulse-driven items of all types, management classes 	 * can be attached to GoEngine to run processes across items. This is done voluntarily 	 * by the end-user with <code>addManager</code>, which keeps management entirely 	 * compile-optional and extensible.</p>	 * 	 * <p>You may modify any class in the go package to suit your project's needs.</p>	 *  	 * <p>Go is a community initiative led by Moses Gunesch at 	 * <a href="http://www.mosessupposes.com/">MosesSupposes.com</a>. Please visit the 	 * <a href="http://www.goasap.org/">Go website</a> for more information.</p>	 * 	 * <p></i>{In the game of Go, the wooden playing board, or Goban, features a grid	 *  on which black & white go-ishi stones are laid at its intersections.}</i></p>	 * 	 * @author Moses Gunesch	 */	public class GoEngine 	{		// -== Constants ==-				public static const INFO:String = "Go 0.3.2 (c) Moses Gunesch, MIT Licensed.";				// -== Settable Class Defaults ==-				/**		 * A pulseInterval that runs on the player's natural framerate, 		 * which is often most efficient.		 */		public static const ENTER_FRAME	: int = -1;		// -== Protected Properties ==-				private static var managers : Object = new Object(); // registration list of IManager instances		private static var itemLists : Dictionary = new Dictionary(false); // key: pulseInterval, value: Array of IUpdatable items for that pulse.		private static var items : Dictionary = new Dictionary(false); // reverse lookup. key: IUpdatable item, value: pulseInterval at add.		private static var timers : Dictionary = new Dictionary(false); // key: pulseInterval, value: Timer for that pulse		private static var pulseSprite : Sprite; // used for ENTER_FRAME pulse		private static var paused : Boolean = false;				// -== Public Class Methods ==-				/**		 * @param className		A string naming the manager class, such as "OverlapMonitor".		 * @return				The manager instance, if registered.		 * @see #addManager()		 * @see #removeManager()		 */		public static function getManager(className:String) : IManager		{			return managers[ className ];		}				/**		 * Enables the extending of this class' functionality with a tight		 * coupling to an IManager. 		 * 		 * <p>Tight coupling is crucial in such a time-sensitive context; 		 * standard events are too asynchronous. All items that implement 		 * IManageable are reported to registered managers as they add and 		 * remove themselves from GoEngine.</p>		 * 		 * <p>Managers normally act as singletons within the Go system (which 		 * you are welcome to modify). This method throws a DuplicateManagerError 		 * if an instance of the same manager class is already registered. Use a 		 * try/catch block when calling this method if your program might duplicate 		 * managers, or use getManager() to check for prior registration.</p>		 * 		 * @param instance	An instance of a manager you wish to add.		 * @see #getManager()		 * @see #removeManager()		 */		public static function addManager( instance:IManager ):void		{			var className:String = getQualifiedClassName(instance);			className = className.slice(className.lastIndexOf("::")+2);			if (managers[ className ]) {				throw new DuplicateManagerError( className );				return;			}			managers[ className ] = instance;		}				/**		 * Unregisters any manager set in <code>addManager</code>.		 * 		 * @param className		A string naming the manager class, such as "OverlapMonitor".		 * @see #getManager()		 * @see #addManager()		 */		public static function removeManager( className:String ):void		{			delete managers[ className ];		}				/**		 * Test whether an item is currently stored and being updated by the engine.		 * 		 * @param item		Any object implementing IUpdatable		 * @return			Whether the IUpdatable is in the engine		 */		public static function hasItem( item:IUpdatable ):Boolean		{			return (items[ item ]!=null);		}				/**		 * Adds an IUpdatable instance to an update-queue corresponding to		 * the item's pulseInterval property.		 * 		 * @param item		Any object implementing IUpdatable that wishes 		 * 					to receive update calls on a pulse.		 * 							 * @return			Success		 * @see #removeItem()		 */		public static function addItem( item:IUpdatable ):Boolean		{			if (items[ item ])				removeItem(item);			// Group items by pulse for efficient update cycles.			var interval:int = item.pulseInterval;			if (!itemLists[ interval ])				itemLists[ interval ] = new Array();			(itemLists[ interval ] as Array).push(item);			items[ item ] = interval; // Tether item to original pulseint. Used in removeItem & setPaused(false).			if (!timers[ interval ])				addPulse(interval);						// Report IManageable instances to registered managers			if (item is IManageable) {				for each (var manager:IManager in managers)					manager.reserve( item as IManageable );			}			return true;		}				/**		 * Removes an item from the queue and removes its pulse timer if		 * the queue is depleted.		 * 		 * @param item		Any IUpdatable previously added that wishes 		 * 					to stop receiving update calls.		 * 							 * @return			Success		 * @see #addItem()		 */		public static function removeItem( item:IUpdatable ):Boolean		{			if (items[ item ]==null)				return false;			var interval:int = items[ item ]; // original pulseInterval is anchored as the item-key's value.			delete items[ item ];			var list:Array = (itemLists[interval] as Array); // Should not error if addItem is working.			list.splice( list.indexOf(item), 1 );			if (list.length==0) {				delete itemLists[interval];				GoEngine.removePulse(interval);			}			// Report IManageable item removal to registered managers.			if (item is IManageable) {				for each (var manager:IManager in managers) 					manager.release( item as IManageable );			}			return true;		}				/**		 * Removes all items and resets the engine, 		 * or removes just items running on a specific pulse.		 * 		 * @param pulseInterval		Optionally filter by a specific pulse 		 * 							such as ENTER_FRAME or a number of milliseconds.		 * @return					The number of items successfully removed.		 * @see #removeItem()		 */		public static function clear(pulseInterval:Number = NaN) : uint		{			var all:Boolean = (isNaN(pulseInterval));			var n:Number = 0;			for (var item:Object in items) {				if (all || items[ item ]==pulseInterval)					if (removeItem(item as IUpdatable)==true)						n++;			}			return n;		}				/**		 * Retrieves number of active items in the engine 		 * or active items running on a specific pulse.		 * 		 * @param pulseInterval		Optionally filter by a specific pulseInterval		 *							such as ENTER_FRAME or a number of milliseconds.		 * 		 * @return					Number of active items in the Engine.		 */		public static function getCount(pulseInterval:Number = NaN) : uint		{			if (!isNaN(pulseInterval))				return (itemLists[pulseInterval]==null ? 0 : (itemLists[pulseInterval] as Array).length);			var n:Number = 0;			for each (var item:* in items)				n++;			return n;		}				/**		 * @return			The paused state of engine.		 * @see #setPaused()		 */		public static function getPaused() : Boolean {			return paused;		}				/**		 * Pauses or resumes all animation globally by suspending processing,		 * and calls pause() or resume() on each item with those methods. 		 * 		 * <p>The return value only reflects how many items had pause() or resume()		 * called on them, but the GoEngine.getPaused() state will change if any 		 * pulses are suspended or resumed.</p>		 * 		 * @param pause				Pass false to resume if currently paused.		 * @param pulseInterval		Optionally filter by a specific pulse 		 * 							such as ENTER_FRAME or a number of milliseconds.		 * @return					The number of items on which a pause() or resume()		 * 							method was called (0 doesn't necessarily reflect		 * 							whether the GoEngine.getPaused() state changed, it		 * 							may simply indicate that no items had that method).		 * @see #resume()		 */		public static function setPaused(pause:Boolean=true, pulseInterval:Number = NaN) : uint		{			if (paused==pause) return 0;			var n:Number = 0;			var pulseChanged:Boolean = false;			var all:Boolean = (isNaN(pulseInterval));			var item:Object;			var method:String = (pause ? "pause" : "resume");			for (item in items) {				var pulse:int = (items[item] as int);				if (all || pulse==pulseInterval) {					pulseChanged = (pulseChanged || (pause ? removePulse(pulse) : addPulse(pulse)));					if (item.hasOwnProperty(method)) {						if (item[method] is Function) {							item[method].apply(item);							n++;						}					}				}			}			if (pulseChanged)				paused = pause;			return n;		}				// -== Private Class Methods ==-				/**		 * Executes the update queue corresponding to the dispatcher's interval.		 * 		 * @param event			TimerEvent or Sprite ENTER_FRAME Event		 */		private static function update(event:Event) : void 		{			var currentTime:Number = getTimer();			var pulse:int = (event is TimerEvent ? ( event.target as Timer ).delay : ENTER_FRAME);			var list:Array = (itemLists[ pulse ] as Array);			for each (var item:IUpdatable in list) {				item.update(currentTime);			}		}				/**		 * Creates new timers when a previously unused interval is specified,		 * and tracks the number of items associated with that interval.		 * 		 * @param pulse			The pulseInterval requested		 * @return				Whether a pulse was added		 */		private static function addPulse(pulse : int) : Boolean		{			if (pulse==ENTER_FRAME) {				if (!pulseSprite) {					pulseSprite = new Sprite();					pulseSprite.addEventListener(Event.ENTER_FRAME, update);				}				return true;			}			var t:Timer = timers[ pulse ] as Timer;			if (!t) {				t = timers[ pulse ] = new Timer(pulse);				(timers[ pulse ] as Timer).addEventListener(TimerEvent.TIMER, update);				t.start();				return true;			}			return false;		}				/**		 * Tracks whether a removed item was the last one using a timer 		 * and if so, removes that timer.		 * 		 * @param pulse			The pulseInterval corresponding to an item being removed.		 * @return				Whether a pulse was removed		 */		private static function removePulse(pulse : int) : Boolean		{			if (pulse==ENTER_FRAME) {				if (pulseSprite) {					pulseSprite.removeEventListener(Event.ENTER_FRAME, update);					pulseSprite = null;					return true;				}			}			var t:Timer = timers[ pulse ] as Timer;			if (t) {				t.stop();				t.removeEventListener(TimerEvent.TIMER, update);				delete timers[ pulse ];				return true;			}			return false;		}	}}