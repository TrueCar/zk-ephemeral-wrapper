require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

describe ZkEphemeralWrapper do
  describe ".call" do
    describe "node" do
      context "when passed a top-level node" do
        it "creates an ephemeral node for the top-level node" do
          mock.strong(Zookeeper).new("127.0.0.1:2181") do
            mock!.create(:path => "/foobar", :ephemeral => true)
          end
          mock.strong(ZkEphemeralWrapper).system("my-program") {0}
          mock.strong(ZkEphemeralWrapper).exit(0)
          ZkEphemeralWrapper.call("127.0.0.1:2181", "/foobar", "my-program")
        end
      end

      context "when passed a node in a directory" do
        it "creates nodes for each directory and an ephemeral node leaf node" do
          mock.strong(Zookeeper).new("127.0.0.1:2181") do
            mock! do |z|
              z.create(:path => "/foo")
              z.create(:path => "/foo/bar")
              z.create(:path => "/foo/bar/baz", :ephemeral => true)
            end
          end
          mock.strong(ZkEphemeralWrapper).system("my-program") {0}
          mock.strong(ZkEphemeralWrapper).exit(0)
          ZkEphemeralWrapper.call("127.0.0.1:2181", "/foo/bar/baz", "my-program")
        end
      end
    end

    describe "node paths" do
      context "when passed a comma-delimited list of node paths" do
        it "creates nodes for path" do
          mock.strong(Zookeeper).new("127.0.0.1:2181") do
            mock! do |z|
              z.create(:path => "/foo")
              z.create(:path => "/foo/bar")
              z.create(:path => "/foo/bar/baz", :ephemeral => true)
              z.create(:path => "/one")
              z.create(:path => "/one/two")
              z.create(:path => "/one/two/three", :ephemeral => true)
            end
          end
          mock.strong(ZkEphemeralWrapper).system("my-program") {0}
          mock.strong(ZkEphemeralWrapper).exit(0)
          ZkEphemeralWrapper.call("127.0.0.1:2181", "/foo/bar/baz,/one/two/three", "my-program")
        end
      end
    end

    describe "command" do
      it "accepts concats multiple cmd parts" do
        mock.strong(Zookeeper).new("127.0.0.1:2181") do
          mock!.create(:path => "/foobar", :ephemeral => true)
        end
        mock.strong(ZkEphemeralWrapper).system("my program runs") {0}
        mock.strong(ZkEphemeralWrapper).exit(0)
        ZkEphemeralWrapper.call("127.0.0.1:2181", "/foobar", "my", "program", "runs")        
      end
    end
  end
end
