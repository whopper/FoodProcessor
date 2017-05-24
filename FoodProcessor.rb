require 'sinatra'
require 'data_mapper'

get '/' do
  @items = Item.all :order => :id.desc
  erb :home
end

post '/' do
  item = Item.new
  item.name = params[:content]
  item.required = params[:required].nil? ? false : params[:required]
  item.save
  redirect '/'
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/foodprocessor.db")

class Item
  include DataMapper::Resource
  property :id, Serial
  property :name, Text, :required => true, :unique => true
  property :required, Boolean, :required => true, :default => false
end


DataMapper.finalize.auto_upgrade!
