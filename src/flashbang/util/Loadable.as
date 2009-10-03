// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
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
// $Id: Loadable.as 9755 2009-09-24 01:34:59Z tim $

package com.whirled.contrib.simplegame.util {

import com.threerings.util.Log;

public class Loadable
{
    public function Loadable (numRetries :int = 0)
    {
        // the number of times to retry a failed load attempt
        _numRetries = numRetries;
    }

    public function load (onLoaded :Function = null, onLoadErr :Function = null) :void
    {
        if (_loaded && onLoaded != null) {
            onLoaded();

        } else if (!_loaded) {
            if (onLoaded != null) {
                _onLoadedCallbacks.push(onLoaded);
            }
            if (onLoadErr != null) {
                _onLoadErrCallbacks.push(onLoadErr);
            }

            if (!_loading) {
                _loading = true;
                _retriesRemaining = _numRetries;
                doLoad();
            }
        }
    }

    public function unload () :void
    {
        if (_loading) {
            onLoadCanceled();
        }

        _loaded = false;
        _loading = false;
        _onLoadedCallbacks = [];
        _onLoadErrCallbacks = [];

        doUnload();
    }

    public function get isLoaded () :Boolean
    {
        return _loaded;
    }

    protected function onLoaded () :void
    {
        var callbacks :Array = _onLoadedCallbacks;

        _onLoadedCallbacks = [];
        _onLoadErrCallbacks = [];
        _loaded = true;
        _loading = false;

        for each (var callback :Function in callbacks) {
            callback();
        }
    }

    protected function onLoadErr (err :String) :void
    {
        log.error("load error: " + err);

        if (_retriesRemaining != 0) {
            if (_retriesRemaining > 0) {
                _retriesRemaining--;
            }
            log.info("Retrying load", "retriesRemaining", _retriesRemaining);
            doLoad();

        } else {
            var callbacks :Array = _onLoadErrCallbacks;
            unload();
            for each (var callback :Function in callbacks) {
                callback(err);
            }
        }
    }

    /**
     * Subclasses may override this to perform logic when an in-progress load is canceled.
     */
    protected function onLoadCanceled () :void
    {
    }

    /**
     * Subclasses must override this to perform the load.
     * If the load is successful, this function should call onLoaded, otherwise it should
     * call unLoadErr.
     */
    protected function doLoad () :void
    {
        throw new Error("abstract");
    }

    /**
     * Subclasses must override this to perform the unload.
     */
    protected function doUnload () :void
    {
        throw new Error("abstract");
    }

    protected var _onLoadedCallbacks :Array = [];
    protected var _onLoadErrCallbacks :Array = [];
    protected var _loading :Boolean;
    protected var _loaded :Boolean;
    protected var _numRetries :int;
    protected var _retriesRemaining :int;

    protected static const log :Log = Log.getLog(Loadable);
}

}
