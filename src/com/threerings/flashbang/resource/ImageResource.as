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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class ImageResource extends Resource
{
    public static function instantiateBitmap (rsrcs :ResourceManager, resourceName :String) :Bitmap
    {
        var img :ImageResource = rsrcs.getResource(resourceName) as ImageResource;
        if (null != img) {
            return img.createBitmap();
        }

        return null;
    }

    public function ImageResource (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams);

        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
            function (e :IOErrorEvent) :void {
                onError(e.text);
            });
    }

    public function get bitmapData () :BitmapData
    {
        return (_loader.content as Bitmap).bitmapData;
    }

    public function createBitmap (pixelSnapping :String = "auto", smoothing :Boolean = false)
        :Bitmap
    {
        return new Bitmap(this.bitmapData, pixelSnapping, smoothing);
    }

    override protected function load (completeCallback :Function, errorCallback :Function) :void
    {
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;

        // parse loadParams
        if (hasLoadParam("url")) {
            _loader.load(new URLRequest(getLoadParam("url")));
        } else if (hasLoadParam("bytes")) {
            var bytes :ByteArray = getLoadParam("bytes");
            if (bytes == null) {
                onError("missing bytes!");
            } else {
                _loader.loadBytes(getLoadParam("bytes"));
            }
        } else if (hasLoadParam("embeddedClass")) {
            var embeddedClass :Class = getLoadParam("embeddedClass");
            if (embeddedClass == null) {
                onError("missing embedded class!");
            } else {
                _loader.loadBytes(ByteArray(new embeddedClass()));
            }
        } else {
            throw new Error("one of 'url', 'bytes', or 'embeddedClass' must be specified in " +
                "loadParams");
        }
    }

    override protected function unload () :void
    {
        try {
            _loader.close();
        } catch (e :Error) {
            // swallow the exception
        }

        _loader.unload();
    }

    protected function onInit (e :Event) :void
    {
        _completeCallback();
    }

    protected function onError (errText :String) :void
    {
        _errorCallback("ImageResource (" + _resourceName + "): " + errText);
    }

    protected var _loader :Loader;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;
}

}
