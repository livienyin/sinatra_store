# gem install --version 1.3.0 sinatra
require 'pry'
gem 'sinatra', '1.3.0'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

require 'open-uri'
require 'json'
require 'uri'
require './private.rb'

before do
  @db = SQLite3::Database.new "store.sqlite3"
  @db.results_as_hash = true
end

configure do
  @@home_uri = "/"
  @@users_uri = "/users"
  @@products_uri = "/products"
  @@google_shopping_api_base_url = "https://www.googleapis.com/shopping/search/v1/public/products"
end

get '/' do
  redirect @@products_uri
end


get '/users' do
  @rs = @db.execute('SELECT * FROM users;')
  erb :show_users
end

get '/users.json' do
  @rs = @db.execute('SELECT id, name FROM users;')
  @rs.to_json
end

get '/products' do
  @rs = @db.execute('SELECT * FROM products;')
  erb :show_products
end

get '/products/search' do
  @q = params[:q]
  file = open("http://search.twitter.com/search.json?q=#{URI.escape(@q)}")
  @results = JSON.load(file.read)
  erb :product_search
end

post '/products' do
  @name = params[:product_name]
  @price = params[:product_price]
  sql = "INSERT INTO products ('name', 'price') VALUES ('#{@name}', '#{@price}');"
  @db.execute(sql)
  @rs = @db.execute('SELECT * FROM products;')
  erb :show_products
end

get '/products/:id' do
  @id = params[:id]
  sql = "SELECT * FROM products WHERE id = '#{@id}';"
  @row = @db.get_first_row(sql)
  file = open([@@google_shopping_api_base_url,
               "?key=AIzaSyDq8g3qfnOBHkCnDPYGJdIbkOMNQOUD2Vs",
               "&country=US&q=#{URI.escape(@row['name'])}&alt=json"].join,
              :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
  @shopping_results = JSON.load(file.read)
  erb :product_id
end

post '/products/update/:id' do
  name = params[:product_name]
  price = params[:product_price]
  id = params[:id]
  sale = params[:on_sale]
  sql = "UPDATE products SET name = '#{name}', price = '#{price}', on_sale = '#{sale}' WHERE id = '#{id}';"
  @db.execute(sql)
  redirect "/products"
end

get '/products/:id/delete' do
  @id = params[:id]  
  erb :delete_product
end

post '/products/:id/delete' do
  sql = "DELETE FROM products WHERE id = #{params[:id]};"
  @db.execute(sql)
  redirect '/products'
end
