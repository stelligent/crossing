require_relative '../lib/crossing'
require 'securerandom'

class S3Result
  attr_accessor :body
  def initialize
    @body = self
  end

  def read
    'content'
  end
end

RSpec.describe 'Crossing' do
  context 'it can put files' do
    it 'will store the file in s3' do
      s3 = double('AWS::S3::Encryption::Client')
      bucket = 'mock-bucket-name'
      filename = 'crossing.gemspec'
      content = File.new(filename, 'r').read
      expect(s3).to receive(:put_object).with(bucket: bucket, key: filename, body: content)
      client = Crossing.new(s3)
      client.put(bucket, filename)
    end

    it 'will upload a file at any path' do
      s3 = double('AWS::S3::Encryption::Client')
      bucket = 'mock-bucket-name'
      filename = 'spec/crossing_spec.rb'
      content = File.new(filename, 'r').read
      expect(s3).to receive(:put_object).with(bucket: bucket, key: 'crossing_spec.rb', body: content)
      client = Crossing.new(s3)
      client.put(bucket, filename)
    end

    it 'will raise an error for missing file' do
      s3 = double('AWS::S3::Encryption::Client')
      file = SecureRandom.uuid
      begin
        Crossing.new(s3).put('bucket', file)
        raise("should've thrown an exception for non-existent file")
      rescue CrossingFileNotFoundException
        # all good
      rescue StandardError => e
        raise("threw unexpected exception #{e}")
      end
    end
  end

  context 'it can get files' do
    it 'will retrieve the file in s3' do
      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:get_object).with(bucket: bucket, key: filename).and_return(S3Result.new)

      filesystem = double('File')
      allow(filesystem).to receive(:exist?)
      allow(filesystem).to receive(:write)

      bucket = 'mock-bucket-name'
      filename = 'mock-file-name'

      client = Crossing.new(s3)
      client.get(filesystem, bucket, filename)
    end

    it 'will not overwrite local files' do
      s3 = double('AWS::S3::Encryption::Client')
      filesystem = double('File')
      allow(filesystem).to receive(:exist?).and_return true

      bucket = 'mock-bucket-name'
      filename = 'mock-file-name'

      client = Crossing.new(s3)
      begin
        client.get(filesystem, bucket, filename)
      rescue CrossingFileExistsException
        # all good
      rescue StandardError => e
        raise("threw unexpected exception #{e}")
      end
    end
  end
end
