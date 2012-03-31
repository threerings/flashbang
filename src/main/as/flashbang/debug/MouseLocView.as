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

package flashbang.debug {

import flash.display.DisplayObject;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import flashbang.objects.SceneObject;

public class MouseLocView extends SceneObject
{
    public function MouseLocView (color :uint = 0x0000ff, outlineColor :uint = 0xffffff)
    {
        _tf = new TextField();
        _tf.autoSize = TextFieldAutoSize.LEFT;
        _tf.textColor = color;
        _tf.filters = [ new GlowFilter(outlineColor, 1, 4, 4, 10) ];
    }

    override protected function update (dt :Number) :void
    {
        var loc :Point = _tf.localToGlobal(new Point(_tf.mouseX, _tf.mouseY));
        _tf.text = "Mouse: (" + int(loc.x) + ", " + int(loc.y) + ")";
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    protected var _tf :TextField;
}

}
