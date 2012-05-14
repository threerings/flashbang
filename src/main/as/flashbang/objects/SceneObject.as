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

package flashbang.objects {

import flash.display.DisplayObject;

import com.threerings.geom.Vector2;

import flashbang.GameObject;
import flashbang.components.AlphaComponent;
import flashbang.components.BoundsComponent;
import flashbang.components.RotationComponent;
import flashbang.components.ScaleComponent;
import flashbang.components.DisplayComponent;
import flashbang.components.VisibleComponent;

public class SceneObject extends GameObject
    implements AlphaComponent, BoundsComponent, ScaleComponent, DisplayComponent, VisibleComponent,
               RotationComponent
{
    public function get display () :DisplayObject
    {
        throw new Error("abstract");
    }

    public function get alpha () :Number
    {
        return this.display.alpha;
    }

    public function set alpha (val :Number) :void
    {
        this.display.alpha = val;
    }

    public function get x () :Number
    {
        return this.display.x;
    }

    public function set x (val :Number) :void
    {
        this.display.x = val;
    }

    public function get y () :Number
    {
        return this.display.y;
    }

    public function set y (val :Number) :void
    {
        this.display.y = val;
    }

    public function get loc () :Vector2
    {
        return new Vector2(this.display.x, this.display.y);
    }

    public function set loc (loc :Vector2) :void
    {
        this.display.x = loc.x;
        this.display.y = loc.y;
    }

    public function get width () :Number
    {
        return this.display.width;
    }

    public function set width (val :Number) :void
    {
        this.display.width = val;
    }

    public function get height () :Number
    {
        return this.display.height;
    }

    public function set height (val :Number) :void
    {
        this.display.height = val;
    }

    public function get scaleX () :Number
    {
        return this.display.scaleX;
    }

    public function set scaleX (val :Number) :void
    {
        this.display.scaleX = val;
    }

    public function get scaleY () :Number
    {
        return this.display.scaleY;
    }

    public function set scaleY (val :Number) :void
    {
        this.display.scaleY = val;
    }

    public function get scale () :Vector2
    {
        return new Vector2(this.display.scaleX, this.display.scaleY);
    }

    public function set scale (val :Vector2) :void
    {
        this.display.scaleX = val.x;
        this.display.scaleY = val.y;
    }

    public function get visible () :Boolean
    {
        return this.display.visible;
    }

    public function set visible (val :Boolean) :void
    {
        this.display.visible = val;
    }

    public function get rotation () :Number
    {
        return this.display.rotation;
    }

    public function set rotation (val :Number) :void
    {
        this.display.rotation = val;
    }
}

}
