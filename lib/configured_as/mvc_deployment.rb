class MvcDeployment
  attr_accessor :environment
  attr_accessor :host  
  attr_accessor :to
  attr_accessor :port
  attr_accessor :description
  attr_accessor :site_name
  attr_accessor :deploy_zip_path
  
  def initialize()
    set_defaults
  end

  def set_defaults()
    self.port = 80
    self.description = "MvcDeployment"
  end
  
  def set_name(name)
    self.site_name = name
  end    
  
  def set_deploy(path)
    self.deploy_zip_path = path    
  end
  
  def set_description(desc)
    self.description = desc
  end    

  def set_host(header)
    self.host = header
  end

  def set_port(num)
    self.port = num
  end

  def set_environment(env)
    self.environment = env
  end
  
  def set_to(locations)
    self.to = []
  
    i = 0
    while i < locations.length
      location = DeployTo.new
      location.server = locations[i]
      location.path = locations[i + 1]

      self.to << location
      i = i + 2
    end      
  end
  
  def get_location(server)
    servers = self.to.select{|t| t.server == server}
    servers[0].path
  end
  
  def upload(server)
    
  end
  
  def deploy(server)  
    location = get_location(server)
    latest_version_location = get_latest_version(location)
    
    extract(latest_version_location)
    
    iis = IIS.new
    iis.deploy(server, latest_version_location, self)
    #  Execute post deployment steps
    #     Configure ISAPI etc
  end
  
  def extract(location)
    UnZip.unzip(self.deploy_zip_path, location)
    swap_configs(location)
  end
  
  def get_latest_version(location)
    dirs = Dir.glob("#{location}/**").grep(/#{self.site_name}/)
    
    new_version = find_next_release_version(dirs)
    
    File.join(location, self.site_name + "%02d" % new_version)
  end
  
  def find_next_release_version(dirs)
    release_numbers = [0]
    
    dirs.each do |dir|
      s = /#{self.site_name}(\d+)/.match(dir)
      release_numbers << s[1].to_i unless s.nil?
    end
    
    new_version = release_numbers.max + 1
  end
  
  def swap_configs(location)
    env = self.environment
    FileUtils.cp File.join(location, 'web.config'), File.join(location, 'web.original.config')
    FileUtils.mv File.join(location, "web.#{env.to_s}.config"), File.join(location, 'web.config')
  end
end

class DeployTo
  attr_accessor :server
  attr_accessor :path  
end