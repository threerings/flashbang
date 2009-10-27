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
import com.threerings.flashbang.ObjectMessage;
import com.threerings.flashbang.ObjectTask;
import com.threerings.util.MathUtil;

import mx.effects.easing.Linear;

public class InterpolatingTask
    implements ObjectTask
{
    public function InterpolatingTask (time :Number = 0, easingFn :Function = null)
    {
        _totalTime = Math.max(time, 0);
        // default to linear interpolation
        _easingFn = (easingFn != null ? easingFn : mx.effects.easing.Linear.easeNone);
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

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected static function interpolate (a :Number, b :Number, t :Number, duration :Number,
        easingFn :Function) :Number
    {
        // we need to rejuggle arguments to fit the signature of the mx easing functions:
        // ease(t, b, c, d)
        // t - specifies time
        // b - specifies the initial position of a component
        // c - specifies the total change in position of the component
        // d - specifies the duration of the effect, in milliseconds

        if (duration <= 0) {
            return b;
        }
        t = MathUtil.clamp(t, 0, duration);
        return easingFn(t * 1000, a, (b - a), duration * 1000);
    }

    protected var _totalTime :Number = 0;
    protected var _elapsedTime :Number = 0;

    protected var _easingFn :Function;
}

}
