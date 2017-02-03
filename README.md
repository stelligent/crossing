# :children_crossing: crossing

build status: [![CircleCI](https://circleci.com/gh/stelligent/crossing.svg?style=svg)](https://circleci.com/gh/stelligent/crossing)

### :children_crossing: Description
Crossing is a utility for storing objects in S3 while taking advantage of client side envelope encryption with KMS.  The native AWS CLI tool does not have an easy way to client-side-encrypted-upload's into S3.  The Ruby SDK _does_ have an easy way to do this, but not everyone wants drop to Ruby.  

This utility allows you to do client side encrypted uploads to S3 from the command line, allowing you to quickly upload files to S3 securely. 

### :children_crossing: Installation

Crossing requires Ruby 1.9.3 (or higher). 1.9.3 is the default ruby install on most modern operating systems and can be installed from your package manager (`apt-get install ruby` or similar).

To install the gem:

    gem install crossing

### :children_crossing: Usage
Crossing is designed to be dead simple to use. To upload, you just need to provide a filepath, bucket location, region and which KMS key to use.

    crossing put \
      --file path/to/your/src/file \
      --bucket your-bucket \
      --kms-key-id abcde-12345-abcde-12345 \
      --region 'us-east-1'

Downloading is basically the same:

    crossing get \
      --file path/to/your/dest/file \
      --bucket your-bucket \
      --region 'us-east-1'

### :children_crossing: License

Refer to [LICENSE.md](LICENSE.md)
