require 'rest-client'
require 'json'


class Warewulf
  def Warewulf.node_list
      hostname = 'localhost:9871'
      command = '/v1/node'
      response = RestClient.get(hostname+command)
      nodes = JSON.parse(response)
      nodes["nodes"]
    end
end
