require 'active_model_serializers' 

# inspired from ASM
class Model

include ActiveModel::Serialization
include ActiveModel::SerializerSupport
include ActiveModel::ArraySerializerSupport

  attr_reader :options, :attributes
  def initialize(attrs={},options={})
    @some_id = make_id
    @attributes = attrs.merge(some_id: @some_id) if attrs
    @options = options
  end

  def some_id
    @some_id.to_s
  end

  def make_id
    if defined?(BSON)
      BSON::ObjectId.new
    else
      rand(100)
    end
  end
end

class Comment < Model
  attr_accessor :title
  def initialize(attrs)
    self.title = attrs[:title]
    super(attributes)
  end
  def active_model_serializer; CommentSerializer; end
end

class Post < Model
  attr_accessor :comments, :comments_disabled, :author, :title, :body
  def initialize(attributes)
    self.comments ||= attributes[:comments] || [] 
    self.author = attributes[:author] || nil
    self.title = attributes[:title] || nil
    self.body  = attributes[:body] || nil
    super(attributes)
  end
  def active_model_serializer; PostSerializer; end
end

class User < Model
  attr_accessor :name
  def initialize(attrs)
    self.name = attrs[:name]
    super(attributes)
  end
  def active_model_serializer; CommentSerializer; end
end



class BaseSerializer < ActiveModel::Serializer
  attributes :some_id
  def to_json
    as_json.to_json
  end
end

# SErializers
class CommentSerializer < BaseSerializer
  attributes :title
end

class UserSerializer < BaseSerializer
  attributes :name     
end

class PostSerializer < BaseSerializer 
  attributes :title, :body
  has_many :comments, :serializer => CommentSerializer
  has_one :author, :serializer => UserSerializer
end


