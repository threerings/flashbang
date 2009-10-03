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
// $Id: ObjectDB.as 9722 2009-08-24 06:34:21Z ray $

package com.whirled.contrib.simplegame {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.tasks.*;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class ObjectDB extends EventDispatcher
    implements Updatable
{
    /**
     * Adds a SimObject to the ObjectDB. The SimObject must not be owned by another ObjectDB.
     */
    public function addObject (obj :SimObject) :SimObjectRef
    {
        if (null == obj || null != obj._ref) {
            throw new ArgumentError("obj must be non-null, and must never have belonged to " +
                                    "another ObjectDB");
        }

        // create a new SimObjectRef
        var ref :SimObjectRef = new SimObjectRef();
        ref._obj = obj;

        // add the ref to the list
        var oldListHead :SimObjectRef = _listHead;
        _listHead = ref;

        if (null != oldListHead) {
            ref._next = oldListHead;
            oldListHead._prev = ref;
        }

        // initialize object
        obj._parentDB = this;
        obj._ref = ref;

        // does the object have a name?
        var objectName :String = obj.objectName;
        if (null != objectName) {
            var oldObj :* = _namedObjects.put(objectName, obj);
            if (undefined !== oldObj) {
                throw new Error("two objects with the same name ('" + objectName + "') " +
                                "added to the ObjectDB");
            }
        }

        // iterate over the object's groups
        var groupNum :int = 0;
        do {
            var groupName :String = obj.getObjectGroup(groupNum++);
            if (null != groupName) {
                var groupArray :Array = (_groupedObjects.get(groupName) as Array);
                if (null == groupArray) {
                    groupArray = [];
                    _groupedObjects.put(groupName, groupArray);
                }

                groupArray.push(ref);
            }
        } while (null != groupName);

        obj.addedToDBInternal();

        ++_objectCount;

        return ref;
    }

    /** Removes a SimObject from the ObjectDB. */
    public function destroyObjectNamed (name :String) :void
    {
        var obj :SimObject = getObjectNamed(name);
        if (null != obj) {
            destroyObject(obj.ref);
        }
    }

    /** Removes all SimObjects in the given group from the ObjectDB. */
    public function destroyObjectsInGroup (groupName :String) :void
    {
        for each (var ref :SimObjectRef in getObjectRefsInGroup(groupName)) {
            if (!ref.isNull) {
                ref.object.destroySelf();
            }
        }
    }

    /** Removes a SimObject from the ObjectDB. */
    public function destroyObject (ref :SimObjectRef) :void
    {
        if (null == ref) {
            return;
        }

        var obj :SimObject = ref.object;

        if (null == obj) {
            return;
        }

        // the ref no longer points to the object
        ref._obj = null;

        // does the object have a name?
        var objectName :String = obj.objectName;
        if (null != objectName) {
            _namedObjects.remove(objectName);
        }

        obj.removedFromDBInternal();
        obj.destroyedInternal();

        if (null == _objectsPendingRemoval) {
            _objectsPendingRemoval = new Array();
        }

        // the ref will be unlinked from the objects list
        // at the end of the update()
        _objectsPendingRemoval.push(obj);

        --_objectCount;
    }

    /** Returns the object in this mode with the given name, or null if no such object exists. */
    public function getObjectNamed (name :String) :SimObject
    {
        return (_namedObjects.get(name) as SimObject);
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
     * Returns an Array containing the SimObjects in the given group.
     * The returned Array is instantiated by the function, and so can be
     * safely modified by client code.
     *
     * This function is not as performant as getObjectRefsInGroup().
     */
    public function getObjectsInGroup (groupName :String) :Array
    {
        var refs :Array = getObjectRefsInGroup(groupName);

        // Array.map would be appropriate here, except that the resultant
        // Array might contain fewer entries than the source.

        var objs :Array = new Array();
        for each (var ref :SimObjectRef in refs) {
            if (!ref.isNull) {
                objs.push(ref.object);
            }
        }

        return objs;
    }

    /** Called once per update tick. Updates all objects in the mode. */
    public function update (dt :Number) :void
    {
        beginUpdate(dt);
        endUpdate(dt);
    }

    /** Sends a message to every object in the database. */
    public function broadcastMessage (msg :ObjectMessage) :void
    {
        var ref :SimObjectRef = _listHead;
        while (null != ref) {
            if (!ref.isNull) {
                ref.object.receiveMessageInternal(msg);
            }

            ref = ref._next;
        }
    }

    /** Sends a message to a specific object. */
    public function sendMessageTo (msg :ObjectMessage, targetRef :SimObjectRef) :void
    {
        if (!targetRef.isNull) {
            targetRef.object.receiveMessageInternal(msg);
        }
    }

    /** Sends a message to the object with the given name. */
    public function sendMessageToNamedObject (msg :ObjectMessage, objectName :String) :void
    {
        var target :SimObject = getObjectNamed(objectName);
        if (null != target) {
            target.receiveMessageInternal(msg);
        }
    }

    /** Sends a message to each object in the given group. */
    public function sendMessageToGroup (msg :ObjectMessage, groupName :String) :void
    {
        var refs :Array = getObjectRefsInGroup(groupName);
        for each (var ref :SimObjectRef in refs) {
            sendMessageTo(msg, ref);
        }
    }

    /** Returns the number of live SimObjects in this ObjectDB. */
    public function get objectCount () :uint
    {
        return _objectCount;
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

        var ref :SimObjectRef = _listHead;
        while (null != ref) {
            var obj :SimObject = ref._obj;
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
            for each (var obj :SimObject in _objectsPendingRemoval) {
                finalizeObjectRemoval(obj);
            }

            _objectsPendingRemoval = null;
        }
    }

    /** Removes a single dead object from the object list. */
    protected function finalizeObjectRemoval (obj :SimObject) :void
    {
        Assert.isTrue(null != obj._ref && null == obj._ref._obj);

        // unlink the object ref
        var ref :SimObjectRef = obj._ref;

        var prev :SimObjectRef = ref._prev;
        var next :SimObjectRef = ref._next;

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

        // iterate over the object's groups
        // (we remove the object from its groups here, rather than in
        // destroyObject(), because client code might be iterating an
        // object group Array when destroyObject is called)
        var groupNum :int = 0;
        do {
            var groupName :String = obj.getObjectGroup(groupNum++);
            if (null != groupName) {
                var groupArray :Array = (_groupedObjects.get(groupName) as Array);
                if (null == groupArray) {
                    throw new Error("destroyed SimObject is returning different object groups " +
                                    "than it did on creation");
                }

                var wasInArray :Boolean = ArrayUtil.removeFirst(groupArray, ref);
                if (!wasInArray) {
                    throw new Error("destroyed SimObject is returning different object groups " +
                                    "than it did on creation");
                }
            }
        } while (null != groupName);

        obj._parentDB = null;
    }

    /**
     * Destroys all SimObjects contained by this ObjectDB. Applications generally don't need
     * to call this function - it's called automatically when an {@link AppMode} is popped from
     * the mode stack.
     */
    protected function shutdown () :void
    {
        var ref :SimObjectRef = _listHead;
        while (null != ref) {
            if (!ref.isNull) {
                ref.object.destroyedInternal();
            }

            ref = ref._next;
        }

        _listHead = null;
        _objectCount = 0;
        _objectsPendingRemoval = null;
        _namedObjects = null;
        _groupedObjects = null;

        _events.freeAllHandlers();
    }

    protected var _listHead :SimObjectRef;
    protected var _objectCount :uint;

    /** An array of SimObjects */
    protected var _objectsPendingRemoval :Array;

    /** stores a mapping from String to Object */
    protected var _namedObjects :Map = Maps.newMapOf(String);

    /** stores a mapping from String to Array */
    protected var _groupedObjects :Map = Maps.newMapOf(String);

    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
