require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'

require "sinatra/activerecord"
require 'dotenv/load'
require "open-uri"
require "json"
require "net/http"

# require 'itunes-search-api'

enable :sessions

helpers do
    def  current_user
        User.find_by(id: session[:user])
    end
end


get '/' do
    erb :index
end

get "/signup" do
    erb :sign_up
end

get "/search" do
    @user = current_user.name
    uri = URI("https://itunes.apple.com/search?term=GRAY&media=music&country=JP&limit=10")
    #uri.query=URI.encode_www_form()
    res = Net::HTTP.get_response(uri)
    json = JSON.parse(res.body)
    @music=json
    erb :search
end

post "/signup" do
    @user = User.create(
        name: params[:name],
        password: params[:password], 
        password_confirmation: params[:password_confirmation]
    )
    
    if @user.persisted?
        session[:user] = @user.id
    end
    redirect "/"
end

post "/signin" do
    user=User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
        redirect "/search"
    else
        redirect "/"
    end
end