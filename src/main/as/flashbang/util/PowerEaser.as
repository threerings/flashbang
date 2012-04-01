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

    public function easeIn (t :Number, b :Number, c :Number, d :Number) :Number
    {
        return c * (t /= d) * Math.pow(t, _pow - 1) + b;
    }

    public function easeOut (t :Number, b :Number, c :Number, d :Number) :Number
    {
        return c * ((t = t / d - 1) * Math.pow(t, _pow - 1) + 1) + b;
    }

    public function easeInOut (t :Number, b :Number, c :Number, d :Number) :Number
    {
        if ((t /= d / 2) < 1) {
            return c / 2 * Math.pow(t, _pow) + b;
        } else {
            return c / 2 * ((t -= 2) * Math.pow(t, _pow - 1) + 2) + b;
        }
    }

    protected var _pow :int;
}
}
