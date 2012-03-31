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

import flashbang.GameObject;
import flashbang.ObjectTask;

public class TimedTask
    implements ObjectTask
{
    public function TimedTask (time :Number)
    {
        _time = time;
    }

    public function update (dt :Number, obj :GameObject) :Boolean
    {
        _elapsedTime += dt;

        return (_elapsedTime >= _time);
    }

    public function clone () :ObjectTask
    {
        return new TimedTask(_time);
    }

    protected var _time :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
