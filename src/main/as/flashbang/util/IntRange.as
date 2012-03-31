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

public class IntRange
{
    public var min :int;
    public var max :int;
    public var defaultRandStreamId :uint;

    public function IntRange (min :int, max :int, defaultRandStreamId :uint = uint.MAX_VALUE)
    {
        this.min = min;
        this.max = max;
        this.defaultRandStreamId = defaultRandStreamId;
    }

    public function next (randStreamId :int = -1) :int
    {
        return Rand.nextIntInRange(min, max,
            (randStreamId >= 0 ? randStreamId : defaultRandStreamId));
    }

    public function clone () :IntRange
    {
        return new IntRange(min, max, defaultRandStreamId);
    }
}

}
