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

import flashbang.GameObject;
import flashbang.ObjectTask;

public class ComplexLocationTask extends LocationTask
{
    public function ComplexLocationTask (x :Number, y :Number, time :Number, xEasingFn :Function,
        yEasingFn :Function, disp :DisplayObject = null)
    {
        super(x, y, time, null, disp);
        _xEasingFn = xEasingFn;
        _yEasingFn = yEasingFn;
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        if (0 == _elapsedTime) {
            _lc = getLocationTarget(obj);
            _fromX = _lc.x;
            _fromY = _lc.y;
        }

        _elapsedTime = Math.min(_elapsedTime + dt, _totalTime);
        _lc.x = _xEasingFn(_fromX, _toX, _elapsedTime, _totalTime);
        _lc.y = _yEasingFn(_fromY, _toY, _elapsedTime, _totalTime);

        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new ComplexLocationTask(_toX, _toY, _totalTime, _xEasingFn, _yEasingFn, _display);
    }

    protected var _xEasingFn :Function;
    protected var _yEasingFn :Function;
}

}
