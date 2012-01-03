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

import flash.media.SoundChannel;

import org.osflash.signals.Signal;

import com.threerings.flashbang.resource.SoundResource;

public class AudioChannel
{
    /**
     * Dispatched when the AudioChannel has completed playing. If the channel loops, the signal will
     * dispatch after it has completed looping.
     * The signal will not dispatch if the channel is manually stopped.
     */
    public const completed :Signal = new Signal();

    public function get isPlaying () :Boolean
    {
        return (null != sound);
    }

    public function get priority () :int
    {
        return (null != sound ? sound.priority : int.MIN_VALUE);
    }

    public function get isPaused () :Boolean
    {
        return (null != sound && null == channel);
    }

    public function get audioControls () :AudioControls
    {
        return (null != controls ? controls : DUMMY_CONTROLS);
    }

    /**
     * Returns the length of the sound in milliseconds, or 0 if the sound doesn't exist.
     */
    public function get length () :Number
    {
        return null == sound ? 0 : sound.sound.length;
    }

    // managed by AudioManager

    internal var completeHandler :Function;
    internal var controls :AudioControls;
    internal var sound :SoundResource;
    internal var channel :SoundChannel;
    internal var playPosition :Number;
    internal var startTime :int;
    internal var loopCount :int;

    internal static const DUMMY_CONTROLS :AudioControls = new AudioControls();
}

}
