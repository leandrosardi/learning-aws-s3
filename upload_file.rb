require 'aws-sdk-s3' # Ensure the AWS SDK for S3 is installed
require_relative 'config.rb'

# Initialize the S3 client
S3 = Aws::S3::Client.new(
  region: AWS_S3_REGION,
  access_key_id: AWS_S3_ACCESS_KEY_ID,
  secret_access_key: AWS_S3_SECRET_ACCESS_KEY
)

# Function to upload a file and get its public URL
def upload_file_to_s3(bucket_name, file_path, s3_key)
  # Upload the file
  S3.put_object(bucket: bucket_name, key: s3_key, body: File.open(file_path))
  # Generate the public URL
  public_url = "https://#{bucket_name}.s3.amazonaws.com/#{s3_key}"
  # return
  return public_url
end

# Usage example
bucket_name = AWS_S3_BUCKET_NAME
file_path = './assets/massprospecting-logo.png' # Path to the local file
s3_key = 'my-first-folder/logo.png'     # Key (including "folders") for the file in S3
#s3_key = 'Gemfile'     # Key (including "folders") for the file in S3

puts upload_file_to_s3(bucket_name, file_path, s3_key)
# => https://massprospecting.s3.us-east-2.amazonaws.com/my-first-folder/logo.png