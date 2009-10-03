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
// $Id: Rand.as 9700 2009-08-11 22:45:36Z tim $

package flashbang.util {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Random;

public class Rand
{
    public static const STREAM_GAME :uint = 0;
    public static const STREAM_COSMETIC :uint = 1;

    /** Adds a new random stream, and returns its streamId. */
    public static function addStream (seed :uint = 0) :uint
    {
        _randStreams.push(new Random(seed));
        return (_randStreams.length - 1);
    }

    /** Returns the Random object associated with the given streamId. */
    public static function getStream (streamId :uint) :Random
    {
        return (_randStreams[streamId] as Random);
    }

    /** Sets a new seed for the given stream. */
    public static function seedStream (streamId :uint, seed :uint) :void
    {
        getStream(streamId).setSeed(seed);
    }

    /** Returns a random element from the given Array. */
    public static function nextElement (arr :Array, streamId :uint) :*
    {
        return (arr.length > 0 ? arr[nextIntInRange(0, arr.length - 1, streamId)] : undefined);
    }

    /** Returns an integer in the range [0, MAX) */
    public static function nextInt (streamId :uint) :int
    {
        return getStream(streamId).nextInt();
    }

    /**
     * Returns an int in the range [low, high)
     * @deprecated use {@link #nextIntInRange}
     */
    public static function nextIntRange (low :int, high :int, streamId :uint) :int
    {
        return nextIntInRange(low, high - 1, streamId);
    }

    /** Returns an int in the range [min, max] */
    public static function nextIntInRange (min :int, max :int, streamId :uint) :int
    {
        return min + getStream(streamId).nextInt(max - min + 1);
    }

    /** Returns a Boolean. */
    public static function nextBoolean (streamId :uint) :Boolean
    {
        return getStream(streamId).nextBoolean();
    }

    /**
     * Returns true (chance * 100)% of the time.
     * @param chance a number in the range [0, 1)
     */
    public static function nextChance (chance :Number, streamId :uint) :Boolean
    {
        return nextNumber(streamId) < chance;
    }

    /** Returns a Number in the range [0.0, 1.0) */
    public static function nextNumber (streamId :uint) :Number
    {
        return getStream(streamId).nextNumber();
    }

    /**
     * Returns a Number in the range [low, high)
     * @deprecated use {@link #nextNumberInRange}
     */
    public static function nextNumberRange (low :Number, high :Number, streamId :uint) :Number
    {
        return nextNumberInRange(low, high, streamId);
    }

    /** Returns a Number in the range [low, high) */
    public static function nextNumberInRange (low :Number, high :Number, streamId :uint) :Number
    {
        return low + (getStream(streamId).nextNumber() * (high - low));
    }

    /** Randomizes the order of the elements in the given Array, in place. */
    public static function shuffleArray (arr :Array, streamId :uint) :void
    {
        ArrayUtil.shuffle(arr, getStream(streamId));
    }

    // We always have the STREAM_GAME and STREAM_COSMETIC streams
    protected static var _randStreams :Array = [ new Random(), new Random() ];
}

}
