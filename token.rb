class Token
    attr_accessor :type, :lexeme, :literal, :line

    def initialize(type, lexeme, literal, line)
        @type = type
        @lexeme = lexeme
        @literal = literal
        @line = line
    end

    def to_s
        return "#{type} #{lexeme} #{literal}"
    end
end
