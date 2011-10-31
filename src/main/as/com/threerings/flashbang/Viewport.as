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

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;

import org.osflash.signals.Signal;

import com.threerings.util.Assert;

import com.threerings.display.DisplayUtil;

import com.threerings.flashbang.audio.*;
import com.threerings.flashbang.resource.*;

/**
 * Viewport contains the AppMode stack. The topmost AppMode in the stack gets ticked on every
 * update. Don't create a Viewport directly - call FlashbangApp.createViewport.
 */
public class Viewport
{
    public static const DEFAULT :String = "DefaultViewport";

    public const topModeChanged :Signal = new Signal();
    public const destroyed :Signal = new Signal();

    public function Viewport (app :FlashbangApp, name :String, parentSprite :Sprite)
    {
        _app = app;
        _name = name;
        parentSprite.addChild(_topSprite);
    }

    public final function get name () :String
    {
        return _name;
    }

    /**
     * Causes the Viewport to be destroyed.
     * (This won't happen immediately - it'll happen at the end of the current update loop)
     */
    public function destroy () :void
    {
        _destroyed = true;
    }

    /**
     * Returns the top mode on the mode stack, or null
     * if the stack is empty.
     */
    public function get topMode () :AppMode
    {
        if (_modeStack.length == 0) {
            return null;
        } else {
            return ((_modeStack[_modeStack.length - 1]) as AppMode);
        }
    }

    /**
     * Applies the specify mode transition to the mode stack.
     * (Mode changes take effect between game updates.)
     */
    public function doModeTransition (type :ModeTransition, mode :AppMode = null, index :int = 0)
        :void
    {
        if (type.requiresMode && mode == null) {
            throw new Error("mode must be non-null for " + type);
        }

        var transition :PendingTransition = new PendingTransition();
        transition.type = type;
        transition.mode = mode;
        transition.index = index;
        _pendingModeTransitionQueue.push(transition);
    }

    /**
     * Inserts a mode into the stack at the specified index. All modes
     * at and above the specified index will move up in the stack.
     * (Mode changes take effect between game updates.)
     *
     * @param mode the AppMode to add
     * @param index the stack position to add the mode at.
     * You can use a negative integer to specify a position relative
     * to the top of the stack (for example, -1 is the top of the stack).
     */
    public function insertMode (mode :AppMode, index :int) :void
    {
        doModeTransition(ModeTransition.INSERT, mode, index);
    }

    /**
     * Removes a mode from the stack at the specified index. All
     * modes above the specified index will move down in the stack.
     * (Mode changes take effect between game updates.)
     *
     * @param index the stack position to add the mode at.
     * You can use a negative integer to specify a position relative
     * to the top of the stack (for example, -1 is the top of the stack).
     */
    public function removeMode (index :int) :void
    {
        doModeTransition(ModeTransition.REMOVE, null, index);
    }

    /**
     * Pops the top mode from the stack, if the modestack is not empty, and pushes
     * a new mode in its place.
     * (Mode changes take effect between game updates.)
     */
    public function changeMode (mode :AppMode) :void
    {
        doModeTransition(ModeTransition.CHANGE, mode);
    }

    /**
     * Pushes a mode to the mode stack.
     * (Mode changes take effect between game updates.)
     */
    public function pushMode (mode :AppMode) :void
    {
        doModeTransition(ModeTransition.PUSH, mode);
    }

    /**
     * Pops the top mode from the mode stack.
     * (Mode changes take effect between game updates.)
     */
    public function popMode () :void
    {
        doModeTransition(ModeTransition.REMOVE, null, -1);
    }

    /**
     * Pops all modes from the mode stack.
     * Mode changes take effect before game updates.
     */
    public function popAllModes () :void
    {
        doModeTransition(ModeTransition.UNWIND);
    }

    /**
     * Pops modes from the stack until the specified mode is reached.
     * If the specified mode is not reached, it will be pushed to the top
     * of the mode stack.
     * Mode changes take effect before game updates.
     */
    public function unwindToMode (mode :AppMode) :void
    {
        doModeTransition(ModeTransition.UNWIND, mode);
    }

    public function update (dt :Number) :void
    {
        handleModeTransitions();

        // update the top mode
        var theTopMode :AppMode = this.topMode;
        if (null != theTopMode) {
            theTopMode.update(dt);
        }
    }

    public function onKeyDown (e :KeyboardEvent) :void
    {
        var topMode :AppMode = this.topMode;
        if (null != topMode) {
            topMode.onKeyDown(e);
        }
    }

    public function onKeyUp (e :KeyboardEvent) :void
    {
        var topMode :AppMode = this.topMode;
        if (null != topMode) {
            topMode.onKeyUp(e);
        }
    }

    internal function handleModeTransitions () :void
    {
        if (_pendingModeTransitionQueue.length <= 0) {
            return;
        }

        var initialTopMode :AppMode = this.topMode;
        var self :Viewport = this;

        function doPushMode (newMode :AppMode) :void {
            if (null == newMode) {
                throw new Error("Can't push a null mode to the mode stack");
            }

            _modeStack.push(newMode);
            _topSprite.addChild(newMode.modeSprite);

            newMode.setupInternal(_app, self);
        }

        function doInsertMode (newMode :AppMode, index :int) :void {
            if (null == newMode) {
                throw new Error("Can't insert a null mode in the mode stack");
            }

            if (index < 0) {
                index = _modeStack.length + index;
            }
            index = Math.max(index, 0);
            index = Math.min(index, _modeStack.length);

            _modeStack.splice(index, 0, newMode);
            _topSprite.addChildAt(newMode.modeSprite, index);

            newMode.setupInternal(_app, self);
        }

        function doRemoveMode (index :int) :void {
            if (_modeStack.length == 0) {
                throw new Error("Can't remove a mode from an empty stack");
            }

            if (index < 0) {
                index = _modeStack.length + index;
            }

            index = Math.max(index, 0);
            index = Math.min(index, _modeStack.length - 1);

            // if the top mode is removed, make sure it's exited first
            var mode :AppMode = _modeStack[index];
            if (mode == initialTopMode) {
                initialTopMode.exitInternal();
                initialTopMode = null;
            }

            mode.destroyInternal();

            _modeStack.splice(index, 1);
            _topSprite.removeChild(mode.modeSprite);
        }

        // create a new _pendingModeTransitionQueue right now
        // so that we can properly handle mode transition requests
        // that occur during the processing of the current queue
        var transitionQueue :Array = _pendingModeTransitionQueue;
        _pendingModeTransitionQueue = [];

        for each (var transition :PendingTransition in transitionQueue) {
            var mode :AppMode = transition.mode;
            switch (transition.type) {
            case ModeTransition.PUSH:
                doPushMode(mode);
                break;

            case ModeTransition.INSERT:
                doInsertMode(mode, transition.index);
                break;

            case ModeTransition.REMOVE:
                doRemoveMode(transition.index);
                break;

            case ModeTransition.CHANGE:
                // a pop followed by a push
                if (null != this.topMode) {
                    doRemoveMode(-1);
                }
                doPushMode(mode);
                break;

            case ModeTransition.UNWIND:
                // pop modes until we find the one we're looking for
                while (_modeStack.length > 0 && this.topMode != mode) {
                    doRemoveMode(-1);
                }

                Assert.isTrue(this.topMode == mode || _modeStack.length == 0);

                if (_modeStack.length == 0 && null != mode) {
                    doPushMode(mode);
                }
                break;
            }
        }

        var topMode :AppMode = this.topMode;
        if (topMode != initialTopMode) {
            if (null != initialTopMode) {
                initialTopMode.exitInternal();
            }

            if (null != topMode) {
                topMode.enterInternal();
            }
            topModeChanged.dispatch();
        }
    }

    protected function clearModeStackNow () :void
    {
        _pendingModeTransitionQueue = [];
        if (_modeStack.length > 0) {
            popAllModes();
            handleModeTransitions();
        }
    }

    internal function get isDestroyed () :Boolean
    {
        return _destroyed;
    }

    internal function shutdown () :void
    {
        clearModeStackNow();
        _modeStack = null;
        _pendingModeTransitionQueue = null;
        DisplayUtil.detach(_topSprite);
        _topSprite = null;
        this.destroyed.dispatch();
    }


    protected var _app :FlashbangApp;
    protected var _name :String;
    protected var _topSprite :Sprite = new Sprite();
    protected var _modeStack :Array = [];
    protected var _pendingModeTransitionQueue :Array = [];
    protected var _destroyed :Boolean;
}
}

import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.ModeTransition;

class PendingTransition
{
    public var mode :AppMode;
    public var type :ModeTransition;
    public var index :int;
}
