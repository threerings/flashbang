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

package flashbang.util {

import flash.events.TimerEvent;
import flash.utils.Timer;

import com.threerings.util.Log;

public class Loadable
{
    public function Loadable (numRetries :int = 0, retryDelayMs :int = 0)
    {
        // the number of times to retry a failed load attempt
        _numRetries = numRetries;
        // the number of milliseconds to wait between retries
        _retryDelayMs = retryDelayMs;
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
        stopRetryTimer();

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
        if (_retriesRemaining != 0) {
            if (_retriesRemaining > 0) {
                _retriesRemaining--;
            }
            log.warning("Load error, retrying load", "err", err, "retriesRemaining",
                _retriesRemaining);

            if (_retryDelayMs <= 0) {
                doLoad();
            } else {
                startRetryTimer();
            }

        } else {
            var callbacks :Array = _onLoadErrCallbacks;
            unload();
            for each (var callback :Function in callbacks) {
                callback(err);
            }
        }
    }

    /**
     * Subclasses may override this to respond to the canceling of an in-progress load.
     */
    protected function onLoadCanceled () :void
    {
    }

    /**
     * Subclasses must override this to perform the load.
     * If the load is successful, this function should call onLoaded(), otherwise it should
     * call onLoadErr().
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

    protected function startRetryTimer () :void
    {
        stopRetryTimer();
        _retryTimer = new Timer(_retryDelayMs, 1);
        _retryTimer.addEventListener(TimerEvent.TIMER,
            function (...ignored) :void {
                doLoad();
                _retryTimer = null;
            });
        _retryTimer.start();
    }

    protected function stopRetryTimer () :void
    {
        if (_retryTimer != null) {
            _retryTimer.stop();
            _retryTimer = null;
        }
    }

    protected function get willRetry () :Boolean
    {
        return (_retriesRemaining != 0);
    }

    protected var _onLoadedCallbacks :Array = [];
    protected var _onLoadErrCallbacks :Array = [];
    protected var _loading :Boolean;
    protected var _loaded :Boolean;
    protected var _numRetries :int;
    protected var _retryDelayMs :int;
    protected var _retriesRemaining :int;
    protected var _retryTimer :Timer;

    protected static const log :Log = Log.getLog(Loadable);
}

}
