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

public class PlayFramesTask extends MovieTask
{
    public function PlayFramesTask (startFrame :int, endFrame :int, totalTime :Number,
        easingFn :Function = null, movie :MovieClip = null)
    {
        super(totalTime, easingFn, movie);
        _startFrame = startFrame;
        _endFrame = endFrame;
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        super.update(dt, obj);

        if (_target == null) {
            _target = getTarget(obj);
        }

        var curFrame :int = interpolate(_startFrame, _endFrame);
        _target.gotoAndStop(curFrame);

        return _elapsedTime >= _totalTime;
    }

    override public function clone () :ObjectTask
    {
        return new PlayFramesTask(_startFrame, _endFrame, _totalTime, _easingFn, _movie);
    }

    protected var _startFrame :int;
    protected var _endFrame :int;
}

}
