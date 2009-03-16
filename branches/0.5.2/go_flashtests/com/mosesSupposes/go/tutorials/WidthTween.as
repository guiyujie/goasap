/**
	 * A basic example of how you could build a tween on LinearGo.
	 */
	public class WidthTween extends LinearGo {
		
		// -== Public Properties ==-
		
		public function get width() : Number {
			return _width;
		}
		public function set width(value : Number):void {
			if (_state==PlayStates.STOPPED)
				_width = value;
		} 		
		
		public function get target() : DisplayObject {
			return _target;
		}
		public function set target(obj : DisplayObject):void {
			if (_state==PlayStates.STOPPED)
				_target = obj;
		}
		
		// -== Protected Properties ==-
		protected var _target : DisplayObject;
		protected var _width : Number;
		protected var _startWidth : Number;
		protected var _changeWidth : Number;
		
		// -== Public Methods ==-
		
		public function WidthTween(	target				: DisplayObject=null,
									widthTo				: Number=NaN,
									delay	 			: Number=NaN,
									duration 			: Number=NaN,
									easing 				: Function=null ) 
		{
			super(delay, duration, easing);
			_target = target;
			_width = widthTo;
		}
		
		override public function start():Boolean 
		{
			if (!_target || !_width || isNaN(_width))
				return false;
			
			_changeWidth = (useRelative 
							? _width // relative positioning: like if the user set -10, we should change "by" that much.  
		}
		
			_target.width = super.correctValue( _startWidth + _changeWidth * _position );
		}
	}
}