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

package com.threerings.flashbang.util {

public class NumRange
{
    public var min :Number;
    public var max :Number;
    public var defaultRandStreamId :uint;

    public function NumRange (min :Number, max :Number, defaultRandStreamId :uint)
    {
        this.min = min;
        this.max = max;
        this.defaultRandStreamId = defaultRandStreamId;
    }

    public function next (randStreamId :int = -1) :Number
    {
        return Rand.nextNumberInRange(
            min, max, (randStreamId >= 0 ? randStreamId : defaultRandStreamId));
    }

    public function clone () :NumRange
    {
        return new NumRange(min, max, defaultRandStreamId);
    }
}

}
