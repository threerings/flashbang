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
    public static function get app () :FlashbangApp
    {
        return _app;
    }

    public static function get rsrcs () :ResourceManager
    {
        return _app._rsrcs;
    }

    public static function get audio () :AudioManager
    {
        return _app._audio;
    }

    internal static function registerApp (app :FlashbangApp) :void
    {
        Preconditions.checkState(_app == null, "A FlashbangApp has already been registered");
        _app = app;
    }

    protected static var _app :FlashbangApp;
}
}
