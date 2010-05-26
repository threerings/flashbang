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
import com.threerings.util.Framerate;

import flash.display.DisplayObject;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class FramerateView extends SceneObject
{
    public function FramerateView (normalColor :uint = 0x0000ff, slowColor :uint = 0xff0000,
        outlineColor :uint = 0xffffff, slowFps :Number = 15)
    {
        _normalColor = normalColor;
        _slowColor = slowColor;
        _slowFps = slowFps;

        _tf = new TextField();
        _tf.autoSize = TextFieldAutoSize.LEFT;
        _tf.filters = [ new GlowFilter(outlineColor, 1, 3, 3, 10) ];

        _framerate = new Framerate(_tf, 1000);
    }

    override protected function destroyed () :void
    {
        _framerate.shutdown();
        super.destroyed();
    }

    override protected function update (dt :Number) :void
    {
        var text :String =
            "" + Math.round(_framerate.fpsCur) +
            " (Avg=" + Math.round(_framerate.fpsMean) +
            " Min=" + Math.round(_framerate.fpsMin) +
            " Max=" + Math.round(_framerate.fpsMax) + ")";

        _tf.text = text;
        _tf.textColor = (_framerate.fpsMean > _slowFps ? _normalColor : _slowColor);
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    protected var _normalColor :uint;
    protected var _slowColor :uint;
    protected var _slowFps :Number;

    protected var _tf :TextField;
    protected var _framerate :Framerate;
}

}
