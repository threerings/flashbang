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

import com.threerings.util.Preconditions;

import flash.display.MovieClip;

import flashbang.GameObject;
import flashbang.components.DisplayComponent;

public class MovieTask extends InterpolatingTask
{
    public function MovieTask (time :Number, easing :Function, movie :MovieClip)
    {
        super(time, easing);
        _movie = movie;
    }

    protected function getTarget (obj :GameObject) :MovieClip
    {
        var movie :MovieClip = _movie;
        if (movie == null) {
            var dc :DisplayComponent = obj as DisplayComponent;
            Preconditions.checkState(dc != null, "obj does not implement DisplayComponent");
            movie = (dc.display as MovieClip);
            Preconditions.checkState(movie != null, "obj does not contain a MovieClip");
        }
        return movie;
    }

    protected var _movie :MovieClip;

    protected var _target :MovieClip;
}
}
