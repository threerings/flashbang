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

package com.threerings.flashbang.util {

import org.osflash.signals.ISignal;

import com.threerings.util.Arrays;
import com.threerings.util.Map;
import com.threerings.util.Maps;

/**
 * A class for keeping track of signal listeners and freeing them all at a given time,
 * similar to EventHandlerManager.
 */
public class SignalListenerManager
{
    /**
     * Create a SignalListenerManager
     *
     * @param parent (optional) if not null, this SignalListenerManager will become a child of
     * the specified parent. If the parent is shutdown, or its freeAllHandlers() or freeAllOn()
     * functions are called, this SignalListenerManager will be similarly affected.
     */
    public function SignalListenerManager (parent :SignalListenerManager = null)
    {
        if (parent != null) {
            _parent = parent;
            parent._children.push(this);
        }
    }

    /**
     * Unregisters all signal handlers, and disconnects the SignalListenerManager from its parent,
     * if it has one. All child SignalListenerManagers will be shutdown as well.
     *
     * It's an error to call any function on SignalListenerManager after shutdown() has been called.
     */
    public function shutdown () :void
    {
        // detach from our parent, if we have one
        if (_parent != null) {
            Arrays.removeFirst(_parent._children, this);
            _parent = null;
        }

        // shutdown our children
        for each (var child :SignalListenerManager in _children) {
            child._parent = null;
            child.shutdown();
        }
        _children = null;

        // Free all handlers
        removeAllSignalListeners();

        // null out internal state so that future calls to this object will immediately NPE
        _listeners = null;
    }

    /**
     * Adds the specified listener to the specified signal.
     */
    public function addSignalListener (signal :ISignal, listener :Function) :void
    {
        var listeners :Array = getListeners(signal, true);
        listeners.push(listener);

        signal.add(listener);
    }

    /**
     * Removes the specified listener from the specified signal.
     */
    public function removeSignalListener (signal :ISignal, listener :Function) :void
    {
        var listeners :Array = getListeners(signal, false);
        if (listeners != null) {
            Arrays.removeFirst(listeners, listener);
            signal.remove(listener);
        }
    }

    /**
     * Free all listeners on the specified signal. Children SignalListenerManagers will
     * be similarly affected.
     */
    public function removeAllSignalListenersOn (signal :ISignal) :void
    {
        var listeners :Array = getListeners(signal, false);
        if (listeners != null) {
            for each (var listener :Function in listeners) {
                signal.remove(listener);
            }
            listeners = [];
        }
    }

    /**
     * Free all listeners that have been added via this registerListener() and have not been
     * freed already via unregisterListener(). Children SignalListenerManagers will also have their
     * listeners freed.
     */
    public function removeAllSignalListeners () :void
    {
        _listeners.forEach(function (signal :ISignal, listeners :Array) :void {
            listeners.forEach(function (listener :Function, ..._) :void {
                signal.remove(listener);
            });
        });
        _listeners.clear();

        for each (var child :SignalListenerManager in _children) {
            child.removeAllSignalListeners();
        }
    }

    protected function getListeners (signal :ISignal, addIfMissing :Boolean) :Array
    {
        var listeners :Array = _listeners.get(signal);
        if (listeners == null && addIfMissing) {
            listeners = [];
            _listeners.put(signal, listeners);
        }
        return listeners;
    }

    protected var _listeners :Map = Maps.newMapOf(ISignal); // Map< ISignal, Array<Listener> >
    protected var _parent :SignalListenerManager;
    protected var _children :Array = []; // Array<SignalListenerManager>
}
}
