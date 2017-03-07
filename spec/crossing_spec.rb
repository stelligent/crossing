require_relative '../lib/crossing'
require 'securerandom'
require 'spec_helper'

class S3Result
  attr_accessor :body
  def initialize
    @body = self
  end

  def read
    'content'
  end
end

describe 'Crossing' do
  context 'it gives you useful errors' do
    it 'will tell you that you need to pass in a parameter' do
      expect do
        Crossing.new
      end.to raise_error(ArgumentError)
    end

    it 'will tell you that you need to pass in an S3 client' do
      expect do
        Crossing.new(Aws::S3::Client.new(region: 'us-east-1'))
      end.to raise_exception(CrossingMisconfigurationException)
    end

    it 'will will allow only Aws::S3::Encryption::Client' do
      expect(
        Crossing.new(
          Aws::S3::Encryption::Client.new(
            encryption_key: 'asdfasdfasdfasdf',
            region: 'us-east-1'
          )
        )
      ).to be_kind_of(Crossing)
    end
  end

  context 'it can put files' do
    it 'will store the file in s3' do
      s3 = double('AWS::S3::Encryption::Client')
      bucket = 'mock-bucket-name'
      filename = 'crossing.gemspec'
      content = File.new(filename, 'r').read
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:put_object).with(bucket: bucket,
                                              key: filename,
                                              body: content)
      client = Crossing.new(s3)
      client.put(bucket, filename)
    end

    it 'will upload a file at any path' do
      s3 = double('AWS::S3::Encryption::Client')
      bucket = 'mock-bucket-name'
      filename = 'spec/crossing_spec.rb'
      content = File.new(filename, 'r').read
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:put_object).with(bucket: bucket,
                                              key: 'crossing_spec.rb',
                                              body: content)
      client = Crossing.new(s3)
      client.put(bucket, filename)
    end

    it 'will raise an error for missing file' do
      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      file = SecureRandom.uuid
      expect do
        Crossing.new(s3).put('bucket', file)
      end.to raise_error(CrossingFileNotFoundException)
    end

    it 'will raw content in s3' do
      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      bucket = 'mock-bucket-name'
      filename = 'crossing.gemspec'
      content = File.new(filename, 'r').read
      expect(s3).to receive(:put_object).with(bucket: bucket,
                                              key: filename,
                                              body: content)
      client = Crossing.new(s3)
      client.put_content(bucket, filename, content)
    end
  end

  context 'it can get files' do
    it 'will retrieve the file in s3' do
      bucket = 'mock-bucket-name'
      filename = 'mock-file-name'

      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:get_object).with(bucket: bucket, key: filename)
        .and_return(S3Result.new)

      allow(File).to receive(:exist?)
      allow(File).to receive(:write)

      client = Crossing.new(s3)
      client.get(bucket, filename)
    end

    it 'will not overwrite local files' do
      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      allow(File).to receive(:exist?).and_return true

      bucket = 'mock-bucket-name'
      filename = 'mock-file-name'

      expect do
        client = Crossing.new(s3)
        client.get(bucket, filename)
      end.to raise_error(CrossingFileExistsException)
    end

    it 'will deliver the file contents without writing a file' do
      bucket = 'mock-bucket-name'
      filename = 'mock-file-name'

      allow(File).to receive(:exist?).and_return true

      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:get_object).with(bucket: bucket,
                                              key: filename).and_return(S3Result.new)
      expect(
        Crossing.new(s3).get_content(bucket, filename)
      ).to be_kind_of(String)
    end
  end
end
