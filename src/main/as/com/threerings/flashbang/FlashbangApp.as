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

package com.threerings.flashbang {

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.utils.getTimer;

import org.osflash.signals.Signal;

import com.threerings.util.Arrays;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Preconditions;

import com.threerings.flashbang.audio.*;
import com.threerings.flashbang.resource.*;

public class FlashbangApp
{
    public const didShutdown :Signal = new Signal();

    public function FlashbangApp (hostSprite :Sprite, config :Config = null)
    {
        if (config == null) {
            config = new Config();
        }

        _minFrameRate = config.minFrameRate;
        _hostSprite = hostSprite;

        _audio = new AudioManager(this, config.maxAudioChannels);
        addUpdatable(_audio);

        _rsrcs = new ResourceManager();
        rsrcs.registerDefaultResourceTypes(); // image, swf, xml, sound

        // Create our default viewport
        createViewport(Viewport.DEFAULT);
    }

    /**
     * Kicks off the app. Game updates will start happening after this function is called.
     */
    public function run () :void
    {
        if (_running) {
            throw new Error("already running");
        }

        var stage :Stage = _hostSprite.stage;
        Preconditions.checkNotNull(stage, "The Flashbang host Sprite must be on the stage");
        _keyDispatcher = stage;

        _running = true;

        _events.registerListener(_hostSprite, Event.ENTER_FRAME, update);
        _events.registerListener(_keyDispatcher, KeyboardEvent.KEY_DOWN, onKeyDown);
        _events.registerListener(_keyDispatcher, KeyboardEvent.KEY_UP, onKeyUp);

        _lastTime = getAppTime();

        _viewports.forEach(function (name :String, viewport :Viewport) :void {
            viewport.handleModeTransitions();
        });
    }

    /**
     * Call this function before the application shuts down to release
     * memory and disconnect event handlers. The app may not shut down
     * immediately when this function is called - if it is running, it will be
     * shut down at the end of the current update.
     *
     * It's an error to continue to use a FlashbangApp that has been shut down.
     *
     * Most applications will want to install an Event.REMOVED_FROM_STAGE
     * handler on the main sprite, and call shutdown from there.
     */
    public function shutdown () :void
    {
        if (_running) {
            _shutdownPending = true;
        } else {
            shutdownNow();
        }
    }

    /**
     * Creates and registers a new Viewport. (Flashbang automatically creates a Viewport on
     * initialization, so this is only necessary for creating additional ones.)
     *
     * Viewports must be uniquely named.
     */
    public function createViewport (name :String, parentSprite :Sprite = null) :Viewport
    {
        if (parentSprite == null) {
            parentSprite = _hostSprite;
        }

        var viewport :Viewport = new Viewport(this, name, parentSprite);
        var existing :Object = _viewports.put(name, viewport);
        if (existing != null) {
            throw new Error("A viewport named '" + name + "' already exists");
        }
        return viewport;
    }

    /**
     * Returns the Viewport with the given name, if it exists.
     */
    public function getViewport (name :String) :Viewport
    {
        return _viewports.get(name);
    }

    /**
     * Returns the default Viewport that was created when Flashbang was initialized
     */
    public function get defaultViewport () :Viewport
    {
        return getViewport(Viewport.DEFAULT);
    }

    public function addUpdatable (obj :Updatable) :void
    {
        _updatables.push(obj);
    }

    public function removeUpdatable (obj :Updatable) :void
    {
        Arrays.removeFirst(_updatables, obj);
    }

    /**
     * Returns the approximate frames-per-second that the application
     * is running at.
     */
    public function get fps () :Number
    {
        return _fps;
    }

    /**
     * Returns the current "time" value, in seconds. This should only be used for the purposes
     * of calculating time deltas, not absolute time, as the implementation may change.
     *
     * We use Date().time, instead of flash.utils.getTimer(), since the latter is susceptible to
     * Cheat Engine speed hacks:
     * http://www.gaminggutter.com/forum/f16/how-use-cheat-engine-speedhack-games-2785.html
     */
    public function getAppTime () :Number
    {
        return (new Date().time * 0.001); // convert millis to seconds
    }

    /**
     * Returns the FlashbangApp's ResourceManager
     */
    public function get rsrcs () :ResourceManager
    {
        return _rsrcs;
    }

    /**
     * Returns the FlashbangApp's AudioManager
     */
    public function get audio () :AudioManager
    {
        return _audio;
    }

    protected function update (e :Event) :void
    {
        // how much time has elapsed since last frame?
        var newTime :Number = getAppTime();
        var dt :Number = newTime - _lastTime;

        if (_minFrameRate > 0) {
            // Ensure that our time deltas don't get too large
            dt = Math.min(1 / _minFrameRate, dt);
        }

        _fps = 1 / dt;

        // update all our "updatables"
        for each (var updatable :Updatable in _updatables) {
            updatable.update(dt);
        }

        // update our viewports
        // we iterate the values Array so that we can safely removed destroyed Viewports
        for each (var viewport :Viewport in _viewports.values()) {
            if (!viewport.isDestroyed) {
                viewport.update(dt);
            }
            if (viewport.isDestroyed) {
                _viewports.remove(viewport.name);
                viewport.shutdown();
            }
        }

        // should the MainLoop be stopped?
        if (_shutdownPending) {
            _running = false;
            _events.freeAllHandlers();
            shutdownNow();
        }

        _lastTime = newTime;
    }

    protected function shutdownNow () :void
    {
        _viewports.forEach(function (name :String, viewport :Viewport) :void {
            viewport.shutdown();
        });
        _viewports = null;

        _hostSprite = null;
        _keyDispatcher = null;
        _updatables = null;

        _events.shutdown();
        _events = null;

        _audio.shutdown();
        _rsrcs.shutdown();

        didShutdown.dispatch();
    }

    protected function onKeyDown (e :KeyboardEvent) :void
    {
        _viewports.forEach(function (name :String, viewport :Viewport) :void {
            if (!viewport.isDestroyed) {
                viewport.onKeyDown(e);
            }
        });
    }

    protected function onKeyUp (e :KeyboardEvent) :void
    {
        _viewports.forEach(function (name :String, viewport :Viewport) :void {
            if (!viewport.isDestroyed) {
                viewport.onKeyUp(e);
            }
        });
    }

    protected var _rsrcs :ResourceManager;
    protected var _audio :AudioManager;

    protected var _minFrameRate :Number;
    protected var _hostSprite :Sprite;
    protected var _keyDispatcher :IEventDispatcher;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected var _running :Boolean;
    protected var _shutdownPending :Boolean;
    protected var _lastTime :Number;
    protected var _updatables :Array = [];
    protected var _viewports :Map = Maps.newMapOf(String); // <String, Viewport>
    protected var _fps :Number = 0;
}

}
