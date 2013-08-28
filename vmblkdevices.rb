require "rexml/document"

if ARGV.length != 1
	puts "Error de argumentos"
	exit(1)
end

file = ARGV[0]

if not File.exists?(file)
	puts "Fichero #{file} No existe"
	exit(2)
end

xml = REXML::Document.new(File.new(file))

xml.root.elements.each("*/disk/source") do |element| 
	puts element.attributes["file"]
end
