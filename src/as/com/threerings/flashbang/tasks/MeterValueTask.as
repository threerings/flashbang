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

import com.threerings.flashbang.ObjectMessage;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.SimObject;
import com.threerings.flashbang.components.MeterComponent;
import com.threerings.flashbang.util.Interpolator;
import com.threerings.flashbang.util.MXInterpolatorAdapter;

import mx.effects.easing.*;

public class MeterValueTask
    implements ObjectTask
{
    public static function CreateLinear (value :Number, time :Number) :MeterValueTask
    {
        return new MeterValueTask(
            value,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (value :Number, time :Number) :MeterValueTask
    {
        return new MeterValueTask(
            value,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (value :Number, time :Number) :MeterValueTask
    {
        return new MeterValueTask(
            value,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (value :Number, time :Number) :MeterValueTask
    {
        return new MeterValueTask(
            value,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public static function CreateWithFunction (value :Number, time :Number, fn :Function)
        :MeterValueTask
    {
        return new MeterValueTask(
           value,
           time,
           new MXInterpolatorAdapter(fn));
    }

    public function MeterValueTask (
        value :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        _to = value;
        _totalTime = Math.max(time, 0);
        _interpolator = interpolator;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var meterComponent :MeterComponent = (obj as MeterComponent);

        if (null == meterComponent) {
            throw new Error("MeterValueTask can only be applied to SimObjects that implement " +
                            "MeterComponent");
        }

        if (0 == _elapsedTime) {
            _from = meterComponent.value;
        }

        _elapsedTime += dt;

        meterComponent.value = _interpolator.interpolate(_from, _to, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new MeterValueTask(_to, _totalTime, _interpolator);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _interpolator :Interpolator;

    protected var _to :Number;
    protected var _from :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
