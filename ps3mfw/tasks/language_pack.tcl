#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 950
# Description: Language Pack

# Option --language-pack: Language Pack path
# Option --language-replace: Language Pack to replace (keep empty for none)
# Option --language-font: Replace fonts

# Type --language-pack: file open {"Language Pack" {.LP}}
# Type --language-replace: combobox {{} {English} {French} {German} {Italian} {Finnish} {Dutch} {Danish} {Swedish} {Spanish} {Russian} {Portugese} {Norwegian} {Korean} {ChineseTrad} {ChineseSimpl} {Japanese}}
# Type --language-font: boolean


namespace eval ::language_pack {

    array set ::language_pack::options {
        --language-pack "Language_Pack.LP"
        --language-replace ""
        --language-font true
    }
	
    proc main {} {
        variable options
        set fontPrefix "SCE-PS3-"
        set langpackDir [file join ${::BUILD_DIR} langpack]
		file delete -force $langpackDir
        extract_tar $options(--language-pack) ${langpackDir}

        set fontFiles {{CP-R-KANA} {DH-R-CGB} {MT-BI-LATIN} {MT-B-LATIN} {MT-I-LATIN} {MT-R-LATIN} {NR-B-JPN} {NR-L-JPN} {NR-R-EXT} {NR-R-JPN} {RD-BI-LATIN} {RD-B-LATIN} {RD-B-LATIN2} {RD-I-LATIN} {RD-LI-LATIN} {RD-L-LATIN} {RD-L-LATIN2} {RD-R-LATIN} {RD-R-LATIN2} {SR-R-EXT} {SR-R-JPN} {SR-R-LATIN} {SR-R-LATIN2} {VR-R-LATIN} {VR-R-LATIN2} {YG-B-KOR} {YG-L-KOR} {YG-R-KOR}}

		if {$::language_pack::options(--language-font)} {
            foreach fontFile $fontFiles {
                set devflashFontFile [file join dev_flash data font ${fontPrefix}${fontFile}.TTF]
                set langpackFontFile [file join ${langpackDir} font ${fontPrefix}${fontFile}.TTF]
                if {[file exists ${langpackFontFile}]} {
                  ::modify_devflash_file ${devflashFontFile} ::language_pack::callback_font ${langpackFontFile}
                }
            }
		}	

        set rcoFiles {{ap_plugin} {audioplayer_plugin} {audioplayer_plugin_dummy} {audioplayer_plugin_mini} {audioplayer_plugin_util} {auth_plugin} {autodownload_plugin} {avc_game_plugin} {avc_plugin} {avc2_game_plugin} {avc2_game_video_plugin} {avc2_text_plugin} {bdp_disccheck_plugin} {bdp_plugin} {bdp_storage_plugin} {category_setting_plugin} {checker_plugin} {custom_render_plugin} {data_copy_plugin} {deviceconf_plugin} {dlna_plugin} {download_plugin} {edy_plugin} {eula_cddb_plugin} {eula_hcopy_plugin} {eula_net_plugin} {explore_category_friend} {explore_category_game} {explore_category_music} {explore_category_network} {explore_category_photo} {explore_category_psn} {explore_category_sysconf} {explore_category_tv} {explore_category_user} {explore_category_video} {explore_plugin_ft} {explore_plugin_full} {explore_plugin_game} {explore_plugin_np} {filecopy_plugin} {friendim_plugin} {friendim_plugin_game} {friendml_plugin} {friendml_plugin_game} {friendtrophy_plugin} {friendtrophy_plugin_game} {game_ext_plugin} {game_indicator_plugin} {game_plugin} {gamedata_plugin} {gamelib_plugin} {gameupdate_plugin} {hknw_plugin} {idle_plugin} {impose_plugin} {kensaku_plugin} {msgdialog_plugin} {musicbrowser_plugin} {nas_plugin} {netconf_plugin} {newstore_effect} {newstore_plugin} {np_eula_plugin} {np_matching_plugin} {np_multisignin_plugin} {np_trophy_ingame} {np_trophy_plugin} {npsignin_plugin} {osk_plugin} {oskfullkeypanel_plugin} {oskpanel_plugin} {pesm_plugin} {photo_network_sharing_plugin} {photolist_plugin} {photoupload_plugin} {photoviewer_plugin} {playlist_plugin} {poweroff_plugin} {premo_plugin} {print_plugin} {profile_plugin} {profile_plugin_mini} {ps3_savedata_plugin} {rec_plugin} {regcam_plugin} {sacd_plugin} {scenefolder_plugin} {screenshot_plugin} {search_service} {software_update_plugin} {soundvisualizer_plugin} {strviewer_plugin} {subdisplay_plugin} {sv_pseudoaudioplayer_plugin} {sysconf_plugin} {system_plugin} {thumthum_plugin} {upload_util} {user_info_plugin} {user_plugin} {videodownloader_plugin} {videoeditor_plugin} {videoplayer_plugin} {videoplayer_util} {vmc_savedata_plugin} {wboard_plugin} {webbrowser_plugin} {webrender_plugin} {xmb_ingame} {xmb_plugin_normal} {ycon_manual_plugin}}

        foreach rcoFile $rcoFiles {
            set devflashRcoFile [file join dev_flash vsh resource ${rcoFile}.rco]
			
			if {$options(--language-replace) == ""} {
				} else {
			    	if {[file isdirectory [file join ${langpackDir} replace]]} {
                	    set replacelangpackRcoFile [file join ${langpackDir} replace ${rcoFile}.xml]
                	    if {[file exists $replacelangpackRcoFile]} {
					    set mode "0"
                 	   ::modify_rco_file ${devflashRcoFile} ::language_pack::callback_rco ${replacelangpackRcoFile} ${mode} {empty}
				 	   }
					}	
                }
			
			if {[file isdirectory [file join ${langpackDir} edit]]} {
			set langs {{English} {French} {German} {Italian} {Finnish} {Dutch} {Danish} {Swedish} {Spanish} {Russian} {Portugese} {Norwegian} {Korean} {ChineseTrad} {ChineseSimpl} {Japanese}}
				foreach lang $langs {
                    set editlangpackRcoFile [file join ${langpackDir} edit ${rcoFile} ${lang}.xml]
                    if {[file exists $editlangpackRcoFile]} {
			    	set mode "1"
                    ::modify_rco_file ${devflashRcoFile} ::language_pack::callback_rco ${editlangpackRcoFile} ${mode} ${lang}
			    	}
                }
            }
			
			if {[file exists [file join ${langpackDir} format.txt]]} {
            set formatlangpackRcoFile [file join ${langpackDir} format.txt]
                if {[file exists $formatlangpackRcoFile]} {
			    set mode "2"
                ::modify_rco_file ${devflashRcoFile} ::language_pack::callback_rco ${formatlangpackRcoFile} ${mode} ${rcoFile}
			    }
            }
        }
	}	

    proc callback_font { dst src } {
        if {[file exists ${src}]} {
            if {[file exists ${dst}]} {
                log "Replacing font file [file tail ${dst}] with [file tail ${src}]"
                copy_file -force ${src} ${dst}
            } else {
                die "Font file ${dst} does not exist"
            }
        } else {
            die "Font file ${src} does not exist"
        }
    }

    proc callback_rco {path src mode name} {
        variable options

        if {${mode} == "0" } {
            set dst [file join ${path} $options(--language-replace).xml]
		    }
		
		if {${mode} == "1" } {
		    set dst [file join ${path} ${name}.xml]
			}
			
		if {${mode} == "2" } {
		set dst [file join ${::CUSTOM_PUP_DIR} "update_files" "dev_flash" "dev_flash" "vsh" "resource" ${name}.rco.xml]
		}
			
        if {[file exists ${src}]} {	
            if {[file exists ${dst}]} {			
			if {${mode} != "2" } {			
                log "Replacing ${dst}"
                copy_file -force ${src} ${dst}
				} else {				                  		
				log "Patching format"
				set re [open ${src} r]
                set format [read $re]
				set read [read [open ${dst} r]]
                sed_in_place ${read} utf16 ${format}
				close $re	
				}
            } else {
                die "${dst} does not exist"
            }						
        } else {
            die "${src} does not exist"
        }
    }
}
