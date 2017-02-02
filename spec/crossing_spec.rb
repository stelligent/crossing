require_relative '../lib/crossing'

RSpec.describe 'Crossing' do
  context 'it can put files' do
    it 'will store the file in s3' do
      s3 = double("AWS::S3::Encryption::Client")
      allow(s3).to receive(:put_object).with(:bucket=>'bucketname', :key=>'keyname', :body=>'filename')
      client = Crossing.new(s3)
      client.put('bucketname', 'keyname', 'filename')
    end
  end
  context 'it can get files' do
    it 'will retrieve the file in s3' do

    end
  end
end
