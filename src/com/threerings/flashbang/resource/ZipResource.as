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

import com.threerings.flashbang.resource.Resource;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipFile;

public class ZipResource extends Resource
{
    public function ZipResource (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams);
    }

    public function get zip () :ZipFile
    {
        return _zip;
    }

    public function getEntryData (entryName :String) :ByteArray
    {
        var entry :ZipEntry = _zip.getEntry(entryName);
        return (entry != null ? _zip.getInput(entry) : null);
    }

    override protected function load (completeCallback :Function, errorCallback :Function) :void
    {
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;

        if (hasLoadParam("url")) {
            loadFromURL(getLoadParam("url"));
        } else if (hasLoadParam("embeddedClass")) {
            var embeddedClass :Class = getLoadParam("embeddedClass");
            if (embeddedClass == null) {
                onError("missing embedded class!");
            } else {
                createZip(ByteArray(new embeddedClass()));
            }
        } else if (hasLoadParam("bytes")) {
            var bytes :ByteArray = getLoadParam("bytes");
            if (bytes == null) {
                onError("missing bytes!");
            } else {
                createZip(bytes);
            }
        } else {
            throw new Error("'url', 'embeddedClass', or 'bytes' must be specified in loadParams");
        }
    }

    override protected function unload () :void
    {
        if (null != _urlLoader) {
            try {
                _urlLoader.close();
            } catch (e :Error) {
                // swallow the exception
            }
            _urlLoader = null;
        }
    }

    protected function loadFromURL (urlString :String) :void
    {
        _urlLoader = new URLLoader();
        _urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        _urlLoader.addEventListener(Event.COMPLETE,
            function (..._) :void {
                createZip(_urlLoader.data);
            });
        _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
        _urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
        _urlLoader.load(new URLRequest(urlString));

        function handleLoadError (e :ErrorEvent) :void {
            onError(e.text);
        }
    }

    protected function loadFromEmbeddedClass (theClass :Class) :void
    {
        try {
            var ba :ByteArray = ByteArray(new theClass());
            createZip(ba);
        } catch (e :TypeError) {
            onError("missing zip data!");
        }
    }

    protected function createZip (bytes :ByteArray) :void
    {
        try {
            _zip = new ZipFile(bytes);
        } catch (e :Error) {
            onError("failed to create ZipFile: " + e.message);
            return;
        }
        _completeCallback();
    }

    protected function onError (errText :String) :void
    {
        _errorCallback(createLoadErrorString(errText));
    }

    protected var _urlLoader :URLLoader;
    protected var _zip :ZipFile;
    protected var _objectGenerator :Function;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;
}

}
