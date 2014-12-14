#!/usr/bin/env ruby

require 'fileutils'
require 'time'
require 'aws-sdk'

version = `cat style.css | grep ersion | awk '{print $2}'`.chomp

directory = "yams-foundation-two-#{version}"

FileUtils.rm_rf directory if File.directory?(directory)

Dir.mkdir(directory)

globs = ['./*.php',
         'README.md',
         './assets',
         './css',
         './js',
         './languages',
         './library',
         './*.json',
         './parts',
         './scss',
         'screenshot.png',
         './style.css']

FileUtils.cp_r Dir.glob(globs), directory, :verbose => true

`zip -r yams-foundation-two-#{version}.zip yams-foundation-two-#{version} -x "*.DS_Store"`

creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'],
                             ENV['AWS_SECRET_ACCESS_KEY'])
s3client = Aws::S3::Client.new(credentials: creds,
                               region:'us-west-1')
s3 = Aws::S3::Resource.new(client: s3client)

path_to_file = "yams-foundation-two-#{version}.zip"

object = Aws::S3::Object.new(bucket_name: ENV['ZIP_BUCKET'],
                             key: "provisioning/yams-foundation-two-#{version}.zip",
                             client: s3client)

object.upload_file(path_to_file,
                   acl: 'public-read',
                   expires: Date.today >> 3,
                   cache_control: "Cache-Control: max-age=2592000")
