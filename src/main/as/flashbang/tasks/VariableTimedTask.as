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
import flashbang.util.Rand;

public class VariableTimedTask
    implements ObjectTask
{
    public function VariableTimedTask (timeLo :Number, timeHi :Number,
        randStreamId :uint = Rand.STREAM_UNSPECIFIED)
    {
        _timeLo = timeLo;
        _timeHi = timeHi;
        _randStreamId = randStreamId;

        _time = Rand.nextNumberInRange(timeLo, timeHi, randStreamId);
    }

    public function update (dt :Number, obj :GameObject) :Boolean
    {
        _elapsedTime += dt;

        return (_elapsedTime >= _time);
    }

    public function clone () :ObjectTask
    {
        return new VariableTimedTask(_timeLo, _timeHi, _randStreamId);
    }

    protected var _timeLo :Number;
    protected var _timeHi :Number;
    protected var _randStreamId :uint;
    protected var _time :Number = 0;
    protected var _elapsedTime :Number = 0;
}

}
