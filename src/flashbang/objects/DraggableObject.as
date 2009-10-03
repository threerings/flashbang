package com.whirled.contrib.simplegame.objects {

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
        this.db.addObject(_dragger);

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
