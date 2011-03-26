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

package com.threerings.flashbang {

import com.threerings.flashbang.tasks.ParallelTask;
import com.threerings.flashbang.tasks.TaskContainer;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class GameObject extends EventDispatcher
{
    /** Event dispatched when the GameObject is removed from the ObjectDB */
    public static const DESTROYED :String = "GameObject_Destroyed";

    /**
     * Returns the unique GameObjectRef that stores a reference to this GameObject.
     */
    public final function get ref () :GameObjectRef
    {
        return _ref;
    }

    /**
     * Returns the ObjectDB that this object is contained in.
     */
    public final function get db () :ObjectDB
    {
        return _parentDB;
    }

    /**
     * Returns true if the object is in an ObjectDB and is "live"
     * (not pending removal from the database)
     */
    public final function get isLiveObject () :Boolean
    {
        return (null != _ref && !_ref.isNull);
    }

    /**
     * Returns the name of this object.
     * Objects can have multiple names, via {@link #objectNames}
     * TODO: deprecate/remove this?
     */
    public function get objectName () :String
    {
        return null;
    }

    /**
     * Returns the names of this object. (Objects can have multiple names.)
     * Two objects in the same mode cannot have the same name.
     * Objects cannot change their names once added to a mode.
     * <code>
     * override public function get objectNames () :Array
     * {
     *     return [ "MyName", "MyOtherName" ].concat(super.objectNames);
     * }
     * </code>
     */
    public function get objectNames () :Array
    {
        return (this.objectName != null ? [ this.objectName ] : []);
    }

    /**
     * Override to return the groups that this object belongs to. E.g.:
     * <code>
     * override public function get objectGroups () :Array
     * {
     *     return [ "Foo", "Bar" ].concat(super.objectGroups);
     * }
     * </code>
     */
    public function get objectGroups () :Array
    {
        return [];
    }

    /** Removes the GameObject from its parent database. */
    public function destroySelf () :void
    {
        _parentDB.destroyObject(_ref);
    }

    /** Adds an unnamed task to this GameObject. */
    public function addTask (task :ObjectTask) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }

        _anonymousTasks.addTask(task);
    }

    /** Adds a named task to this GameObject. */
    public function addNamedTask (name :String, task :ObjectTask,
        removeExistingTasks :Boolean = false) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }

        if (null == name || name.length == 0) {
            throw new ArgumentError("name must be at least 1 character long");
        }

        var idx :int = _taskNames.indexOf(name);
        var namedTaskContainer :TaskContainer;
        if (idx == -1) {
            namedTaskContainer = new ParallelTask();
            _taskNames.push(name);
            _namedTasks.push(namedTaskContainer);
        } else {
            namedTaskContainer = _namedTasks[idx];
            if (removeExistingTasks) {
                namedTaskContainer.removeAllTasks();
            }
        }

        namedTaskContainer.addTask(task);
    }

    /** Removes all tasks from the GameObject. */
    public function removeAllTasks () :void
    {
        if (_updatingTasks) {
            // if we're updating tasks, invalidate all named task containers so that
            // they stop iterating their children
            for each (var taskContainer :TaskContainer in _namedTasks) {
                if (taskContainer != null) {// Could've been removed already
                    taskContainer.removeAllTasks();
                }
            }
        }

        _anonymousTasks.removeAllTasks();
        _namedTasks = [];
        _taskNames = [];
    }

    /** Removes all tasks with the given name from the GameObject. */
    public function removeNamedTasks (name :String) :void
    {
        if (null == name || name.length == 0) {
            throw new ArgumentError("name must be at least 1 character long");
        }

        var idx :int = _taskNames.indexOf(name);
        if (idx != -1) {
            // if we're updating tasks, invalidate this task container so that it stops iterating
            // its children.  Instead of removing it from the array immediately, null it out so
            // the order of iteration isn't disturbed.
            if (_updatingTasks) {
                _namedTasks[idx].removeAllTasks();
                _namedTasks[idx] = null;
                _taskNames[idx] = null;
                _collapseRemovedTasks = true;
            } else {
                _namedTasks.splice(idx, 1);
                _taskNames.splice(idx, 1);
            }
        }
    }

    /** Returns true if the GameObject has any tasks. */
    public function hasTasks () :Boolean
    {
        if (_anonymousTasks.hasTasks()) {
            return true;

        } else {
            return _namedTasks.some(function (container :ParallelTask, ..._) :Boolean {
                return container.hasTasks();
            });
        }
    }

    /** Returns true if the GameObject has any tasks with the given name. */
    public function hasTasksNamed (name :String) :Boolean
    {
        var idx :int = _taskNames.indexOf(name);
        return idx != -1 && ParallelTask(_namedTasks[idx]).hasTasks();
    }

    /**
     * Causes the lifecycle of the given GameObject to be managed by this object. Dependent
     * objects will be added to this object's ObjectDB, and will be destroyed when this
     * object is destroyed.
     */
    public function addDependentObject (obj :GameObject) :void
    {
        if (_parentDB != null) {
            manageDependentObject(obj, false, null, 0);
        } else {
            _pendingDependentObjects.push(new PendingDependentObject(obj, false, null, 0));
        }
    }

    /**
     * Causes the lifecycle of the given GameObject to be managed by this object. Dependent
     * objects will be added to this object's ObjectDB, and will be destroyed when this
     * object is destroyed.
     */
    public function addDependentSceneObject (obj :GameObject,
        displayParent :DisplayObjectContainer = null, displayIdx :int = -1) :void
    {
        if (_parentDB != null) {
            manageDependentObject(obj, true, displayParent, displayIdx);
        } else {
            _pendingDependentObjects.push(
                new PendingDependentObject(obj, true, displayParent, displayIdx));
        }
    }

    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     *
     * Listeners registered in this way will be automatically unregistered when the GameObject is
     * destroyed.
     */
    protected function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerListener(dispatcher, event, listener, useCapture, priority);
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    protected function unregisterListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false) :void
    {
        _events.unregisterListener(dispatcher, event, listener, useCapture);
    }

    /**
     * Registers a zero-arg callback function that should be called once when the event fires.
     *
     * Listeners registered in this way will be automatically unregistered when the GameObject is
     * destroyed.
     */
    protected function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
    }

    /**
     * Called once per update tick. (Subclasses can override this to do something useful.)
     *
     * @param dt the number of seconds that have elapsed since the last update.
     */
    protected function update (dt :Number) :void
    {
    }

    /**
     * Called immediately after the GameObject has been added to an ObjectDB.
     * (Subclasses can override this to do something useful.)
     */
    protected function addedToDB () :void
    {
    }

    /**
     * Called immediately after the GameObject has been removed from an AppMode.
     *
     * removedFromDB is not called when the GameObject's AppMode is removed from the mode stack.
     * For logic that must be run in this instance, see {@link #cleanup}.
     *
     * (Subclasses can override this to do something useful.)
     */
    protected function removedFromDB () :void
    {
    }

    /**
     * Called after the GameObject has been removed from the active AppMode, or if the
     * object's containing AppMode is removed from the mode stack.
     *
     * If the GameObject is removed from the active AppMode, {@link #removedFromDB}
     * will be called before destroyed.
     *
     * {@link #cleanup} should be used for logic that must be always be run when the GameObject is
     * destroyed (disconnecting event listeners, releasing resources, etc).
     *
     * (Subclasses can override this to do something useful.)
     */
    protected function cleanup () :void
    {
    }

    /**
     * Called to deliver a message to the object.
     * (Subclasses can override this to do something useful.)
     */
    protected function receiveMessage (msg :ObjectMessage) :void
    {

    }

    protected function manageDependentObject (obj :GameObject, isSceneObject :Boolean,
        displayParent :DisplayObjectContainer, displayIdx :int) :void
    {
        var ref :GameObjectRef;

        // the dependent object may already be in the DB
        if (obj._parentDB != null) {
            if (obj._parentDB == _parentDB) {
                ref = obj.ref;
            } else {
                throw new Error("Dependent object belongs to another ObjectDB");
            }

        } else {
            if (isSceneObject) {
                if (!(_parentDB is AppMode)) {
                    throw new Error("can't add SceneObject to non-AppMode ObjectDB");
                }
                ref = AppMode(_parentDB).addSceneObject(obj, displayParent, displayIdx);
            } else {
                ref = _parentDB.addObject(obj);
            }
        }

        _dependentObjectRefs.push(ref);
    }

    internal function addedToDBInternal () :void
    {
        for each (var dep :PendingDependentObject in _pendingDependentObjects) {
            manageDependentObject(dep.obj, dep.isSceneObject, dep.displayParent, dep.displayIdx);
        }
        _pendingDependentObjects = null;
        addedToDB();
    }

    internal function removedFromDBInternal () :void
    {
        for each (var ref :GameObjectRef in _dependentObjectRefs) {
            if (ref.isLive) {
                ref.object.destroySelf();
            }
        }
        removedFromDB();
        dispatchEvent(new Event(DESTROYED));
    }

    internal function cleanupInternal () :void
    {
        cleanup();
        _events.shutdown();
    }

    internal function updateInternal (dt :Number) :void
    {
        _updatingTasks = true;
        _anonymousTasks.update(dt, this);
        for each (var namedTask :ParallelTask in _namedTasks) {
            if (namedTask != null) {// Can be nulled out by being removed during the update
                namedTask.update(dt, this);
            }
        }
        if (_collapseRemovedTasks) {
           // Only iterate over the _namedTasks array if there are removed tasks in there
            _collapseRemovedTasks = false;
            for (var ii :int = 0; ii < _namedTasks.length; ii++) {
                if (_namedTasks[ii] === null) {
                    _namedTasks.splice(ii, 1);
                    _taskNames.splice(ii--, 1);
                }
            }
        }
        _updatingTasks = false;

        update(dt);
    }

    internal function receiveMessageInternal (msg :ObjectMessage) :void
    {
        _anonymousTasks.receiveMessage(msg);

        for each (var namedTask :ParallelTask in _namedTasks) {
            (namedTask as ParallelTask).receiveMessage(msg);
        }

        receiveMessage(msg);
    }

    protected var _anonymousTasks :ParallelTask = new ParallelTask();
    // The names of the tasks in _namedTasks in the same order as _namedTasks.  These arrays
    // function as a Map, but they're maintained as parallel arrays to speed up iterating over
    // the tasks in updateInternal while maintaining a deterministic task iteration order.
    protected var _taskNames :Array = [];//<String>
    protected var _namedTasks :Array = [];//<ParallelTask>
    protected var _updatingTasks :Boolean;
    // True if tasks were removed while an update was in progress
    protected var _collapseRemovedTasks :Boolean;

    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected var _dependentObjectRefs :Array = [];
    protected var _pendingDependentObjects :Array = [];

    // managed by ObjectDB/AppMode
    internal var _ref :GameObjectRef;
    internal var _parentDB :ObjectDB;
}

}

import com.threerings.flashbang.GameObject;
import flash.display.DisplayObjectContainer;

class PendingDependentObject
{
    public var obj :GameObject;
    public var isSceneObject :Boolean;
    public var displayParent :DisplayObjectContainer;
    public var displayIdx :int;

    public function PendingDependentObject (obj :GameObject, isSceneObject :Boolean,
        displayParent :DisplayObjectContainer, displayIdx :int)
    {
        this.obj = obj;
        this.isSceneObject = isSceneObject;
        this.displayParent = displayParent;
        this.displayIdx = displayIdx;
    }
}
