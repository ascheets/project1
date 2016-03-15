require 'sinatra'
require 'sequel'
require 'sinatra/json'

#configure the app
configure do

  #connect to the sqlite database
  DB = Sequel.connect('sqlite://Teardowns.db')

  #create an inventory table?

  #create a projects table
  DB.create_table? :projects do
    primary_key :id
    String :title
  end
  
  #create a teardowns table (if it doesn't already exist)
  DB.create_table? :teardowns do
    primary_key :id
    String :object
  end

  #create a component table
  DB.create_table? :components do
    primary_key :id
    String :code
    String :type
  end

  #create a join table for components and teardowns
  if not DB.table_exists?(:components_teardowns)
    DB.create_join_table(:component_id=>:components, :teardown_id=>:teardowns)
  end

  #create a join table for components and projects
  if not DB.table_exists?(:components_projects)
    DB.create_join_table(:component_id=>:components, :project_id=>:projects)
  end

  #create the models
  class Project < Sequel::Model
    many_to_many :components
  end

  class Teardown < Sequel::Model
    many_to_many :components
  end

  class Component < Sequel::Model
    many_to_many :projects
    many_to_many :teardowns
  end

end

#create helper methods


#handles the initial request for the page
get '/' do

  #get pre-existing data as relevant
  @all_teardowns = Teardown.all
  @all_components = Component.all
  @all_projects = Project.all

  #render the template in the views folder
  erb :main

end

get '/teardowns' do

  erb :teardown

end

#handles requests to add new components
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

#adding new teardowns
post '/teardowns' do

  #create a new teardown object with data
  Teardown.create(:object => params[:object])

  #get all teardowns
  teardowns = Teardown.all.map do |teardown|

    {:object => teardown.object}

  end

  return json teardowns

end

#adding new project
post '/newProject' do

  #create a new teardown object with data
  Project.create(:title => params[:title])

  #get all teardowns
  projects = Project.all.map do |project|

    {:title => project.title}

  end

  return json projects

end


