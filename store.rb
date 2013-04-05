# gem install --version 1.3.0 sinatra
require 'pry'
gem 'sinatra', '1.3.0'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'open-uri'
require 'json'
require 'uri'

before do
  @db = SQLite3::Database.new "store.sqlite3"
  @db.results_as_hash = true
end

configure do
  @@home_uri = "/"
  @@users_uri = "/users"
  @@products_uri = "/products"
end

get '/' do
  erb :home
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
  name = params[:product_name]
  price = params[:product_price]
  sql = "INSERT INTO products ('name', 'price') VALUES ('#{name}', '#{price}');"
  @db.execute(sql)
  @rs = @db.execute('SELECT * FROM products;')
  @name = name
  @price = price 
  erb :show_products
end

get '/products/:id' do
  @name = params[:product_name]
  @price = params[:product_price]
  @id = params[:id]
  sql = "SELECT * FROM products WHERE id = '#{@id}';"
  @row = @db.get_first_row(sql)
  erb :product_id
end

post '/products/:id' do
  @name = params[:product_name]
  @price = params[:product_price]
  @id = params[:id]
  sql = "UPDATE products SET name = '#{@name}', price = '#{@price}' WHERE id = '#{@id}';"
  @db.execute(sql)
  sql = "SELECT * FROM products WHERE id = '#{@id}';"
  @row = @db.get_first_row(sql)
  erb :product_id
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
