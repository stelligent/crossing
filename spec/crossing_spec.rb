require_relative '../lib/crossing'
require 'securerandom'

RSpec.describe 'Crossing' do
  context 'it can put files' do
    it 'will store the file in s3' do
      s3 = double('AWS::S3::Encryption::Client')
      bucket = 'mock-bucket-name'
      filename = 'crossing.gemspec'
      content = File.new(filename, 'r').read
      allow(s3).to receive(:put_object).with(bucket: bucket, key: filename, body: content)
      client = Crossing.new(s3)
      client.put(bucket, filename)
    end

    it 'will upload a file at any path' do
      s3 = double('AWS::S3::Encryption::Client')
      bucket = 'mock-bucket-name'
      filename = 'spec/crossing_spec.rb'
      content = File.new(filename, 'r').read
      allow(s3).to receive(:put_object).with(bucket: bucket, key: 'crossing_spec.rb', body: content)
      client = Crossing.new(s3)
      client.put(bucket, filename)
    end

    it 'will raise an error for missing file' do
      s3 = double('AWS::S3::Encryption::Client')
      file = SecureRandom.uuid
      begin
        Crossing.new(s3).put('bucket', file)
        fail("should've thrown an exception for non-existent file")
      rescue CrossingFileNotFoundException => e
        # all good
      rescue Exception => e
        fail("threw unexpected exception #{e}")
      end
    end

  end
  context 'it can get files' do
    it 'will retrieve the file in s3' do
    end
  end
end
