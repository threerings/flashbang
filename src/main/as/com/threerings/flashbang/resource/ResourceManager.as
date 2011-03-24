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

package com.threerings.flashbang.resource {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

public class ResourceManager
{
    public function shutdown () :void
    {
        cancelLoad();
        unloadAll();
    }

    public function registerDefaultResourceTypes () :void
    {
        registerResourceType("image", ImageResource);
        registerResourceType("swf", SwfResource);
        registerResourceType("xml", XmlResource);
        registerResourceType("sound", SoundResource);
    }

    public function registerResourceType (resourceType :String, theClass :Class) :void
    {
        _resourceClasses.put(resourceType, theClass);
    }

    public function queueResourceLoad (resourceType :String, resourceName: String, loadParams :*)
        :void
    {
        if (_pendingSet == null) {
            _pendingSet = new ResourceSet(this);
        }

        _pendingSet.queueResourceLoad(resourceType, resourceName, loadParams);
    }

    public function loadQueuedResources (onLoaded :Function = null, onLoadErr :Function = null)
        :void
    {
        if (_pendingSet == null) {
            throw new Error("No resources queued for loading");
        }

        var loadingSet :ResourceSet = _pendingSet;
        _pendingSet = null;
        loadingSet.load(onLoaded, onLoadErr);
    }

    public function cancelLoad () :void
    {
        var loadingSets :Array = _loadingSets;
        for each (var rsrcSet :ResourceSet in loadingSets) {
            rsrcSet.unload();
        }

        _pendingSet = null;
    }

    /**
     * @deprecated
     */
    public function unload (resourceName :String) :void
    {
        var rsrc :Resource = (_resources.remove(resourceName));
        if (rsrc != null) {
            rsrc.loadable.unload();
        }
    }

    public function getResource (resourceName :String) :Resource
    {
        return (_resources.get(resourceName) as Resource);
    }

    public function isResourceLoaded (name :String) :Boolean
    {
        return (null != getResource(name));
    }

    public function get isLoading () :Boolean
    {
        return _loadingSets.length > 0;
    }

    protected function unloadAll () :void
    {
        for each (var rsrc :Resource in _resources.values()) {
            rsrc.loadable.unload();
        }

        _resources.clear();
    }

    internal function createResource (resourceType :String, resourceName :String, loadParams :*)
        :Resource
    {
        var loaderClass :Class = _resourceClasses.get(resourceType);
        if (null != loaderClass) {
            return (new loaderClass(resourceName, loadParams) as Resource);
        }

        return null;
    }

    internal function setResourceSetLoading (resourceSet :ResourceSet, loading :Boolean) :void
    {
        if (loading) {
            _loadingSets.push(resourceSet);
        } else {
            ArrayUtil.removeFirst(_loadingSets, resourceSet);
        }
    }

    internal function addResources (resources :Array) :void
    {
        var rsrc :Resource;
        // validate all resources before adding them
        for each (rsrc in resources) {
            if (getResource(rsrc.resourceName) != null) {
                throw new Error("A resource named '" + rsrc.resourceName + "' already exists");
            }
        }
        for each (rsrc in resources) {
            _resources.put(rsrc.resourceName, rsrc);
        }
    }

    internal function removeResources (resources :Array) :void
    {
        for each (var rsrc :Resource in resources) {
            _resources.remove(rsrc.resourceName);
        }
    }

    protected var _resources :Map = Maps.newMapOf(String); // Map<name, resource>
    protected var _pendingSet :ResourceSet;
    protected var _loadingSets :Array = [];

    protected var _resourceClasses :Map = Maps.newMapOf(String);

    protected static var log :Log = Log.getLog(ResourceManager);
}

}
