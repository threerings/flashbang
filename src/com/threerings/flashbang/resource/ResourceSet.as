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

package com.threerings.flashbang.resource {

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.threerings.flashbang.util.LoadableBatch;

public class ResourceSet extends LoadableBatch
{
    public function ResourceSet (rm :ResourceManager, loadInSequence :Boolean = false)
    {
        super(loadInSequence);
        _rm = rm;
    }

    public function queueResourceLoad (resourceType :String, resourceName: String, loadParams :*)
        :void
    {
        if (_resources.containsKey(resourceName)) {
            throw new Error("A resource named '" + resourceName + "' already exists");
        }

        var rsrc :Resource = _rm.createResource(resourceType, resourceName, loadParams);
        if (null == rsrc) {
            throw new Error("Unrecognized Resource type '" + resourceType + "'");
        }

        addLoadable(rsrc.loadable);
        _resources.put(resourceName, rsrc);
    }

    override protected function doLoad () :void
    {
        _rm.setResourceSetLoading(this, true);
        super.doLoad();
    }

    override protected function onLoaded () :void
    {
        _rm.setResourceSetLoading(this, false);
        if(addLoadedResources()) {
            super.onLoaded();
        }
    }

    protected function addLoadedResources () :Boolean
    {
        // add resources to the ResourceManager
        try {
            _rm.addResources(_resources.values());
        } catch (e :Error) {
            onLoadErr(e.message);
            return false;
        }

        return true;
    }

    override protected function onLoadCanceled () :void
    {
        _rm.setResourceSetLoading(this, false);
        super.onLoadCanceled();
    }

    override protected function doUnload () :void
    {
        super.doUnload();
        _rm.removeResources(_resources.values());
    }

    protected var _rm :ResourceManager;
    protected var _resources :Map = Maps.newMapOf(String);

    protected static const log :Log = Log.getLog(ResourceSet);
}

}
