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

package com.threerings.flashbang.tasks {

import flash.display.DisplayObject;

import com.threerings.flashbang.components.AlphaComponent;
import com.threerings.flashbang.components.BoundsComponent;
import com.threerings.flashbang.components.RotationComponent;
import com.threerings.flashbang.components.ScaleComponent;
import com.threerings.flashbang.components.SceneComponent;
import com.threerings.flashbang.components.VisibleComponent;

public class DisplayObjectWrapper
    implements AlphaComponent, BoundsComponent, ScaleComponent, SceneComponent, VisibleComponent,
               RotationComponent
{
    public static function create (disp :DisplayObject) :DisplayObjectWrapper
    {
        return (disp != null ? new DisplayObjectWrapper(disp) : NULL_WRAPPER);
    }

    public function get isNull () :Boolean
    {
        return (_disp == null);
    }

    public function get displayObject () :DisplayObject
    {
        return _disp;
    }

    public function get alpha () :Number
    {
        return _disp.alpha;
    }

    public function set alpha (val :Number) :void
    {
        _disp.alpha = val;
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

    public function get width () :Number
    {
        return _disp.width;
    }

    public function set width (val :Number) :void
    {
        _disp.width = val;
    }

    public function get height () :Number
    {
        return _disp.height;
    }

    public function set height (val :Number) :void
    {
        _disp.height = val;
    }

    public function get scaleX () :Number
    {
        return _disp.scaleX;
    }

    public function set scaleX (val :Number) :void
    {
        _disp.scaleX = val;
    }

    public function get scaleY () :Number
    {
        return _disp.scaleY;
    }

    public function set scaleY (val :Number) :void
    {
        _disp.scaleY = val;
    }

    public function get visible () :Boolean
    {
        return _disp.visible;
    }

    public function set visible (val :Boolean) :void
    {
        _disp.visible = val;
    }

    public function get rotation () :Number
    {
        return _disp.rotation;
    }

    public function set rotation (val :Number) :void
    {
        _disp.rotation = val;
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
