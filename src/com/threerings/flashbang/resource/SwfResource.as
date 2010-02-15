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

import com.threerings.util.ClassUtil;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class SwfResource extends Resource
{
    public static function instantiateMovieClip (rsrcs :ResourceManager, resourceName :String,
        className :String, disableMouseInteraction :Boolean = false, fromCache :Boolean = false)
        :MovieClip
    {
        var theClass :Class = getClass(rsrcs, resourceName, className);
        if (theClass != null) {
            var movie :MovieClip;
            if (fromCache) {
                var cache :Array = getCache(theClass);
                if (cache.length > 0) {
                    movie = cache.pop();
                    // Reset some properties of the cached movie
                    movie.gotoAndPlay(1);
                    movie.x = movie.y = 0;
                    movie.scaleX = movie.scaleY = 1;
                    movie.rotation = 0;
                }
            }
            if (movie == null) {
                movie = new theClass();
            }
            if (disableMouseInteraction) {
                movie.mouseChildren = false;
                movie.mouseEnabled = false;
            }
            return movie;
        }

        return null;
    }

    public static function releaseMovieClip (mc :MovieClip) :void
    {
        if (mc.parent != null) {
            mc.parent.removeChild(mc);
        }
        mc.stop();
        var cache :Array = getCache(ClassUtil.getClass(mc));
        if (cache.indexOf(mc) == -1) {
            cache.push(mc);
        }
    }

    public static function instantiateButton (rsrcs :ResourceManager, resourceName :String,
        className :String) :SimpleButton
    {
        var theClass :Class = getClass(rsrcs, resourceName, className);
        return (null != theClass ? new theClass() : null);
    }

    public static function getBitmapData (rsrcs :ResourceManager, resourceName :String,
        className :String, width :int, height :int) :BitmapData
    {
        var theClass :Class = getClass(rsrcs, resourceName, className);
        return (null != theClass ? new theClass(width, height) : null);
    }

    public static function getSwfDisplayRoot (rsrcs :ResourceManager, resourceName :String)
        :DisplayObject
    {
        var swf :SwfResource = getSwf(rsrcs, resourceName);
        return (null != swf ? swf.displayRoot : null);
    }

    public static function getSwf (rsrcs :ResourceManager, resourceName :String) :SwfResource
    {
        return rsrcs.getResource(resourceName) as SwfResource;
    }

    public function SwfResource (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams);

        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
            function (e :IOErrorEvent) :void {
                onError(e.text);
            });
    }

    public function getSymbol (name :String) :Object
    {
        try {
            return _loader.contentLoaderInfo.applicationDomain.getDefinition(name);
        } catch (e :Error) {
            // swallow the exception and return null
        }

        return null;
    }

    public function hasSymbol (name :String) :Boolean
    {
        return _loader.contentLoaderInfo.applicationDomain.hasDefinition(name);
    }

    public function getFunction (name :String) :Function
    {
        return getSymbol(name) as Function;
    }

    public function getClass (name :String) :Class
    {
        return getSymbol(name) as Class;
    }

    public function get displayRoot () :DisplayObject
    {
        return _loader.content;
    }

    override protected function load (completeCallback :Function, errorCallback :Function) :void
    {
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;

        var context :LoaderContext = new LoaderContext();

        // allowLoadBytesCodeExecution is an AIR-only LoaderContext property that must be true
        // to avoid 'SecurityError: Error #3015' when loading swfs with executable code
        try {
            Object(context)["allowLoadBytesCodeExecution"] = true;
        } catch (e :Error) {}

        // parse loadParams
        if (getLoadParam("useSubDomain", true)) {
            // default to loading symbols into a subdomain
            context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
        } else {
            context.applicationDomain = ApplicationDomain.currentDomain;
        }

        if (hasLoadParam("url")) {
            _loader.load(new URLRequest(getLoadParam("url")), context);
        } else if (hasLoadParam("bytes")) {
            var bytes :ByteArray = getLoadParam("bytes");
            if (bytes == null) {
                onError("missing bytes!");
            } else {
                _loader.loadBytes(bytes, context);
            }
        } else if (hasLoadParam("embeddedClass")) {
            var embeddedClass :Class = getLoadParam("embeddedClass");
            if (embeddedClass == null) {
                onError("missing embedded class!");
            } else {
                _loader.loadBytes(ByteArray(new embeddedClass()), context);
            }
        } else {
            throw new Error("one of 'url', 'bytes', or 'embeddedClass' must be specified in " +
                "loadParams");
        }
    }

    override protected function unload () :void
    {
        try {
            if (!_loaded) {
                _loader.close();
            }
        } catch (e :Error) {
            // swallow exceptions
        }

        try {
            _loader.unload();
        } catch (e :Error) {
            // swallow exceptions
        }

        _loaded = false;
    }

    protected function onInit (...ignored) :void
    {
        _completeCallback();
        _loaded = true;
    }

    protected function onError (errText :String) :void
    {
        _errorCallback(createLoadErrorString(errText));
    }

    protected static function getClass (rsrcs :ResourceManager, resourceName :String,
        className :String) :Class
    {
        var swf :SwfResource = getSwf(rsrcs, resourceName);
        return (null != swf ? swf.getClass(className) : null);
    }

    protected static function getCache (c :Class) :Array
    {
        return (_mcCache[c] == null ? _mcCache[c] = new Array() : _mcCache[c]);
    }

    protected var _loaded :Boolean;
    protected var _loader :Loader;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;

    protected static var _mcCache :Dictionary = new Dictionary();
}

}
