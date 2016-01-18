#!/usr/bin/ruby
#
#
require 'aws-sdk'
require 'open3'
require 'json'

# Things we need to get passed in
SNS_Target_ARN, *DIRS = ARGV

SQS_Target_ARN="arn:aws:sqs:us-east-1:496486987401:cfarris-proxytest"
SQS_Target_URL="https://sqs.us-east-1.amazonaws.com/496486987401/cfarris-proxytest"


mydirs=""
DIRS.each do |d|
  mydirs = mydirs + " " + d
end

# Assumes EC2 IAM role
sqs_client = Aws::SQS::Client.new()


while 1 do

  puts "Checking...."
  resp = sqs_client.receive_message({
    queue_url: SQS_Target_URL,
    attribute_names: ["Policy"], # accepts Policy, VisibilityTimeout, MaximumMessageSize, MessageRetentionPeriod, ApproximateNumberOfMessages, ApproximateNumberOfMessagesNotVisible, CreatedTimestamp, LastModifiedTimestamp, QueueArn, ApproximateNumberOfMessagesDelayed, DelaySeconds, ReceiveMessageWaitTimeSeconds, RedrivePolicy
    message_attribute_names: ["MessageAttributeName"],
    max_number_of_messages: 1,
    visibility_timeout: 1,
    wait_time_seconds: 10,
  })
  next if resp.messages.length == 0

  puts "Body: " + resp.messages[0].body.inspect
  message = JSON.parse(resp.messages[0].body)

  puts message.inspect
  puts "Filename: " + message[:\"filename\"]
  # puts "Attributes: " + resp.messages[0].attributes.inspect
  # puts "Handle: " + resp.messages[0].receipt_handle.inspect

  # resp = sqs_client.delete_message({
  #   queue_url: SQS_Target_URL,
  #   receipt_handle: resp.messages[0].receipt_handle
  #   })

end


exit 