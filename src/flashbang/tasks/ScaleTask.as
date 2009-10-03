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
// $Id: ScaleTask.as 7231 2009-01-23 20:17:52Z tim $

package flashbang.tasks {

import com.threerings.util.Assert;

import flashbang.SimObject;
import flashbang.ObjectTask;
import flashbang.ObjectMessage;
import flashbang.util.Interpolator;
import flashbang.util.MXInterpolatorAdapter;

import flash.geom.Point;

import mx.effects.easing.*;
import flash.display.DisplayObject;
import flashbang.components.ScaleComponent;

public class ScaleTask
    implements ObjectTask
{
    public static function CreateLinear (x :Number, y :Number, time :Number) :ScaleTask
    {
        return new ScaleTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Linear.easeNone));
    }

    public static function CreateSmooth (x :Number, y :Number, time :Number) :ScaleTask
    {
        return new ScaleTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeInOut));
    }

    public static function CreateEaseIn (x :Number, y :Number, time :Number) :ScaleTask
    {
        return new ScaleTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn));
    }

    public static function CreateEaseOut (x :Number, y :Number, time :Number) :ScaleTask
    {
        return new ScaleTask(
            x, y,
            time,
            new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeOut));
    }

    public function ScaleTask (
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
        var sc :ScaleComponent = (obj as ScaleComponent);

        if (null == sc) {
            throw new Error("ScaleTask can only be applied to SimObjects that implement " +
                            "ScaleComponent");
        }

        if (0 == _elapsedTime) {
            _fromX = sc.scaleX;
            _fromY = sc.scaleY;
        }

        _elapsedTime += dt;

        sc.scaleX = _interpolator.interpolate(_fromX, _toX, _elapsedTime, _totalTime);
        sc.scaleY = _interpolator.interpolate(_fromY, _toY, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new ScaleTask(_toX, _toY, _totalTime, _interpolator);
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
