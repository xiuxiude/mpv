ACLOCAL_AMFLAGS = -I m4
bin_PROGRAMS = mpv

mpv_SOURCES = \
    talloc.c \
    audio/audio.c \
    audio/chmap.c \
    audio/chmap_sel.c \
    audio/fmt-conversion.c \
    audio/format.c \
    audio/mixer.c \
    audio/reorder_ch.c \
    audio/decode/ad_lavc.c \
    audio/decode/ad_spdif.c      \
    audio/decode/dec_audio.c \
    audio/filter/af.c \
    audio/filter/af_center.c \
    audio/filter/af_channels.c \
    audio/filter/af_delay.c \
    audio/filter/af_dummy.c \
    audio/filter/af_equalizer.c \
    audio/filter/af_extrastereo.c \
    audio/filter/af_force.c \
    audio/filter/af_format.c \
    audio/filter/af_hrtf.c \
    audio/filter/af_karaoke.c \
    audio/filter/af_lavcac3enc.c \
    audio/filter/af_lavrresample.c \
    audio/filter/af_pan.c \
    audio/filter/af_scaletempo.c \
    audio/filter/af_sinesuppress.c \
    audio/filter/af_sub.c \
    audio/filter/af_surround.c \
    audio/filter/af_sweep.c \
    audio/filter/af_tools.c \
    audio/filter/af_drc.c \
    audio/filter/af_volume.c \
    audio/filter/filter.c \
    audio/filter/window.c \
    audio/out/ao.c \
    audio/out/ao_null.c \
    audio/out/ao_pcm.c \
    demux/codec_tags.c \
    demux/demux.c \
    demux/demux_edl.c \
    demux/demux_cue.c \
    demux/demux_lavf.c \
    demux/demux_mf.c \
    demux/demux_mkv.c \
    demux/demux_subreader.c \
    demux/demux_raw.c \
    demux/ebml.c \
    demux/mf.c \
    mpvcore/asxparser.c \
    mpvcore/av_common.c \
    mpvcore/av_log.c \
    mpvcore/av_opts.c \
    mpvcore/bstr.c \
    mpvcore/charset_conv.c \
    mpvcore/codecs.c \
    mpvcore/command.c \
    mpvcore/cpudetect.c \
    mpvcore/m_config.c \
    mpvcore/m_option.c \
    mpvcore/m_property.c \
    mpvcore/mp_common.c \
    mpvcore/mp_msg.c \
    mpvcore/mp_ring.c \
    mpvcore/mplayer.c \
    mpvcore/options.c \
    mpvcore/parser-cfg.c \
    mpvcore/parser-mpcmd.c \
    mpvcore/path.c \
    mpvcore/playlist.c \
    mpvcore/playlist_parser.c \
    mpvcore/screenshot.c \
    mpvcore/version.c \
    mpvcore/input/input.c \
    mpvcore/timeline/tl_edl.c \
    mpvcore/timeline/tl_matroska.c \
    mpvcore/timeline/tl_cue.c \
    osdep/@osdep_getch@.c \
    osdep/io.c \
    osdep/numcores.c \
    osdep/timer.c \
    osdep/@osdep_timer@.c \
    stream/cookies.c \
    stream/stream.c \
    stream/stream_avdevice.c \
    stream/stream_file.c \
    stream/stream_lavf.c \
    stream/stream_memory.c \
    stream/stream_mf.c \
    stream/stream_null.c \
    sub/dec_sub.c \
    sub/draw_bmp.c \
    sub/find_subfiles.c \
    sub/img_convert.c \
    sub/sd_lavc.c \
    sub/sd_lavc_conv.c \
    sub/sd_lavf_srt.c \
    sub/sd_microdvd.c \
    sub/sd_movtext.c \
    sub/sd_spu.c \
    sub/sd_srt.c \
    sub/spudec.c \
    sub/sub.c \
    video/csputils.c \
    video/fmt-conversion.c \
    video/image_writer.c \
    video/img_format.c \
    video/mp_image.c \
    video/mp_image_pool.c \
    video/sws_utils.c \
    video/decode/dec_video.c \
    video/decode/vd.c \
    video/decode/vd_lavc.c \
    video/filter/vf.c \
    video/filter/pullup.c \
    video/filter/vf_crop.c \
    video/filter/vf_delogo.c \
    video/filter/vf_divtc.c \
    video/filter/vf_down3dright.c \
    video/filter/vf_dsize.c \
    video/filter/vf_eq.c \
    video/filter/vf_expand.c \
    video/filter/vf_flip.c \
    video/filter/vf_format.c \
    video/filter/vf_gradfun.c \
    video/filter/vf_hqdn3d.c \
    video/filter/vf_ilpack.c \
    video/filter/vf_mirror.c \
    video/filter/vf_noformat.c \
    video/filter/vf_noise.c \
    video/filter/vf_phase.c \
    video/filter/vf_pullup.c \
    video/filter/vf_rotate.c \
    video/filter/vf_scale.c \
    video/filter/vf_screenshot.c \
    video/filter/vf_softpulldown.c \
    video/filter/vf_stereo3d.c \
    video/filter/vf_sub.c \
    video/filter/vf_swapuv.c \
    video/filter/vf_unsharp.c \
    video/filter/vf_vo.c \
    video/filter/vf_yadif.c \
    video/out/bitmap_packer.c \
    video/out/aspect.c \
    video/out/filter_kernels.c \
    video/out/vo.c \
    video/out/vo_null.c \
    video/out/vo_image.c

if HAVE_SYS_MMAN_H
  mpv_SOURCES += audio/filter/af_export.c
endif

if HAVE_STREAM_CACHE
  mpv_SOURCES += stream/cache.c
endif

if HAVE_LIBPOSTPROC
  mpv_SOURCES += video/filter/vf_pp.c
endif

if !HAVE_LIBAVUTIL_REFCOUNTING
  mpv_SOURCES += video/decode/lavc_dr1.c
endif

if HAVE_LIBASS
  mpv_SOURCES += sub/ass_mp.c sub/sd_ass.c demux/demux_libass.c
endif

if HAVE_LIBASS_OSD
  mpv_SOURCES += sub/osd_libass.c
else
  mpv_SOURCES += sub/osd_dummy.c
endif

mpvcore/input/input.c: mpvcore/input/input_conf.h
mpvcore/input/input_conf.h: TOOLS/file2string.pl etc/input.conf
	./$^ >$@

MKVLIB_DEPS = TOOLS/lib/Parse/Matroska.pm \
              TOOLS/lib/Parse/Matroska/Definitions.pm \
              TOOLS/lib/Parse/Matroska/Element.pm \
              TOOLS/lib/Parse/Matroska/Reader.pm \
              TOOLS/lib/Parse/Matroska/Utils.pm

demux/ebml.c demux/demux_mkv.c: demux/ebml_types.h
demux/ebml_types.h: TOOLS/matroska.pl $(MKVLIB_DEPS)
	./$< --generate-header > $@

demux/ebml.c: demux/ebml_defs.c
demux/ebml_defs.c: TOOLS/matroska.pl $(MKVLIB_DEPS)
	./$< --generate-definitions > $@

video/out/gl_video.c: video/out/gl_video_shaders.h
video/out/gl_video_shaders.h: TOOLS/file2string.pl video/out/gl_video_shaders.glsl
	./$^ >$@

sub/osd_libass.c: sub/osd_font.h
sub/osd_font.h: TOOLS/file2string.pl sub/osd_font.otf
	./$^ >$@
