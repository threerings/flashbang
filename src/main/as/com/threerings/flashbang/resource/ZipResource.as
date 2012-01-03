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

import com.threerings.flashbang.resource.Resource;

public class ZipResource extends Resource
{
    /** Load params */

    /** A String containing the URL to load the zip from.
     * (URL, BYTES, or EMBEDDED_CLASS must be specified). */
    public static const URL :String = "url";

    /** The [Embed]'d class to load the zip from.
     * (URL, BYTES, or EMBEDDED_CLASS must be specified). */
    public static const EMBEDDED_CLASS :String = "embeddedClass";

    /** A ByteArray containing the zip.
     * (URL, BYTES, or EMBEDDED_CLASS must be specified). */
    public static const BYTES :String = "bytes";

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

        if (hasLoadParam(URL)) {
            loadFromURL(getLoadParam(URL));
        } else if (hasLoadParam(EMBEDDED_CLASS)) {
            var embeddedClass :Class = getLoadParam(EMBEDDED_CLASS);
            if (embeddedClass == null) {
                onError("missing embedded class!");
            } else {
                createZip(ByteArray(new embeddedClass()));
            }
        } else if (hasLoadParam(BYTES)) {
            var bytes :ByteArray = getLoadParam(BYTES);
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
