require "rexml/document"

xml = REXML::Document.new(File.new("/tmp/precise.bosh.xml"))

i = 0
xml.root.elements.each do |element|
	i = i + 1
	puts " --------------- Interacion -------------- [ i = #{i} ] "
	puts element.name
	puts element
	j = 0
	element.each do |element2|
		j = j + 1
		puts "\t\t ----------- Iteracion -------------- [ j = #{j} ] "
		puts element2
		element2.raw
	end
end

puts xml.root.elements
puts xml.root.name

devices = xml.get_elements("disk")
puts devices

puts xml.size
puts xml.root.size
puts xml.root.elements.size
xml.root.elements.each("*/disk/source") do |element| 
	puts element.attributes["file"]
end
