/*
 * This file is part of MPlayer.
 *
 * MPlayer is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * MPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with MPlayer; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "talloc.h"

#include "config.h"
#include "ao.h"
#include "audio/format.h"

#include "mpvcore/options.h"
#include "mpvcore/m_config.h"
#include "mpvcore/mp_msg.h"
#include "mpvcore/mpv_global.h"

extern const struct ao_driver audio_out_oss;
extern const struct ao_driver audio_out_coreaudio;
extern const struct ao_driver audio_out_rsound;
extern const struct ao_driver audio_out_pulse;
extern const struct ao_driver audio_out_jack;
extern const struct ao_driver audio_out_openal;
extern const struct ao_driver audio_out_null;
extern const struct ao_driver audio_out_alsa;
extern const struct ao_driver audio_out_dsound;
extern const struct ao_driver audio_out_wasapi;
extern const struct ao_driver audio_out_pcm;
extern const struct ao_driver audio_out_lavc;
extern const struct ao_driver audio_out_portaudio;
extern const struct ao_driver audio_out_sdl;

static const struct ao_driver * const audio_out_drivers[] = {
// native:
#ifdef CONFIG_COREAUDIO
    &audio_out_coreaudio,
#endif
#ifdef CONFIG_PULSE
    &audio_out_pulse,
#endif
#ifdef CONFIG_ALSA
    &audio_out_alsa,
#endif
#ifdef CONFIG_WASAPI
    &audio_out_wasapi,
#endif
#ifdef CONFIG_OSS_AUDIO
    &audio_out_oss,
#endif
#ifdef CONFIG_DSOUND
    &audio_out_dsound,
#endif
#ifdef CONFIG_PORTAUDIO
    &audio_out_portaudio,
#endif
    // wrappers:
#ifdef CONFIG_JACK
    &audio_out_jack,
#endif
#ifdef CONFIG_OPENAL
    &audio_out_openal,
#endif
#ifdef CONFIG_SDL
    &audio_out_sdl,
#endif
    &audio_out_null,
    // should not be auto-selected:
    &audio_out_pcm,
#ifdef CONFIG_ENCODING
    &audio_out_lavc,
#endif
#ifdef CONFIG_RSOUND
    &audio_out_rsound,
#endif
    NULL
};

static bool get_desc(struct m_obj_desc *dst, int index)
{
    if (index >= MP_ARRAY_SIZE(audio_out_drivers) - 1)
        return false;
    const struct ao_driver *ao = audio_out_drivers[index];
    *dst = (struct m_obj_desc) {
        .name = ao->info->short_name,
        .description = ao->info->name,
        .priv_size = ao->priv_size,
        .priv_defaults = ao->priv_defaults,
        .options = ao->options,
        .hidden = ao->encode,
        .p = ao,
    };
    return true;
}

// For the ao option
const struct m_obj_list ao_obj_list = {
    .get_desc = get_desc,
    .description = "audio outputs",
    .allow_unknown_entries = true,
    .allow_trailer = true,
};

static struct ao *ao_create(bool probing, struct mpv_global *global,
                            struct input_ctx *input_ctx,
                            struct encode_lavc_context *encode_lavc_ctx,
                            int samplerate, int format, struct mp_chmap channels,
                            char *name, char **args)
{
    struct mp_log *log = mp_log_new(NULL, global->log, "ao");
    struct m_obj_desc desc;
    if (!m_obj_list_find(&desc, &ao_obj_list, bstr0(name))) {
        mp_tmsg_log(log, MSGL_ERR, "Audio output %s not found!\n", name);
        talloc_free(log);
        return NULL;
    };
    struct ao *ao = talloc_ptrtype(NULL, ao);
    talloc_steal(ao, log);
    *ao = (struct ao) {
        .driver = desc.p,
        .probing = probing,
        .opts = global->opts,
        .encode_lavc_ctx = encode_lavc_ctx,
        .input_ctx = input_ctx,
        .samplerate = samplerate,
        .channels = channels,
        .format = format,
        .log = mp_log_new(ao, log, name),
    };
    if (ao->driver->encode != !!ao->encode_lavc_ctx)
        goto error;
    struct m_config *config = m_config_from_obj_desc(ao, &desc);
    if (m_config_set_obj_params(config, args) < 0)
        goto error;
    ao->priv = config->optstruct;
    if (ao->driver->init(ao) < 0)
        goto error;
    ao->bps = ao->channels.num * ao->samplerate * af_fmt2bits(ao->format) / 8;
    return ao;
error:
    talloc_free(ao);
    return NULL;
}

struct ao *ao_init_best(struct mpv_global *global,
                        struct input_ctx *input_ctx,
                        struct encode_lavc_context *encode_lavc_ctx,
                        int samplerate, int format, struct mp_chmap channels)
{
    struct m_obj_settings *ao_list = global->opts->audio_driver_list;
    if (ao_list && ao_list[0].name) {
        for (int n = 0; ao_list[n].name; n++) {
            if (strlen(ao_list[n].name) == 0)
                goto autoprobe;
            mp_tmsg(MSGT_AO, MSGL_V, "Trying preferred audio driver '%s'\n",
                    ao_list[n].name);
            struct ao *ao = ao_create(false, global, input_ctx, encode_lavc_ctx,
                                      samplerate, format, channels,
                                      ao_list[n].name, ao_list[n].attribs);
            if (ao)
                return ao;
            mp_tmsg(MSGT_AO, MSGL_WARN, "Failed to initialize audio driver '%s'\n",
                    ao_list[n].name);
        }
        return NULL;
    }
autoprobe:
    // now try the rest...
    for (int i = 0; audio_out_drivers[i]; i++) {
        struct ao *ao = ao_create(true, global, input_ctx, encode_lavc_ctx,
                                  samplerate, format, channels,
                          (char *)audio_out_drivers[i]->info->short_name, NULL);
        if (ao)
            return ao;
    }
    return NULL;
}

void ao_uninit(struct ao *ao, bool cut_audio)
{
    assert(ao->buffer.len >= ao->buffer_playable_size);
    ao->buffer.len = ao->buffer_playable_size;
    ao->driver->uninit(ao, cut_audio);
    if (!cut_audio && ao->buffer.len)
        mp_msg(MSGT_AO, MSGL_WARN, "Audio output truncated at end.\n");
    talloc_free(ao);
}

int ao_play(struct ao *ao, void *data, int len, int flags)
{
    return ao->driver->play(ao, data, len, flags);
}

int ao_control(struct ao *ao, enum aocontrol cmd, void *arg)
{
    if (ao->driver->control)
        return ao->driver->control(ao, cmd, arg);
    return CONTROL_UNKNOWN;
}

double ao_get_delay(struct ao *ao)
{
    if (!ao->driver->get_delay) {
        assert(ao->untimed);
        return 0;
    }
    return ao->driver->get_delay(ao);
}

int ao_get_space(struct ao *ao)
{
    return ao->driver->get_space(ao);
}

void ao_reset(struct ao *ao)
{
    ao->buffer.len = 0;
    ao->buffer_playable_size = 0;
    if (ao->driver->reset)
        ao->driver->reset(ao);
}

void ao_pause(struct ao *ao)
{
    if (ao->driver->pause)
        ao->driver->pause(ao);
}

void ao_resume(struct ao *ao)
{
    if (ao->driver->resume)
        ao->driver->resume(ao);
}

bool ao_chmap_sel_adjust(struct ao *ao, const struct mp_chmap_sel *s,
                         struct mp_chmap *map)
{
    return mp_chmap_sel_adjust(s, map);
}

bool ao_chmap_sel_get_def(struct ao *ao, const struct mp_chmap_sel *s,
                          struct mp_chmap *map, int num)
{
    return mp_chmap_sel_get_def(s, map, num);
}
