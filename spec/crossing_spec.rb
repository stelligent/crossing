# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
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
        Crossing.new(Aws::S3::Client.new(region: 'us-east-1', stub_responses: true))
      end.to raise_exception(CrossingMisconfigurationException)
    end

    it 'will allow only Aws::S3::Encryption::Client as first parameter' do
      expect(
        Crossing.new(
          Aws::S3::Encryption::Client.new(
            encryption_key: 'asdfasdfasdfasdf',
            region: 'us-east-1',
            stub_responses: true
          )
        )
      ).to be_kind_of(Crossing)
    end

    it 'will allow only Aws:S3:Client as second parameter' do
      expect(
        Crossing.new(
          Aws::S3::Encryption::Client.new(
            encryption_key: 'asdfasdfasdfasdf',
            region: 'us-east-1',
            stub_responses: true
          ),
          Aws::S3::Client.new(region: 'us-east-1', stub_responses: true)
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
      expect(s3).to receive(:client).with(no_args)
      expect(s3).to receive(:put_object).with(bucket: bucket,
                                              key: filename,
                                              body: content,
                                              metadata: { 'x-crossing-uploaded' => 'true' })
      client = Crossing.new(s3)
      client.put(bucket, filename)
    end

    it 'will store multiple files in s3' do
      bucket = 'mock-bucket-name'
      filelist = %w[crossing.gemspec spec/crossing_spec.rb Rakefile]

      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      filelist.each do |file|
        expect(s3).to receive(:put_object)
          .with(bucket: bucket,
                key: File.basename(file),
                body: File.new(file, 'r').read,
                metadata: { 'x-crossing-uploaded' => 'true' })
      end

      client = Crossing.new(s3)
      client.put_multiple(bucket, filelist)
    end

    it 'will upload a file at any path' do
      s3 = double('AWS::S3::Encryption::Client')
      bucket = 'mock-bucket-name'
      filename = 'spec/crossing_spec.rb'
      content = File.new(filename, 'r').read
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      expect(s3).to receive(:put_object).with(bucket: bucket,
                                              key: 'crossing_spec.rb',
                                              body: content,
                                              metadata: { 'x-crossing-uploaded' => 'true' })
      client = Crossing.new(s3)
      client.put(bucket, filename)
    end

    it 'will raise an error for missing file' do
      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      file = SecureRandom.uuid
      expect do
        Crossing.new(s3).put('bucket', file)
      end.to raise_error(CrossingFileNotFoundException)
    end

    it 'will raw content in s3' do
      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      bucket = 'mock-bucket-name'
      filename = 'crossing.gemspec'
      content = File.new(filename, 'r').read
      expect(s3).to receive(:put_object).with(bucket: bucket,
                                              key: filename,
                                              body: content,
                                              metadata: { 'x-crossing-uploaded' => 'true' })
      client = Crossing.new(s3)
      client.put_content(bucket, filename, content)
    end
  end

  before :context do
    @filename = 'mock-file-name'
  end

  after :context do
    File.delete(@filename)
  end

  context 'it can get files' do
    it 'will retrieve the file in s3' do
      bucket = 'mock-bucket-name'

      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      expect(s3).to receive(:get_object).with(bucket: bucket, key: @filename)
                                        .and_return(S3Result.new)

      allow(File).to receive(:exist?)
      allow(File).to receive(:write)

      client = Crossing.new(s3)
      client.get(bucket, @filename)
    end

    it 'will retrieve an unencrypted file in s3' do
      bucket = 'mock-bucket-name'

      s3 = double('AWS::S3::Encryption::Client', stub_responses: true)
      s3.stub_responses(:get_object, Aws::S3::Encryption::Errors::DecryptionError)
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:get_object).with(bucket: bucket, key: @filename)
                                        .and_raise(Aws::S3::Encryption::Errors::DecryptionError)

      s3_reg = double('AWS::S3::Client', region: 'us-east-1')
      expect(s3_reg).to receive(:is_a?).and_return(true)
      expect(s3_reg).to receive(:get_object).with(bucket: bucket, key: @filename)
                                            .and_return(S3Result.new)

      allow(File).to receive(:exist?)
      allow(File).to receive(:write)

      # init crossing with the enc s3 and regular s3 clients
      client = Crossing.new(s3, s3_reg)

      client.get(bucket, @filename)
    end

    it 'will retrieve multiple files from s3' do
      bucket = 'mock-bucket-name'
      filelist = %w[mock-file-name1 mock-file-name2 mock-file-name3]

      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      filelist.each do |file|
        expect(s3).to receive(:get_object)
          .with(bucket: bucket, key: file)
          .and_return(S3Result.new)
      end

      client = Crossing.new(s3)
      client.get_multiple(bucket, filelist)

      filelist.each { |file| File.delete(file) }
    end

    it 'will use wb mode' do
      bucket = 'mock-bucket-name'
      expected_mode = 'wb'

      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      expect(s3).to receive(:get_object).with(bucket: bucket, key: @filename)
                                        .and_return(S3Result.new)

      allow(File).to receive(:open).with(@filename, expected_mode)
      allow(File).to receive(:exist?)
      allow(File).to receive(:write)

      client = Crossing.new(s3)
      client.get(bucket, @filename)
    end

    it 'will not overwrite local files' do
      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      allow(File).to receive(:exist?).and_return true

      bucket = 'mock-bucket-name'

      expect do
        client = Crossing.new(s3)
        client.get(bucket, @filename)
      end.to raise_error(CrossingFileExistsException)
    end

    it 'will deliver the file contents without writing a file' do
      bucket = 'mock-bucket-name'

      allow(File).to receive(:exist?).and_return true

      s3 = double('AWS::S3::Encryption::Client')
      expect(s3).to receive(:is_a?).and_return(true)
      expect(s3).to receive(:client).with(no_args)
      expect(s3).to receive(:get_object).with(bucket: bucket,
                                              key: @filename).and_return(S3Result.new)
      expect(
        Crossing.new(s3).get_content(bucket, @filename)
      ).to be_kind_of(String)
    end
  end
end
# rubocop:enable Metrics/BlockLength
