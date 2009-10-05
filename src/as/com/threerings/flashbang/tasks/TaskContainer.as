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

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;

import com.threerings.flashbang.ObjectMessage;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.SimObject;

public class TaskContainer
    implements ObjectTask
{
    public static const TYPE_PARALLEL :uint = 0;
    public static const TYPE_SERIAL :uint = 1;
    public static const TYPE_REPEATING :uint = 2;

    public static const TYPE__LIMIT :uint = 3;

    public function TaskContainer (type :uint, subtasks :Array = null)
    {
        if (type >= TYPE__LIMIT) {
            throw new ArgumentError("invalid 'type' parameter");
        }

        _type = type;

        if (subtasks != null) {
            for each (var task :ObjectTask in subtasks) {
                addTask(task);
            }
        }
    }

    /** Adds a child task to the TaskContainer. */
    public function addTask (task :ObjectTask) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }

        _tasks.push(task);
        _completedTasks.push(null);
        _activeTaskCount += 1;
    }

    /** Removes all tasks from the TaskContainer. */
    public function removeAllTasks () :void
    {
        _invalidated = true;
        _tasks = new Array();
        _completedTasks = new Array();
        _activeTaskCount = 0;
    }

    /** Returns true if the TaskContainer has any child tasks. */
    public function hasTasks () :Boolean
    {
        return (_activeTaskCount > 0);
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var result :Boolean = applyFunction(
            function (task :ObjectTask) :Boolean {
                return task.update(dt, obj);
            });

        return result;
    }

    protected function cloneSubtasks () :Array
    {
        Assert.isTrue(_tasks.length == _completedTasks.length);

        var out :Array = new Array(_tasks.length);

        // clone each child task and put it in the cloned container
        var n :int = _tasks.length;
        for (var i :int = 0; i < n; ++i) {
            var task :ObjectTask =
                (null != _tasks[i] ? _tasks[i] as ObjectTask : _completedTasks[i] as ObjectTask);
            Assert.isNotNull(task);
            out[i] = task.clone();
        }

        return out;
    }

    /** Returns a clone of the TaskContainer. */
    public function clone () :ObjectTask
    {
        var clonedSubtasks :Array = cloneSubtasks();

        var theClone :TaskContainer = new TaskContainer(_type);
        theClone._tasks = clonedSubtasks;
        theClone._completedTasks = ArrayUtil.create(clonedSubtasks.length, null);
        theClone._activeTaskCount = clonedSubtasks.length;

        return theClone;
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return applyFunction(
            function (task :ObjectTask) :Boolean {
                return task.receiveMessage(msg);
            }
        );
    }

    /**
     * Helper function that applies the function f to each object in the container
     * (for parallel tasks) or the first object in the container (for serial and repeating tasks)
     * and returns true if there are no more active tasks in the container.
     * f must be of the form:
     * function f (task :ObjectTask) :Boolean
     * it must return true if the task is complete after f is applied.
     */
    protected function applyFunction (f :Function) :Boolean
    {
        _invalidated = false;

        var n :int = _tasks.length;
        for (var i :int = 0; i < n; ++i) {

            var task :ObjectTask = (_tasks[i] as ObjectTask);

            // we can have holes in the array
            if (null == task) {
                continue;
            }

            var complete :Boolean = f(task);

            if (_invalidated) {
                // The TaskContainer was destroyed by its containing
                // SimObject during task iteration. Stop processing immediately.
                return false;
            }

            if (!complete && TYPE_PARALLEL != _type) {
                // Serial and Repeating tasks proceed one task at a time
                break;

            } else if (complete) {
                // the task is complete - move it the completed tasks array
                _completedTasks[i] = _tasks[i];
                _tasks[i] = null;
                _activeTaskCount -= 1;
            }
        }

        // if this is a repeating task and all its tasks have been completed, start over again
        if (_type == TYPE_REPEATING && 0 == _activeTaskCount && _completedTasks.length > 0) {
            var completedTasks :Array = _completedTasks;

            _tasks = new Array();
            _completedTasks = new Array();

            for each (var completedTask :ObjectTask in completedTasks) {
                addTask(completedTask.clone());
            }
        }

        // once we have no more active tasks, we're complete
        return (0 == _activeTaskCount);
    }

    protected var _type :int;
    protected var _tasks :Array = new Array();
    protected var _completedTasks :Array = new Array();
    protected var _activeTaskCount :int;
    protected var _invalidated :Boolean;
}

}
