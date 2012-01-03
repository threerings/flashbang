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

package com.threerings.flashbang.audio {

public class AudioState
{
    public var volume :Number = 1;
    public var pan :Number = 0;
    public var paused :Boolean;
    public var muted :Boolean;
    public var stopped :Boolean;

    public function get actualVolume () :Number
    {
        return (muted ? 0 : volume);
    }

    public static function defaultState () :AudioState
    {
        return new AudioState();
    }

    public static function combine (a :AudioState, b :AudioState, into :AudioState = null)
        :AudioState
    {
        if (null == into) {
            into = new AudioState();
        }

        into.volume = a.volume * b.volume;
        into.pan = (a.pan + b.pan) * 0.5;
        into.paused = a.paused || b.paused;
        into.muted = a.muted || b.muted;
        into.stopped = a.stopped || b.stopped;

        return into;
    }
}

}
