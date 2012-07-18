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

package flashbang {

import com.threerings.util.Preconditions;
import com.threerings.util.StringUtil;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flashbang.components.DisplayComponent;
import flashbang.tasks.ParallelTask;
import flashbang.tasks.TaskContainer;
import flashbang.util.SignalAndEventRegistrations;

import org.osflash.signals.Signal;

public class GameObject
{
    public const destroyed :Signal = new Signal();

    public function toString () :String
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
     * Returns the AppMode that this object is contained in.
     */
    public final function get mode () :AppMode
    {
        return _mode;
    }

    /**
     * Returns the Viewport that this object is a part of
     */
    public final function get viewport () :Viewport
    {
        return _mode.viewport;
    }

    /**
     * Returns true if the object is in an AppMode and is "live"
     * (not pending removal from the database)
     */
    public final function get isLiveObject () :Boolean
    {
        return (null != _ref && !_ref.isNull);
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
        return [];
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

    /**
     * Removes the GameObject from its parent database.
     * If a subclass needs to cleanup after itself after being destroyed, it should do
     * so either in removedFromDb or cleanup.
     */
    public final function destroySelf () :void
    {
        _mode.destroyObject(_ref);
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
     * objects will be added to this object's AppMode, and will be destroyed when this
     * object is destroyed.
     */
    public function addDependentObject (obj :GameObject,
        displayParent :DisplayObjectContainer = null, displayIdx :int = -1) :void
    {
        Preconditions.checkNotNull(obj);

        // Was a displayParent specified?
        // We attach the object's displayObject to its displayParent immediately,
        // even if we're not yet live, to ensure that the displayList is ordered
        // as the client code intends.
        if (displayParent != null) {
            obj.attachToDisplayList(displayParent, displayIdx);
        }

        if (_mode != null) {
            manageDependentObject(obj);
        } else {
            _pendingDependentObjects.push(obj);
        }
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
     * Called immediately after the GameObject has been added to an AppMode.
     * (Subclasses can override this to do something useful.)
     */
    protected function addedToMode () :void
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
    protected function removedFromMode () :void
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

    protected function manageDependentObject (obj :GameObject) :void
    {
        var ref :GameObjectRef;

        // the dependent object may already be in the DB
        if (obj._mode != null) {
            Preconditions.checkState(obj._mode == _mode,
                "Dependent object belongs to another AppMode");
            ref = obj.ref;

        } else {
            ref = _mode.addObject(obj);
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

    internal function addedToModeInternal () :void
    {
        for each (var obj :GameObject in _pendingDependentObjects) {
            manageDependentObject(obj);
        }
        _pendingDependentObjects = null;
        addedToMode();
    }

    internal function removedFromModeInternal () :void
    {
        for each (var ref :GameObjectRef in _dependentObjectRefs) {
            if (ref.isLive) {
                ref.object.destroySelf();
            }
        }
        removedFromMode();
        this.destroyed.dispatch();
    }

    internal function cleanupInternal () :void
    {
        cleanup();
        _regs.cancel();
        _regs = null;
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

    internal function attachToDisplayList (displayParent :DisplayObjectContainer,
        displayIdx :int) :void
    {
        Preconditions.checkState(this is DisplayComponent, "obj must implement DisplayComponent");

        // Attach the object to a display parent.
        // (This is purely a convenience - the client is free to do the attaching themselves)
        var disp :DisplayObject = (this as DisplayComponent).display;
        Preconditions.checkState(null != disp,
            "obj must return a non-null displayObject to be attached to a display parent");

        if (displayIdx < 0 || displayIdx >= displayParent.numChildren) {
            displayParent.addChild(disp);
        } else {
            displayParent.addChildAt(disp, displayIdx);
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

    protected var _regs :SignalAndEventRegistrations = new SignalAndEventRegistrations();

    protected var _dependentObjectRefs :Array = [];
    protected var _pendingDependentObjects :Array = [];

    // managed by AppMode
    internal var _ref :GameObjectRef;
    internal var _mode :AppMode;
}

}

import flashbang.tasks.ParallelTask;

class NamedParallelTask extends ParallelTask
{
    public var name :String;

    public function NamedParallelTask (name :String)
    {
        this.name = name;
    }
}
