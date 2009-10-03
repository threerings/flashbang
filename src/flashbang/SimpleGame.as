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
// $Id: SimpleGame.as 9690 2009-08-05 23:16:46Z tim $

package flashbang {

import flashbang.audio.*;
import flashbang.resource.*;

import flash.display.Sprite;
import flash.events.IEventDispatcher;

public class SimpleGame
{
    public function SimpleGame (config :Config = null)
    {
        if (config == null) {
            config = new Config();
        }

        _ctx.mainLoop = new MainLoop(_ctx, config.minFrameRate);
        _ctx.audio = new AudioManager(_ctx, config.maxAudioChannels);
        _ctx.mainLoop.addUpdatable(_ctx.audio);

        if (config.externalResourceManager == null) {
            _ctx.rsrcs = new ResourceManager();
            _ownsResourceManager = true;

            // add resource factories
            _ctx.rsrcs.registerResourceType("image", ImageResource);
            _ctx.rsrcs.registerResourceType("swf", SwfResource);
            _ctx.rsrcs.registerResourceType("xml", XmlResource);
            _ctx.rsrcs.registerResourceType("sound", SoundResource);

        } else {
            _ctx.rsrcs = config.externalResourceManager;
            _ownsResourceManager = false;
        }
    }

    public function run (hostSprite :Sprite, keyDispatcher :IEventDispatcher = null) :void
    {
        _ctx.mainLoop.setup();
        _ctx.mainLoop.run(hostSprite, keyDispatcher);
    }

    public function shutdown () :void
    {
        _ctx.mainLoop.shutdown();
        _ctx.audio.shutdown();

        if (_ownsResourceManager) {
            _ctx.rsrcs.shutdown();
        }
    }

    public function get ctx () :Context
    {
        return _ctx;
    }

    protected var _ctx :Context = new Context();
    protected var _ownsResourceManager :Boolean;
}

}
