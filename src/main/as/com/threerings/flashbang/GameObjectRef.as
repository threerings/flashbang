//
// $Id$
//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2010 Three Rings Design, Inc., All Rights Reserved
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

package com.threerings.flashbang {

public class GameObjectRef
{
    public static const NULL :GameObjectRef = new GameObjectRef();

    public function destroyObject () :void
    {
        if (null != _obj) {
            _obj.destroySelf();
        }
    }

    public function get object () :GameObject
    {
        return _obj;
    }

    public function get isLive () :Boolean
    {
        return (null != _obj);
    }

    public function get isNull () :Boolean
    {
        return (null == _obj);
    }

    // managed by ObjectDB
    internal var _obj :GameObject;
    internal var _next :GameObjectRef;
    internal var _prev :GameObjectRef;
}
}
