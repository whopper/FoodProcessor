require 'sinatra'

get '/' do
  @test = 'Hello World'
  erb :home
end
