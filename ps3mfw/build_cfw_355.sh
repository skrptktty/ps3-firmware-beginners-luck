#!/bin/sh
#
# Copyright (C) 2011 glevand (geoffrey.levand@mail.ru)
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

OFW=$HOME/firmwares/OFW355.PUP
CFW=$HOME/firmwares/CFW355-OTHEROS++.PUP

./ps3mfw $OFW $CFW \
	--gui false \
	--debug false \
	--change_version \
		--pup-build "" \
		--version-string "" \
		--version-suffix "-OtherOS++" \
	--add_license_msg \
	--patch_lv1 \
		--patch-lv1-mmap true \
		--patch-lv1-peek-poke true \
		--patch-lv1-htab-write true \
		--patch-lv1-mfc-sr1-mask true \
		--patch-lv1-dabr-priv-mask true \
		--patch-lv1-encdec-ioctl-0x85 true \
		--patch-lv1-dispmgr-access true \
		--patch-lv1-iimgr-access true \
		--patch-lv1-um-extract-pkg true \
		--patch-lv1-um-write-eprom-product-mode true \
		--patch-lv1-sm-del-encdec-key true \
		--patch-lv1-repo-node-lpar true \
		--patch-lv1-sysmgr-disable-integrity-check true \
		--patch-lv1-gameos-sysmgr-ability true \
		--patch-lv1-gameos-gos-mode-one true \
		--patch-lv1-storage-skip-acl-check true \
		--patch-lv1-otheros-plus-plus true \
	--patch_lv2 \
		--patch-lv2-peek-poke true \
		--patch-lv2-lv1-peek-poke-355 true \
	--patch-emer-init \
		--patch-emer-init-gameos-hdd-region-size-half false \
		--patch-emer-init-gameos-hdd-region-size-quarter false \
		--patch-emer-init-gameos-hdd-region-size-eighth true \
		--patch-emer-init-gameos-hdd-region-size-22gb-smaller false \
	--patch-profile \
		--patch-profile-gameos-bootmem-size true \
	--patch_category_game \
		--patch-package-files true \
		--patch-app-home true \
	--patch_nas_plugin \
		--allow-pseudoretail-pkg true \
		--allow-debug-pkg true \
	--patch_vsh \
		--allow-unsigned-app true
