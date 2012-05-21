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

import com.threerings.util.MathUtil;

import flashbang.Easing;
import flashbang.GameObject;
import flashbang.ObjectTask;

public class InterpolatingTask
    implements ObjectTask
{
    public function InterpolatingTask (time :Number = 0, easingFn :Function = null)
    {
        _totalTime = Math.max(time, 0);
        // default to linear interpolation
        _easingFn = (easingFn != null ? easingFn : Easing.linear);
    }

    public function update (dt :Number, obj :GameObject) :Boolean
    {
        _elapsedTime += dt;
        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new InterpolatingTask(_totalTime, _easingFn);
    }

    protected function interpolate (from :Number, to :Number) :Number
    {
        return _easingFn(from, to, Math.min(_elapsedTime, _totalTime), _totalTime);
    }

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;

    protected var _easingFn :Function;
}

}
