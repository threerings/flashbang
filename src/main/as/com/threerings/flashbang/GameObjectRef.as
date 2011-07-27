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

public class GameObjectRef
{
    public static function Null () :GameObjectRef
    {
        return NULL;
    }

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

    // We expose this through a function (above), rather than directly, because
    // member variable assignments of another class's static member don't work:
    // class Foo { public var ref :GameObjectRef = GameObjectRef.NULL; }
    // (ref will be initialized to null, rather than GameObjectRef.NULL).
    protected static const NULL :GameObjectRef = new GameObjectRef();
}

}
