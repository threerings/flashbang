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
// $Id: XmlResource.as 9624 2009-06-26 00:19:45Z tim $

package flashbang.resource {

import com.threerings.util.Util;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class XmlResource extends Resource
{
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

        if (_loadParams.hasOwnProperty("url")) {
            loadFromURL(_loadParams["url"]);
        } else if (_loadParams.hasOwnProperty("embeddedClass")) {
            loadFromEmbeddedClass(_loadParams["embeddedClass"]);
        } else if (_loadParams.hasOwnProperty("text")) {
            loadFromText(_loadParams["text"]);
        } else {
            throw new Error("XmlResourceLoader: 'url', 'embeddedClass', or 'text' must be " +
                            "specified in loadParams");
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
        }
    }

    protected function loadFromURL (urlString :String) :void
    {
        _urlLoader = new URLLoader();
        _urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
        _urlLoader.addEventListener(Event.COMPLETE, onComplete);
        _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
        _urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);

        _urlLoader.load(new URLRequest(_loadParams["url"]));
    }

    protected function loadFromEmbeddedClass (theClass :Class) :void
    {
        try {
            var ba :ByteArray = ByteArray(new theClass());
            instantiateXml(ba.readUTFBytes(ba.length));
        } catch (e :TypeError) {
            instantiateXml(XML(theClass.data));
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
            _xml = Util.newXML(data);
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
        _errorCallback("XmlResourceLoader (" + _resourceName + "): " + errText);
    }

    protected var _urlLoader :URLLoader;
    protected var _xml :XML;
    protected var _generatedObject :*;
    protected var _objectGenerator :Function;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;
}

}
