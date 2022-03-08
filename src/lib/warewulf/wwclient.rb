this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'wwapi')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'routes_services_pb'
require 'grpc'

class Warewulf
  class Node
    def initialize(node_name,node_profile,node_container)
      @name = node_name
      @profile = node_profile
      @container = node_container
    end
    attr_accessor :profile
    attr_accessor :container
    attr_accessor :name

  end
    # Calls the wwapi for the nodes
  def Warewulf.node_list
      hostname = 'localhost:9872'
      stub = Wwapi::V1::WWApi::Stub.new(hostname, :this_channel_is_insecure)
      nodesmessage = stub.node_list(Wwapi::V1::NodeListResponse.new())
      nodes = Array.new
      nodesmessage.nodes.each { |node|
        puts "name: #{node.id.value} container: #{node.container.value}"
        nodes.push(Node.new(node.id.value,node.profiles,node.container.value))
      }
      nodes
    end
end

#def main
#  nodelist = Warewulf.node_list
#  nodelist.each {|node|
#    puts "#{node.name}"
#  }
#end
#
#main
