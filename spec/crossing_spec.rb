require_relative '../lib/crossing'

RSpec.describe 'Crossing' do
  context 'it can put files' do
    it 'will store the file in s3' do
      s3 = double('AWS::S3::Encryption::Client')
      allow(s3).to receive(:put_object).with(bucket: 'bucketname', key: 'gemtest.txt', body: "test\n")
      client = Crossing.new(s3)
      puts Dir.pwd
      client.put('bucketname', 'gemtest.txt')
    end
  end
  context 'it can get files' do
    it 'will retrieve the file in s3' do
    end
  end
end
