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

package com.threerings.flashbang.audio {

public class AudioControls
{
    public function AudioControls (parentControls :AudioControls = null)
    {
        if (null != parentControls) {
            _parentControls = parentControls;
            _parentControls.attachChild(this);
        }
    }

    internal function attachChild (child :AudioControls) :void
    {
        _children.push(child);
    }

    public function retain () :void
    {
        ++_refCount;
    }

    public function release () :void
    {
        if (--_refCount < 0) {
            throw new Error("Cannot release() below a refCount of 0");
        }
    }

    public function volume (val :Number) :AudioControls
    {
        _localState.volume = Math.max(val, 0);
        _localState.volume = Math.min(_localState.volume, 1);
        return this;
    }

    public function volumeTo (targetVal :Number, time :Number) :AudioControls
    {
        if (time <= 0) {
            volume(targetVal);
            _targetVolumeTotalTime = 0;
        } else {
            _initialVolume = _localState.volume;
            var targetVolume :Number = Math.max(targetVal, 0);
            targetVolume = Math.min(targetVolume, 1);
            _targetVolumeDelta = targetVolume - _initialVolume;
            _targetVolumeElapsedTime = 0;
            _targetVolumeTotalTime = time;
        }

        return this;
    }

    public function fadeOut (time :Number) :AudioControls
    {
        return volumeTo(0, time);
    }

    public function fadeIn (time :Number) :AudioControls
    {
        return volumeTo(1, time);
    }

    public function fadeOutAndStop (time :Number) :AudioControls
    {
        return fadeOut(time).stopAfter(time);
    }

    public function pan (val :Number) :AudioControls
    {
        _localState.pan = Math.max(val, -1);
        _localState.pan = Math.min(_localState.pan, 1);
        return this;
    }

    public function panTo (targetVal :Number, time :Number) :AudioControls
    {
        if (time <= 0) {
            pan(targetVal);
            _targetPanTotalTime = 0;
        } else {
            _initialPan = _localState.pan;
            var targetPan :Number = Math.max(targetVal, -1);
            targetPan = Math.min(targetPan, 1);
            _targetPanDelta = targetPan - _initialPan;
            _targetPanElapsedTime = 0;
            _targetPanTotalTime = time;
        }

        return this;
    }

    public function pause (val :Boolean) :AudioControls
    {
        _localState.paused = val;
        _pauseCountdown = 0;
        _unpauseCountdown = 0;
        return this;
    }

    public function pauseAfter (time :Number) :AudioControls
    {
        if (time <= 0) {
            pause(true);
        } else {
            _pauseCountdown = time;
        }

        return this;
    }

    public function unpauseAfter (time :Number) :AudioControls
    {
        if (time <= 0) {
            pause(false);
        } else {
            _unpauseCountdown = time;
        }

        return this;
    }

    public function mute (val :Boolean) :AudioControls
    {
        _localState.muted = val;
        _muteCountdown = 0;
        _unmuteCountdown = 0;
        return this;
    }

    public function muteAfter (time :Number) :AudioControls
    {
        if (time <= 0) {
            mute(true);
        } else {
            _muteCountdown = time;
        }

        return this;
    }

    public function unmuteAfter (time :Number) :AudioControls
    {
        if (time <= 0) {
            mute(false);
        } else {
            _unmuteCountdown = time;
        }

        return this;
    }

    public function stop (val :Boolean) :AudioControls
    {
        _localState.stopped = val;
        _stopCountdown = 0;
        _playCountdown = 0;
        return this;
    }

    public function stopAfter (time :Number) :AudioControls
    {
        if (time <= 0) {
            stop(true);
        } else {
            _stopCountdown = time;
        }

        return this;
    }

    public function playAfter (time :Number) :AudioControls
    {
        if (time <= 0) {
            stop(false);
        } else {
            _playCountdown = time;
        }

        return this;
    }

    public function update (dt :Number, parentState :AudioState) :void
    {
        if (_targetVolumeTotalTime > 0) {
            _targetVolumeElapsedTime =
                Math.min(_targetVolumeElapsedTime + dt, _targetVolumeTotalTime);
            var volumeTransition :Number = _targetVolumeElapsedTime / _targetVolumeTotalTime;
            _localState.volume = _initialVolume + (_targetVolumeDelta * volumeTransition);

            if (_targetVolumeElapsedTime >= _targetVolumeTotalTime) {
                _targetVolumeTotalTime = 0;
            }
        }

        if (_targetPanTotalTime > 0) {
            _targetPanElapsedTime = Math.min(_targetPanElapsedTime + dt, _targetPanTotalTime);
            var panTransition :Number = _targetPanElapsedTime / _targetPanTotalTime;
            _localState.pan = _initialPan + (_targetPanDelta * panTransition);

            if (_targetPanElapsedTime >= _targetPanTotalTime) {
                _targetPanTotalTime = 0;
            }
        }

        if (_pauseCountdown > 0) {
            _pauseCountdown = Math.max(_pauseCountdown - dt, 0);
            if (_pauseCountdown == 0) {
                _localState.paused = true;
            }
        }

        if (_unpauseCountdown > 0) {
            _unpauseCountdown = Math.max(_unpauseCountdown - dt, 0);
            if (_unpauseCountdown == 0) {
                _localState.paused = false;
            }
        }

        if (_muteCountdown > 0) {
            _muteCountdown = Math.max(_muteCountdown - dt, 0);
            if (_muteCountdown == 0) {
                _localState.muted = true;
            }
        }

        if (_unmuteCountdown > 0) {
            _unmuteCountdown = Math.max(_unmuteCountdown - dt, 0);
            if (_unmuteCountdown == 0) {
                _localState.muted = false;
            }
        }

        if (_stopCountdown > 0) {
            _stopCountdown = Math.max(_stopCountdown - dt, 0);
            if (_stopCountdown == 0) {
                _localState.stopped = true;
            }
        }

        if (_playCountdown > 0) {
            _playCountdown = Math.max(_playCountdown - dt, 0);
            if (_playCountdown == 0) {
                _localState.stopped = false;
            }
        }

        _globalState = AudioState.combine(_localState, parentState, _globalState);

        // update children
        for (var ii :int = 0; ii < _children.length; ++ii) {
            var childController :AudioControls = _children[ii];
            childController.update(dt, _globalState);
            if (childController.needsCleanup) {
                // @TODO - use a linked list?
                _children.splice(ii--, 1);
            }
        }
    }

    public function updateStateNow () :AudioState
    {
        if (null != _parentControls) {
            _globalState =
                AudioState.combine(_localState, _parentControls.updateStateNow(), _globalState);
            return _globalState;
        } else {
            return _localState;
        }
    }

    public function get state () :AudioState
    {
        return (null != _parentControls ? _globalState : _localState);
    }

    public function get needsCleanup () :Boolean
    {
        return (_refCount <= 0 && _children.length == 0);
    }

    protected var _parentControls :AudioControls;
    protected var _children :Array = [];

    protected var _refCount :int;

    protected var _localState :AudioState = new AudioState();
    protected var _globalState :AudioState = new AudioState();

    protected var _initialVolume :Number = 0;
    protected var _targetVolumeDelta :Number = 0;
    protected var _targetVolumeElapsedTime :Number = 0;
    protected var _targetVolumeTotalTime :Number = 0;

    protected var _initialPan :Number = 0;
    protected var _targetPanDelta :Number = 0;
    protected var _targetPanElapsedTime :Number = 0;
    protected var _targetPanTotalTime :Number = 0;

    protected var _pauseCountdown :Number = 0;
    protected var _unpauseCountdown :Number = 0;
    protected var _muteCountdown :Number = 0;
    protected var _unmuteCountdown :Number = 0;
    protected var _stopCountdown :Number = 0;
    protected var _playCountdown :Number = 0;
}

}
