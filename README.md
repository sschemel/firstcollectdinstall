# firstcollectdinstall

To run the script:

bash <(curl -s https://raw.githubusercontent.com/sschemel/firstcollectdinstall/master/firstcollectdinstall.sh) 

**you will be prompted hostname for username and password**

or

bash <(curl -s https://raw.githubusercontent.com/sschemel/firstcollectdinstall/master/firstcollectdinstall.sh) API_TOKEN

**you will be prompted for only hostname**


The final one liner will be of the format something like this: 

curl -sSL https://dl.signalfx.com/collectd-simple-v2 | bash -s YOUR_API_TOKEN



