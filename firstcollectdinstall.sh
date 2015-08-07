#! /bin/bash

#suported OS Variables
aa="CentOS Linux 7"
bb="CentOS Linux 6"
bbb="CentOS release 6"
cc="CentOS release 5"
dd="Amazon Linux AMI 2014.09"
ee="Amazon Linux AMI 2015.03"
ff="Ubuntu 15.04"
gg="Ubuntu 14.04.1 LTS"
hh="Ubuntu 12.04" #maps to hostOS_3

#addtional variables used
selection=0
needed_rpm=null
needed_rpm_name=null

#download location variables
centos_7="https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-RPMs-centos-7-release-1.0-0.noarch.rpm"
centos_6="https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-RPMs-centos-6-release-1.0-0.noarch.rpm"
centos_5="https://s3.amazonaws.com/public-downloads--signalfuse-com/rpms/SignalFx-rpms/release/SignalFx-RPMs-centos-5-release-1.0-0.noarch.rpm"
aws_linux_2014_09="https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-RPMs-AWS_EC2_Linux_2014_09-release-1.0-0.noarch.rpm"
aws_linux_2015_03="https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-RPMs-AWS_EC2_Linux_2015_03-release-1.0-0.noarch.rpm"

#rpm file variables
centos_7_rpm="SignalFx-RPMs-centos-7-release-1.0-0.noarch.rpm"
centos_6_rpm="SignalFx-RPMs-centos-6-release-1.0-0.noarch.rpm"
centos_5_rpm="SignalFx-RPMs-centos-5-release-1.0-0.noarch.rpm"
aws_linux_2014_09_rpm="SignalFx-RPMs-AWS_EC2_Linux_2014_09-release-1.0-0.noarch.rpm"
aws_linux_2015_03_rpm="SignalFx-RPMs-AWS_EC2_Linux_2015_03-release-1.0-0.noarch.rpm"

#determine hostOS
hostOS=$(sudo cat /etc/*-release | grep PRETTY_NAME | grep -o '".*"' | sed 's/"//g' | sed -e 's/([^()]*)//g' | sed -e 's/[[:space:]]*$//') #for newer versions of linux
hostOS_2=$(sudo cat /etc/redhat-release | head -c 16) #older versions of RPM based linux that don't have version in PRETTY_NAME format
hostOS_3=$(sudo cat /etc/*-release | grep DISTRIB_DESCRIPTION | grep -o '".*"' | sed 's/"//g' | sed -e 's/([^()]*)//g' | sed -e 's/[[:space:]]*$//' | head -c 12)

#Functions used throughout
basic_collectd() #url to configure collectd asks for hostname & username:password
{
	echo "-->Starting Configuration of collectd..."
	curl -sSL https://dl.signalfx.com/collectd-simple | sudo bash -s --
}
#aggregatedhost_collectd() #url to assume hostname. Asks for username:password

give_needed_os()
{
	if [[ "$selection" -eq 1 ]]
	 	then
	 	needed_rpm=$centos_7
		needed_rpm_name=$centos_7_rpm
	elif [[ "$selection" -eq 2 ]]
	 	then
	 	needed_rpm=$centos_6
		needed_rpm_name=$centos_6_rpm
	elif [[ "$selection" -eq 3 ]]
		then
		needed_rpm=$centos_5
		needed_rpm_name=$centos_5_rpm
	elif [[ "$selection" -eq 4 ]] 
		then
		needed_rpm=$aws_linux_2014_09
		needed_rpm_name=$aws_linux_2014_09
	elif [[ "$selection" -eq 5 ]] 
		then
		needed_rpm=$aws_linux_2015_03
		needed_rpm_name=$aws_linux_2015_03_rpm
	fi
}

#RPM Based Linux Functions
update_wget() #update wget
{
	echo "--->Updating wget<---"
	sudo yum -y install wget
}

download_sfx_rpm() #download signalfx rpm for collectd
{
	echo "--->Downloading SignalFx RPM<---"
	wget $needed_rpm
}

install_sfx_rpm() #install signalfx rpm for collectd
{
	echo "--->Installing SignalFx RPM<---"
	sudo yum -y install $needed_rpm_name
}

install_collectd() #install collectd from signalfx rpm 
{
	echo "--->Installing collectd<---"
	sudo yum -y install collectd 
}

install_baseplugins() #install base plugins signalfx deems nessescary 
{
	echo "--->Installing baseplugins<---"
	sudo yum -y install collectd-disk collectd-write_http
}

install_rpm_collectd_procedure()
{
	update_wget
	download_sfx_rpm
	install_sfx_rpm
	install_collectd
	install_collectd
	install_baseplugins
	basic_collectd
}

install_debian_collectd_procedure()
{
	echo "--->Updating apt-get<---"
	sudo apt-get -y update

	if [[ ( "$selection" -eq 6)  || ( "$selection" -eq 7 ) ]]
		then
		echo "--->Installing source package to get SignalFx collectd package<---"
		sudo apt-get -y install software-properties-common #not used for ubuntu < 13.10
	elif [[ "$selection" -eq 8 ]]
		then
		echo "--->Installing source package to get SignalFx collectd package<---"
		sudo apt-get install python-software-properties #not needed for ubuntu after version 13.10
	fi
		
		echo "--->Getting SignalFx collectd package<---"
		sudo add-apt-repository -y ppa:signalfx/collectd-release
		echo "--->Updating apt-get to reference new SignalFx package<---"
		sudo apt-get -y update
		echo "--->Installing collectd and additional plugins<---"
		sudo apt-get install collectd -y
		echo "--->Starting Configuration of collectd...<---"	
		basic_collectd
}

confirm ()
{
	read -r -p "is this correct? [y/N] " response
		if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
			then
    			return
		else
    			exit 0
		fi 
}

#take "hostOS" and match it up to OS and assign a new value
if [ "$aa" == "$hostOS" ] #CentOS/RHEL Linux 7 Check
	then 
		selection=1
		needed_rpm=$centos_7
		needed_rpm_name=$centos_7_rpm
		echo "Install will proceed for Centos/RHEL Linux 7"
		confirm
			
elif [[ ( "$bb" = "$hostOS" ) || ( "$bbb" = "$hostOS_2" ) ]] #CentOS/RHEL Linux 6 Check
	then 
		selection=2
		needed_rpm=$centos_6
		needed_rpm_name=$centos_6_rpm
		echo "Install will proceed for Centos/RHEL Linux 6"
		confirm
		
elif [ "$cc" == "$hostOS_2" ] #CentOS/RHEL Linux 5 Check #tested and works
	then
		selection=3
		needed_rpm=$centos_5
		needed_rpm_name=$centos_5_rpm
		echo "Install will proceed for Centos/RHEL Linux 5"
		confirm

elif [ "$dd" == "$hostOS" ] #Amazon Linux 2014.09
	then
		selection=4
		needed_rpm=$aws_linux_2014_09
		needed_rpm_name=$aws_linux_2014_09_rpm
		echo "Install will proceed for Amazon Linux 2014.09"
		confirm

elif [ "$ee" == "$hostOS" ] #Amazon Linux 2015.03
	then
		selection=5
		needed_rpm=$aws_linux_2015_03
		needed_rpm_name=$aws_linux_2015_03_rpm
		echo "Install will proceed for Amazon Linux 2015.03"
		confirm

elif [ "$ff" == "$hostOS" ]
	then
		selection=6
		echo "Install will proceed for Ubuntu 15.04"
		confirm

elif [ "$gg" == "$hostOS" ]
	then
		selection=7
		echo "Install will proceed for Ubuntu 14.04"
		confirm

elif [ "$hh" == "$hostOS_3" ]
	then
		selection=8
		echo "Install will proceed for Ubuntu 12.04"
		confirm

else
	#echo $selection #check for currently value of selection
	echo "We were unable to automatically determine the verions of Linux you are on!
		Please enter the the number of the OS you wish to install for:
		1. RHEL/Centos 7
		2. RHEL/Centos 6.x
		3. REHL/Centos 5.x
		4. Amazon Linux 2014.09
		5. Amazon Linux 2015.03
		6. Ubuntu 15.04
		7. Ubuntu 14.04
		8. Ubuntu 12.04
		9. Other"
		read selection
			
			if [ "$selection" -eq 9 ]
				then
				echo "We currently do not support any other versions of
collectd with our RPM. You need to vist ~link~ for detailed 
instrucitons on how to install collectd." && exit 0
			else
				give_needed_os
			fi
fi


#Check needed dependencies, install collectd, and configure to send to SignalFX
if [[ ( "$selection" -eq 1 ) || ( "$selection" -eq 2 ) || ( "$selection" -eq 4 ) || ( "$selection" -eq 5 ) ]] #centos 7 & 6 linux install
		then
			install_rpm_collectd_procedure

	elif [ "$selection" -eq 3 ] #CentOS/RHEL Linux 5 Install
		then
			#echo "--->Updating Yum<---"
			#sudo yum -y update
			echo "--->Installing Simple-Json<---"
			sudo yum -y install python-simplejson

			echo "--->Updating Openssl<---"
			sudo yum -y update openssl 

			echo "--->Installing wget<---"
			sudo yum -y install wget

			echo "--->Downloading SignalFx RPM<---"
			wget $centos_5
		
			echo "--->Installing SignalFx RPM<---"
			sudo yum -y install --nogpgcheck $centos_5_rpm

			echo "--->Installing collectd<---"
			install_collectd

			echo "--->Installing baseplugins<---"
			install_baseplugins

			echo "-->Starting Configuration of collectd..."
			curl https://s3.amazonaws.com/public-downloads--signalfuse-com/collectd-simple | sudo bash -s --
	

	elif [[ ( "$selection" -eq 6)  || ( "$selection" -eq 7 ) || ( "$selection" -eq 8 ) ]] #Ubuntu 15.04 & 14.04 Install
		then
			install_debian_collectd_procedure

fi

echo "Install is now compelete and you can view your metrics at app.signalfx.com.
If you had any issues please contact support@signalfx.com"
