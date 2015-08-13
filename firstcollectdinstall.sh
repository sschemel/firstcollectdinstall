#! /bin/bash

#variables used
selection=0
needed_rpm=null_rpm_link
needed_rpm_name=null_rpm_name
api_token=$1

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
hostOS=$(cat /etc/*-release | grep PRETTY_NAME | grep -o '".*"' | sed 's/"//g' | sed -e 's/([^()]*)//g' | sed -e 's/[[:space:]]*$//') #for newer versions of linux
hostOS_2=$(head -c 16 /etc/redhat-release) #older versions of RPM based linux that don't have version in PRETTY_NAME format

#Functions used throughout
basic_collectd() #url to configure collectd asks for hostname & username:password
{
	printf "-->Starting Configuration of collectd... \n"
	if [ -z "$api_token" ]
		then
		curl -sSL https://dl.signalfx.com/collectd-simple | sudo bash -s --
	else
		curl -sSL https://dl.signalfx.com/collectd-simple | sudo bash -s -- -t "$api_token"
	fi

}

get_needed_os()
{
	case $selection in
		1)
    		needed_rpm=$centos_7
			needed_rpm_name=$centos_7_rpm
			install_rpm_collectd_procedure
		;;
		2)
			needed_rpm=$centos_6
			needed_rpm_name=$centos_6_rpm
			install_rpm_collectd_procedure
		;;
		3)
			needed_rpm=$centos_5
			needed_rpm_name=$centos_5_rpm
			install_rpm_RHELcentos5.x_procedure
		;;
		4)
			needed_rpm=$aws_linux_2014_09
			needed_rpm_name=$aws_linux_2014_09
			install_rpm_collectd_procedure
		;;
		5)
			needed_rpm=$aws_linux_2015_03
			needed_rpm_name=$aws_linux_2015_03_rpm
			install_rpm_collectd_procedure
		;;
		6)
			install_debian_collectd_procedure
		;;
		7)
			install_debian_collectd_procedure
		;;
		8)
			install_debian_collectd_procedure
		;;
		*)
			printf "error occured. Exiting. Please contact support@signalfx.com \n" && exit 0
		;;
	esac
}

get_os_input() 
{
	#check for currently value of selection
	printf "/n/nWe were unable to automatically determine the verions of Linux you are on!
Please enter the the number of the OS you wish to install for:
1. RHEL/Centos 7
2. RHEL/Centos 6.x
3. REHL/Centos 5.x
4. Amazon Linux 2014.09
5. Amazon Linux 2015.03
6. Ubuntu 15.04
7. Ubuntu 14.04
8. Ubuntu 12.04
9. Other \n"
	read -r selection

	if [ "$selection" -eq 9 ]
		then
			printf "We currently do not support any other versions of
collectd with our RPM. You need to vist ~link~ for detailed 
instrucitons on how to install collectd. \n" && exit 0
	
	else
			get_needed_os
	fi
}

#RPM Based Linux Functions
install_rpm_collectd_procedure() #install function for RPM collectd
{

	printf "Updating wget \n"
	sudo yum -y install wget #update wget

	printf "Downloading SignalFx RPM \n"
	wget $needed_rpm #download signalfx rpm for collectd

	printf "Installing SignalFx RPM \n"
	sudo yum -y install $needed_rpm_name  #install signalfx rpm for collectd

	printf "Installing collectd \n"
	sudo yum -y install collectd #install collectd from signalfx rpm 

	printf "Installing baseplugins \n"
	sudo yum -y install collectd-disk collectd-write_http #install base plugins signalfx deems nessescary

	basic_collectd
	
}
install_rpm_RHELcentos5.x_procedure()
{
	printf "Installing Simple-Json \n"
	sudo yum -y install python-simplejso
	printf "Updating Openssl \n"
	sudo yum -y update openssl
	printf "Installing wget \n"
	sudo yum -y install wge
	printf "Downloading SignalFx RPM \n"
	wget $centos_5

	printf "Installing SignalFx RPM \n"
	sudo yum -y install --nogpgcheck $centos_5_rpm
	printf "Installing collectd \n"
	sudo yum -y install collectd #install collectd from signalfx rpm
	printf "Installing baseplugins \n"
	sudo yum -y install collectd-disk collectd-write_http #install base plugins signalfx deems nessescar
	if [ -z "$api_token" ]
	then
		printf "We need you to provide the API Token for your org. This can be found @ https://app.signalfx.com/#/myprofile  \n"
		printf "Please enter your API Token: \n"
		read -r api_token
		printf "-->Starting Configuration of collectd... \n"
		curl https://s3.amazonaws.com/public-downloads--signalfuse-com/collectd-simple | sudo bash -s -- -t "$api_token"
	else
		curl https://s3.amazonaws.com/public-downloads--signalfuse-com/collectd-simple  | sudo bash -s -- -t "$api_token"
	fi
}


#Debian Based Linux Functions
install_debian_collectd_procedure() #install function for debian collectd
{
	printf "Updating apt-get \n"
	sudo apt-get -y update

	if [[ ( "$selection" -eq 6)  || ( "$selection" -eq 7 ) ]]
		then
			printf "Installing source package to get SignalFx collectd package \n"
			sudo apt-get -y install software-properties-common #for ubuntu > 13.10
	
	elif [[ "$selection" -eq 8 ]]
		then
			printf "Installing source package to get SignalFx collectd package \n"
			sudo apt-get install python-software-properties #for unbuntu < 13.10
	fi
		
	printf "Getting SignalFx collectd package \n"
	sudo add-apt-repository -y ppa:signalfx/collectd-release
	
	printf "Updating apt-get to reference new SignalFx package \n"
	sudo apt-get -y update
	
	printf "Installing collectd and additional plugins \n"
	sudo apt-get install collectd -y
	
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

#take "hostOS" and match it up to OS and assign task
case $hostOS in 
	"CentOS Linux 7") #hostOS
		needed_rpm=$centos_7
		needed_rpm_name=$centos_7_rpm
		printf "Install will proceed for Centos/RHEL Linux 7 \n"
		confirm
		install_rpm_collectd_procedure
	;;
	"CentOS Linux 6")
		needed_rpm=$centos_6
		needed_rpm_name=$centos_6_rpm
		printf "Install will proceed for Centos/RHEL Linux 6 \n"
		confirm
		install_rpm_collectd_procedure
	;;
	"Amazon Linux AMI 2014.09") #hostOS
		needed_rpm=$aws_linux_2014_09
		needed_rpm_name=$aws_linux_2014_09_rpm
		printf "Install will proceed for Amazon Linux 2014.09 \n"
		confirm
		install_rpm_collectd_procedure
	;;
	"Amazon Linux AMI 2015.03") #hostOS
		needed_rpm=$aws_linux_2015_03
		needed_rpm_name=$aws_linux_2015_03_rpm
		printf "Install will proceed for Amazon Linux 2015.03 \n"
		confirm
		install_rpm_collectd_procedure
	;;
	"Ubuntu 15.04" | "Ubuntu 14.04.1 LTS") #hostOS
		printf "Install will proceed for " "$hostOS" "\n"
		confirm
		install_debian_collectd_procedure
	;;
	*)
    	case $hostOS_2 in 
    		"CentOS release 6") #hostOS_2
				needed_rpm=$centos_6
				needed_rpm_name=$centos_6_rpm
				printf "Install will proceed for Centos/RHEL Linux 6 \n"
				confirm
				install_rpm_collectd_procedure
				;;
		
			
			"CentOS release 5") #hostOS_2
				needed_rpm=$centos_5
				needed_rpm_name=$centos_5_rpm
				printf "Install will proceed for Centos/RHEL Linux 5 \n"
				confirm
				install_rpm_RHELcentos5.x_procedure
				;;
		*) 
			get_os_input
			;;
		esac
	;;
    
esac