require 'spec_helper'

if defined?(ActiveModel::Serializer)

  describe "SerialSpec::RequestResponse::ProvideMatcher" do
    include SerialSpec::RequestResponse::ProvideMatcher

    let(:post)       { Post.new(title: "title", body: "body") }
    let(:other_post) { Post.new(title: "title2", body: "body2") }

    let(:posts) do
      [
        post,
        other_post
      ]
    end

    let(:resource_json) { PostSerializer.new(post, root: nil).to_json }
    let(:collection_json) { ActiveModel::ArraySerializer.new(posts, serializer: PostSerializer, root: nil).as_json.to_json}

    let(:response) { resource_json }
    let(:parsed_body) { SerialSpec::ParsedBody.new(response) }
    let(:execute_hash) { SerialSpec::ParsedBody.new(response).execute }

    context ":as not valid" do
      it "should return rspec error" do
        expect{
          SerialSpec::RequestResponse::ProvideMatcher::Provide.new(post, as: String)
        }.to raise_error(ArgumentError)
      end
    end

    context "when actual is Hash" do
      it "should match" do
        expect(parsed_body.execute).to provide(post, as: PostSerializer)
      end
    end

    context "with no associations" do
      context "resource" do
        let(:resource_json) { PostSerializer.new(post, root: nil).as_json.to_json }
        it "should match serialized resource with supplied root" do
          expect(parsed_body).to provide(post, as: PostSerializer)
        end
      end

      context "collection" do
        let(:collection_json) { ActiveModel::ArraySerializer.new(posts,serializer: PostSerializer, root: nil).as_json.to_json}
        let(:response) { collection_json }

        it "should match serialized resource with supplied root" do
          expect(parsed_body).to provide(posts, as: PostSerializer)
        end
      end
    end

    context "with associations" do
      let(:comments) do
        [
          Comment.new(title: "Comment1"),
          Comment.new(title: "Comment2")
        ]
      end

      let(:user) { User.new(name: "Enrique") }

      let(:post_with_associations) do
        post.tap do |p|
          p.comments = comments
          p.author = user
        end
      end

      let(:other_post_with_associations) do
        other_post.tap do |p|
          p.comments = comments
          p.author = user
        end
      end

      let(:posts) do
        [post_with_associations,other_post_with_associations]
      end

      context "resource" do
        it "should match with default serializer" do
          expect(parsed_body).to provide(post)
        end
      end

      context "collection" do
        let(:parsed_body) { SerialSpec::ParsedBody.new(collection_json) }

        context "no :as Serializer" do
          let(:collection_json) { ActiveModel::ArraySerializer.new(posts, serializer: PostSerializer).as_json.to_json}
          it "should not match response " do
            expect(parsed_body).to provide(posts)
          end
        end

      end

    end
  end

  describe "SerialSpec::RequestResponse::IncludeAProvidedMatcher" do

    it "should match with default serializer" do
      post = Post.new(title: "title")

      json = [
        {},
        PostSerializer.new(post, root: nil).as_json,
        {}
      ].to_json


      body = SerialSpec::ParsedBody.new(json)
      expect(body).to include_a_provided(post)
    end
  end

end
