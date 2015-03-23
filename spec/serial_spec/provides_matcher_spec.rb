require 'spec_helper'

if defined?(ActiveModel::Serializer)

  describe "SerialSpec::RequestResponse::ProvideMatcher" do
    include SerialSpec::RequestResponse::ProvideMatcher

    let(:post) do
      Post.new(:title => "New Post", :body => "Body of new post")
    end
    let(:posts) do 
      [
        Post.new(:title => "New Post", :body => "Body of new post"),
        Post.new(:title => "New Post2", :body => "Body of new post2")
      ]
    end

    let(:resource_json) { PostSerializer.new(post).as_json.to_json }
    let(:collection_json) { ActiveModel::ArraySerializer.new(posts,serializer: PostSerializer, root: 'posts').as_json.to_json}

    let(:response) { resource_json }
    let(:parsed_body) { SerialSpec::ParsedBody.new(response) }
    let(:execute_hash) { SerialSpec::ParsedBody.new(response).execute }

    context "using provide" do

      context ":as not valid" do
        # can't quite figure out how to assert the error string here
        # like here: https://www.relishapp.com/rspec/rspec-expectations/v/3-2/docs/customized-message
        xit "should return rspec error" do
          expect(parsed_body).to provide(post, as: String)
        end
      end

      context "when actual is Hash" do
        it "should match" do
          expect(parsed_body.execute).to provide(post, as: PostSerializer, with_root: :post)
        end
      end

      context "with no associations" do
        context "resource" do
          context ":with_root" do
            let(:fake_root) { "fake_root" }
            let(:resource_json) { PostSerializer.new(post, root: fake_root).as_json.to_json } 
            it "should match serialized resource with supplied root" do
              expect(parsed_body).to provide(post, as: PostSerializer, with_root: fake_root)
            end
          end
        end

        context "collection" do
          let(:response) { collection_json }
          context ":with_root" do
            let(:fake_root) { "fake_root" }
            let(:collection_json) { ActiveModel::ArraySerializer.new(posts,serializer: PostSerializer, root: fake_root).as_json.to_json}
            it "should match serialized resource with supplied root" do
              expect(parsed_body).to provide(posts, as: PostSerializer, with_root: fake_root)
            end
          end
        end
      end

      context "with associations" do
        let(:comments) do 
          [Comment.new(:title => "Comment1"), Comment.new(:title => "Comment2")]
        end
        let(:reordered_comments) do 
          comments.reverse
        end
        let(:user) { User.new(name: "Enrique") }
        let(:post) do 
          p = Post.new(:title => "New Post", :body => "Body of new post")
          p.comments = comments
          p.author = user
          p
        end
        let(:other_post) do 
          p = post
          p.comments = reordered_comments
          p.author = user
          p
        end

        let(:posts) do
          [post,other_post]
        end

        context "resource" do
          it "should match with default serializer" do
            expect(parsed_body[:post]).to provide(post)
          end
          context "no :as Serializer" do
            let(:resource_json) { PostSerializer.new(post).as_json.to_json } 
            it "should match serialized resource" do
              expect(parsed_body).to provide(post, with_root: "post")
            end
          end
          context ":with_root" do
            let(:fake_root) { "fake_root" }
            let(:resource_json) { PostSerializer.new(post, root: fake_root).as_json.to_json } 
            it "should match serialized resource with supplied root" do
              expect(parsed_body).to provide(post, as: PostSerializer, with_root: fake_root)
            end
          end
        end

        context "collection" do
          let(:response) { collection_json }

          it "should not match serialized resource without root" do
            expect(parsed_body).not_to provide(posts, as: PostSerializer)
          end

          context "ParsedBody selectors" do
            it do
              expect(parsed_body[:posts].first).to provide(post, as: PostSerializer)
            end
            it do
              expect(parsed_body[:posts].first).to provide(post)
            end
          end

          context "no :as Serializer" do
            let(:collection_json) { ActiveModel::ArraySerializer.new(posts,serializer: PostSerializer, root: 'posts').as_json.to_json}
            it "should not match response " do
              expect(parsed_body).to_not provide(posts, as: PostSerializer)
            end
          end

          context ":with_root" do
            let(:fake_root) { "fake_root" }
            let(:collection_json) { ActiveModel::ArraySerializer.new(posts,serializer: PostSerializer, root: fake_root).as_json.to_json}
            it "should match serialized resource with supplied root" do
              expect(parsed_body).to provide(posts, as: PostSerializer, with_root: fake_root)
            end
          end
        end

      end
    end
  end

end
