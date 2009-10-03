package com.whirled.contrib.simplegame.objects {

import com.threerings.util.MathUtil;
import com.whirled.contrib.simplegame.SimObject;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class Dragger extends SimObject
{
    public static const SNAP_NONE :int = 0;

    public static const SNAP_LEFT :int = 1;
    public static const SNAP_RIGHT :int = 2;
    public static const SNAP_LEFT_RIGHT :int = 3;

    public static const SNAP_TOP :int = SNAP_LEFT;
    public static const SNAP_BOTTOM :int = SNAP_RIGHT;
    public static const SNAP_TOP_BOTTOM :int = SNAP_LEFT_RIGHT;

    public function Dragger (draggableObj :InteractiveObject,
                             displayObj :DisplayObject = null,
                             draggedCallback :Function = null,
                             droppedCallback :Function = null)
    {
        _draggableObj = draggableObj;
        _displayObj = (displayObj != null ? displayObj : draggableObj);
        _draggedCallback = draggedCallback;
        _droppedCallback = droppedCallback;
    }

    public function setConstraints (constrainedBounds :Rectangle,
                                    xSnap :int = SNAP_NONE,
                                    ySnap :int = SNAP_NONE,
                                    customObjectBounds :Rectangle = null) :void
    {
        _constrainedBounds = constrainedBounds;
        _xSnap = xSnap;
        _ySnap = ySnap;
        _customObjectBounds = customObjectBounds;

        if (_constrainedBounds != null) {
            var p :Point = new Point(_displayObj.x, _displayObj.y);
            applyConstraints(p);
            _displayObj.x = p.x;
            _displayObj.y = p.y;
        }
    }

    public function removeConstraints () :void
    {
        setConstraints(null);
    }

    public function set isDraggable (val :Boolean) :void
    {
        _isDraggable = val;
        updateDraggability();
    }

    public function get isDraggable () :Boolean
    {
        return _isDraggable;
    }

    protected function updateDraggability () :void
    {
        // Don't updateDraggability until we've been added to the db
        if (this.db == null) {
            return;
        }

        if (_isDraggable && !_isDragRegistered) {
            registerListener(_draggableObj, MouseEvent.MOUSE_DOWN, startDrag);
            _isDragRegistered = true;

        } else if (!_isDraggable && _isDragRegistered) {
            unregisterListener(_draggableObj, MouseEvent.MOUSE_DOWN, startDrag);
            _isDragRegistered = false;
            if (_dragging) {
                endDrag();
            }
        }
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        updateDraggability();
    }

    protected function startDrag (e :MouseEvent) :void
    {
        if (!_dragging && _displayObj.parent != null) {
            _startX = _displayObj.x;
            _startY = _displayObj.y;
            _parentMouseX = _displayObj.parent.mouseX;
            _parentMouseY = _displayObj.parent.mouseY;
            _dragging = true;

            registerListener(_draggableObj, MouseEvent.MOUSE_UP, endDrag);
        }
    }

    protected function endDrag (...ignored) :void
    {
        unregisterListener(_draggableObj, MouseEvent.MOUSE_UP, endDrag);
        updateDraggedLocation();

        if (_droppedCallback != null) {
            _droppedCallback(_displayObj.x, _displayObj.y);
        }

        _dragging = false;
    }

    protected function updateDraggedLocation () :void
    {
        if (_displayObj.parent != null) {
            var newLoc :Point = new Point(
                _startX + (_displayObj.parent.mouseX - _parentMouseX),
                _startY + (_displayObj.parent.mouseY - _parentMouseY));

            applyConstraints(newLoc);

            if (newLoc.x != _displayObj.x || newLoc.y != _displayObj.y) {
                _displayObj.x = newLoc.x;
                _displayObj.y = newLoc.y;

                if (_draggedCallback != null) {
                    _draggedCallback(newLoc.x, newLoc.y);
                }
            }
        }
    }

    protected function applyConstraints (p :Point) :void
    {
        if (_constrainedBounds != null) {
            var objectBounds :Rectangle = (_customObjectBounds != null ?
                _customObjectBounds :
                _displayObj.getBounds(_displayObj));

            var minX :Number = _constrainedBounds.left - objectBounds.left;
            var maxX :Number = _constrainedBounds.right - objectBounds.right - 1;

            var minY :Number = _constrainedBounds.top - objectBounds.top;
            var maxY :Number = _constrainedBounds.bottom - objectBounds.bottom - 1;

            p.x = MathUtil.clamp(p.x, minX, maxX);
            p.y = MathUtil.clamp(p.y, minY, maxY);

            if ((_xSnap == SNAP_LEFT || _xSnap == SNAP_LEFT_RIGHT) &&
                Math.abs(p.x - minX) < SNAP_MARGIN) {
                p.x = minX;
            } else if ((_xSnap == SNAP_RIGHT || _xSnap == SNAP_LEFT_RIGHT) &&
                Math.abs(p.x - maxX) < SNAP_MARGIN) {
                p.x = maxX;
            }

            if ((_ySnap == SNAP_TOP || _ySnap == SNAP_TOP_BOTTOM) &&
                Math.abs(p.y - minY) < SNAP_MARGIN) {
                p.y = minY;
            } else if ((_ySnap == SNAP_BOTTOM || _ySnap == SNAP_TOP_BOTTOM) &&
                Math.abs(p.y - maxY) < SNAP_MARGIN) {
                p.y = maxY;
            }
        }
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_dragging) {
            updateDraggedLocation();
        }
    }

    protected var _draggableObj :InteractiveObject;
    protected var _displayObj :DisplayObject;

    protected var _isDraggable :Boolean = true;
    protected var _isDragRegistered :Boolean;
    protected var _draggedCallback :Function;
    protected var _droppedCallback :Function;

    protected var _startX :Number;
    protected var _startY :Number;
    protected var _parentMouseX :Number;
    protected var _parentMouseY :Number;
    protected var _dragging :Boolean;

    protected var _constrainedBounds :Rectangle;
    protected var _customObjectBounds :Rectangle;
    protected var _xSnap :int;
    protected var _ySnap :int;

    protected static const SNAP_MARGIN :Number = 20;
}

}
