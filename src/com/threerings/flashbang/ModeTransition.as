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

package com.threerings.flashbang {

import com.threerings.util.Enum;

public final class ModeTransition extends Enum
{
    public static const PUSH :ModeTransition = new ModeTransition("PUSH", true, false);
    public static const UNWIND :ModeTransition = new ModeTransition("UNWIND", false, false);
    public static const INSERT :ModeTransition = new ModeTransition("INSERT", true, true);
    public static const REMOVE :ModeTransition = new ModeTransition("REMOVE", false, true);
    public static const CHANGE :ModeTransition = new ModeTransition("CHANGE", true, false);
    finishedEnumerating(ModeTransition);

    /**
     * Get the values of the ModeTransition enum
     */
    public static function values () :Array
    {
        return Enum.values(ModeTransition);
    }

    /**
     * Get the value of the ModeTransition enum that corresponds to the specified string.
     * If the value requested does not exist, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :ModeTransition
    {
        return Enum.valueOf(ModeTransition, name) as ModeTransition;
    }

    public function get requiresMode () :Boolean
    {
        return _requiresMode;
    }

    public function get requiresIndex () :Boolean
    {
        return _requiresIndex;
    }

    /** @private */
    public function ModeTransition (name :String, requiresMode :Boolean, requiresIndex :Boolean)
    {
        super(name);
        _requiresMode = requiresMode;
        _requiresIndex = requiresIndex;
    }

    protected var _requiresMode :Boolean;
    protected var _requiresIndex :Boolean;
}
}
