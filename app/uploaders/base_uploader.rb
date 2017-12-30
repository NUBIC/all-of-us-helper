# encoding: utf-8
class BaseUploader < CarrierWave::Uploader::Base
  storage :file

  # Copy from https://github.com/Lorjuo/tgt/blob/master/app/uploaders/document_uploader.rb
  # partitions ID to be like: 0000/0000/0123
  # to keep no more than 10,000 entries per directory
  # EXT3 max: 32,000 dirs
  # EXT4 max: 64,000 dirs
  def partition(modelid)
    ("%08d" % modelid).scan(/\d{4}/).join("/")
  end
end