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

import com.threerings.util.Arrays;
import com.threerings.util.Assert;

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectMessage;
import com.threerings.flashbang.ObjectTask;

public class TaskContainer
    implements ObjectTask
{
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
    public function addTask (task :ObjectTask, ...moreTasks) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }

        _tasks.push(task);
        _completedTasks.push(null);
        _activeTaskCount += 1;

        for each (var task :ObjectTask in moreTasks) {
            addTask(task);
        }
    }

    /** Removes all tasks from the TaskContainer. */
    public function removeAllTasks () :void
    {
        _invalidated = true;
        _tasks = [];
        _completedTasks = [];
        _activeTaskCount = 0;
    }

    /** Returns true if the TaskContainer has any child tasks. */
    public function hasTasks () :Boolean
    {
        return (_activeTaskCount > 0);
    }

    public function update (dt :Number, obj :GameObject) :Boolean
    {
        // Store the object and delta on the container to avoid the expense of creating a closure
        // in an oft-called method
        _updateDelta = dt;
        _updateObj = obj;
        return applyFunction(updateTask);
    }

    protected function updateTask(task :ObjectTask) :Boolean
    {
        return task.update(_updateDelta, _updateObj);
    }

    /** Returns a clone of the TaskContainer. */
    public function clone () :ObjectTask
    {
        var clonedSubtasks :Array = cloneSubtasks();

        var theClone :TaskContainer = new TaskContainer(_type);
        theClone._tasks = clonedSubtasks;
        theClone._completedTasks = Arrays.create(clonedSubtasks.length, null);
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

    protected function cloneSubtasks () :Array
    {
        Assert.isTrue(_tasks.length == _completedTasks.length);

        var out :Array = new Array(_tasks.length);

        // clone each child task and put it in the cloned container
        var n :int = _tasks.length;
        for (var ii :int = 0; ii < n; ++ii) {
            var task :ObjectTask =
                (null != _tasks[ii] ? _tasks[ii] as ObjectTask : _completedTasks[ii] as ObjectTask);
            Assert.isNotNull(task);
            out[ii] = task.clone();
        }

        return out;
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
        for (var ii :int = 0; ii < n; ++ii) {

            var task :ObjectTask = (_tasks[ii] as ObjectTask);

            // we can have holes in the array
            if (null == task) {
                continue;
            }

            var complete :Boolean = f(task);

            if (_invalidated) {
                // The TaskContainer was destroyed by its containing
                // GameObject during task iteration. Stop processing immediately.
                return false;
            }

            if (!complete && TYPE_PARALLEL != _type) {
                // Serial and Repeating tasks proceed one task at a time
                break;

            } else if (complete) {
                // the task is complete - move it the completed tasks array
                _completedTasks[ii] = _tasks[ii];
                _tasks[ii] = null;
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

    // The most recent delta and object values from update.  Only valid while update is being
    // called
    protected var _updateDelta :Number;
    protected var _updateObj :GameObject;

    protected var _type :int;
    protected var _tasks :Array = new Array();
    protected var _completedTasks :Array = new Array();
    protected var _activeTaskCount :int;
    protected var _invalidated :Boolean;

    protected static const TYPE_PARALLEL :uint = 0;
    protected static const TYPE_SERIAL :uint = 1;
    protected static const TYPE_REPEATING :uint = 2;
    protected static const TYPE__LIMIT :uint = 3;
}

}
