require 'sinatra'
require 'securerandom'
require 'data_mapper'
require 'pony'
require_relative 'lib/foodprocessor.rb'
require_relative 'models/schema.rb'

get '/' do
  @events = Event.all order: :id.desc
  erb :home
end

get '/event/new' do
  @event = Event.new
  erb :event
end

get '/item/:id' do
  @item = Item.get params[:id]
  erb :item
end

get '/item/:id/delete' do
  @item = Item.get params[:id]
  @title = "Confirm deletion of item ##{params[:id]}"
  erb :delete
end

get '/events/create' do
  erb :create_event
end

delete '/item/:id' do
  item = Item.get params[:id]
  item.destroy
  redirect '/'
end

post '/events/create' do
  event = Event.new
  event.name = params[:eventname]
  event.date = params[:eventdate]
  event.location = params[:location]
  link = Link.new
  link.url = "#{request.base_url}/invite/#{SecureRandom.hex(6)}"
  link.save
  event.link = link

  # make an owner
  owner = Owner.new
  owner.name = 'Will Hopper'
  owner.email = 'willliam.hopper@acquia.com'
  # owner.save
  event.owner = owner

  # make a guest
  guest = User.new
  guest.name = 'William Van Hevelingen'
  guest.email = 'william.vanhevelingen@acquia.com'
  # guest.save
  event.guests << guest

  # save
  event.save

  event.guests.each do |guest|
    FoodProcessor::Invite.send_email(event, guest)
  end

  redirect '/events'
end
