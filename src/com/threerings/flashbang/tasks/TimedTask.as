//
// $Id$
//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2010 Three Rings Design, Inc., All Rights Reserved
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

package com.threerings.flashbang.tasks {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.ObjectMessage;

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

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _time :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
