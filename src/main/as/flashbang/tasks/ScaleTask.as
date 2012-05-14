//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2012 Three Rings Design, Inc., All Rights Reserved
// http://github.com/threerings/flashbang
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.

package flashbang.tasks {

import flash.display.DisplayObject;

import flashbang.Easing;
import flashbang.GameObject;
import flashbang.ObjectTask;

public class ScaleTask extends DisplayObjectTask
{
    public static function CreateLinear (x :Number, y :Number, time :Number,
        disp :DisplayObject = null) :ScaleTask
    {
        return new ScaleTask(x, y, time, Easing.linear, disp);
    }

    public static function CreateSmooth (x :Number, y :Number, time :Number,
        disp :DisplayObject = null) :ScaleTask
    {
        return new ScaleTask(x, y, time, Easing.cubic.easeInOut, disp);
    }

    public static function CreateEaseIn (x :Number, y :Number, time :Number,
        disp :DisplayObject = null) :ScaleTask
    {
        return new ScaleTask(x, y, time, Easing.cubic.easeIn, disp);
    }

    public static function CreateEaseOut (x :Number, y :Number, time :Number,
        disp :DisplayObject = null) :ScaleTask
    {
        return new ScaleTask(x, y, time, Easing.cubic.easeOut, disp);
    }

    public function ScaleTask (x :Number, y :Number, time :Number = 0,
        easingFn :Function = null, disp :DisplayObject = null)
    {
        super(time, easingFn, disp);
        _toX = x;
        _toY = y;
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        if (0 == _elapsedTime) {
            _target = getTarget(obj);
            _fromX = _target.scaleX;
            _fromY = _target.scaleY;
        }

        _elapsedTime += dt;
        _target.scaleX = interpolate(_fromX, _toX);
        _target.scaleY = interpolate(_fromY, _toY);
        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new ScaleTask(_toX, _toY, _totalTime, _easingFn, _display);
    }

    protected var _toX :Number;
    protected var _toY :Number;
    protected var _fromX :Number;
    protected var _fromY :Number;
}

}
