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
import flashbang.components.DisplayComponent;

public class GotoAndPlayUntilTask extends MovieTask
{
    /**
     * Plays movie starting at frame until stopFrame. If the start frame isn't given, it defaults
     * to 1. If the stopFrame isn't given, it defaults to the movie's totalFrames. If movie isn't
     * given, it defaults to the displayObject of the DisplayComponent this task is on.
     */
    public function GotoAndPlayUntilTask (frame :Object = null, stopFrame :Object = null,
        movie :MovieClip = null)
    {
        super(0, null, movie);
        _startFrame = frame;
        _stopFrame = stopFrame;
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        if (_target == null) {
            _target = getTarget(obj);

            if (_startFrame == null) {
                _startFrame = 1;
            }
            if (_stopFrame == null) {
                _stopFrame = _target.totalFrames;
            }
            _target.gotoAndPlay(_startFrame);
        }

        if ((_stopFrame is String && _target.currentFrameLabel == String(_stopFrame)) ||
            (_stopFrame is int && _target.currentFrame == int(_stopFrame))) {
            _target.gotoAndStop(_target.currentFrame);
            return true;
        } else {
            return false;
        }
    }

    override public function clone () :ObjectTask
    {
        return new GotoAndPlayUntilTask(_startFrame, _stopFrame, _movie);
    }

    protected var _startFrame :Object;
    protected var _stopFrame :Object;
}

}
