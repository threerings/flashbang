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

package flashbang.resource {

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Preconditions;

import flashbang.Flashbang;
import flashbang.util.LoadableBatch;

public class ResourceSet extends LoadableBatch
{
    public function ResourceSet (loadInSequence :Boolean = false)
    {
        super(loadInSequence);
    }

    /**
     * @return true if this ResourceSet contains a resource of the given name, regardless of
     * whether that resource has been loaded or not.
     */
    public function containsResource (resourceName :String) :Boolean
    {
        return _resources.containsKey(resourceName);
    }

    public function queueResourceLoad (resourceType :String, resourceName: String, loadParams :*)
        :void
    {
        Preconditions.checkArgument(!_resources.containsKey(resourceName),
            "A resource named '" + resourceName + "' already exists");

        var rsrc :Resource = Flashbang.rsrcs.createResource(resourceType, resourceName, loadParams);
        Preconditions.checkArgument(null != rsrc,
            "Unrecognized Resource type '" + resourceType + "'");

        addLoadable(rsrc.loadable);
        _resources.put(resourceName, rsrc);
    }

    override protected function doLoad () :void
    {
        Flashbang.rsrcs.setResourceSetLoading(this, true);
        super.doLoad();
    }

    override protected function onLoaded () :void
    {
        Flashbang.rsrcs.setResourceSetLoading(this, false);
        if(addLoadedResources()) {
            super.onLoaded();
        }
    }

    protected function addLoadedResources () :Boolean
    {
        // add resources to the ResourceManager
        try {
            Flashbang.rsrcs.addResources(_resources.values());
        } catch (e :Error) {
            onLoadErr(e.message);
            return false;
        }

        return true;
    }

    override protected function onLoadCanceled () :void
    {
        Flashbang.rsrcs.setResourceSetLoading(this, false);
        super.onLoadCanceled();
    }

    override protected function doUnload () :void
    {
        super.doUnload();
        Flashbang.rsrcs.removeResources(_resources.values());
    }

    protected var _resources :Map = Maps.newMapOf(String);

    protected static const log :Log = Log.getLog(ResourceSet);
}

}
