// Flashbang - a framework for creating Flash games
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
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.threerings.flashbang.tasks {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.components.AlphaComponent;

import flash.display.DisplayObject;

import mx.effects.easing.*;

public class AlphaTask extends InterpolatingTask
{
    public static function CreateLinear (alpha :Number, time :Number, disp :DisplayObject = null)
        :AlphaTask
    {
        return new AlphaTask(alpha, time, mx.effects.easing.Linear.easeNone, disp);
    }

    public static function CreateSmooth (alpha :Number, time :Number, disp :DisplayObject = null)
        :AlphaTask
    {
        return new AlphaTask(alpha, time, mx.effects.easing.Cubic.easeInOut, disp);
    }

    public static function CreateEaseIn (alpha :Number, time :Number, disp :DisplayObject = null)
        :AlphaTask
    {
        return new AlphaTask(alpha, time, mx.effects.easing.Cubic.easeIn, disp);
    }

    public static function CreateEaseOut (alpha :Number, time :Number, disp :DisplayObject = null)
        :AlphaTask
    {
        return new AlphaTask(alpha, time, mx.effects.easing.Cubic.easeOut, disp);
    }

    public function AlphaTask (alpha :Number, time :Number = 0, easingFn :Function = null,
        disp :DisplayObject = null)
    {
        super(time, easingFn);
        _to = alpha;
        _dispOverride = DisplayObjectWrapper.create(disp);
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        var alphaComponent :AlphaComponent =
            (!_dispOverride.isNull ? _dispOverride : obj as AlphaComponent);
        if (null == alphaComponent) {
            throw new Error("obj does not implement AlphaComponent");
        }

        if (0 == _elapsedTime) {
            _from = alphaComponent.alpha;
        }

        _elapsedTime += dt;

        alphaComponent.alpha = interpolate(_from, _to, _elapsedTime, _totalTime, _easingFn);

        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new AlphaTask(_to, _totalTime, _easingFn, _dispOverride.displayObject);
    }

    protected var _to :Number;
    protected var _from :Number;
    protected var _dispOverride :DisplayObjectWrapper;
}

}
