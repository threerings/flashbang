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

import flashbang.ObjectMessage;
import flashbang.ObjectTask;
import flashbang.SimObject;
import flashbang.components.VisibleComponent;

public class VisibleTask
    implements ObjectTask
{
    public function VisibleTask (visible :Boolean)
    {
        _visible = visible;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var vc :VisibleComponent = (obj as VisibleComponent);

        if (null == vc) {
            throw new Error("VisibleTask can only be applied to SimObjects that implement " +
                            "VisibleComponent");
        }

        vc.visible = _visible;

        return true;
    }

    public function clone () :ObjectTask
    {
        return new VisibleTask(_visible);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _visible :Boolean;
}

}
