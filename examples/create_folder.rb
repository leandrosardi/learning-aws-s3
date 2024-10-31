require 'aws-sdk-s3' # Ensure the AWS SDK for S3 is installed
require_relative 'config.rb'

# Initialize the S3 client
S3 = Aws::S3::Client.new(
  region: AWS_S3_REGION,
  access_key_id: AWS_S3_ACCESS_KEY_ID,
  secret_access_key: AWS_S3_SECRET_ACCESS_KEY
)

# Function to create a folder in S3
def create_s3_folder(bucket_name, folder_name)
  S3.put_object(bucket: bucket_name, key: "#{folder_name}/")
  return true
end

# Usage example
bucket_name = AWS_S3_BUCKET_NAME
folder_name = 'my-first-folder' # Name of the folder you want to create

create_s3_folder(bucket_name, folder_name)
