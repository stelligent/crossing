require 'aws-sdk'

# Documentation incoming
class Crossing
  def initialize(s3_client)
    raise 'You did not pass in an S3 client...aborting' if s3_client.nil?
    @s3_client = s3_client
  end

  def put(bucket, filename)
    begin
      file = File.new(filename, 'r')
    rescue
      raise CrossingFileNotFoundException.new("File not found: #{filename}")
    end

    @s3_client.put_object(bucket: bucket, key: filename.split('/').last, body: file.read)
  end

  def get(bucket, file)
    @s3_client.get_object(bucket: bucket, key: file)
  end
end

class CrossingError < StandardError
end

class CrossingFileNotFoundException < CrossingError
end
