## Installing Gems

```
git clone https://github.com/leandrosardi/learning-aws-s3
cd learning-aws-s3
bundler update
```

## Creating a Folder

```ruby
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
```

## Uploading Files

```ruby
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
```

## Steps to Obtain `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from the AWS Console:

1. Log into the AWS Management Console:
   - Open your browser and go to https://aws.amazon.com/console/
   - Sign in to your AWS account.

2. Navigate to IAM (Identity and Access Management):
   - In the AWS Console, locate the search bar at the top.
   - Type "IAM" and select IAM from the list of services.

3. Go to Users:
   - In the IAM dashboard, click on "Users" from the left-hand menu.

4. Select or Create a User:
   - To use an existing user with programmatic access, select the user from the list.
   - Alternatively, to create a new user, click "Add user":
      a. Enter a username.
      b. Under "Access type," select "Programmatic access" to enable an access key.
      c. Click "Next" and proceed to set up permissions.
         - For S3 access, you might attach a policy like "AmazonS3FullAccess" to grant the user necessary permissions.

5. Generate Access Keys:
   - For an existing user, go to the "Security credentials" tab of the user.
   - Click "Create access key" to generate a new access key.
   - This action will provide both the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.

6. Download and Save the Keys:
   - Store the keys securely. 
   - IMPORTANT: The Secret Access Key will only be shown once; download the CSV file or copy it securely.

Example of using AWS credentials in Ruby:

```ruby
require 'aws-sdk-s3'

Aws.config.update({
  region: 'your-region',                        e.g., 'us-east-1'
  credentials: Aws::Credentials.new(
    'YOUR_AWS_ACCESS_KEY_ID',                   Replace with your Access Key ID
    'YOUR_AWS_SECRET_ACCESS_KEY'                Replace with your Secret Access Key
  )
})

s3 = Aws::S3::Resource.new
bucket = s3.bucket('your-bucket-name')          Replace with your bucket name
puts "Bucket exists? #{bucket.exists?}"
```

This will configure the AWS SDK to authenticate with the provided keys and allow interaction with S3.

## If the Bucket Should Be Public (e.g., for Hosting Public Files)

- You can disable "Block all public access" if the bucket is intended to serve files publicly (e.g., static assets for a website).

- Instead of using object ACLs, add a bucket policy to control access more securely and selectively.

- Example: You can allow public s3:GetObject access to only certain paths or objects while keeping other objects private.

## Resolving the "The bucket does not allow ACLs" Error:

This error occurs when the S3 bucket has **S3 Object Ownership** enabled, 
which enforces the bucket owner to have full control over the objects and disables ACLs (Access Control Lists).

To set up the bucket properly, follow these steps in the AWS Console:

1. Open the AWS S3 Console:
   - Go to https://s3.console.aws.amazon.com/ and log in to your AWS account.

2. Locate the Bucket:
   - In the S3 dashboard, find the bucket you are trying to upload to and click on it to access its settings.

3. Configure Bucket's Object Ownership:
   - Go to the **Permissions** tab.
   - Under **Object Ownership**, ensure the setting is set to **Bucket owner enforced**. 
     - This setting makes the bucket owner the sole owner of all objects and disables ACLs.
     - As a result, using ACL settings (like `acl: 'public-read'`) in upload operations will trigger an error.

4. Set Public Access at the Bucket Level (if public access is needed):
   - Instead of using ACLs for individual objects, configure public access at the bucket level:
     - Go to **Bucket Policy** under the **Permissions** tab.
     - Use a bucket policy to make the entire bucket or specific paths publicly accessible.
   - Example Bucket Policy for Public Access:

     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": "*",
           "Action": "s3:GetObject",
           "Resource": "arn:aws:s3:::your-bucket-name/*"
         }
       ]
     }
     ```

     - Replace `"your-bucket-name"` with the actual bucket name.
     - This policy allows public read access to all objects in the bucket without requiring `acl: 'public-read'` in the code.

5. Update the Code (if ACLs are disabled):
   - Since ACLs are not allowed with **Bucket owner enforced**, remove `acl: 'public-read'` from the code:

   ```ruby
   S3.put_object(bucket: bucket_name, key: s3_key, body: File.open(file_path))
   ```

6. Access the Public URL:
   - With the bucket policy set for public access, you can directly access the uploaded file using:
     ```ruby
     public_url = "https://#{bucket_name}.s3.amazonaws.com/#{s3_key}"
     ```
   - This URL will work if the bucket policy allows public access.
