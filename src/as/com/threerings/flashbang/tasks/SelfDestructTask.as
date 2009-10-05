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
// $Id$

package com.threerings.flashbang.tasks {

import com.threerings.flashbang.ObjectMessage;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.SimObject;

public class SelfDestructTask
    implements ObjectTask
{
    public function update (dt :Number, obj :SimObject) :Boolean
    {
        obj.destroySelf();
        return true;
    }

    public function clone () :ObjectTask
    {
        return new SelfDestructTask();
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }
}

}
