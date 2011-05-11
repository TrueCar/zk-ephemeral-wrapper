require "zookeeper"

class ZkEphemeralWrapper
  def self.call(zookeeper_hosts, full_nodes, *cmd)
    z = Zookeeper.new(zookeeper_hosts)
    full_nodes.split(",").each do |full_node|
      split_nodes = full_node.split("/")[1..-1]
      parent_node = split_nodes[0..-2].inject("") do |memo, dir_node|
        File.join(memo, dir_node).tap do |dir|
          z.create(:path => dir)
        end
      end
      z.create(:path => File.join(parent_node, split_nodes[-1]), :ephemeral => true)
    end
    exit system(cmd.join(" "))
  end
end

if __FILE__ == $0
  if ARGV.length < 3
    puts <<-TEXT
    Wraps a program with a zookeeper ephemeral node.

    Usage:
      zk-ephemeral-wrapper [options] <comma_delimited_zookeeper_hosts> <comma_delimited_node_paths> <*cmd>
    TEXT
    exit 1
  end
  ZkEphemeralWrapper.call(*ARGV)
end
