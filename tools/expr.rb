def define_ast(output_directory, base_name, types)
    path = "#{output_directory}/#{base_name.downcase}.rb"

    File.open(path, 'w') do |file|
        file.write("class #{base_name}\n")
        define_visitor(file, base_name, types)
        types.each do |type|
            class_name, fields = type.split(":")
            define_type(file, base_name, class_name.strip, fields.strip)
        end
        file.write("    def accept(visitor)\n")
        file.write("    end\n")
        file.write("end\n")
    end
end

def define_type(file, base_name, class_name, fields_list)
    fields = fields_list.split(", ")
    file.write("    class #{class_name} < #{base_name}\n")
    file.write("        attr_reader #{fields.map { |field| ":#{field}" }.join(", ")}\n")
    file.write("        def initialize(#{fields_list})\n")
    fields.each do |field|
        file.write("            @#{field} = #{field}\n")
    end
    file.write("        end\n")
    file.write("        def accept(visitor)\n")
    file.write("            return visitor.visit_#{class_name.downcase}_#{base_name.downcase}(self)\n")
    file.write("        end\n")
    file.write("    end\n")
end

def define_visitor(file, base_name, types)
    file.write("    class Visitor\n")
    types.each do |type|
        type_name = type.split(":")[0].strip
        file.write("        def visit_#{type_name.downcase}_#{base_name.downcase}(#{base_name.downcase})\n")
        file.write("        end\n")
    end
    file.write("    end\n")
end

def main
    if 1 != ARGV.length
        puts "Usage: generate_ast <output directory>"
        exit(64)
    end

    output_directory = ARGV[0]
    define_ast(output_directory, "Expr", [
        "Binary     : left, operator, right",
        "Grouping   : expression",
        "Literal    : value",
        "Unary      : operator, right",
    ])
rescue Interrupt
end

if __FILE__ == $0
    main
end
