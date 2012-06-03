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

package flashbang.input {

import flash.events.MouseEvent;

/**
 * A MouseListener implementation that returns true (i.e. "handled") for every MouseEvent
 */
public class MouseReactor
    implements MouseListener
{
    public function onMouseDown (e :MouseEvent) :Boolean { return true; }
    public function onMouseMove (e :MouseEvent) :Boolean { return true; }
    public function onMouseUp (e :MouseEvent) :Boolean { return true; }
    public function onClick (e :MouseEvent) :Boolean { return true; }
    public function onMouseOver (e :MouseEvent) :Boolean { return true; }
    public function onMouseOut (e :MouseEvent) :Boolean { return true; }
    public function onRollOver (e :MouseEvent) :Boolean { return true; }
    public function onRollOut (e :MouseEvent) :Boolean { return true; }
    public function onMouseWheel (e :MouseEvent) :Boolean { return true; }
}
}
