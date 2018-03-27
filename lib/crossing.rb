require 'aws-sdk'

# Documentation incoming
class Crossing
  def setup_unencrypted_client(s3_client_encrypted, s3_client_unencrypted)
    if !s3_client_unencrypted.nil?
      raise CrossingMisconfigurationException unless s3_client_unencrypted.is_a? Aws::S3::Client
      @s3_client_unencrypted = s3_client_unencrypted
    else
      # assign regular s3 client
      @s3_client_unencrypted = s3_client_encrypted.client
    end
  end

  def initialize(s3_client_encrypted, s3_client_unencrypted = nil)
    raise CrossingMisconfigurationException if s3_client_encrypted.nil?
    unless s3_client_encrypted.is_a? Aws::S3::Encryption::Client
      raise CrossingMisconfigurationException
    end
    @s3_client_encrypted = s3_client_encrypted

    setup_unencrypted_client s3_client_encrypted, s3_client_unencrypted
  end

  def put(bucket, filename)
    File.open(filename, 'r') do |file|
      put_content(bucket, File.basename(filename), file.read)
    end
  rescue Errno::ENOENT
    raise CrossingFileNotFoundException, "File not found: #{filename}"
  end

  def put_content(bucket, filename, content)
    @s3_client_encrypted.put_object(bucket: bucket,
                                    key: filename,
                                    body: content,
                                    metadata: { 'x-crossing-uploaded' => 'true' })
  end

  def get(bucket, file)
    if File.exist?(file)
      raise(CrossingFileExistsException,
            "File #{file} already exists, will not overwrite.")
    end

    content = get_content(bucket, file)

    File.open(file, 'wb') { |f| f.write(content) }
  end

  def get_multiple(bucket, filelist)
    filelist.each { |file| get(bucket, file) }
  end

  def put_multiple(bucket, filelist)
    filelist.each { |file| put(bucket, file) }
  end

  def get_content(bucket, file)
    @s3_client_encrypted.get_object(bucket: bucket, key: file).body.read

  # If a decryption exception occurs, warn and get the object without decryption
  rescue Aws::S3::Encryption::Errors::DecryptionError
    STDERR.puts "WARNING: #{file} decryption failed. Retreiving the object without encryption."
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
