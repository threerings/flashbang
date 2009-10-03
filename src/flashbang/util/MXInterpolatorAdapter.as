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

package flashbang.util {

import flashbang.util.Interpolator;

public class MXInterpolatorAdapter
   implements Interpolator
{
    /**
     * Creates an Interpolator that adapts an easing function from mx.effects.easing.
     * Example: new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn);
     */
    public function MXInterpolatorAdapter (easingFunction :Function)
    {
        _easingFunction = easingFunction;
    }

    public function interpolate (a :Number, b :Number, t :Number, duration :Number) :Number
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

        t = Math.max(t, 0);
        t = Math.min(t, duration);
        return _easingFunction (t * 1000, a, (b - a), duration * 1000);
    }

    protected var _easingFunction :Function;
}

}
