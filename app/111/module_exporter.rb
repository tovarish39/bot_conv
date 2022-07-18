class ModuleExporter
    class Sandbox < BasicObject
      def self.import(from)
        ::ModuleExporter.import(from)
      end
  
      def self.export(object, &block)
        object.class_eval(&block) if block_given?
        @__export__ = object
      end
  
      def self.__export__
        @__export__
      end
    end
  
    def self.setup(root:)
      Thread.current['__exports_root__'] = root
      Thread.current['__exports__'] = {}
    end
  
    def self.root
      Thread.current['__exports_root__']
    end
  
    def self.module(file, &block)
      Thread.current['__exports__'] ||= {}
      raise 'Only one module block per file!' if Thread.current['__exports__'].has_key?(file)
  
      Thread.current['__exports__'][file] = Class.new(ModuleExporter::Sandbox)
      Thread.current['__exports__'][file].instance_eval(&block)
    end
  
    def self.import(source)
      file = File.join(root, source) + ".rb"
  
      require file unless Thread.current['__exports__'][file]
      raise "Unknown import #{source}. Check your paths (looked in: #{file})" unless Thread.current['__exports__'][file]
  
      export = Thread.current['__exports__'][file].__export__
      raise "#{source} does not export any classes" unless export
  
      export
    end
  end