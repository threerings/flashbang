//
// flashbang

package flashbang.input {

import com.threerings.util.Arrays;

import flash.display.InteractiveObject;
import flash.events.EventDispatcher;
import flash.events.EventPhase;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;

import com.threerings.util.Registration;
import com.threerings.util.Registrations;

public class MouseInput
{
    public function MouseInput (root :InteractiveObject)
    {
        _root = root;
    }

    public function registerListener (l :MouseListener) :Registration
    {
        _listeners.unshift(l);
        installMouseListeners();
        return Registrations.createWithFunction(function () :void {
            Arrays.removeFirst(_listeners, l);
            if (_listeners.length == 0) {
                uninstallMouseListeners();
            }
        });
    }

    public function removeAllListeners () :void
    {
        _listeners = [];
        uninstallMouseListeners();
    }

    protected function installMouseListeners () :void
    {
        if (!_mouseListenersInstalled) {
            for each (var type :String in MOUSE_EVENTS) {
                connect(_root, type, handleMouseEvent);
            }
            _mouseListenersInstalled = true;
        }
    }

    protected function uninstallMouseListeners () :void
    {
        if (_mouseListenersInstalled) {
            for each (var type :String in MOUSE_EVENTS) {
                disconnect(_root, type, handleMouseEvent);
            }
            _mouseListenersInstalled = false;
        }
    }

    protected function handleMouseEvent (e :MouseEvent) :void
    {
        if (e.eventPhase == EventPhase.BUBBLING_PHASE) {
            return;
        }

        var handled :Boolean = false;
        for each (var ml :MouseListener in _listeners) {
            switch (e.type) {
            case MouseEvent.MOUSE_DOWN:
                handled = ml.onMouseDown(e);
                break;

            case MouseEvent.MOUSE_MOVE:
                handled = ml.onMouseMove(e);
                break;

            case MouseEvent.MOUSE_UP:
                handled = ml.onMouseUp(e);
                break;

            case MouseEvent.MOUSE_OVER:
                handled = ml.onMouseOver(e);
                break;

            case MouseEvent.MOUSE_OUT:
                handled = ml.onMouseOut(e);
                break;

            case MouseEvent.ROLL_OVER:
                handled = ml.onRollOver(e);
                break;

            case MouseEvent.ROLL_OUT:
                handled = ml.onRollOut(e);
                break;

            case MouseEvent.CLICK:
                handled = ml.onClick(e);
                break;
            }

            if (handled) {
                e.preventDefault();
                e.stopImmediatePropagation();
                return;
            }
        }
    }

    protected static function connect (target :IEventDispatcher, type :String, l :Function) :void
    {
        target.addEventListener(type, l, true, int.MAX_VALUE);
        target.addEventListener(type, l, false, int.MAX_VALUE);
    }

    protected static function disconnect (target :IEventDispatcher, type :String, l :Function) :void
    {
        target.removeEventListener(type, l, true);
        target.removeEventListener(type, l, false);
    }

    protected var _root :InteractiveObject;
    protected var _listeners :Array = [];
    protected var _mouseListenersInstalled :Boolean;

    protected var _lastEvent :MouseEvent;

    protected static const MOUSE_EVENTS :Array = [
        MouseEvent.MOUSE_DOWN,
        MouseEvent.MOUSE_MOVE,
        MouseEvent.MOUSE_UP,
        MouseEvent.MOUSE_OVER,
        MouseEvent.MOUSE_OUT,
        MouseEvent.ROLL_OVER,
        MouseEvent.ROLL_OUT,
        MouseEvent.CLICK,
    ];
}
}
