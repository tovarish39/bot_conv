ModuleExporter.module __FILE__ do
    # can't use Bar because it's automatically leaking to global namespace
    _Bar = import 'bar' 
  
    _Foo = Class.new(_Bar) do
      def foo
        "Foo" + bar
      end
    end
  
    export _Foo
  end