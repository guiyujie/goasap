/** * Copyright (c) 2007 Moses Gunesch *  * Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE. */package org.goasap.interfaces {		/**
	 * Makes an object compatible with <code>GoEngine.addManager()</code>.	 * 	 * <p>Go items normally have no knowledge of each other. The Go system's	 * management layer provides a way to monitor and interact with some or	 * all active items at once. It is designed so that users can choose to	 * exclude all management from their projects to lighten filesize and 	 * processor load, or can create and add new managers as needed for any	 * project. A simple manager/item contract is defined between this interface	 * and the IManageable interface.</p> 	 * 	 * <p>The tie-in is simple: GoEngine reports the adding and removal of all 	 * items that implement the IManageable interface to all registered managers.	 * The end-user gets to choose which managers to instantiate and register  	 * using <code>GoEngine.addManager()</code>. As the engine passes references	 * to each item as it is added, managers can store and manipulate these items 	 * however they like. OverlapMonitor, for example, releases items with 	 * conflicting target/property combinations as new items are added.</p>	 * 	 * <p>To make sure that the filesize associated with your managers remains	 * compile-optional, only interfaces should be used as datatypes. It's especially	 * important that item classes don't import or make direct references to specific 	 * manager classes, or those classes will always be compiled.</p>	 * 	 * <p><b>Conventions</b></p>	 * 	 * <p>There is a distinct difference in the Go system between <i>managers</i> and 	 * <i>utilities</i>, although both typically work with batches of Go items. 	 * Utilities are tools designed to be directly used by the developer at a project 	 * level, such as a Sequence class for animation timelining. In contrast, managers 	 * are self-sufficient entities that, once registered to GoEngine, operate in the 	 * background without requiring any direct interaction at runtime.</p>	 * 	 * <p>Managers can do whatever they want with items, as long as they operate strictly 	 * via interfaces. When creating your own managers, be sure to document these things	 * so users understand all caveats. Utilities and active program code will be handling 	 * the same items your manager does, so interactions need to be thought through and tested. 	 * The general assumption is that managers can freely call <code>releaseHandling()</code> 	 * on any item; the item should then dispatch a STOP event that can be listened for on 	 * the utility side.</p>	 * 	 * <p>Finally, it's important that managers operate as efficiently as possible. You can use 	 * the open-source TweenBencher utility to test & optimize.</p>	 * 	 * <p><b>Extending Management Capabilities</b></p>	 * 	 * <p>The Go system only interacts with managers by telling them which items are being	 * added and removed (played or stopped, normally). For more complex managers, 	 * like a hitTest routine, you may need to actively monitor items as they update. 	 * LinearGo and other items can provide udpate callbacks to facilitate this. You can 	 * also formally extend the manager/item contract by extending the IManager and 	 * IManageable interfaces to open up new interactions between managers and items.</p>	 * 	 * <p>Interface extensions can also be used as marker datatypes that don't contain any 	 * custom methods. This enables your custom managers to sniff for a particular interface 	 * type in order to determine which items to store, monitor, or alter. If it's possible	 * to avoid extending IManageable with new methods, you'll save the filesize of those 	 * method implementations across sets of items — As a general rule be as conservative 	 * as possible in what you add to the item side beyond IManageable's methods.</p>	 * 	 * <p>(The aforementioned issue is a potential weakness with this version of Go. However, 	 * an alternative system of decorating or composititing this functionality in is hard to 	 * conceive of, since items need to be able to report private, instance-level information.)</p>	 * 	 * @see IManageable	 * @see org.goasap.managers.OverlapMonitor OverlapMonitor	 * @see org.goasap.GoEngine#addManager GoEngine.addManager	 * 	 * @author Moses Gunesch	 */
	public interface IManager 	{				/**		 * GoEngine reporting that an IManageable is being added to its pulse list.		 * 		 * @param handler		IManageable to query		 */		function reserve(handler:IManageable):void;						/**		 * GoEngine reporting that an IManageable is being removed from its pulse list.		 * 		 * <p>This method should NOT directly stop the item, stopping an item results in 		 * a release() call from GoEngine. This method should simply remove the item from 		 * any internal lists and unsubscribe all listeners on the item.</p> 		 */		function release(handler:IManageable):void;	}}