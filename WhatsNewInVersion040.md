This page is updated sporadically, for details click Source > Changes above.

**0.4.9 notes**
Improves GoASAP's management layer.
  * All managers are now accessed by GoEngine in the order they are added, so various duties can be carefully ordered.
  * NEW INTERFACE: ILiveManager. GoEngine has been altered so that any managers that implement this interface receive a special onUpdate() callback after each update cycle.
  * OverlapMonitor has been rewritten to use Dictionaries instead of Arrays to store handlers internally, and to correct an efficiency flaw in release().
  * Also: GoItem.defaultPulseInterval has been set back to ENTER\_FRAME. (While 33ms does perform faster on benchmarks with thousands of animations, ENTER\_FRAME runs much smoother in practical contexts.)

**0.4.7 notes**
  * Added new Repeater & LinearGoRepeater classes.
  * LinearGo, PlayableGroup and sequence classes now sport repeater instances.
  * Added new event types to GoEvent and playable classes: PAUSE, RESUME and CYCLE.
  * useFrames support added to LinearGo
  * id property of PlayableBase changed to playableID (v0.4.8) to avoid conflicts, id was too generic.
  * static playRetainer property added to PlayableBase for stashing refs to self during play cycle (v0.4.4)

**0.4.2 notes**

  * Totally new tests package with GoTestBase class and tutorial classes
  * The tutorial class SizeTweenMG renamed slightly (was Mg) and updated a little
  * GoItem now sports a smoother defaultPulseInterval of 33
  * Sequence Looping feature added: repeatCount & currentCount props added
  * Sequences now should not be GC'd while running if you don't store a ref to them
  * SequenceCA: Many changes and fixes mostly dealing with _trailingTweens
  * TweenBencher updated for use with this version._


**0.4.0 notes**

  * IPlayable, IPlayableBase, and PlayableBase are reorganized so that PlayableBase does not implement IPlayable.
  * Sequence.addStepAt parameters were switched to match DisplayObjectContainer.addChildAt().
  * GoEngine has been rewritten again for some very successful optimization (new charts! http://www.goasap.org/info.html#benchmarks), and adds an internal caching mechanism that keeps animations in sync during sequence advance.
  * TweenBencher 1.6 now includes a memory meter so you can keep an eye peeled for memory leaks in your animation systems.