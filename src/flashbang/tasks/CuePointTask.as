// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
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
// $Id: CuePointTask.as 9696 2009-08-11 20:28:14Z tim $

package com.whirled.contrib.simplegame.tasks {

import com.whirled.contrib.simplegame.CuePoint;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.SimObject;

public class CuePointTask
    implements ObjectTask
{
    public static function CueAfter (cueName :String, task :ObjectTask) :ObjectTask
    {
        return new SerialTask(task, new CuePointTask(cueName));
    }

    public static function WaitForCue (cueName :String, task :ObjectTask) :ObjectTask
    {
        return new SerialTask(new CuePointTask(cueName), task);
    }

    public function CuePointTask (cueName :String)
    {
        _cuePoint = CuePoint.create(cueName);
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        if (!_hasCued) {
            _cuePoint.cue();
            _hasCued = true;
        }

        return _cuePoint.canPass;
    }

    public function clone () :ObjectTask
    {
        return new CuePointTask(_cuePoint.name);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _cuePoint :CuePoint;
    protected var _hasCued :Boolean;
}

}
