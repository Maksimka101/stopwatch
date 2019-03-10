
file_name = "main.dart"

end_file = []
file = open(file_name, "r")
for line in file:
	tmp_line = ''
	previos = ''

	for char in line:
		if char == ' ' and previos == ':':
			continue
		if char == ' ' and previos == '=':
			continue
		tmp_line += char
		previos = char
		
	end_file.append(tmp_line.strip()+"\n")
file.close()

file = open(file_name, "w")
for line in end_file:
	if line != '\n':
		file.write(line)
file.close()
