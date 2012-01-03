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

package com.threerings.flashbang.resource {

import com.threerings.util.ClassUtil;
import com.threerings.util.Joiner;
import com.threerings.util.StringUtil;

import com.threerings.flashbang.util.Loadable;

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

    protected function getLoadParam (name :String, defaultValue :* = undefined) :*
    {
        return (hasLoadParam(name) ? _loadParams[name] : defaultValue);
    }

    protected function requireLoadParam (name :String, type :Class) :*
    {
        if (!hasLoadParam(name)) {
            throw new Error("Missing required loadParam [name=" + name + "]");
        }
        var param :* = getLoadParam(name);
        if (!(param is type)) {
            throw new Error("Bad load param [name=" + name + " type=" + type + "]");
        }
        return param;
    }

    protected function createLoadErrorString (errText :String) :String
    {
        return Joiner.pairs(ClassUtil.tinyClassName(this) + " load error",
            "resourceName", _resourceName, "loadParams", StringUtil.simpleToString(_loadParams),
            "err", errText);

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
