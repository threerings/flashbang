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
// $Id: CuePoint.as 9722 2009-08-24 06:34:21Z ray $

package flashbang {

import com.threerings.util.Map;
import com.threerings.util.Maps;

/**
 * A simple mechanism for synchronizing logic across objects.
 */
public class CuePoint
{
    public static function create (name :String) :CuePoint
    {
        var cpi :CuePointInternal = _cuePoints.get(name);
        if (cpi == null) {
            cpi = new CuePointInternal(name);
            _cuePoints.put(name, cpi);
        }

        cpi.cueCount++;

        return new CuePoint(cpi);
    }

    public function get name () :String
    {
        return _cpi.name;
    }

    public function get canPass () :Boolean
    {
        return (_cpi.cueCount <= 0);
    }

    public function cue () :void
    {
        if (_cued) {
            throw new Error("cannot call cue() more than once");

        } else {
            _cued = true;
            if (--_cpi.cueCount == 0) {
                _cuePoints.remove(_cpi.name);
            }
        }
    }

    public function clone () :CuePoint
    {
        _cpi.cueCount++;
        return new CuePoint(_cpi);
    }

    /**
     * @private
     */
    public function CuePoint (cpi :CuePointInternal)
    {
        _cpi = cpi;
    }

    protected var _cpi :CuePointInternal;
    protected var _cued :Boolean;

    // Map<name, waitCount>
    protected static var _cuePoints :Map = Maps.newMapOf(String);
}

}

class CuePointInternal
{
    public var name :String;
    public var cueCount :int;

    public function CuePointInternal (name :String)
    {
        this.name = name;
    }
}
