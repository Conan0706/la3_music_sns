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
    
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV["CLOUD_NAME"]
        config.api_key = ENV["CLOUDINARY_API_KEY"]
        config.api_secret = ENV["CLOUDINARY_API_SECRET"]
    end
end

before "/search" do
    @nowuser = current_user
end

before "/post" do
    @nowuser = current_user
end



get '/' do
    @posts = Post.all
    @nowuser = current_user
    
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

get "/signout" do
    session[:user] = nil
    redirect "/"
end

get "/post" do
    @user = current_user.name
    @likes = Like.all
    @posts = Post.all
    erb :home
end

post "/signup" do
    if params[:image].nil?
        img_url = "/assets/img/hito.png"
    else
        img=params[:image]
        tempfile = img[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        img_url = upload["url"]
    end
    
    @user = User.create(
        name: params[:name],
        image: img_url,
        password: params[:password], 
        password_confirmation: params[:password_confirmation]
    )
    
    if @user.persisted?
        session[:user] = @user.id
        redirect "/search"
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

get "/posts/:id/delete" do
    post = Post.find(params[:id])
    post.destroy
    redirect "/post"
end

get "/posts/:id/edit" do
    @post = Post.find(params[:id])
    erb :edit
end

post "/post/:id/edit" do
    @post = Post.find(params[:id])
    @post.comment = params[:newcomment]
    @post.save
    
    redirect "/post"
end

get "/posts/:id/like" do
    post_id = params[:id]
    Like.create(
        user_id: current_user.id,
        post_id: post_id
    )
    
    redirect "/"
end