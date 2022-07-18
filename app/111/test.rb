
require './module_exporter'
ModuleExporter.setup(root: File.expand_path(File.dirname(__FILE__)))

_MyLocalClass = ModuleExporter.import 'foo'
MyGlobalClass = ModuleExporter.import 'bar'

puts _MyLocalClass.new.foo # => FooBar!
puts MyGlobalClass.new.bar # => Bar!