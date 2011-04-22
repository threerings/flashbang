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

import flash.display.DisplayObject;

import mx.effects.easing.*;

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectMessage;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.components.LocationComponent;

public class ComplexLocationTask
    implements ObjectTask
{
    public function ComplexLocationTask (x :Number, y :Number, time :Number, xEasingFn :Function,
        yEasingFn :Function, disp :DisplayObject = null)
    {
        _toX = x;
        _toY = y;
        _totalTime = Math.max(time, 0);
        _xEasingFn = xEasingFn;
        _yEasingFn = yEasingFn;
        _dispOverride = DisplayObjectWrapper.create(disp);
    }

    public function update (dt :Number, obj :GameObject) :Boolean
    {
        var lc :LocationComponent =
            (!_dispOverride.isNull ? _dispOverride : obj as LocationComponent);
        if (null == lc) {
            throw new Error("obj does not implement LocationComponent");
        }

        if (0 == _elapsedTime) {
            _fromX = lc.x;
            _fromY = lc.y;
        }

        _elapsedTime += dt;

        var totalMs :Number = _totalTime * 1000;
        var elapsedMs :Number = Math.min(_elapsedTime * 1000, totalMs);

        lc.x = _xEasingFn(elapsedMs, _fromX, (_toX - _fromX), totalMs);
        lc.y = _yEasingFn(elapsedMs, _fromY, (_toY - _fromY), totalMs);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new ComplexLocationTask(_toX, _toY, _totalTime, _xEasingFn, _yEasingFn,
            _dispOverride.displayObject);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _xEasingFn :Function;
    protected var _yEasingFn :Function;

    protected var _toX :Number;
    protected var _toY :Number;

    protected var _fromX :Number;
    protected var _fromY :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;

    protected var _dispOverride :DisplayObjectWrapper;
}

}
