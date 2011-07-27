//
// Flashbang - a framework for creating Flash games
// Copyright (C) 2008-2011 Three Rings Design, Inc., All Rights Reserved
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

import com.threerings.util.XmlUtil;

public class XmlResource extends Resource
{
    /** Load params */

    /** A String containing the URL to load the XML from.
     * (URL, BYTES, EMBEDDED_CLASS or TEXT must be specified). */
    public static const URL :String = "url";

    /** A ByteArray containing the XML.
     * (URL, BYTES, EMBEDDED_CLASS or TEXT must be specified). */
    public static const BYTES :String = "bytes";

    /** The [Embed]'d class to load the XML from.
     * (URL, BYTES, EMBEDDED_CLASS or TEXT must be specified). */
    public static const EMBEDDED_CLASS :String = "embeddedClass";

    /** A String containing the XML.
     * (URL, BYTES, EMBEDDED_CLASS or TEXT must be specified). */
    public static const TEXT :String = "text";

    public function XmlResource (resourceName :String, loadParams :Object,
        objectGenerator :Function = null)
    {
        super(resourceName, loadParams);
        _objectGenerator = objectGenerator;
    }

    public function get xml () :XML
    {
        return _xml;
    }

    public function get generatedObject () :*
    {
        return _generatedObject;
    }

    override protected function load (completeCallback :Function, errorCallback :Function) :void
    {
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;

        if (hasLoadParam(URL)) {
            loadFromURL(getLoadParam(URL));
        } else if (hasLoadParam(EMBEDDED_CLASS)) {
            loadFromEmbeddedClass(getLoadParam(EMBEDDED_CLASS));
        } else if (hasLoadParam(BYTES)) {
            var bytes :ByteArray = getLoadParam(BYTES);
            if (bytes == null) {
                onError("missing bytes!");
            } else {
                instantiateXml(bytes.readUTFBytes(bytes.length));
            }
        } else if (hasLoadParam(TEXT)) {
            loadFromText(getLoadParam(TEXT));
        } else {
            throw new Error("'url', 'embeddedClass', 'bytes', or 'text' must be specified in " +
                "loadParams");
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
        _urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
        _urlLoader.addEventListener(Event.COMPLETE, onComplete);
        _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
        _urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
        _urlLoader.load(new URLRequest(urlString));
    }

    protected function loadFromEmbeddedClass (theClass :Class) :void
    {
        try {
            var ba :ByteArray = ByteArray(new theClass());
            instantiateXml(ba.readUTFBytes(ba.length));
        } catch (e :TypeError) {
            if (theClass != null && theClass.hasOwnProperty("data")) {
                instantiateXml(XML(theClass.data));
            } else {
                onError("missing XML data!");
            }
        }
    }

    protected function loadFromText (text :String) :void
    {
        instantiateXml(text);
    }

    protected function onComplete (...ignored) :void
    {
        instantiateXml(_urlLoader.data);
    }

    protected function instantiateXml (data :*) :void
    {
        // the XML may be malformed, so catch errors thrown when it's instantiated
        try {
            // override the default XML settings, so we get the full text content
            var settings :Object = XML.defaultSettings();
            settings["ignoreWhitespace"] = false;
            settings["prettyPrinting"] = false;
            _xml = XmlUtil.newXML(data, settings);
        } catch (e :Error) {
            onError(e.message);
            return;
        }

        // if we have an object generator function, run the XML through it
        if (null != _objectGenerator) {
            try {
                _generatedObject = _objectGenerator(_xml);
            } catch (e :Error) {
                onError(e.message + "\n\n" + e.getStackTrace());
                return;
            }
        }

        _completeCallback();
    }

    protected function handleLoadError (e :ErrorEvent) :void
    {
        onError(e.text);
    }

    protected function onError (errText :String) :void
    {
        _errorCallback(createLoadErrorString(errText));
    }

    protected var _urlLoader :URLLoader;
    protected var _xml :XML;
    protected var _generatedObject :*;
    protected var _objectGenerator :Function;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;
}

}
