ModuleExporter.module(__FILE__) do
    _Bar = Class.new do
      def bar
        "Bar!"
      end
    end
  
    export _Bar
  end
  
  # alternative syntax:
  #  export Class.new do
  #    def bar
  #      "Bar!"
  #    end
  #  end