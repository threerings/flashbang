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

package flashbang.tasks {

import flashbang.ObjectMessage;
import flashbang.ObjectTask;
import flashbang.SimObject;
import flashbang.components.LocationComponent;

import mx.effects.easing.*;

public class ComplexLocationTask
    implements ObjectTask
{
    public function ComplexLocationTask (
        x :Number,
        y :Number,
        time :Number,
        xInterpolator :Function,
        yInterpolator :Function)
    {
        _toX = x;
        _toY = y;
        _totalTime = Math.max(time, 0);
        _xInterpolator = xInterpolator;
        _yInterpolator = yInterpolator;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var lc :LocationComponent = (obj as LocationComponent);

        if (null == lc) {
            throw new Error("ComplexLocationTask can only be applied to SimObjects that " +
                "implement LocationComponent");
        }

        if (0 == _elapsedTime) {
            _fromX = lc.x;
            _fromY = lc.y;
        }

        _elapsedTime += dt;

        var totalMs :Number = _totalTime * 1000;
        var elapsedMs :Number = Math.min(_elapsedTime * 1000, totalMs);

        lc.x = _xInterpolator(elapsedMs, _fromX, (_toX - _fromX), totalMs);
        lc.y = _yInterpolator(elapsedMs, _fromY, (_toY - _fromY), totalMs);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new ComplexLocationTask(_toX, _toY, _totalTime, _xInterpolator, _yInterpolator);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _xInterpolator :Function;
    protected var _yInterpolator :Function;

    protected var _toX :Number;
    protected var _toY :Number;

    protected var _fromX :Number;
    protected var _fromY :Number;

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
