// Flashbang - a framework for creating Flash games
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
//
// Copyright 2008 Three Rings Design
//
// $Id$

package flashbang.tasks {

import com.threerings.display.FilterUtil;

import flash.display.DisplayObject;
import flash.filters.ColorMatrixFilter;

import flashbang.ObjectMessage;
import flashbang.ObjectTask;
import flashbang.SimObject;
import flashbang.components.SceneComponent;

import mx.effects.easing.*;

public class ColorMatrixBlendTask
    implements ObjectTask
{
    public static function colorize (fromColor :uint, toColor :uint,
        time :Number, disp :DisplayObject = null, interpolator :Function = null,
        preserveFilters :Boolean = false) :ColorMatrixBlendTask
    {
        return new ColorMatrixBlendTask(
            new ColorMatrix().colorize(fromColor, 1),
            new ColorMatrix().colorize(toColor, 1),
            time,
            disp,
            interpolator,
            preserveFilters);
    }

    public function ColorMatrixBlendTask (cmFrom :ColorMatrix,
        cmTo :ColorMatrix, time :Number, disp :DisplayObject = null,
        interpolator :Function = null,
        preserveFilters :Boolean = false)
    {
        _disp = disp;
        _from = cmFrom;
        _to = cmTo;
        _totalTime = time;
        _interpolator = (interpolator != null ? interpolator : mx.effects.easing.Linear.easeNone);
        _preserveFilters = preserveFilters;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var disp :DisplayObject = _disp;
        if (disp == null) {
            var sceneObj :SceneComponent = obj as SceneComponent;
            if (sceneObj == null) {
                throw new Error("ColorMatrixBlendTask must be applied to a SimObject that " +
                                "implements SceneComponent, or must have a non-null disp " +
                                "parameter");
            }

            disp = sceneObj.displayObject;
        }

        _elapsedTime += dt;

        var amount :Number = _interpolator(
            Math.min(_elapsedTime, _totalTime),
            0,
            1,
            _totalTime);

        var filter :ColorMatrixFilter = _from.clone().blend(_to, amount).createFilter();

        // If _preserveFilters is set, we'll preserve any filters already on the DisplayObject
        // when adding the new filter. This can be an expensive operation, so it's false by default.
        if (_preserveFilters) {
            if (_oldFilter != null) {
                FilterUtil.removeFilter(disp, _oldFilter);
            }
            FilterUtil.addFilter(disp, filter);
            _oldFilter = filter;

        } else {
            disp.filters = [ filter ];
        }

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new ColorMatrixBlendTask(
            _from,
            _to,
            _totalTime,
            _disp,
            _interpolator,
            _preserveFilters);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _disp :DisplayObject;
    protected var _from :ColorMatrix;
    protected var _to :ColorMatrix;
    protected var _totalTime :Number;
    protected var _interpolator :Function;
    protected var _preserveFilters :Boolean;

    protected var _oldFilter :ColorMatrixFilter;

    protected var _elapsedTime :Number = 0;
}

}
