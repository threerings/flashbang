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

import com.threerings.util.Randoms;

public class NumRange
{
    public var min :Number;
    public var max :Number;
    public var rands :Randoms;

    public function NumRange (min :Number, max :Number, rands :Randoms)
    {
        this.min = min;
        this.max = max;
        this.rands = rands;
    }

    public function next () :Number
    {
        return rands.getNumberInRange(min, max);
    }

    public function clone () :NumRange
    {
        return new NumRange(min, max, rands);
    }
}

}
