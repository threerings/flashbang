// Flashbang - a framework for creating Flash games
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
//
// Copyright 2009 Three Rings Design
//
// $Id$

package com.threerings.flashbang.debug {

import com.threerings.flashbang.objects.SceneObject;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class MouseLocView extends SceneObject
{
    public function MouseLocView (color :uint = 0x00ff00)
    {
        _tf = new TextField();
        _tf.autoSize = TextFieldAutoSize.LEFT;
        _tf.textColor = color;
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
