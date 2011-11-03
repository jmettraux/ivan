
require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'ruote'

#
# ruote

RUOTE = Ruote::Dashboard.new(
  Ruote::Worker.new(
    Ruote::HashStorage.new))
RUOTE.noisy = true

RUOTE.register :process_user_registration do |workitem|
  puts '>>> process_user_registration'
end
RUOTE.register :send_activation_mail do |workitem|
  puts '>>> send_activation_mail'
end
RUOTE.register :wait_for_confirmation do |workitem|
  puts '>>> wait_for_confirmation'
end
RUOTE.register :finalize_registration do |workitem|
  puts '>>> finalize_registration'
end
RUOTE.register :knit_sweater do |workitem|
  puts '... knit_sweater'
end

#
# sinatra

get '/' do

  content_type 'text/plain'

  "\nare you looking for ?\n  curl -v -X POST http://127.0.0.1:4567/launch\n?\n"
end

post '/launch' do

  wfid = RUOTE.launch(Ruote.define do
    process_user_registration
    send_activation_mail
    wait_for_confirmation :timeout => '24h'
    finalize_registration
  end)

  content_type 'text/plain'

  "launched #{wfid}\n"
end

post '/launchc' do

  wfid = RUOTE.launch(Ruote.define do
    process_user_registration
    send_activation_mail
    concurrence do
      wait_for_confirmation :timeout => '24h'
      knit_sweater
    end
    finalize_registration
  end)

  content_type 'text/plain'

  "launched #{wfid} (c)\n"
end

