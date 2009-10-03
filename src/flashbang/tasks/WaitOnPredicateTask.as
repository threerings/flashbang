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

package flashbang.tasks {

import flashbang.*;
import flashbang.components.*;
import flashbang.objects.*;

import flash.display.MovieClip;

public class WaitOnPredicateTask implements ObjectTask
{
    public function WaitOnPredicateTask (pred :Function)
    {
        _pred = pred;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        return _pred();
    }

    public function clone () :ObjectTask
    {
        return new WaitOnPredicateTask(_pred);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _pred :Function;
}

}
