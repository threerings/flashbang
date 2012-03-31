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

package flashbang.objects {

import flash.display.InteractiveObject;

public class DraggableObject extends SceneObject
{
    public function DraggableObject (draggedCallback :Function = null,
                                     droppedCallback :Function = null)
    {
        _draggedCallback = draggedCallback;
        _droppedCallback = droppedCallback;
    }

    public function get dragger () :Dragger
    {
        return _dragger;
    }

    protected function createDragger () :Dragger
    {
        return new Dragger(this.draggableObject, this.displayObject, _draggedCallback,
            _droppedCallback);
    }

    override protected function addedToDB () :void
    {
        _dragger = createDragger();
        this.mode.addObject(_dragger);

        super.addedToDB();
    }

    override protected function removedFromDB () :void
    {
        super.removedFromDB();
        _dragger.destroySelf();
    }

    protected function get draggableObject () :InteractiveObject
    {
        return this.displayObject as InteractiveObject;
    }

    protected var _draggedCallback :Function;
    protected var _droppedCallback :Function;
    protected var _dragger :Dragger;
}

}
