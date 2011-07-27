//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2011 Three Rings Design, Inc., All Rights Reserved
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

package com.threerings.flashbang.tasks {

import mx.effects.easing.*;

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.util.BoxedNumber;

public class AnimateValueTask extends InterpolatingTask
{
    public static function CreateLinear (value :BoxedNumber, targetValue :Number, time :Number)
        :AnimateValueTask
    {
        return new AnimateValueTask(
            value,
            targetValue,
            time,
            mx.effects.easing.Linear.easeNone);
    }

    public static function CreateSmooth (value :BoxedNumber, targetValue :Number, time :Number)
        :AnimateValueTask
    {
        return new AnimateValueTask(
            value,
            targetValue,
            time,
            mx.effects.easing.Cubic.easeInOut);
    }

    public static function CreateEaseIn (value :BoxedNumber, targetValue :Number, time :Number)
        :AnimateValueTask
    {
        return new AnimateValueTask(
            value,
            targetValue,
            time,
            mx.effects.easing.Cubic.easeIn);
    }

    public static function CreateEaseOut (value :BoxedNumber, targetValue :Number, time :Number)
        :AnimateValueTask
    {
        return new AnimateValueTask(
            value,
            targetValue,
            time,
            mx.effects.easing.Cubic.easeOut);
    }

    public function AnimateValueTask (value :BoxedNumber, targetValue :Number, time :Number = 0,
        easingFn :Function = null)
    {
        super(time, easingFn);

        if (null == value) {
            throw new Error("value must be non null");
        }

        _to = targetValue;
        _value = value;
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        if (0 == _elapsedTime) {
            _from = _value.value;
        }

        _elapsedTime += dt;
        _value.value = interpolate(_from, _to);
        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new AnimateValueTask(_value, _to, _totalTime, _easingFn);
    }

    protected var _to :Number;
    protected var _from :Number;
    protected var _value :BoxedNumber;
}

}
