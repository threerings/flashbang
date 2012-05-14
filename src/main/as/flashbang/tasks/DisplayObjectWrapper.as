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

package flashbang.tasks {

import flash.display.DisplayObject;

import flashbang.components.DisplayComponent;
import flashbang.components.LocationComponent;

public class DisplayObjectWrapper
    implements DisplayComponent, LocationComponent
{
    public static function create (disp :DisplayObject) :DisplayObjectWrapper
    {
        return (disp != null ? new DisplayObjectWrapper(disp) : NULL_WRAPPER);
    }

    public function get isNull () :Boolean
    {
        return (_disp == null);
    }

    public function get display () :DisplayObject
    {
        return _disp;
    }

    public function get x () :Number
    {
        return _disp.x;
    }

    public function set x (val :Number) :void
    {
        _disp.x = val;
    }

    public function get y () :Number
    {
        return _disp.y;
    }

    public function set y (val :Number) :void
    {
        _disp.y = val;
    }

    /**
     * @private
     */
    public function DisplayObjectWrapper (disp :DisplayObject)
    {
        _disp = disp;
    }

    protected var _disp :DisplayObject;

    protected static const NULL_WRAPPER :DisplayObjectWrapper = new DisplayObjectWrapper(null);
}

}
