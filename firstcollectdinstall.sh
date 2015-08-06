#! /bin/bash

#suported OS Variables
aa=="CentOS Linux 7"
bb=="CentOS Linux 6"
bbb=="CentOS release 6"
cc=="CentOS release 5"
dd=="Amazon Linux AMI 2014.09"
ff=="Amazon Linux AMI 2015.03"
ee=="Ubuntu 15.04"
ff=="Ubuntu 14.04.1 LTS"
gg=="Ubuntu 12.04" #maps to hostOS_3

#addtional variables used
selection=0

#download location variables
centos_7=="https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-RPMs-centos-7-release-1.0-0.noarch.rpm"
centos_6=="https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-RPMs-centos-6-release-1.0-0.noarch.rpm"
centos_5=="https://s3.amazonaws.com/public-downloads--signalfuse-com/rpms/SignalFx-rpms/release/SignalFx-RPMs-centos-5-release-1.0-0.noarch.rpm"
aws_linux_2014_09=="https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-RPMs-AWS_EC2_Linux_2014_09-release-1.0-0.noarch.rpm"
aws_linux_2015_03=="https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-RPMs-AWS_EC2_Linux_2015_03-release-1.0-0.noarch.rpm"

#rpm file variables
centos_7_rpm=="SignalFx-RPMs-centos-7-release-1.0-0.noarch.rpm"
centos_6_rpm=="SignalFx-RPMs-centos-6-release-1.0-0.noarch.rpm"
centos_5_rpm=="SignalFx-RPMs-centos-5-release-1.0-0.noarch.rpm"
aws_linux_2014_09_rpm=="SignalFx-RPMs-AWS_EC2_Linux_2014_09-release-1.0-0.noarch.rpm"
aws_linux_2015_03_rpm=="SignalFx-RPMs-AWS_EC2_Linux_2015_03-release-1.0-0.noarch.rpm"

#determine hostOS
hostOS==$(sudo cat /etc/*-release | grep PRETTY_NAME | grep -o '".*"' | sed 's/"//g' | sed -e 's/([^()]*)//g' | sed -e 's/[[:space:]]*$//') #for newer versions of linux
hostOS_2==$(sudo cat /etc/redhat-release | head -c 16) #older versions of RPM based linux that don't have version in PRETTY_NAME format
hostOS_3==$(sudo cat /etc/*-release | grep DISTRIB_DESCRIPTION | grep -o '".*"' | sed 's/"//g' | sed -e 's/([^()]*)//g' | sed -e 's/[[:space:]]*$//' | head -c 12)

#configure collectd variables
basic_collectd="https://dl.signalfx.com/collectd-simple | sudo bash -s --"
#aggregatedhost_collectd==""

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


#Variable Checks
#echo "hostOS is $hostOS<"
#echo "hostOS_2 is $hostOS_2<"


#take "hostOS" and match it up to OS and assign a new value
if [ "$aa" == "$hostOS" ] #CentOS/RHEL Linux 7 Check
	then 
		selection=1
		echo "Install will proceed for Centos/RHEL Linux 7"
		confirm
			
elif [[ ( "$bb" = "$hostOS" ) || ( "$bbb" = "$hostOS_2" ) ]] #CentOS/RHEL Linux 6 Check
	then 
		selection=2
		echo "Install will proceed for Centos/RHEL Linux 6"
		confirm
		
elif [ "$cc" == "$hostOS_2" ] #CentOS/RHEL Linux 5 Check #tested and works
	then
		selection=3
		echo "Install will proceed for Centos/RHEL Linux 5"
		confirm

elif [ "$dd" == "$hostOS" ] #Amazon Linux 2014.09
	then
		selection=4
		echo "Install will proceed for Amazon Linux 2014.09"
		confirm

elif [ "$ff" == "$hostOS" ]
	then
		selection=5
		echo "Install will proceed for Amazon Linux 2014.10"
		confirm

elif [ "$ee" == "$hostOS" ]
	then
		selection=6
		echo "Install will proceed for Ubuntu 15.04"
		confirm

elif [ "$ff" == "$hostOS" ]
	then
		selection=7
		echo "Install will proceed for Ubuntu 14.04"
		confirm

elif [ "$gg" == "$hostOS_3" ]
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
		5. Amazon Linux 2014.10
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
				true

			fi

fi


#Check needed dependencies, install collectd, and configure to send to SignalFX
if [ "$selection" -eq 1 ] #centos 7 linux install
		then
			echo "--->Updating wget<---"
			sudo yum -y install wget

			echo "--->Downloading SignalFx RPM<---"
			wget $centos_7

			echo "--->Installing SignalFx RPM<---"
			sudo yum -y install $centos_7_rpm

			echo "--->Installing collectd and additional plugins<---"
			sudo yum -y install collectd collectd-disk collectd-write_http

			echo "-->Starting Configuration of collectd..."
			curl -sSL $basic_collectd

			

	elif [ "$selection" -eq 2 ] #centos 6 linux install
		then
			echo "--->Updating wget<---"
			sudo yum -y install wget

			echo "--->Downloading SignalFx RPM<---"
			wget $centos_6
		
			echo "--->Installing SignalFx RPM<---"
			sudo yum -y install $centos_6_rpm

			echo "--->Installing collectd and additional plugins<---"
			sudo yum -y install collectd collectd-disk collectd-write_http

			echo "-->Starting Configuration of collectd..."
			curl -sSL $basic_collectd

			
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

			echo "--->Installing collectd and additional plugins<---"
			sudo yum -y install collectd collectd-disk collectd-write_http

			echo "-->Starting Configuration of collectd..."
			curl https://s3.amazonaws.com/public-downloads--signalfuse-com/collectd-simple | sudo bash -s --

	elif [ "$selection" -eq 4 ] #Amazon Linux 2014.09 Install 
		then
			echo "--->Installing wget<---"
			sudo yum -y install wget

			echo "--->Downloading SignalFx RPM<---"
			wget $aws_linux_2014_09

			echo "--->Installing SignalFx RPM<---"
			sudo yum -y install $aws_linux_2014_09_rpm

			echo "--->Installing collectd and additional plugins<---"
			sudo yum -y install collectd collectd-disk collectd-write_http

			echo "-->Starting Configuration of collectd..."
			curl -sSL $basic_collectd

	elif [ "$selection" -eq 5 ] #Amazon Linux 2015.03 Install 
		then
			echo "--->Installing wget<---"
			sudo yum -y install wget

			echo "--->Downloading SignalFx RPM<---"
			wget $aws_linux_2015_03

			echo "--->Installing SignalFx RPM<---"
			sudo yum -y install $aws_linux_2015_03_rpm

			echo "--->Installing collectd and additional plugins<---"
			sudo yum -y install collectd collectd-disk collectd-write_http

			echo "-->Starting Configuration of collectd..."
			curl -sSL $basic_collectd

	elif [[ ( "$selection" -eq 6)  || ( "$selection" -eq 7 ) ]] #Ubuntu 15.04 & 14.04 Install
		then
			echo "--->Updating apt-get<---"
			sudo apt-get -y update

			echo "--->Installing source package to get SignalFx collectd package<---"
			sudo apt-get -y install software-properties-common

			#echo "--->Installing source package to get SignalFx collectd package<---"
			#sudo apt-get install python-software-properties #not needed for ubuntu after version 13.10

			echo "--->Getting SignalFx collectd package<---"
			sudo add-apt-repository -y ppa:signalfx/collectd-release

			echo "--->Updating apt-get to reference new SignalFx package<---"
			sudo apt-get -y update

			echo "--->Installing collectd and additional plugins<---"
			sudo apt-get install collectd -y

			echo "--->Starting Configuration of collectd...<---"	
			curl -sSL $basic_collectd

	elif [ "$selection" -eq 8 ] #Ubuntu 12.04 Install
		then
			echo "--->Updating apt-get<---"
			sudo apt-get -y update

			#echo "--->Installing source package to get SignalFx collectd package<---" #not used for ubuntu < 13.10
			#sudo apt-get -y install software-properties-common

			echo "--->Installing source package to get SignalFx collectd package<---"
			sudo apt-get install python-software-properties #not needed for ubuntu > 13.10

			echo "--->Getting SignalFx collectd package<---"
			sudo add-apt-repository -y ppa:signalfx/collectd-release

			echo "--->Updating apt-get to reference new SignalFx package<---"
			sudo apt-get -y update

			echo "--->Installing collectd and additional plugins<---"
			sudo apt-get install collectd -y

			echo "--->Starting Configuration of collectd...<---"	
			curl -sSL $basic_collectd

fi

echo "Install is now compelete and you can view your metrics at app.signalfx.com.
If you had any issues please contact support@signalfx.com"
