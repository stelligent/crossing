require 'aws-sdk'

# Documentation incoming
class Crossing
  def initialize(s3_client, s3_client_unenc=nil)
    raise CrossingMisconfigurationException if s3_client.nil?
    raise CrossingMisconfigurationException unless s3_client.is_a? Aws::S3::Encryption::Client
    @s3_client = s3_client

    if s3_client_unenc != nil
      raise CrossingMisconfigurationException unless s3_client_unenc.is_a? Aws::S3::Client
      @s3_client_unencrypted = s3_client_unenc
    else
      #create regular s3 client
      @s3_client_unencrypted = Aws::S3::Client.new
    end
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
                          body: content,
			  tagging: "x-crossing-uploaded=true")
  end

  def get(bucket, file)
    if File.exist?(file)
      raise(CrossingFileExistsException,
            "File #{file} already exists, will not overwrite.")
    end

    content = get_content(bucket, file)

    File.open(file, 'wb') { |f| f.write(content) }
  end

  def get_content(bucket, file)
    @s3_client.get_object(bucket: bucket, key: file).body.read

  # If a decryption exception occurs, warn and get the object without decryption
  rescue Aws::S3::Encryption::Errors::DecryptionError
    STDERR.puts "WARNING: \""+file+"\" decryption with the key failed. Retreiving the object without encryption."
    @s3_client_unencrypted.get_object(bucket: bucket, key: file).body.read
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
