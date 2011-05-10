require "zookeeper"

class ZkEphemeralWrapper
  def self.call(zookeeper_hosts, full_node, cmd)
    z = Zookeeper.new(zookeeper_hosts)
    split_nodes = full_node.split("/")[1..-1]
    parent_node = split_nodes[0..-2].inject("") do |memo, dir_node|
      File.join(memo, dir_node).tap do |dir|
        z.create(:path => dir)
      end
    end
    z.create(:path => File.join(parent_node, split_nodes[-1]), :ephemeral => true)
    system(cmd)
    exit
  end
end
