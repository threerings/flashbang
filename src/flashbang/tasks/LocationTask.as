// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
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
// $Id: LocationTask.as 7231 2009-01-23 20:17:52Z tim $

package com.whirled.contrib.simplegame.tasks {

import com.threerings.util.Assert;

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.util.Interpolator;
import com.whirled.contrib.simplegame.util.MXInterpolatorAdapter;

import flash.geom.Point;

import mx.effects.easing.*;
import flash.display.DisplayObject;
import com.whirled.contrib.simplegame.components.LocationComponent;
import com.whirled.contrib.simplegame.ObjectMessage;

public class LocationTask
    implements ObjectTask
{
    public static function CreateLinear (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public static function CreateWithFunction (x :Number, y:Number, time :Number, fn :Function)
        :LocationTask
    {
        return new LocationTask(
           x, y,
           time,
           new MXInterpolatorAdapter(fn));
    }

    public function LocationTask (
        x :Number,
        y :Number,
        time :Number = 0,
        interpolator :Interpolator = null)
    {
        // default to linear interpolation
        if (null == interpolator) {
            interpolator = new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone);
        }

        _toX = x;
        _toY = y;
        _totalTime = Math.max(time, 0);
        _interpolator = interpolator;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var lc :LocationComponent = (obj as LocationComponent);

        if (null == lc) {
            throw new Error("LocationTask can only be applied to SimObjects that implement " +
                            "LocationComponent");
        }

        if (0 == _elapsedTime) {
            _fromX = lc.x;
            _fromY = lc.y;
        }

        _elapsedTime += dt;

        lc.x = _interpolator.interpolate(_fromX, _toX, _elapsedTime, _totalTime);
        lc.y = _interpolator.interpolate(_fromY, _toY, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new LocationTask(_toX, _toY, _totalTime, _interpolator);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _interpolator :Interpolator;

    protected var _toX :Number;
    protected var _toY :Number;

    protected var _fromX :Number;
    protected var _fromY :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
