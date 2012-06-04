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

package flashbang.util {

import com.threerings.util.Registration;
import com.threerings.util.RegistrationManager;
import com.threerings.util.Registrations;

import flash.events.Event;
import flash.events.IEventDispatcher;

import org.osflash.signals.ISignal;

public class SignalAndEventConnections
{
    /**
     * Adds a listener to the specified signal.
     * @return a Registration object that will disconnect the listener from the signal.
     */
    public function addSignalListener (signal :ISignal, l :Function) :Registration
    {
        signal.add(l);
        return _regs.add(Registrations.createWithFunction(function () :void {
            signal.remove(l);
        }));
    }

    /**
     * Adds a listener to the specified signal. It will be removed after being dispatched once.
     * @return a Registration object that will disconnect the listener from the signal.
     */
    public function addOneShotSignalListener (signal :ISignal, l :Function) :Registration
    {
        signal.addOnce(l);
        return _regs.add(Registrations.createWithFunction(function () :void {
            signal.remove(l);
        }));
    }

    /**
     * Adds a listener to the specified EventDispatcher for the specified event type.
     * @return a Registration object that will disconnect the listener from the EventDispatcher.
     */
    public function addEventListener (dispatcher :IEventDispatcher, type :String, l :Function,
        useCapture :Boolean = false, priority :int = 0) :Registration
    {
        dispatcher.addEventListener(type, l, useCapture, priority);
        return _regs.add(Registrations.createWithFunction(function () :void {
            dispatcher.removeEventListener(type, l, useCapture);
        }));
    }

    /**
     * Adds a listener to the specified EventDispatcher for the specified event type.
     * It will be removed after being dispatched once.
     * @return a Registration object that will disconnect the listener from the EventDispatcher.
     */
    public function addOneShotEventListener (dispatcher :IEventDispatcher, type :String,
        l :Function, useCapture :Boolean = false, priority :int = 0) :Registration
    {
        var eventListener :Function = function (e :Event) :void {
            dispatcher.removeEventListener(type, l, useCapture);
            l(e);
        };

        return addEventListener(dispatcher, type, eventListener, useCapture, priority);
    }

    /**
     * Cancels all signal and event listeners.
     */
    public function cancelAll () :void
    {
        _regs.cancelAll();
    }

    protected var _regs :RegistrationManager = new RegistrationManager();
}
}
