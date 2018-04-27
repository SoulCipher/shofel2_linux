#!/bin/bash
# Dump /dev/mmcblk1 using dcfldd or dd v1.0
# soul@kombos.org

nandpath="/dev/mmcblk1"
boot0path="/dev/mmcblk1boot0"
boot1path="/dev/mmcblk1boot1"
dd=`command -v dd`
free=`df -H --type=ext4 | grep root | awk '{ print $4 }' | sed -e 's/G//'`
timestamp="$(date +%Y%m%d_%H%M%S)"
highlight="\033[1;37m"
md5status=1

echo -e " ___ "
echo -e "|[_]| \033[1;31mNintendo Switch\033[32m NAND\033[1;37m dumper\033[0m "
echo -e "|+ ;| \033[1;37;44m -//- soul@kombos.org -//- \033[0m		"
echo -e "\`---'\033[1;37m -=-=-=-=-=-=-=-=-=-=-=-=-=-\033[0m"
echo

if [ -e "$nandpath" ] && [ -e "$boot0path" ] && [ -e "$boot1path" ]; then

echo -e "\033[1;37mChecking if your SD Card root partition can fit NAND backup:\033[0m"
if [ "$free" -lt "32" ];
	then
		echo -e "You only have \033[31m$free GB\033[0m free space. Sorry, at least \033[1;37m32 GB\033[0m is required"
		echo
		echo -e "\033[31;7mError.\033[0m" 
		echo
		exit 1
	else
		echo -e "You have \033[32m$free GB\033[0m free space on your SD ! It's enough to fit NAND dump."
		echo
		echo -e "\033[1;37mChecking if enhanced version of GNU dd is installed:\033[0m"
		dcfldd=`command -v dcfldd`
		
		if [ -z "$dcfldd" ];
		then
			echo -e "\033[31mNo.\033[0m We are going to use $dd instead"
		else
			echo -e "\033[32mYes.\033[0m We are going to use $dcfldd then"
			dd=$dcfldd 
		fi
		
		start=`date +%s`
		echo 
		echo -e "\033[1;37mWe are going to execute below commands now:\033[0m"
                echo -e "`basename $dd` if=$boot0path of=$HOME/SwitchBOOT0_dump_$timestamp.bin bs=512"
                echo -e "`basename $dd` if=$boot1path of=$HOME/SwitchBOOT1_dump_$timestamp.bin bs=512"
                echo -e "`basename $dd` if=$nandpath of=$HOME/SwitchNAND_dump_$timestamp.bin bs=512"
		echo
		read -p "Are you sure? [y/N] " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
	                start=`date +%s`
                        $dd if=$boot0path of=$HOME/SwitchBOOT0_dump_$timestamp.bin bs=512
			echo -e "\033[32mBOOT0 Done.\033[0m"
			$dd if=$boot1path of=$HOME/SwitchBOOT1_dump_$timestamp.bin bs=512
                        echo -e "\033[32mBOOT1 Done.\033[0m"
			$dd if=$nandpath of=$HOME/SwitchNAND_dump_$timestamp.bin bs=512
                        echo -e "\033[32mNAND  Done.\033[0m"
			end=`date +%s`
			runtime=$((end-start))
			echo
			echo -e "\033[1;37mIt took \033[0;34m$runtime seconds\033[1;37m to dump your BOOT0, BOOT1 & NAND\033[0m"
			echo
			echo -e "  ((  "
			echo -e "   ))   \033[1;37mWe are going to generate checksums of NAND and NAND dump.\033[0m" 
			echo -e "  |~~|  \033[1;37mIt will take a while.\033[0m"
			echo -e " C|__|  \033[1;37mMake a coffe and be patient.\033[0m"
			echo
                        start=`date +%s`
			boot0_md5=`md5sum $boot0path | awk '{ print $1}'`
                        echo -e "\033[32;7m BOOT0 \033[0m $boot0_md5"
                        dump_md5=`md5sum $HOME/SwitchBOOT0_dump_$timestamp.bin | awk '{ print $1}'`
                	if [ "$boot0_md5" != "$dump_md5" ]; then 
				highlight="\033[31m"
				md5status=0
                        else
                                highlight="\033[1;37m"
			fi
		        echo -e "\033[32;7m DUMP0 \033[0m$highlight $dump_md5\033[0m"
                        boot1_md5=`md5sum $boot1path | awk '{ print $1}'`
                        echo -e "\033[33;7m BOOT1 \033[0m $boot1_md5"
                        dump_md5=`md5sum $HOME/SwitchBOOT1_dump_$timestamp.bin | awk '{ print $1}'`
                        if [ "$boot1_md5" != "$dump_md5" ]; then
                                highlight="\033[31m"
				md5status=0
			else
                                highlight="\033[1;37m"
			fi
                        echo -e "\033[33;7m DUMP1 \033[0m$highlight $dump_md5\033[0m"
			nand_md5=`md5sum $nandpath | awk '{ print $1}'`
			echo -e "\033[31;7m NAND  \033[0m $nand_md5"			
                        dump_md5=`md5sum $HOME/SwitchNAND_dump_$timestamp.bin | awk '{ print $1}'`
                        if [ "$nand_md5" != "$dump_md5" ]; then
                                highlight="\033[31m"
				md5status=0
                        else
                                highlight="\033[1;37m"
                        fi
			echo -e "\033[31;7m DUMP  \033[0m$highlight $dump_md5\033[0m"
                        end=`date +%s`
                        runtime=$((end-start))
                        echo
			echo -e "\033[1;37mIt took \033[0;34m$runtime seconds\033[1;37m to generate MD5 checksums\033[0m"
			if [ "$md5status" = 1 ]; then
				echo -e "\033[1;37mChecksums status: \033[32mOK\033[0m"
			else
       				echo
				echo -e "\033[1;37mChecksums status: \033[31mFAIL\033[0m"
				echo
				echo -e "\033[31m!!! There was checksums mismatch !!!"
				echo -e "\033[31m  Some of your files are corrupted  \033[0m"
                                echo -e "\033[31m!!!!!!!!! Don't use them !!!!!!!!!  \033[0m"
				echo
		                read -p "Do you want to remove this dump files? [y/N] " -n 1 -r
		                if [[ $REPLY =~ ^[Yy]$ ]]
                		then
					rm $HOME/SwitchBOOT0_dump_$timestamp.bin
					rm $HOME/SwitchBOOT1_dump_$timestamp.bin
					rm $HOME/SwitchNAND_dump_$timestamp.bin
					echo
					echo -e "\033[1;37mAll dump files was deleted\033[0m"
				fi
				exit 1
			fi
                        echo -e "\033[32mDone.\033[1;37m Have fun ! ;-)\033[0m"
			echo
			echo -e "\033[1;37mYou can find dumps there:\033[0m"
			echo -e "$HOME/SwitchBOOT0_dump_$timestamp.bin"
                        echo -e "$HOME/SwitchBOOT1_dump_$timestamp.bin"
                        echo -e "$HOME/SwitchNAND_dump_$timestamp.bin"
			echo
			echo -ne "\033[1;37mBrought to you by\033[0m "
			echo -e "\033[0m\033[48;5;17mk\033[0m\033[48;5;18mo\033[0m\033[48;5;19mm\033[0m\033[48;5;20mb\033[0m\033[48;5;21mo\033[0m\033[48;5;21ms\033[0m\033[48;5;20m.\033[0m\033[48;5;19mo\033[0m\033[48;5;18mr\033[0m\033[48;5;17mg\033[0m\033[48;5;16m \033[0m"
			echo 
			exit 0
		else
			echo
			echo -e "\033[33m c\033[1;37m\"\033[0;33m}"
			echo -e ",(_)."
			echo -e " -\"- "
			echo -e "Coward... \033[1;37mBye !\033[0m"
			echo
			exit 0
		fi 		
fi

else
	echo -e "\033[31mAre you sure all your NAND devices \033[1;37m$boot0path\033[0;31m,\033[1;37m$boot1path\033[0;31m&\033[1;37m$nandpath\033[0;31m exists ?\033[0m"
	echo 
	echo -e "This script is intended to run on Switch running Linux. It won't work on your \033[1;37m*MacBook*\033[0m. Sorry." 
	echo
        echo -e "\033[31;7mError.\033[0m"
	echo
fi
