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
 * Used with MouseInput to intercept mouse events.
 * Return true from any of the listener methods to indicate that the event has been
 * fully handled, and processing should stop.
 */
public interface MouseListener
{
    function onMouseDown (e :MouseEvent) :Boolean;
    function onMouseMove (e :MouseEvent) :Boolean;
    function onMouseUp (e :MouseEvent) :Boolean;
    function onClick (e :MouseEvent) :Boolean;

    function onMouseOver (e :MouseEvent) :Boolean;
    function onMouseOut (e :MouseEvent) :Boolean;
    function onRollOver (e :MouseEvent) :Boolean;
    function onRollOut (e :MouseEvent) :Boolean;

    function onMouseWheel (e :MouseEvent) :Boolean;
}
}
