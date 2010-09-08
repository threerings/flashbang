//
// $Id$
//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2010 Three Rings Design, Inc., All Rights Reserved
// http://code.google.com/p/flashbang/
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

package com.threerings.flashbang.tasks {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.components.ScaleComponent;

import flash.display.DisplayObject;

import mx.effects.easing.*;

public class ScaleTask extends InterpolatingTask
{
    public static function CreateLinear (x :Number, y :Number, time :Number,
        disp :DisplayObject = null) :ScaleTask
    {
        return new ScaleTask(x, y, time, mx.effects.easing.Linear.easeNone, disp);
    }

    public static function CreateSmooth (x :Number, y :Number, time :Number,
        disp :DisplayObject = null) :ScaleTask
    {
        return new ScaleTask(x, y, time, mx.effects.easing.Cubic.easeInOut, disp);
    }

    public static function CreateEaseIn (x :Number, y :Number, time :Number,
        disp :DisplayObject = null) :ScaleTask
    {
        return new ScaleTask(x, y, time, mx.effects.easing.Cubic.easeIn, disp);
    }

    public static function CreateEaseOut (x :Number, y :Number, time :Number,
        disp :DisplayObject = null) :ScaleTask
    {
        return new ScaleTask(x, y, time, mx.effects.easing.Cubic.easeOut, disp);
    }

    public function ScaleTask (x :Number, y :Number, time :Number = 0,
        easingFn :Function = null, disp :DisplayObject = null)
    {
        super(time, easingFn);
        _toX = x;
        _toY = y;
        _dispOverride = DisplayObjectWrapper.create(disp);
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        var sc :ScaleComponent =
            (!_dispOverride.isNull ? _dispOverride : obj as ScaleComponent);
        if (null == sc) {
            throw new Error("obj does not implement ScaleComponent");
        }

        if (0 == _elapsedTime) {
            _fromX = sc.scaleX;
            _fromY = sc.scaleY;
        }

        _elapsedTime += dt;
        sc.scaleX = interpolate(_fromX, _toX);
        sc.scaleY = interpolate(_fromY, _toY);
        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new ScaleTask(_toX, _toY, _totalTime, _easingFn, _dispOverride.displayObject);
    }

    protected var _toX :Number;
    protected var _toY :Number;
    protected var _fromX :Number;
    protected var _fromY :Number;
    protected var _dispOverride :DisplayObjectWrapper;
}

}
