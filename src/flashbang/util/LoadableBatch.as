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
// $Id: LoadableBatch.as 9637 2009-07-08 00:34:41Z tim $

package flashbang.util {

import com.threerings.util.Log;

public class LoadableBatch extends Loadable
{
    /**
     * Creates a new LoadableBatch.
     *
     * @param loadInSequence if true, loads all Loadables one by one (useful if there are
     * dependencies between the Loadables). Otherwise, loads all Loadables simultaneously.
     * Defaults to false.
     */
    public function LoadableBatch (loadInSequence :Boolean = false)
    {
        _loadInSequence = loadInSequence;
    }

    public function addLoadable (loadable :Loadable) :void
    {
        if (_loading || _loaded) {
            throw new Error("Can't add new Loadables while a LoadableBatch is loading or loaded");
        }

        _allObjects.push(loadable);
    }

    override protected function doLoad () :void
    {
        // If we don't have any objects to load, we're done!
        if (_allObjects.length == 0) {
            onLoaded();
            return;
        }

        for each (var loadable :Loadable in _allObjects) {
            loadOneObject(loadable);
            // don't continue if the load operation has been canceled/errored,
            // or if we're loading in sequence
            if (!_loading || _loadInSequence) {
                break;
            }
        }
    }

    protected function loadOneObject (loadable :Loadable) :void
    {
        loadable.load(
            function () :void {
                onObjectLoaded(loadable);
            },
            function (err :String) :void {
                onObjectLoadErr(loadable, err);
            });
    }

    override protected function doUnload () :void
    {
        for each (var loadable :Loadable in _allObjects) {
            loadable.unload();
        }

        _loadedObjects = [];
    }

    protected function onObjectLoaded (loadable :Loadable) :void
    {
        _loadedObjects.push(loadable);

        if (_loadedObjects.length == _allObjects.length) {
            // We finished loading
            onLoaded();
        } else if (_loadInSequence) {
            // We have more to load
            loadOneObject(_allObjects[_loadedObjects.length]);
        }
    }

    protected function onObjectLoadErr (loadable :Loadable, err :String) :void
    {
        onLoadErr(err);
    }

    protected var _loadInSequence :Boolean;
    protected var _allObjects :Array = []; // Array<Loadable>
    protected var _loadedObjects :Array = []; // Array<Loadable>
}

}
