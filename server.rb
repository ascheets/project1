require 'sinatra'
require 'sequel'
require 'sinatra/json'

#configure the app
configure do

  #connect to the sqlite database
  DB = Sequel.connect('sqlite://Teardowns.db')
  
  #create a teardowns table (if it doesn't already exist)
  DB.create_table? :teardowns do
    primary_key :id
    String :instrument
    DateTime :teardownDate
  end

  #create a component table
  DB.create_table? :components do
    primary_key :id
    String :code
    String :type
    foreign_key :teardown_id, :teardowns
  end

  #create the models
  class Teardown < Sequel::Model
    one_to_many :components
  end

  class Component < Sequel::Model
    many_to_one :teardown
  end

end

#create helper methods



#handles the initial request for the page
get '/' do

  #get pre-existing data as relevant
  @all_teardowns = Teardown.all
  @all_components = Component.all

  #render the template in the views folder
  erb :teardowns

end

#handles requests to add new input
post '/components' do

  #create a new input with the data from the browser
  Component.create(:code => params[:code], #from the request's post data
               :type => params[:type])

  #get all the inputs and turn each one into a hash and store it in an array
  components = Component.all.map do |component|

    {:code => component.code, :type => component.type}

  end 

  return json components

end

