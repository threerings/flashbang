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

package com.threerings.flashbang.audio {

import com.threerings.flashbang.FlashbangApp;
import com.threerings.flashbang.Updatable;
import com.threerings.flashbang.resource.*;
import com.threerings.util.F;
import com.threerings.util.Log;

import flash.events.Event;
import flash.media.SoundTransform;
import flash.utils.getTimer;

public class AudioManager
    implements Updatable
{
    public static const LOOP_FOREVER :int = -1;

    public function AudioManager (app :FlashbangApp, maxChannels :int = 25)
    {
        _app = app;
        _maxChannels = maxChannels;

        _masterControls = new AudioControls();
        _soundTypeControls = new Array(SoundResource.TYPE__LIMIT);
        for (var ii :int = 0; ii < SoundResource.TYPE__LIMIT; ++ii) {
            var subControls :AudioControls = new AudioControls(_masterControls);
            subControls.retain(); // these subcontrols will never be cleaned up
            _soundTypeControls[ii] = subControls;
        }
    }

    public function get masterControls () :AudioControls
    {
        return _masterControls;
    }

    public function get musicControls () :AudioControls
    {
        return getControlsForSoundType(SoundResource.TYPE_MUSIC);
    }

    public function get sfxControls () :AudioControls
    {
        return getControlsForSoundType(SoundResource.TYPE_SFX);
    }

    public function getControlsForSoundType (type :int) :AudioControls
    {
        if (type >= 0 && type < _soundTypeControls.length) {
            return _soundTypeControls[type];
        }

        return null;
    }

    public function shutdown () :void
    {
        stopAllSounds();
    }

    public function update (dt :Number) :void
    {
        _masterControls.update(dt, DEFAULT_AUDIO_STATE);

        // update all playing sound channels
        var hasStoppedChannels :Boolean = false;
        for each (var channel :AudioChannel in _activeChannels) {
            if (channel.isPlaying) {
                var audioState :AudioState = channel.controls.state;
                var channelPaused :Boolean = channel.isPaused;
                if (audioState.stopped) {
                    stop(channel);
                } else if (audioState.paused && !channelPaused) {
                    pause(channel);
                } else if (!audioState.paused && channelPaused) {
                    resume(channel);
                } else if (!channelPaused) {
                    var curTransform :SoundTransform = channel.channel.soundTransform;
                    var curVolume :Number = curTransform.volume;
                    var curPan :Number = curTransform.pan;
                    var newVolume :Number = audioState.actualVolume * channel.sound.volume;
                    var newPan :Number = audioState.pan * channel.sound.pan;
                    if (newVolume != curVolume || newPan != curPan) {
                        channel.channel.soundTransform = new SoundTransform(newVolume, newPan);
                    }
                }
            }

            if (!channel.isPlaying) {
                hasStoppedChannels = true;
            }
        }

        // Remove inactive channels
        if (hasStoppedChannels) {
            _activeChannels = _activeChannels.filter(activeChannelFilter);
        }
    }

    public function playSoundNamed (name :String, parentControls :AudioControls = null,
        loopCount :int = 0) :AudioChannel
    {
        var rsrc :SoundResource = _app.rsrcs.getResource(name) as SoundResource;
        if (null == rsrc) {
            log.info("Discarding sound '" + name + "' (sound does not exist)");
            return new AudioChannel();
        }

        return playSound(rsrc, parentControls, loopCount);
    }

    public function playSound (soundResource :SoundResource, parentControls :AudioControls = null,
        loopCount :int = 0) :AudioChannel
    {
        if (null == soundResource.sound) {
            log.info("Discarding sound '" + soundResource.resourceName + "' (sound is null)");
            return new AudioChannel();
        }

        // get the appropriate parent controls
        if (null == parentControls) {
            parentControls = getControlsForSoundType(soundResource.type);
            if (null == parentControls) {
                parentControls = _masterControls;
            }
        }

        // don't play the sound if its parent controls are stopped
        var audioState :AudioState = parentControls.updateStateNow();
        if (audioState.stopped) {
            log.info("Discarding sound '" + soundResource.resourceName +
                "' (parent controls are stopped)");
            return new AudioChannel();
        }

        var timeNow :int = flash.utils.getTimer();

        // Iterate the active channels to determine if this sound has been played recently.
        // Also look for the lowest-priority active channel.
        var lowestPriorityChannel :AudioChannel;
        var lowestPriorityChannelIdx :int = -1;
        for (var ii :int = 0; ii < _activeChannels.length; ++ii) {
            var activeChannel :AudioChannel = _activeChannels[ii];
            if (activeChannel.isPlaying) {
                if (activeChannel.sound == soundResource &&
                    (timeNow - activeChannel.startTime) < SOUND_PLAYED_RECENTLY_DELTA) {
                    /*log.info("Discarding sound '" + soundResource.resourceName +
                               "' (recently played)");*/
                    return new AudioChannel();
                }
            }

            if (null == lowestPriorityChannel ||
                activeChannel.priority < lowestPriorityChannel.priority) {

                lowestPriorityChannel = activeChannel;
                lowestPriorityChannelIdx = ii;
            }
        }

        // Are we out of channels?
        if (_activeChannels.length >= _maxChannels) {
            // Can we shut down a playing channel?
            if (null != lowestPriorityChannel &&
                soundResource.priority > lowestPriorityChannel.priority) {
                // steal the channel from a lower-priority sound
                if (lowestPriorityChannel.sound != null) {
                    log.info("Interrupting sound '" + lowestPriorityChannel.sound.resourceName +
                        "' for higher-priority sound '" + soundResource.resourceName + "'");
                }
                stop(lowestPriorityChannel);
                _activeChannels.splice(lowestPriorityChannelIdx, 1);
            } else {
                // We're out of luck
                log.info("Discarding sound '" + soundResource.resourceName +
                    "' (no free AudioChannels)");
                return new AudioChannel();
            }
        }

        // Create the channel
        var channel :AudioChannel = new AudioChannel();
        channel.completeHandler = F.callback(handleComplete, channel);
        channel.controls = new AudioControls(parentControls);
        channel.controls.retain();
        channel.sound = soundResource;
        channel.playPosition = 0;
        channel.startTime = timeNow;
        channel.loopCount = loopCount;

        // start playing
        if (!audioState.paused) {
            playChannel(channel, audioState, 0);

            // Flash must've run out of sound channels
            if (null == channel.channel) {
                log.info("Discarding sound '" + soundResource.resourceName +
                    "' (Flash is out of channels)");
                channel.controls.release();
                return new AudioChannel();
            }
        }

        _activeChannels.push(channel);
        return channel;
    }

    public function stopAllSounds () :void
    {
        // shutdown all sounds
        for each (var channel :AudioChannel in _activeChannels) {
            stop(channel);
        }
        _activeChannels = [];
    }

    public function stop (channel :AudioChannel) :void
    {
        if (channel.isPlaying) {
            if (null != channel.channel) {
                channel.channel.removeEventListener(Event.SOUND_COMPLETE, channel.completeHandler);
                channel.channel.stop();
                channel.channel = null;
            }

            channel.controls.release();
            channel.controls = null;

            channel.sound = null;
        }
    }

    public function pause (channel :AudioChannel) :void
    {
        if (channel.isPlaying && !channel.isPaused) {
            // save the channel's current play position
            channel.playPosition = channel.channel.position;

            // stop playing
            channel.channel.removeEventListener(Event.SOUND_COMPLETE, channel.completeHandler);
            channel.channel.stop();
            channel.channel = null;
        }
    }

    public function resume (channel :AudioChannel) :void
    {
        if (channel.isPlaying && channel.isPaused) {
            playChannel(channel, channel.controls.state, channel.playPosition);
        }
    }

    protected function handleComplete (channel :AudioChannel) :void
    {
        // does the sound need to loop?
        if (channel.loopCount == 0) {
            stop(channel);
            channel.completed.dispatch();

        } else if (playChannel(channel, channel.controls.state, 0)) {
            channel.loopCount--;
        }
    }

    protected function playChannel (channel :AudioChannel, audioState :AudioState,
        playPosition :Number) :Boolean
    {
        var volume :Number = audioState.actualVolume * channel.sound.volume;
        var pan :Number = audioState.pan * channel.sound.pan;
        channel.channel = channel.sound.sound.play(playPosition, 0,
            new SoundTransform(volume, pan));

        if (null != channel.channel) {
            channel.channel.addEventListener(Event.SOUND_COMPLETE, channel.completeHandler);
            return true;

        } else {
            stop(channel);
            return false;
        }
    }

    protected static function activeChannelFilter (channel :AudioChannel, ..._) :Boolean
    {
        return channel.isPlaying;
    }

    protected var _app :FlashbangApp;
    protected var _maxChannels :int;
    protected var _activeChannels :Array = [];
    protected var _masterControls :AudioControls;
    protected var _soundTypeControls :Array; // of AudioControls

    protected static const log :Log = Log.getLog(AudioManager);

    protected static const DEFAULT_AUDIO_STATE :AudioState = AudioState.defaultState();

    protected static const SOUND_PLAYED_RECENTLY_DELTA :int = 1000 / 20;
}

}
