//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2011 Three Rings Design, Inc., All Rights Reserved
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

package com.threerings.flashbang {

import flash.display.DisplayObjectContainer;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

import com.threerings.util.EventHandlerManager;
import com.threerings.util.Preconditions;
import com.threerings.util.StringUtil;

import com.threerings.flashbang.tasks.ParallelTask;
import com.threerings.flashbang.tasks.TaskContainer;
import com.threerings.flashbang.util.SignalListenerManager;

public class GameObject extends EventDispatcher
{
    public const destroyed :Signal = new Signal();

    override public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "isLiveObject", "objectNames", "objectGroups" ]);
    }

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

        if (_lazyAnonymousTasks == null) {
            _lazyAnonymousTasks = new ParallelTask();
        }
        _lazyAnonymousTasks.addTask(task);
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

        var namedTask :TaskContainer = findNamedTask(name, true);
        if (removeExistingTasks) {
            namedTask.removeAllTasks();
        }
        namedTask.addTask(task);
    }

    /** Removes all tasks from the GameObject. */
    public function removeAllTasks () :void
    {
        if (_updatingTasks && _lazyNamedTasks != null) {
            // if we're updating tasks, invalidate all named task containers so that
            // they stop iterating their children
            for each (var taskContainer :TaskContainer in _lazyNamedTasks) {
                if (taskContainer != null) {// Could've been removed already
                    taskContainer.removeAllTasks();
                }
            }
        }

        if (_lazyAnonymousTasks != null) {
            _lazyAnonymousTasks.removeAllTasks();
        }
        _lazyNamedTasks = null;
    }

    /** Removes all tasks with the given name from the GameObject. */
    public function removeNamedTasks (name :String) :void
    {
        if (null == name || name.length == 0) {
            throw new ArgumentError("name must be at least 1 character long");
        }

        var namedTask :TaskContainer = findNamedTask(name);
        if (namedTask != null) {
            var idx :int = _lazyNamedTasks.indexOf(namedTask);
            // if we're updating tasks, invalidate this task container so that it stops iterating
            // its children.  Instead of removing it from the array immediately, null it out so
            // the order of iteration isn't disturbed.
            if (_updatingTasks) {
                namedTask.removeAllTasks();
                _lazyNamedTasks[idx] = null;
                _collapseRemovedTasks = true;
            } else {
                _lazyNamedTasks.splice(idx, 1);
                if (_lazyNamedTasks.length == 0) {
                    _lazyNamedTasks = null;
                }
            }
        }
    }

    /** Returns true if the GameObject has any tasks. */
    public function hasTasks () :Boolean
    {
        if (_lazyAnonymousTasks != null && _lazyAnonymousTasks.hasTasks()) {
            return true;

        } else if (_lazyNamedTasks != null) {
            return _lazyNamedTasks.some(function (container :ParallelTask, ..._) :Boolean {
                return container.hasTasks();
            });
        } else {
            return false;
        }
    }

    /** Returns true if the GameObject has any tasks with the given name. */
    public function hasTasksNamed (name :String) :Boolean
    {
        var namedTask :TaskContainer = findNamedTask(name);
        return namedTask != null && namedTask.hasTasks();
    }

    /**
     * Causes the lifecycle of the given GameObject to be managed by this object. Dependent
     * objects will be added to this object's ObjectDB, and will be destroyed when this
     * object is destroyed.
     */
    public function addDependentObject (obj :GameObject) :void
    {
        Preconditions.checkNotNull(obj);
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
        Preconditions.checkNotNull(obj);
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
    public function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerListener(dispatcher, event, listener, useCapture, priority);
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    public function unregisterListener (dispatcher :IEventDispatcher, event :String,
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
    public function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
    }

    /**
     * Adds the specified listener to the specified signal.
     *
     * Listeners registered in this way will be automatically unregistered when the GameObject is
     * destroyed.
     */
    public function addSignalListener (signal :ISignal, listener :Function) :void
    {
        _signals.addSignalListener(signal, listener);
    }

    /**
     * Removes the specified listener from the specified signal.
     */
    public function removeSignalListener (signal :ISignal, listener :Function) :void
    {
        _signals.removeSignalListener(signal, listener);
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

    protected function findNamedTask (name :String, create :Boolean = false) :ParallelTask
    {
        if (_lazyNamedTasks == null) {
            if (!create) {
                return null;
            }
            _lazyNamedTasks = [];
        }
        var tc :NamedParallelTask;
        for (var idx :int = _lazyNamedTasks.length - 1; idx >= 0; --idx) {
            if ((tc = NamedParallelTask(_lazyNamedTasks[idx])).name === name) {
                return tc;
            }
        }
        if (create) {
            _lazyNamedTasks.push(tc = new NamedParallelTask(name));
            return tc;
        }
        return null;
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
        this.destroyed.dispatch();
    }

    internal function cleanupInternal () :void
    {
        cleanup();
        _events.shutdown();
        _events = null;
        _signals.shutdown();
        _signals = null;
    }

    internal function updateInternal (dt :Number) :void
    {
        if (_updatingTasks = _lazyAnonymousTasks != null || _lazyNamedTasks != null) {
            if (_lazyAnonymousTasks != null) {
                _lazyAnonymousTasks.update(dt, this);
            }
            if (_lazyNamedTasks != null) {
                for each (var namedTask :ParallelTask in _lazyNamedTasks) {
                    if (namedTask != null) {// Can be nulled out by being removed during the update
                        namedTask.update(dt, this);
                    }
                }
            }
            if (_collapseRemovedTasks) {
               // Only iterate over the _lazyNamedTasks array if there are removed tasks in there
                _collapseRemovedTasks = false;
                for (var ii :int = 0; ii < _lazyNamedTasks.length; ii++) {
                    if (_lazyNamedTasks[ii] === null) {
                        _lazyNamedTasks.splice(ii, 1);
                    }
                }
                if (_lazyNamedTasks.length == 0) {
                    _lazyNamedTasks = null;
                }
            }
            _updatingTasks = false;
        }

        // Call update() if we're still alive (a task could've destroyed us)
        if (this.isLiveObject) {
            update(dt);
        }
    }

    // Note: this is null until needed. Subclassers beware
    protected var _lazyAnonymousTasks :ParallelTask;
    // This is really a linked map : String -> ParallelTask. We use an array though and take the
    // hit in lookup time to gain in iteration time. Also, it is null until needed. Subclassers
    // beware.
    protected var _lazyNamedTasks :Array = null;//<NamedParallelTask>
    protected var _updatingTasks :Boolean;
    // True if tasks were removed while an update was in progress
    protected var _collapseRemovedTasks :Boolean;

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _signals :SignalListenerManager = new SignalListenerManager();

    protected var _dependentObjectRefs :Array = [];
    protected var _pendingDependentObjects :Array = [];

    // managed by ObjectDB/AppMode
    internal var _ref :GameObjectRef;
    internal var _parentDB :ObjectDB;
}

}

import flash.display.DisplayObjectContainer;

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.tasks.ParallelTask;

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

class NamedParallelTask extends ParallelTask
{
    public var name :String;

    public function NamedParallelTask (name :String)
    {
        this.name = name;
    }
}
