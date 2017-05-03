require 'aws-sdk'

# Documentation incoming
class Crossing
  def initialize(s3_client)
    raise CrossingMisconfigurationException if s3_client.nil?
    raise CrossingMisconfigurationException unless s3_client.is_a? Aws::S3::Encryption::Client
    @s3_client = s3_client
  end

  def put(bucket, filename)
    File.open(filename, 'r') do |file|
      put_content(bucket, File.basename(filename), file.read)
    end
  rescue Errno::ENOENT
    raise CrossingFileNotFoundException, "File not found: #{filename}"
  end

  def put_content(bucket, filename, content)
    @s3_client.put_object(bucket: bucket,
                          key: File.basename(filename),
                          body: content)
  end

  def get(bucket, file, binary = false)
    if File.exist?(file)
      raise(CrossingFileExistsException,
            "File #{file} already exists, will not overwrite.")
    end

    binary ? 'wb' : 'w'

    content = get_content(bucket, file)

    File.open(file, mode) { |f| f.write(content) }
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
