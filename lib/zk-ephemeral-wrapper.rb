require "zookeeper"

class ZkEphemeralWrapper
  def self.call(zookeeper_hosts, full_node, *cmd)
    z = Zookeeper.new(zookeeper_hosts)
    split_nodes = full_node.split("/")[1..-1]
    parent_node = split_nodes[0..-2].inject("") do |memo, dir_node|
      File.join(memo, dir_node).tap do |dir|
        z.create(:path => dir)
      end
    end
    z.create(:path => File.join(parent_node, split_nodes[-1]), :ephemeral => true)
    system(cmd.join(" "))
    exit
  end
end

if __FILE__ == $0
  require "trollop"
  opts = Trollop.options do
    banner <<-EOS
Wraps a program with a zookeeper ephemeral node.

Usage:
  zk-ephemeral-wrapper [options] <comma_delimited_zookeeper_hosts> <node_path> <*cmd>
where [options] are:
EOS
    opt :help, "help", :short => "-h", :default => false
  end

  if opts[:help]
    raise Trollop::HelpNeeded
  else
    ZkEphemeralWrapper.call(*ARGV)
  end
end
