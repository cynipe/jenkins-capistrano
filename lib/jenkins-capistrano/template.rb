
module Jenkins
  class Template

    def initialize(template, variables)
      raise ArgumentError, "Template #{template} does not exist." unless File.exists? template
      raise ArgumentError, "variables must be a Hash, but was #{variables.class}" unless variables.is_a? Hash
      @template = template
      @variables = variables
    end

    def evaluate
      @variables.each do |param, value|
        var = "@#{param.to_s}"
        instance_variable_set(var, value)
      end
      ERB.new(File.read(@template), 0, '-').result(binding)
    end
  end
end
