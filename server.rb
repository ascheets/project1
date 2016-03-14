require 'sinatra'
require 'sequel'
require 'sinatra/json'

#configure the app
configure do

  #connect to the sqlite database
  DB = Sequel.connect('sqlite://Inputs.db')
  
  #create tables
  DB.create_table? :inputs do
    primary_key :id
    String :input1
    String :input2
  end

  #open up inputs
  require_relative 'Input'

end

#handles the initial request for the page
get '/' do

  #get pre-existing data as relevant
  @all_inputs = Input.all

  #render the template in the views folder
  erb :relevant

end

#handles requests to add new input
post '/inputs' do

  #create a new input with the data from the browser
  Input.create(:input1 => params[:input1], #from the request's post data
               :input2 => params[:input2])

  #get all the inputs and turn each one into a hash and store it in an array
  inputs = Input.all 

  return json inputs

end

