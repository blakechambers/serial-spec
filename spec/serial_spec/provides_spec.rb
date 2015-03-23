require 'spec_helper'

describe "SerialSpec::RequestResponse::Provide" do
  include SerialSpec::RequestResponse::Provide

  let(:comments) do 
    [Comment.new(:title => "Comment1"), Comment.new(:title => "Comment2")]
  end
  let(:user) { User.new(name: "Enrique") }
  let(:post) do
    Post.new(:title => "New Post", :body => "Body of new post")
  end

  #let(:post) do 
    #p = Post.new(:title => "New Post", :body => "Body of new post")
    #p.comments = comments
    #p.author = user
    #p
  #end

  let(:resource_serializer)  do
    resource.as_json
  end

  let(:response) do 
    SerialSpec::ParsedBody.new(resource.to_json)
  end

  # provide(model_instance) -> uses default ASM 

  # provide(model_instance, as: ModelSerializer)
  #context ".provide" do
  #context "" do

  #it "should match serializable object" do
  #require'pry';binding.pry 
  ##provide(resource).to eq(true)
  #end
  #end
  #context "enumerable supplied" do

  #end
  #end

  context "using provide" do
    context "with :as" do
      it "should match serialized model" do
        expect(serialized_post)e.to provide(post, as: PostSerializer)
      end
    end
  end

end

