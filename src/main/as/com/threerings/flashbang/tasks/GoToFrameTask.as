//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2011 Three Rings Design, Inc., All Rights Reserved
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

package com.threerings.flashbang.tasks {

import flash.display.MovieClip;

import com.threerings.flashbang.*;
import com.threerings.flashbang.components.*;
import com.threerings.flashbang.objects.*;

public class GoToFrameTask
    implements ObjectTask
{
    public function GoToFrameTask (frame :Object, scene :String = null,
        gotoAndPlay :Boolean = true, movie :MovieClip = null)
    {
        _frame = frame;
        _scene = scene;
        _gotoAndPlay = gotoAndPlay;
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
                throw new Error("GoToFrameTask can only operate on SceneComponents with " +
                    "MovieClip DisplayObjects");
            }
        }

        if (_gotoAndPlay) {
            movieClip.gotoAndPlay(_frame, _scene);
        } else {
            movieClip.gotoAndStop(_frame, _scene);
        }

        return true;
    }

    public function clone () :ObjectTask
    {
        return new GoToFrameTask(_frame, _scene, _gotoAndPlay, _movie);
    }

    protected var _frame :Object;
    protected var _scene :String;
    protected var _gotoAndPlay :Boolean;
    protected var _movie :MovieClip;
}

}
