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
// $Id: VariableTimedTask.as 6711 2008-11-18 00:31:58Z tim $

package flashbang.tasks {

import flashbang.ObjectMessage;
import flashbang.ObjectTask;
import flashbang.SimObject;
import flashbang.util.Rand;

public class VariableTimedTask
    implements ObjectTask
{
    public function VariableTimedTask (timeLo :Number, timeHi :Number, randStreamId :int)
    {
        _timeLo = timeLo;
        _timeHi = timeHi;
        _randStreamId = randStreamId;

        _time = Rand.nextNumberRange(timeLo, timeHi, randStreamId);
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        _elapsedTime += dt;

        return (_elapsedTime >= _time);
    }

    public function clone () :ObjectTask
    {
        return new VariableTimedTask(_timeLo, _timeHi, _randStreamId);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _timeLo :Number;
    protected var _timeHi :Number;
    protected var _randStreamId :int;
    protected var _time :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
