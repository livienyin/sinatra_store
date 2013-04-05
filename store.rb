# gem install --version 1.3.0 sinatra
require 'pry'
gem 'sinatra', '1.3.0'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

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

post '/new-product' do
  name = params[:product_name]
  price = params[:product_price]
  sql = "INSERT INTO products ('name', 'price') VALUES ('#{name}', '#{price}');"
  @rs = @db.prepare(sql).execute
  @name = name
  @price = price 
  erb :show_products
end

get '/users' do
  @rs = @db.prepare('SELECT * FROM users;').execute
  erb :show_users
end

get '/products' do
  @rs = @db.prepare('SELECT * FROM products;').execute
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
  @rs = @db.prepare(sql).execute
  sql = "SELECT * FROM products WHERE id = '#{@id}';"
  @row = @db.get_first_row(sql)
  erb :product_id
end
