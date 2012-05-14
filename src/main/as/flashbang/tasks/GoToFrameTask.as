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

public class GoToFrameTask extends MovieTask
{
    public function GoToFrameTask (frame :Object, scene :String = null,
        gotoAndPlay :Boolean = true, movie :MovieClip = null)
    {
        super(0, null, movie);
        _frame = frame;
        _scene = scene;
        _gotoAndPlay = gotoAndPlay;
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        if (_gotoAndPlay) {
            getTarget(obj).gotoAndPlay(_frame, _scene);
        } else {
            getTarget(obj).gotoAndStop(_frame, _scene);
        }

        return true;
    }

    override public function clone () :ObjectTask
    {
        return new GoToFrameTask(_frame, _scene, _gotoAndPlay, _movie);
    }

    protected var _frame :Object;
    protected var _scene :String;
    protected var _gotoAndPlay :Boolean;
}

}
