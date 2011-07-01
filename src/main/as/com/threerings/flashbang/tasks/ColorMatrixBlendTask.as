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

import com.threerings.display.ColorMatrix;
import com.threerings.display.FilterUtil;
import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.components.SceneComponent;

import flash.display.DisplayObject;
import flash.filters.ColorMatrixFilter;

import mx.effects.easing.*;

public class ColorMatrixBlendTask
    implements ObjectTask
{
    public static function fadeToBlack (time :Number, disp :DisplayObject = null,
        easingFn :Function = null, preserveFilters :Boolean = false,
        removeFilterWhenComplete :Boolean = false) :ColorMatrixBlendTask
    {
        return new ColorMatrixBlendTask(
            IDENTITY,
            BLACK,
            time,
            disp,
            easingFn,
            preserveFilters,
            removeFilterWhenComplete);
    }

    public static function fadeFromBlack (time :Number, disp :DisplayObject = null,
        easingFn :Function = null, preserveFilters :Boolean = false,
        removeFilterWhenComplete :Boolean = true) :ColorMatrixBlendTask
    {
        return new ColorMatrixBlendTask(
            BLACK,
            IDENTITY,
            time,
            disp,
            easingFn,
            preserveFilters,
            removeFilterWhenComplete);
    }

    public static function colorize (fromColor :uint, toColor :uint,
        time :Number, disp :DisplayObject = null, easingFn :Function = null,
        preserveFilters :Boolean = false, removeFilterWhenComplete :Boolean = false)
        :ColorMatrixBlendTask
    {
        return new ColorMatrixBlendTask(
            new ColorMatrix().colorize(fromColor, 1),
            new ColorMatrix().colorize(toColor, 1),
            time,
            disp,
            easingFn,
            preserveFilters);
    }

    public function ColorMatrixBlendTask (cmFrom :ColorMatrix,
        cmTo :ColorMatrix, time :Number, disp :DisplayObject = null,
        easingFn :Function = null,
        preserveFilters :Boolean = false,
        removeFilterWhenComplete :Boolean = false)
    {
        _dispOverride = DisplayObjectWrapper.create(disp);
        _from = cmFrom;
        _to = cmTo;
        _totalTime = time;
        _easingFn = (easingFn != null ? easingFn : mx.effects.easing.Linear.easeNone);
        _preserveFilters = preserveFilters;
        _removeFilterWhenComplete = removeFilterWhenComplete;
    }

    public function update (dt :Number, obj :GameObject) :Boolean
    {
        var sc :SceneComponent = (!_dispOverride.isNull ? _dispOverride : obj as SceneComponent);
        if (sc == null) {
            throw new Error("obj does not implement SceneComponent");
        }

        _elapsedTime += dt;

        var complete :Boolean = (_elapsedTime >= _totalTime);
        var filter :ColorMatrixFilter;
        if (!complete || !_removeFilterWhenComplete) {
            var amount :Number = _easingFn(Math.min(_elapsedTime, _totalTime), 0, 1, _totalTime);
            filter = _from.clone().blend(_to, amount).createFilter();
        }

        // If _preserveFilters is set, we'll preserve any filters already on the DisplayObject
        // when adding the new filter. This can be an expensive operation, so it's false by default.
        if (_preserveFilters) {
            if (_oldFilter != null) {
                FilterUtil.removeFilter(sc.displayObject, _oldFilter);
            }
            if (filter != null) {
                FilterUtil.addFilter(sc.displayObject, filter);
                _oldFilter = filter;
            }

        } else {
            sc.displayObject.filters = (filter != null ? [ filter ] : []);
        }

        return complete;
    }

    public function clone () :ObjectTask
    {
        return new ColorMatrixBlendTask(_from, _to, _totalTime, _dispOverride.displayObject,
            _easingFn, _preserveFilters);
    }

    protected var _dispOverride :DisplayObjectWrapper;
    protected var _from :ColorMatrix;
    protected var _to :ColorMatrix;
    protected var _totalTime :Number;
    protected var _easingFn :Function;
    protected var _preserveFilters :Boolean;
    protected var _removeFilterWhenComplete :Boolean;

    protected var _oldFilter :ColorMatrixFilter;

    protected var _elapsedTime :Number = 0;

    protected static const IDENTITY :ColorMatrix = new ColorMatrix();
    protected static const BLACK :ColorMatrix = new ColorMatrix().tint(0);
}

}
