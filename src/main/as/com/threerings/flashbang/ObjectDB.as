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

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import com.threerings.util.Arrays;
import com.threerings.util.Assert;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.threerings.flashbang.tasks.*;

public class ObjectDB extends EventDispatcher
    implements Updatable
{
    /**
     * A convenience function that converts an Array of GameObjectRefs into an array of GameObjects.
     * The resultant Array will not have any null objects, so it may be smaller than the Array
     * that was passed in.
     */
    public static function getObjects (objectRefs :Array) :Array
    {
        // Array.map would be appropriate here, except that the resultant
        // Array might contain fewer entries than the source.

        var objs :Array = [];
        for each (var ref :GameObjectRef in objectRefs) {
            if (!ref.isNull) {
                objs.push(ref.object);
            }
        }

        return objs;
    }

    /**
     * Adds a GameObject to the ObjectDB. The GameObject must not be owned by another ObjectDB.
     */
    public function addObject (obj :GameObject) :GameObjectRef
    {
        if (null == obj || null != obj._ref) {
            throw new ArgumentError("obj must be non-null, and must never have belonged to " +
                                    "another ObjectDB");
        }

        // create a new GameObjectRef
        var ref :GameObjectRef = new GameObjectRef();
        ref._obj = obj;

        // add the ref to the list
        var oldListHead :GameObjectRef = _listHead;
        _listHead = ref;

        if (null != oldListHead) {
            ref._next = oldListHead;
            oldListHead._prev = ref;
        }

        // initialize object
        obj._parentDB = this;
        obj._ref = ref;

        // does the object have names?
        for each (var objectName :String in obj.objectNames) {
            var oldObj :* = _namedObjects.put(objectName, obj);
            if (undefined !== oldObj) {
                throw new Error("two objects with the same name ('" + objectName + "') " +
                    "added to the ObjectDB");
            }
        }

        // add this object to the groups it belongs to
        for each (var groupName :String in obj.objectGroups) {
            var groupArray :Array = (_groupedObjects.get(groupName) as Array);
            if (null == groupArray) {
                groupArray = [];
                _groupedObjects.put(groupName, groupArray);
            }

            groupArray.push(ref);
        }

        obj.addedToDBInternal();

        ++_objectCount;

        return ref;
    }

    /** Removes a GameObject from the ObjectDB. */
    public function destroyObjectNamed (name :String) :void
    {
        var obj :GameObject = getObjectNamed(name);
        if (null != obj) {
            destroyObject(obj.ref);
        }
    }

    /** Removes all GameObjects in the given group from the ObjectDB. */
    public function destroyObjectsInGroup (groupName :String) :void
    {
        for each (var ref :GameObjectRef in getObjectRefsInGroup(groupName)) {
            if (!ref.isNull) {
                ref.object.destroySelf();
            }
        }
    }

    /** Removes a GameObject from the ObjectDB. */
    public function destroyObject (ref :GameObjectRef) :void
    {
        if (null == ref) {
            return;
        }

        var obj :GameObject = ref.object;

        if (null == obj) {
            return;
        }

        // the ref no longer points to the object
        ref._obj = null;

        // does the object have a name?
        for each (var objectName :String in obj.objectNames) {
            _namedObjects.remove(objectName);
        }

        // object group removal takes place in finalizeObjectRemoval()

        obj.removedFromDBInternal();
        obj.cleanupInternal();

        if (null == _objectsPendingRemoval) {
            _objectsPendingRemoval = new Array();
        }

        // the ref will be unlinked from the objects list
        // at the end of the update()
        _objectsPendingRemoval.push(obj);

        --_objectCount;
    }

    /** Returns the object in this mode with the given name, or null if no such object exists. */
    public function getObjectNamed (name :String) :GameObject
    {
        return (_namedObjects.get(name) as GameObject);
    }

    /**
     * Returns an Array containing the object refs of all the objects in the given group.
     * This Array must not be modified by client code.
     *
     * Note: the returned Array will contain null object refs for objects that were destroyed
     * this frame and haven't yet been cleaned up.
     */
    public function getObjectRefsInGroup (groupName :String) :Array
    {
        var refs :Array = (_groupedObjects.get(groupName) as Array);

        return (null != refs ? refs : []);
    }

    /**
     * Returns an Array containing the GameObjects in the given group.
     * The returned Array is instantiated by the function, and so can be
     * safely modified by client code.
     *
     * This function is not as performant as getObjectRefsInGroup().
     */
    public function getObjectsInGroup (groupName :String) :Array
    {
        return getObjects(getObjectRefsInGroup(groupName));
    }

    /** Called once per update tick. Updates all objects in the mode. */
    public function update (dt :Number) :void
    {
        beginUpdate(dt);
        endUpdate(dt);
        _runningTime += dt;
    }

    /** Sends a message to every object in the database. */
    public function broadcastMessage (msg :ObjectMessage) :void
    {
        var ref :GameObjectRef = _listHead;
        while (null != ref) {
            if (!ref.isNull) {
                ref.object.receiveMessageInternal(msg);
            }

            ref = ref._next;
        }
    }

    /** Sends a message to a specific object. */
    public function sendMessageTo (msg :ObjectMessage, targetRef :GameObjectRef) :void
    {
        if (!targetRef.isNull) {
            targetRef.object.receiveMessageInternal(msg);
        }
    }

    /** Sends a message to the object with the given name. */
    public function sendMessageToNamedObject (msg :ObjectMessage, objectName :String) :void
    {
        var target :GameObject = getObjectNamed(objectName);
        if (null != target) {
            target.receiveMessageInternal(msg);
        }
    }

    /** Sends a message to each object in the given group. */
    public function sendMessageToGroup (msg :ObjectMessage, groupName :String) :void
    {
        var refs :Array = getObjectRefsInGroup(groupName);
        for each (var ref :GameObjectRef in refs) {
            sendMessageTo(msg, ref);
        }
    }

    /**
     * Guarantees that the "second" GameObject will have its update logic run after "first"
     * during the update loop.
     */
    public function setUpdateOrder (first :GameObject, second :GameObject) :void
    {
        if (second.db != this || first.db != this) {
            throw new Error("GameObject doesn't belong to this ObjectDB");
        } else if (!second.isLiveObject || !first.isLiveObject) {
            throw new Error("GameObject is not live");
        }

        // unlink second from the list
        unlink(second);

        // relink it directly after first
        var firstRef :GameObjectRef = first._ref;
        var secondRef :GameObjectRef = second._ref;
        var nextRef :GameObjectRef = firstRef._next;

        firstRef._next = secondRef;
        secondRef._prev = firstRef;
        secondRef._next = nextRef;
        if (nextRef != null) {
            nextRef._prev = secondRef;
        }
    }

    /** Returns the number of live GameObjects in this ObjectDB. */
    public function get objectCount () :uint
    {
        return _objectCount;
    }

    /**
     * Returns the number of seconds this ObjectDB has been running, as measured by calls to
     * update().
     */
    public function get runningTime () :Number
    {
        return _runningTime;
    }

    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     *
     * Listeners registered in this way will be automatically unregistered when the ObjectDB is
     * shutdown.
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
     * Listeners registered in this way will be automatically unregistered when the ObjectDB is
     * shutdown.
     */
    protected function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
    }

    /** Updates all objects in the mode. */
    protected function beginUpdate (dt :Number) :void
    {
        // update all objects

        var ref :GameObjectRef = _listHead;
        while (null != ref) {
            var obj :GameObject = ref._obj;
            if (null != obj) {
                obj.updateInternal(dt);
            }

            ref = ref._next;
        }
    }

    /** Removes dead objects from the object list at the end of an update. */
    protected function endUpdate (dt :Number) :void
    {
        // clean out all objects that were destroyed during the update loop

        if (null != _objectsPendingRemoval) {
            for each (var obj :GameObject in _objectsPendingRemoval) {
                finalizeObjectRemoval(obj);
            }

            _objectsPendingRemoval = null;
        }
    }

    /** Removes a single dead object from the object list. */
    protected function finalizeObjectRemoval (obj :GameObject) :void
    {
        Assert.isTrue(null != obj._ref && null == obj._ref._obj);

        // unlink the object ref
        unlink(obj);

        // remove the object from the groups it belongs to
        // (we do this here, rather than in destroyObject(),
        // because client code might be iterating an
        // object group Array when destroyObject is called)
        var ref :GameObjectRef = obj._ref;
        for each (var groupName :String in obj.objectGroups) {
            var groupArray :Array = (_groupedObjects.get(groupName) as Array);
            if (null == groupArray) {
                throw new Error("destroyed GameObject is returning different object groups " +
                    "than it did on creation");
            }

            var wasInArray :Boolean = Arrays.removeFirst(groupArray, ref);
            if (!wasInArray) {
                throw new Error("destroyed GameObject is returning different object groups " +
                    "than it did on creation");
            }
        }

        obj._parentDB = null;
    }

    /**
     * Unlinks the GameObject from the db's linked list of objects. This happens during
     * object removal. It generally should not be called directly.
     */
    protected function unlink (obj :GameObject) :void
    {
        var ref :GameObjectRef = obj._ref;

        var prev :GameObjectRef = ref._prev;
        var next :GameObjectRef = ref._next;

        if (null != prev) {
            prev._next = next;
        } else {
            // if prev is null, ref was the head of the list
            Assert.isTrue(ref == _listHead);
            _listHead = next;
        }

        if (null != next) {
            next._prev = prev;
        }
    }

    /**
     * Destroys all GameObjects contained by this ObjectDB. Applications generally don't need
     * to call this function - it's called automatically when an {@link AppMode} is popped from
     * the mode stack.
     */
    protected function shutdown () :void
    {
        var ref :GameObjectRef = _listHead;
        while (null != ref) {
            if (!ref.isNull) {
                ref.object.cleanupInternal();
            }

            ref = ref._next;
        }

        _listHead = null;
        _objectCount = 0;
        _objectsPendingRemoval = null;
        _namedObjects = null;
        _groupedObjects = null;

        _events.shutdown();
    }

    protected var _runningTime :Number = 0;

    protected var _listHead :GameObjectRef;
    protected var _objectCount :uint;

    /** An array of GameObjects */
    protected var _objectsPendingRemoval :Array;

    /** stores a mapping from String to Object */
    protected var _namedObjects :Map = Maps.newMapOf(String);

    /** stores a mapping from String to Array */
    protected var _groupedObjects :Map = Maps.newMapOf(String);

    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
