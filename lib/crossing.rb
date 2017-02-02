require 'aws-sdk'

# Documentation incoming
class Crossing
  def initialize(s3_client)
    if s3_client.nil?
      raise 'You did not pass in an S3 client...aborting'
    end
    @s3_client = s3_client
  end
  def put(bucket, filename)
    file = File.new(filename, "r")
    @s3_client.put_object(bucket: bucket, key: filename, body: file.read)
  end

  def get(bucket, file)

  end
end
