require 'aws-sdk'

# Documentation incoming
class Crossing
  def initialize(s3_client)
    raise CrossingMisconfigurationException if s3_client.nil?
    raise CrossingMisconfigurationException unless s3_client.is_a? Aws::S3::Encryption::Client
    @s3_client = s3_client
  end

  def put(bucket, filename)
    begin
      file = File.new(filename, 'r')
    rescue
      raise CrossingFileNotFoundException, "File not found: #{filename}"
    end

    put_content(bucket, filename.split('/').last, file.read)
  end

  def put_content(bucket, filename, content)
    @s3_client.put_object(bucket: bucket, key: filename.split('/').last, body: content)
  end

  def get(bucket, file)
    if File.exist?(file)
      raise(CrossingFileExistsException,
            "File #{file} already exists, will not overwrite.")
    end

    content = get_content(bucket, file)
    File.open(file, 'w') { |f| f.write(content) }
  end

  def get_content(bucket, file)
    @s3_client.get_object(bucket: bucket, key: file).body.read
  end
end

class CrossingError < StandardError
end

class CrossingMisconfigurationException < CrossingError
end

class CrossingFileNotFoundException < CrossingError
end

class CrossingFileExistsException < CrossingError
end
