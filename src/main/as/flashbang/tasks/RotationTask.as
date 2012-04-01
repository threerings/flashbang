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
import flashbang.components.RotationComponent;

public class RotationTask extends InterpolatingTask
{
    public static function CreateLinear (rotationDegrees :Number, time :Number,
        disp :DisplayObject = null) :RotationTask
    {
        return new RotationTask(rotationDegrees, time, Easing.linear, disp);
    }

    public static function CreateSmooth (rotationDegrees :Number, time :Number,
        disp :DisplayObject = null) :RotationTask
    {
        return new RotationTask(rotationDegrees, time, Easing.cubic.easeInOut, disp);
    }

    public static function CreateEaseIn (rotationDegrees :Number, time :Number,
        disp :DisplayObject = null) :RotationTask
    {
        return new RotationTask(rotationDegrees, time, Easing.cubic.easeIn, disp);
    }

    public static function CreateEaseOut (rotationDegrees :Number, time :Number,
        disp :DisplayObject = null) :RotationTask
    {
        return new RotationTask(rotationDegrees, time, Easing.cubic.easeOut, disp);
    }

    public function RotationTask (rotationDegrees :Number, time :Number = 0,
        easingFn :Function = null, disp :DisplayObject = null)
    {
        super(time, easingFn);
        _to = rotationDegrees;
        _dispOverride = DisplayObjectWrapper.create(disp);
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        var rc :RotationComponent =
            (!_dispOverride.isNull ? _dispOverride : obj as RotationComponent);
        if (null == rc) {
            throw new Error("obj does not implement RotationComponent");
        }

        if (0 == _elapsedTime) {
            _from = rc.rotation;
        }

        _elapsedTime += dt;
        rc.rotation = interpolate(_from, _to);
        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new RotationTask(_to, _totalTime, _easingFn, _dispOverride.displayObject);
    }

    protected var _to :Number;
    protected var _from :Number;
    protected var _dispOverride :DisplayObjectWrapper;
}

}
