//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2011 Three Rings Design, Inc., All Rights Reserved
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

package com.threerings.flashbang {

import com.threerings.flashbang.audio.*;
import com.threerings.flashbang.resource.*;

import flash.display.Sprite;
import flash.events.IEventDispatcher;

public class FlashbangApp
{
    public function FlashbangApp (hostSprite :Sprite, config :Config = null)
    {
        if (config == null) {
            config = new Config();
        }

        _mainLoop = new MainLoop(this, hostSprite, config.minFrameRate);
        _audio = new AudioManager(this, config.maxAudioChannels);
        _mainLoop.addUpdatable(_audio);

        if (config.externalResourceManager == null) {
            _rsrcs = new ResourceManager();
            rsrcs.registerDefaultResourceTypes(); // image, swf, xml, sound
            _ownsResourceManager = true;

        } else {
            _rsrcs = config.externalResourceManager;
            _ownsResourceManager = false;
        }
    }

    public function run () :void
    {
        _mainLoop.run();
    }

    public function shutdown () :void
    {
        _mainLoop.shutdown();
        _audio.shutdown();

        if (_ownsResourceManager) {
            _rsrcs.shutdown();
        }
    }

    public function get mainLoop () :MainLoop
    {
        return _mainLoop;
    }

    public function get rsrcs () :ResourceManager
    {
        return _rsrcs;
    }

    public function get audio () :AudioManager
    {
        return _audio;
    }

    protected var _mainLoop :MainLoop;
    protected var _rsrcs :ResourceManager;
    protected var _audio :AudioManager;
    protected var _ownsResourceManager :Boolean;
}

}
