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

import com.threerings.flashbang.audio.AudioManager;
import com.threerings.flashbang.resource.ResourceManager;
import com.threerings.util.Preconditions;

public class Flashbang
{
    public static function app () :FlashbangApp
    {
        return _app;
    }

    public static function rsrcs () :ResourceManager
    {
        return _rsrcs;
    }

    public static function audio () :AudioManager
    {
        return _audio;
    }

    /**
     * @return the currently-active AppMode (or null if no AppMode is active)
     */
    public static function mode () :AppMode
    {
        return _ctxMode;
    }

    /**
     * @return the currently-active Viewport (the viewport that's attached to the current
     * AppMode), or null if no AppMode is active.
     */
    public static function viewport () :Viewport
    {
        return (_ctxMode != null ? _ctxMode.viewport : null);
    }

    /**
     * Sets the currently-active GameObjectDatabase and runs the supplied Runnable.
     * All calls to Flashbang.objectDatabase() from within the supplied Runnable will return
     * the supplied db.
     */
    public static function withinMode (mode :AppMode, fn :Function) :void
    {
        var cur :AppMode = _ctxMode;
        _ctxMode = mode;
        try {
            fn();
        } finally {
            _ctxMode = cur;
        }
    }

    internal static function registerApp (app :FlashbangApp) :void
    {
        Preconditions.checkState(_app == null, "A FlashbangApp has already been registered");
        _app = app;
    }

    protected static var _app :FlashbangApp;
    protected static var _rsrcs :ResourceManager = new ResourceManager();
    protected static var _audio :AudioManager;
    protected static var _ctxMode :AppMode;
}
}
