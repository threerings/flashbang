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

import flash.display.MovieClip;

import flashbang.*;
import flashbang.components.*;
import flashbang.objects.*;

public class WaitForFrameTask extends MovieTask
{
    public function WaitForFrameTask (frameLabelOrNumber :*, movie :MovieClip = null)
    {
        super(0, null, movie);

        if (frameLabelOrNumber is int) {
            _frameNumber = frameLabelOrNumber as int;
        } else if (frameLabelOrNumber is String) {
            _frameLabel = frameLabelOrNumber as String;
        } else {
            throw new Error("frameLabelOrNumber must be a String or an int");
        }
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        if (_target == null) {
            _target = getTarget(obj);
        }

        return (null != _frameLabel ? _target.currentLabel == _frameLabel :
                                      _target.currentFrame == _frameNumber);
    }

    override public function clone () :ObjectTask
    {
        return new WaitForFrameTask(null != _frameLabel ? _frameLabel : _frameNumber, _movie);
    }

    protected var _frameLabel :String;
    protected var _frameNumber :int;

}

}
