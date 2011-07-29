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

import com.threerings.display.DisplayUtil;
import com.threerings.flashbang.components.SceneComponent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.KeyboardEvent;

public class AppMode extends ObjectDB
{
    public function AppMode ()
    {
        _modeSprite.mouseEnabled = false;
        _modeSprite.mouseChildren = false;
    }

    public final function get modeSprite () :Sprite
    {
        return _modeSprite;
    }

    /** Returns the Context associated with this AppMode. */
    public final function get ctx () :FlashbangContext
    {
        return _ctx;
    }

    /** Returns the Viewport that this AppMode lives in */
    public final function get viewport () :Viewport
    {
        return _viewport;
    }

    /**
     * A convenience function that adds the given SceneObject to the mode and attaches its
     * DisplayObject to the display list.
     *
     * @param displayParent the parent to attach the DisplayObject to, or null to attach
     * directly to the AppMode's modeSprite.
     *
     * @param displayIdx the index at which the object will be added to displayParent,
     * or -1 to add to the end of displayParent
     */
    public function addSceneObject (obj :GameObject, displayParent :DisplayObjectContainer = null,
        displayIdx :int = -1) :GameObjectRef
    {
        if (!(obj is SceneComponent)) {
            throw new Error("obj must implement SceneComponent");
        }

        // Attach the object to a display parent.
        // (This is purely a convenience - the client is free to do the attaching themselves)
        var disp :DisplayObject = (obj as SceneComponent).displayObject;
        if (null == disp) {
            throw new Error("obj must return a non-null displayObject to be attached " +
                            "to a display parent");
        }

        if (displayParent == null) {
            displayParent = _modeSprite;
        }

        if (displayIdx < 0 || displayIdx >= displayParent.numChildren) {
            displayParent.addChild(disp);
        } else {
            displayParent.addChildAt(disp, displayIdx);
        }

        return addObject(obj);
    }

    override public function destroyObject (ref :GameObjectRef) :void
    {
        if (null != ref && ref.object is SceneComponent) {
            // if the object is attached to a DisplayObject, and if that
            // DisplayObject is in a display list, remove it from the display list
            // so that it will no longer be drawn to the screen
            var disp :DisplayObject = SceneComponent(ref.object).displayObject;
            if (null != disp) {
                DisplayUtil.detach(disp);
            }
        }

        super.destroyObject(ref);
    }

    /** Called when a key is pressed while this mode is active */
    public function onKeyDown (keyEvent :KeyboardEvent) :void
    {
        dispatchEvent(keyEvent);
    }

    /** Called when a key is released while this mode is active */
    public function onKeyUp (keyEvent :KeyboardEvent) :void
    {
        dispatchEvent(keyEvent);
    }

    /** Called when the mode is added to the mode stack */
    protected function setup () :void
    {
    }

    /** Called when the mode is removed from the mode stack */
    protected function destroy () :void
    {
    }

    /** Called when the mode becomes active on the mode stack */
    protected function enter () :void
    {
    }

    /** Called when the mode becomes inactive on the mode stack */
    protected function exit () :void
    {
    }

    internal function setupInternal (ctx :FlashbangContext, viewport :Viewport) :void
    {
        _ctx = ctx;
        _viewport = viewport;
        setup();
    }

    internal function destroyInternal () :void
    {
        destroy();
        shutdown();
        _ctx = null;
        _viewport = null;
    }

    internal function enterInternal () :void
    {
        _modeSprite.mouseEnabled = true;
        _modeSprite.mouseChildren = true;

        enter();
    }

    internal function exitInternal () :void
    {
        _modeSprite.mouseEnabled = false;
        _modeSprite.mouseChildren = false;

        exit();
    }

    protected var _modeSprite :Sprite = new Sprite();
    protected var _ctx :FlashbangContext;
    protected var _viewport :Viewport;
}

}
