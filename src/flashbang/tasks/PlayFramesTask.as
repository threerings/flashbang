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
// Copyright 2008 Three Rings Design
//
// $Id: PlayFramesTask.as 9651 2009-07-20 22:41:38Z tim $

package flashbang.tasks {

import flashbang.*;
import flashbang.components.*;
import flashbang.objects.*;

import flash.display.MovieClip;

import mx.effects.easing.Linear;

public class PlayFramesTask
    implements ObjectTask
{
    public function PlayFramesTask (startFrame :int, endFrame :int, totalTime :Number,
        movie :MovieClip = null)
    {
        _startFrame = startFrame;
        _endFrame = endFrame;
        _totalTime = totalTime;
        _movie = movie;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var movieClip :MovieClip = _movie;

        // if we don't have a default movie,
        if (null == movieClip) {
            var sc :SceneComponent = obj as SceneComponent;
            movieClip = (null != sc ? sc.displayObject as MovieClip : null);

            if (null == movieClip) {
                throw new Error("Can only operate on SceneComponents with MovieClip " +
                    "DisplayObjects");
            }
        }

        _elapsedTime = Math.min(_elapsedTime + dt, _totalTime);
        var curFrame :int = Math.floor(mx.effects.easing.Linear.easeNone(
            _elapsedTime,
            _startFrame, _endFrame - _startFrame,
            _totalTime));
        _movie.gotoAndStop(curFrame);

        return _elapsedTime >= _totalTime;
    }

    public function clone () :ObjectTask
    {
        return new PlayFramesTask(_startFrame, _endFrame, _totalTime, _movie);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _startFrame :int;
    protected var _endFrame :int;
    protected var _totalTime :Number;
    protected var _movie :MovieClip;

    protected var _elapsedTime :Number = 0;
}

}
