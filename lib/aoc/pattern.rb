require "aoc"

module AOC::Pattern
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_accessor :patterns

    def def_pat(name, *args, &block)
      @patterns ||= {}
      @patterns[[name, args]] = block

      unless self.instance_methods.include?(name)
        define_method name do |*block_args|
          _name, impl = self.class.patterns.each_pair.find{|k, v|
            match_name, match_args = k
            match_name == name &&
              match_args.length == block_args.length &&
              match_args.zip(block_args).all?{|m| m[0] === m[1] }
          }
          if impl
            instance_exec(*block_args, &impl)
          else
            raise NoMethodError, "can't pattern match #{name} with args #{block_args}"
          end
        end
      end
    end
  end
end
