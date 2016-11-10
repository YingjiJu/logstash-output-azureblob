# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"

require 'azure'

class LogStash::Outputs::Azureblob < LogStash::Outputs::Base

  config_name "azureblob"

  # This configuration controls which storage account connects to.
  config :storage_account_name, :validate => :string, :default => nil
  # This configuration set the access key of the storage account.
  config :storage_access_key, :validate => :string, :default => nil
  # This configuration controls which container the message uploaded to.
  config :azure_container, :validate => :string, :default => nil
  # This configuration controls whether create container if it doesn't exists.
  config :auto_create_container, :validate => :boolean, :default => true

  public
  def register
    Azure.configure do |config|
        config.storage_account_name = @storage_account_name
        config.storage_access_key = @storage_access_key
    end

    @client = Azure::Blob::BlobService.new
    ensure_container
  end # def register

  public
  def multi_receive(events)
    events.each do |event|
      begin
        file_path = get_file_path(event)
        timestamp = get_message_timestamp(event)
        storage_path = get_storage_path(file_path, timestamp)

        exist = blob_exists?(@azure_container, storage_path)
        if exist
          @logger.warn("Blob #{storage_path} already exists!")
          next
        end

        message = get_message(event)
        upload(message, @azure_container, storage_path)

      rescue => e
        @logger.error("Error occurred uploading data to Azureblob.", :exception => e)
      end #begin
    end # do
  end # def multi_receive

  private
  def validate_config
    if @storage_account_name.nil?
      raise 'azure storage account is needed'
    end

    if @storage_access_key.nil?
      raise 'azure storage account access key is needed'
    end

    if @azure_container.nil?
      puts "default azure container #{@azure_container} is used"
    end
  end #def validate_config

  private
  def ensure_container
    if ! @client.list_containers.find { |c| c.name == @azure_container }
      if @auto_create_container
        @client.create_container(@azure_container)
        @logger.info ("Create container #{@azure_container}succeed!")
      end
    else
      @logger.info( "Container #{@azure_container} exists!")
    end
  end # def ensure_container

  private
  def get_file_path(event)
    return event[:path]
  end # def get_file_path

  private
  def get_message_timestamp(event)
    return (Time.parse(event[:timestamp])).strftime("%Y-%m-%d-%H-%M-%S")
  end #def get_message_timestamp

  private
  def get_storage_path(file_path, timestamp)
    paths = file_path.split("/")
    length = paths.length
    return paths[length-3] + "/" + paths[length-2] + "/" + paths[length-1] + "-" + timestamp
  end #def get_storage_path

  private
  def get_message(event)
    return event[:message]
  end # def get_message

  private
  def blob_exists?(container, blob)
    entires = @client.list_blobs(@azure_container, {:timeout => 10})
    entires.each do |entry|
      if(blob == entry.name)
        return true
      end
    end

    return false
  end # def blob_exists?

  private
  def upload(message, container, blob)
      @client.create_block_blob(container, blob, message)
    @logger.info("upload #{message} to #{blob} in container #{container}")
  end #def upload
end # class Logstash::Outputs::Azureblob