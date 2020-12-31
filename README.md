# :children_crossing: crossing

![](https://github.com/stelligent/crossing/workflows/crossing/badge.svg)
## Overview
Crossing is a utility for storing objects in S3 while taking advantage of client side envelope encryption with KMS.  The native AWS CLI tool does not have an easy way to client-side-encrypted-upload's into S3.

This utility allows you to do client side encrypted uploads to S3 from the command line, allowing you to quickly upload files to S3 securely.

## Installation

Crossing requires Ruby 2.5 (or higher)

To install the gem:
```
  gem install crossing
```
## Usage
Crossing is designed to be simple to use.

```
> crossing --help
Utility for storing and retrieving files in S3 in a secure manner
  available commands:

    put -- store a file in S3
    get -- retrieve a file from S3

  use --help with either command for more information.

  -r, --region=<s>    The AWS region to interact with (default: us-east-1)
  -h, --help          Show this message
```

###  Upload
```
  crossing put \
    --file path/to/your/src/file \
    --bucket your-bucket \
    --kmskeyid abcde-12345-abcde-12345
```

### Download
```
  crossing get \
    --file path/to/your/dest/file \
    --bucket your-bucket
```
## License

Refer to [LICENSE.md](LICENSE.md)
