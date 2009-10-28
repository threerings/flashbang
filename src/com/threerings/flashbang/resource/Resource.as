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

import com.threerings.flashbang.util.Loadable;
import com.threerings.util.ClassUtil;
import com.threerings.util.Joiner;

public class Resource
{
    public function Resource (resourceName :String, loadParams :Object)
    {
        _resourceName = resourceName;
        _loadParams = loadParams;

        _loadable = new LoadableResource(load, unload);
    }

    public function get resourceName () :String
    {
        return _resourceName;
    }

    protected function load (onLoaded :Function, onLoadErr :Function) :void
    {
        // subclasses implement
    }

    protected function unload () :void
    {
        // subclasses implement
    }

    protected function hasLoadParam (name :String) :Boolean
    {
        return _loadParams.hasOwnProperty(name);
    }

    protected function getLoadParam (name :String, requiredClazz :Class = null,
        defaultValue :* = undefined) :*
    {
        if (hasLoadParam(name)) {
            var val :* = _loadParams[name];
            if (requiredClazz != null && !(val is requiredClazz)) {
                throw new Error(Joiner.pairs("bad load param", "name", name, "val", val,
                    "requiredClass", requiredClazz, "actualClass", ClassUtil.getClass(val)));
            }
            return val;
        } else if (defaultValue !== undefined) {
            return defaultValue;
        } else {
            return undefined;
        }
    }

    internal function get loadable () :Loadable
    {
        return _loadable;
    }

    protected var _resourceName :String;
    protected var _loadParams :Object;
    protected var _loadable :Loadable;
}

}

import com.threerings.flashbang.util.Loadable;

class LoadableResource extends Loadable
{
    public function LoadableResource (loadFn :Function, unloadFn :Function)
    {
        _loadFn = loadFn;
        _unloadFn = unloadFn;
    }

    override protected function doLoad () :void
    {
        _loadFn(onLoaded, onLoadErr);
    }

    override protected function doUnload () :void
    {
        _unloadFn();
    }

    protected var _loadFn :Function;
    protected var _unloadFn :Function;
}
