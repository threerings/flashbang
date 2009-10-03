// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
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
// $Id: Config.as 9690 2009-08-05 23:16:46Z tim $

package com.whirled.contrib.simplegame {

import com.whirled.contrib.simplegame.resource.ResourceManager;

public class Config
{
    /** The number of audio channels the AudioManager will use. Optional. Defaults to 25. */
    public var maxAudioChannels :int = 25;

    /**
     * If not null, externalResourceManager will be used in place of a new ResourceManager.
     * externalResourceManager will not be shut down when the SimpleGame is.
     * Defaults to null.
     */
    public var externalResourceManager :ResourceManager;

    /**
     * If the framerate drops below this value, the MainLoop will artificially reduce the
     * time delta passed to update() functions, causing the game to slow down but animate
     * more smoothly. Defaults to 15.
     */
    public var minFrameRate :Number = 15;
}

}
