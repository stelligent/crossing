# :children_crossing: crossing

build status: [![CircleCI](https://circleci.com/gh/stelligent/crossing.svg?style=svg)](https://circleci.com/gh/stelligent/crossing)

### :children_crossing: Description
Crossing is a utility for storing objects in S3 while taking advantage of client side envelope encryption with KMS.  The native AWS CLI tool does not have an easy way to client-side-encrypted-upload's into S3.  The Ruby SDK _does_ have an easy way to do this, but not everyone wants drop to Ruby.  

This utility allows you to do client side encrypted uploads to S3 from the command line, allowing you to quickly upload files to S3 securely. 

### :children_crossing: Installation

Crossing requires Ruby 2.2.9 (or higher). 2.2.9 is the oldest version of ruby still supported by the Ruby language authors.

To install the gem:

    gem install crossing

### :children_crossing: Usage
Crossing is designed to be dead simple to use. To upload, you just need to provide a filepath, bucket location, region and which KMS key to use.

    crossing put \
      --file path/to/your/src/file \
      --bucket your-bucket \
      --kmskeyid abcde-12345-abcde-12345

Downloading is basically the same:

    crossing get \
      --file path/to/your/dest/file \
      --bucket your-bucket

### :children_crossing: License

Refer to [LICENSE.md](LICENSE.md)
