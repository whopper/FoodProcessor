require 'sinatra'
require 'securerandom'
require 'data_mapper'
require 'pony'
require_relative 'lib/foodprocessor.rb'
require_relative 'models/schema.rb'

get '/' do
  @events = Event.all :order => :id.desc
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
  @title= "Confirm deletion of item ##{params[:id]}"
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
  link.save
  event.link = link.id
  event.save

  # TODO remove all this
  params[:name] = event.name
  params[:username] = 'Todd'
  params[:owner_name] = 'Will Hopper'
  params[:link] = 'https://brownbag.io/events/AedfbY'
  params[:email] = 'william.vanhevelingen@acquia.com'
  FoodProcessor::Invite.send_email(params)

  redirect '/events'
end

