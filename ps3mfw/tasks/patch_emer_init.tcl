#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
# Copyright (C) glevand (geoffrey.levand@mail.ru)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 300
# Description: Patch emergency init

# Option --patch-emer-init-gameos-hdd-region-size-half: Create GameOS HDD region of size half of installed HDD
# Option --patch-emer-init-gameos-hdd-region-size-quarter: Create GameOS HDD region of size quarter of installed HDD
# Option --patch-emer-init-gameos-hdd-region-size-eighth: Create GameOS HDD region of size eighth of installed HDD
# Option --patch-emer-init-gameos-hdd-region-size-22gb-smaller: Create GameOS HDD region of size 22GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-10gb-smaller: Create GameOS HDD region of size 10GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-20gb-smaller: Create GameOS HDD region of size 20GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-30gb-smaller: Create GameOS HDD region of size 30GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-40gb-smaller: Create GameOS HDD region of size 40GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-50gb-smaller: Create GameOS HDD region of size 50GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-60gb-smaller: Create GameOS HDD region of size 60GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-70gb-smaller: Create GameOS HDD region of size 70GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-80gb-smaller: Create GameOS HDD region of size 80GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-90gb-smaller: Create GameOS HDD region of size 90GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-100gb-smaller: Create GameOS HDD region of size 100GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-110gb-smaller: Create GameOS HDD region of size 110GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-120gb-smaller: Create GameOS HDD region of size 120GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-130gb-smaller: Create GameOS HDD region of size 130GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-140gb-smaller: Create GameOS HDD region of size 140GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-150gb-smaller: Create GameOS HDD region of size 150GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-160gb-smaller: Create GameOS HDD region of size 160GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-170gb-smaller: Create GameOS HDD region of size 170GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-180gb-smaller: Create GameOS HDD region of size 180GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-190gb-smaller: Create GameOS HDD region of size 190GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-200gb-smaller: Create GameOS HDD region of size 200GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-210gb-smaller: Create GameOS HDD region of size 210GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-220gb-smaller: Create GameOS HDD region of size 220GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-230gb-smaller: Create GameOS HDD region of size 230GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-240gb-smaller: Create GameOS HDD region of size 240GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-250gb-smaller: Create GameOS HDD region of size 250GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-260gb-smaller: Create GameOS HDD region of size 260GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-270gb-smaller: Create GameOS HDD region of size 270GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-280gb-smaller: Create GameOS HDD region of size 280GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-290gb-smaller: Create GameOS HDD region of size 290GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-300gb-smaller: Create GameOS HDD region of size 300GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-310gb-smaller: Create GameOS HDD region of size 310GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-320gb-smaller: Create GameOS HDD region of size 320GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-330gb-smaller: Create GameOS HDD region of size 330GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-340gb-smaller: Create GameOS HDD region of size 340GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-350gb-smaller: Create GameOS HDD region of size 350GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-360gb-smaller: Create GameOS HDD region of size 360GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-370gb-smaller: Create GameOS HDD region of size 370GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-380gb-smaller: Create GameOS HDD region of size 380GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-390gb-smaller: Create GameOS HDD region of size 390GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-400gb-smaller: Create GameOS HDD region of size 400GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-410gb-smaller: Create GameOS HDD region of size 410GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-420gb-smaller: Create GameOS HDD region of size 420GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-430gb-smaller: Create GameOS HDD region of size 430GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-440gb-smaller: Create GameOS HDD region of size 440GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-450gb-smaller: Create GameOS HDD region of size 450GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-460gb-smaller: Create GameOS HDD region of size 460GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-470gb-smaller: Create GameOS HDD region of size 470GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-480gb-smaller: Create GameOS HDD region of size 480GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-490gb-smaller: Create GameOS HDD region of size 490GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-500gb-smaller: Create GameOS HDD region of size 500GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-510gb-smaller: Create GameOS HDD region of size 510GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-520gb-smaller: Create GameOS HDD region of size 520GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-530gb-smaller: Create GameOS HDD region of size 530GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-540gb-smaller: Create GameOS HDD region of size 540GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-550gb-smaller: Create GameOS HDD region of size 550GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-560gb-smaller: Create GameOS HDD region of size 560GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-570gb-smaller: Create GameOS HDD region of size 570GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-580gb-smaller: Create GameOS HDD region of size 580GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-590gb-smaller: Create GameOS HDD region of size 590GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-600gb-smaller: Create GameOS HDD region of size 600GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-610gb-smaller: Create GameOS HDD region of size 610GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-620gb-smaller: Create GameOS HDD region of size 620GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-630gb-smaller: Create GameOS HDD region of size 630GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-640gb-smaller: Create GameOS HDD region of size 640GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-650gb-smaller: Create GameOS HDD region of size 650GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-660gb-smaller: Create GameOS HDD region of size 660GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-670gb-smaller: Create GameOS HDD region of size 670GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-680gb-smaller: Create GameOS HDD region of size 680GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-690gb-smaller: Create GameOS HDD region of size 690GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-700gb-smaller: Create GameOS HDD region of size 700GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-710gb-smaller: Create GameOS HDD region of size 710GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-720gb-smaller: Create GameOS HDD region of size 720GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-730gb-smaller: Create GameOS HDD region of size 730GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-740gb-smaller: Create GameOS HDD region of size 740GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-750gb-smaller: Create GameOS HDD region of size 750GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-760gb-smaller: Create GameOS HDD region of size 760GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-770gb-smaller: Create GameOS HDD region of size 770GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-780gb-smaller: Create GameOS HDD region of size 780GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-790gb-smaller: Create GameOS HDD region of size 790GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-800gb-smaller: Create GameOS HDD region of size 800GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-810gb-smaller: Create GameOS HDD region of size 810GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-820gb-smaller: Create GameOS HDD region of size 820GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-830gb-smaller: Create GameOS HDD region of size 830GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-840gb-smaller: Create GameOS HDD region of size 840GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-850gb-smaller: Create GameOS HDD region of size 850GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-860gb-smaller: Create GameOS HDD region of size 860GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-870gb-smaller: Create GameOS HDD region of size 870GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-880gb-smaller: Create GameOS HDD region of size 880GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-890gb-smaller: Create GameOS HDD region of size 890GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-900gb-smaller: Create GameOS HDD region of size 900GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-910gb-smaller: Create GameOS HDD region of size 910GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-920gb-smaller: Create GameOS HDD region of size 920GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-930gb-smaller: Create GameOS HDD region of size 930GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-940gb-smaller: Create GameOS HDD region of size 940GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-950gb-smaller: Create GameOS HDD region of size 950GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-960gb-smaller: Create GameOS HDD region of size 960GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-970gb-smaller: Create GameOS HDD region of size 970GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-980gb-smaller: Create GameOS HDD region of size 980GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-990gb-smaller: Create GameOS HDD region of size 990GB smaller than default
# Option --patch-emer-init-gameos-hdd-region-size-1000gb-smaller: Create GameOS HDD region of size 1000GB smaller than default
# Option --patch-emer-init-disable-pup-search-in-game-disc: Disable searching for update packages in GAME disc.

# Type --patch-emer-init-gameos-hdd-region-size-half: boolean
# Type --patch-emer-init-gameos-hdd-region-size-quarter: boolean
# Type --patch-emer-init-gameos-hdd-region-size-eighth: boolean
# Type --patch-emer-init-gameos-hdd-region-size-22gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-10gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-20gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-30gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-40gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-50gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-60gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-70gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-80gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-90gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-100gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-110gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-120gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-130gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-140gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-150gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-160gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-170gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-180gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-190gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-200gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-210gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-220gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-230gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-240gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-250gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-260gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-270gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-280gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-290gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-300gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-310gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-320gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-330gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-340gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-350gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-360gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-370gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-380gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-390gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-400gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-410gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-420gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-430gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-440gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-450gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-460gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-470gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-480gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-490gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-500gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-510gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-520gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-530gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-540gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-550gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-560gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-570gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-580gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-590gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-600gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-610gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-620gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-630gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-640gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-650gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-660gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-670gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-680gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-690gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-700gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-710gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-720gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-730gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-740gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-750gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-760gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-770gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-780gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-790gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-800gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-810gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-820gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-830gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-840gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-850gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-860gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-870gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-880gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-890gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-900gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-910gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-920gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-930gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-940gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-950gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-960gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-970gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-980gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-990gb-smaller: boolean
# Type --patch-emer-init-gameos-hdd-region-size-1000gb-smaller: boolean
# Type --patch-emer-init-disable-pup-search-in-game-disc: boolean

namespace eval ::patch_emer_init {

    array set ::patch_emer_init::options {
        --patch-emer-init-gameos-hdd-region-size-half false
        --patch-emer-init-gameos-hdd-region-size-quarter true
        --patch-emer-init-gameos-hdd-region-size-eighth false
        --patch-emer-init-gameos-hdd-region-size-22gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-10gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-20gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-30gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-40gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-50gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-60gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-70gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-80gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-90gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-100gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-110gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-120gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-130gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-140gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-150gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-160gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-170gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-180gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-190gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-200gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-210gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-220gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-230gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-240gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-250gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-260gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-270gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-280gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-290gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-300gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-310gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-320gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-330gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-340gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-350gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-360gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-370gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-380gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-390gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-400gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-410gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-420gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-430gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-440gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-450gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-460gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-470gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-480gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-490gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-500gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-510gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-520gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-530gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-540gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-550gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-560gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-570gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-580gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-590gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-600gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-610gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-620gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-630gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-640gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-650gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-660gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-670gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-680gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-690gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-700gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-710gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-720gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-730gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-740gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-750gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-760gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-770gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-780gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-790gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-800gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-810gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-820gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-830gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-840gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-850gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-860gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-870gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-880gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-890gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-900gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-910gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-920gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-930gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-940gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-950gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-960gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-970gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-980gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-990gb-smaller false
        --patch-emer-init-gameos-hdd-region-size-1000gb-smaller false
        --patch-emer-init-disable-pup-search-in-game-disc false
    }

    proc main { } {
        set self "emer_init.self"

        ::modify_coreos_file $self ::patch_emer_init::patch_self
    }

    proc patch_self {self} {
        ::modify_self_file $self ::patch_emer_init::patch_elf
    }

    proc patch_elf {elf} {
        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-half)} {
            log "Patching emergency init to create GameOS HDD region of size half of installed HDD"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x79\x27\xf8\x42"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-quarter)} {
            log "Patching emergency init to create GameOS HDD region of size quarter of installed HDD"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x79\x27\xf0\x82"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-eighth)} {
            log "Patching emergency init to create GameOS HDD region of size eighth of installed HDD"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x79\x27\xe8\xc2"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-22gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 22GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xfd\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-10gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 10GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xfe\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-20gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 20GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xfd\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-30gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 30GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xfc\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-40gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 40GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xfb\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-50gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 50GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xf9\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-60gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 60GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xf8\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-70gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 70GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xf7\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-80gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 80GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xf6\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-90gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 90GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xf4\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-100gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 100GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xf3\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-110gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 110GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xf2\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-120gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 120GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xf1\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-130gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 130GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xef\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-140gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 140GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xee\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-150gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 150GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xed\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-160gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 160GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xec\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-170gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 170GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xea\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-180gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 180GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xe9\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-190gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 190GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xe8\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-200gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 200GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xe7\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-210gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 210GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xe5\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-220gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 220GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xe4\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-230gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 230GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xe3\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-240gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 240GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xe2\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-250gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 250GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xe0\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-260gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 260GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xdf\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-270gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 270GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xde\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-280gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 280GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xdd\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-290gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 290GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xdb\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-300gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 300GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xda\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-310gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 310GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xd9\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-320gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 320GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xd8\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-330gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 330GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xd6\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-340gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 340GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xd5\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-350gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 350GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xd4\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-360gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 360GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xd3\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-370gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 370GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xd1\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-380gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 380GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xd0\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-390gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 390GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xcf\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-400gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 400GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xce\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-410gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 410GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xcc\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-420gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 420GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xcb\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-430gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 430GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xca\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-440gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 440GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xc9\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-450gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 450GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xc7\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-460gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 460GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xc6\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-470gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 470GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xc5\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-480gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 480GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xc4\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-490gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 490GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xc2\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-500gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 500GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xc1\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-510gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 510GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xc0\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-520gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 520GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xbf\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-530gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 530GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xbd\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-540gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 540GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xbc\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-550gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 550GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xbb\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-560gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 560GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xba\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-570gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 570GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xb8\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-580gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 580GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xb7\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-590gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 590GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xb6\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-600gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 600GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xb5\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-610gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 610GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xb3\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-620gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 620GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xb2\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-630gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 630GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xb1\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-640gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 640GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xb0\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-650gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 650GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xae\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-660gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 660GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xad\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-670gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 670GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xac\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-680gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 680GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xab\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-690gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 690GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xa9\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-700gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 700GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xa8\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-710gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 710GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xa7\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-720gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 720GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xa6\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-730gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 730GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xa4\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-740gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 740GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xa3\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-750gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 750GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xa2\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-760gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 760GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\xa1\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-770gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 770GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x9f\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-780gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 780GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x9e\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-790gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 790GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x9d\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-800gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 800GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x9c\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-810gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 810GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x9a\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-820gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 820GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x99\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-830gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 830GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x98\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-840gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 840GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x97\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-850gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 850GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x95\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-860gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 860GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x94\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-870gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 870GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x93\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-880gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 880GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x92\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-890gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 890GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x90\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-900gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 900GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x8f\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-910gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 910GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x8e\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-920gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 920GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x8d\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-930gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 930GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x8b\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-940gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 940GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x8a\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-950gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 950GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x89\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-960gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 960GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x88\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-970gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 970GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x86\xc0"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-980gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 980GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x85\x80"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-990gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 990GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x84\x40"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-gameos-hdd-region-size-1000gb-smaller)} {
            log "Patching emergency init to create GameOS HDD region of size 1000GB smaller than default"

            set search  "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00\x7d\x26\x48\x50"
            append search "\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace "\x3c\xe9\x83\x00"

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_emer_init::options(--patch-emer-init-disable-pup-search-in-game-disc)} {
            log "Patching emergency init to disable searching for update packages in GAME disc"

            set search  "\x80\x01\x00\x74\x2f\x80\x00\x00\x40\x9e\x00\x14\x7f\xa3\xeb\x78"
            set replace "\x38\x00\x00\x01"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
    }
}
