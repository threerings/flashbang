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

import flashbang.GameObject;
import flashbang.ObjectTask;
import flashbang.components.SceneComponent;

public class GotoAndPlayUntilTask
    implements ObjectTask
{
    /**
     * Plays movie starting at frame until stopFrame. If the start frame isn't given, it defaults
     * to 1. If the stopFrame isn't given, it defaults to the movie's totalFrames. If movie isn't
     * given, it defaults to the displayObject of the SceneComponent this task is on.
     */
    public function GotoAndPlayUntilTask (frame :Object = null, stopFrame :Object = null,
        movie :MovieClip = null)
    {
        _startFrame = frame;
        _stopFrame = stopFrame;
        _movie = movie;
    }

    public function update (dt :Number, obj :GameObject) :Boolean
    {
        var movieClip :MovieClip = _movie;

        // if we don't have a default movie,
        if (null == movieClip) {
            var sc :SceneComponent = obj as SceneComponent;
            movieClip = (null != sc ? sc.displayObject as MovieClip : null);

            if (null == movieClip) {
                throw new Error("GotoAndPlayUntilTask can only operate on SceneComponents with " +
                    "MovieClip DisplayObjects");
            }
        }

        if (!_started) {
            if (_startFrame == null) {
                _startFrame = 1;
            }
            if (_stopFrame == null) {
                _stopFrame = movieClip.totalFrames;
            }
            movieClip.gotoAndPlay(_startFrame);
            _started = true;
        }

        if ((_stopFrame is String && movieClip.currentFrameLabel == String(_stopFrame)) ||
            (_stopFrame is int && movieClip.currentFrame == int(_stopFrame))) {
            movieClip.gotoAndStop(movieClip.currentFrame);
            return true;
        } else {
            return false;
        }
    }

    public function clone () :ObjectTask
    {
        return new GotoAndPlayUntilTask(_startFrame, _stopFrame, _movie);
    }

    protected var _startFrame :Object;
    protected var _stopFrame :Object;
    protected var _movie :MovieClip;

    protected var _started :Boolean;
}

}
