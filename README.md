# crossing

#Destription
Utility for storing objects in S3 while taking advantage of client side envelope encryption with KMS.  The native AWS command line does not have an easy way to upload encrypted files to S3.  The Ruby SDK has a way to do this, but not everyone wants to use it.  This utility allows you to do client side encrypted uploads to S3 from the command line, which is useful for uploads from your CI system to docker containers.

#Installation
Requires ruby 1.9.3(or higher) installed, this is the defaul lruby install on most modern operating systems and can be installed from your package manager.

gem install #gemnametbd

#Usage
crossing upload -s file -b bucket --key
crossing download -s file -b bucket

#License
Refer to LICENSE.md
