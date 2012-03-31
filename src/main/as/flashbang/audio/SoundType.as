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

package flashbang.audio {

import com.threerings.util.Enum;

public final class SoundType extends Enum
{
    public static const SFX :SoundType = new SoundType("SFX");
    public static const MUSIC :SoundType = new SoundType("MUSIC");
    finishedEnumerating(SoundType);

    /**
     * Get the values of the SoundType enum
     */
    public static function values () :Array
    {
        return Enum.values(SoundType);
    }

    /**
     * Get the value of the SoundType enum that corresponds to the specified string.
     * If the value requested does not exist, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :SoundType
    {
        return Enum.valueOf(SoundType, name) as SoundType;
    }

    /** @private */
    public function SoundType (name :String)
    {
        super(name);
    }
}
}
