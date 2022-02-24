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
    uri = URI("https://itunes.apple.com/search")
    uri.query=URI.encode_www_form({
        term: params[:keyward],
        media: "music",
        country: "JP"
    })
    res = Net::HTTP.get_response(uri)
    json = JSON.parse(res.body)
    @results=json["results"]
    erb :search
end

get "/post" do
    erb :home
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

post "/post" do
    content=Post.create(
        user_id: current_user.id,
        artist: params[:artistName],
        album: params[:collectionName],
        title: params[:trackName],
        jacket: params[:artworkUrl100],
        sample: params[:previewUrl],
        comment: params[:comment]
    )
    
    redirect "/post"
end