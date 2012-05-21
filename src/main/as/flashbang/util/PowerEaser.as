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

package flashbang.util {

import flashbang.Easing;

public class PowerEaser
{
    public function PowerEaser (pow :int)
    {
        _pow = pow;
    }

    public function easeIn (from :Number, to :Number, dt :Number, t :Number) :Number
    {
        if (t == 0) {
            return to;
        }
        return from + ((to - from) * Math.pow(dt / t, _pow));
    }

    public function easeOut (from :Number, to :Number, dt :Number, t :Number) :Number
    {
        if (t == 0) {
            return to;
        }
        return from + ((to - from) * (1 - Math.pow(1 - dt / t, _pow)));
    }

    public function easeInOut (from :Number, to :Number, dt :Number, t :Number) :Number
    {
        if (t == 0) {
            return to;
        }

        var mid :Number = from + (to - from) * 0.5;
        t *= 0.5;
        return (dt <= t ? easeIn(from, mid, dt, t) : easeOut(mid, to, dt - t, t));
    }

    protected var _pow :int;
}
}
