require_relative "token"

class Scanner
    attr_accessor :current, :line, :start, :source, :tokens

    KEYWORDS = {
        "and": :AND,
        "class": :CLASS,
        "else": :ELSE,
        "false": :FALSE,
        "for": :FOR,
        "fun": :FUN,
        "if": :IF,
        "nil": :NIL,
        "or": :OR,
        "print": :PRINT,
        "return": :RETURN,
        "super": :SUPER,
        "this": :THIS,
        "true": :TRUE,
        "var": :VAR,
        "while": :WHILE,
    }.transform_keys(&:to_s)

    def initialize(source)
        @current = 0
        @start = 0
        @line = 1
        @source = source
        @tokens = []
    end

    def scan_tokens
        while !is_at_end
            @start = @current
            scan_token
        end

        @tokens.append(
            ::Token.new(:EOF, "", nil, @line)
        )

        @tokens
    end

    private

    def add_token(type, literal = nil)
        text = current_text

        @tokens.append(
            ::Token.new(type, text, literal, @line)
        )
    end

    def advance
        increment_current
        @source[@current - 1]
    end

    def current_text
        @source[@start..@current - 1]
    end

    def identifier
        while is_alpha_numeric(peek) do
            advance
        end

        text = current_text

        type = KEYWORDS[text]
        type = :IDENTIFIER if type.nil?

        add_token(type)
    end

    def increment_current
        @current = @current + 1
    end

    def is_alpha(c)
        ("a" <= c.chr && "z" >= c.chr) || ("A" <= c.chr &&  "Z" >= c.chr) || "_" == c.chr
    end

    def is_alpha_numeric(c)
        is_alpha(c) || is_digit(c)
    end

    def is_at_end
        @current >= @source.length
    end

    def is_digit(c)
        "0" <= c.chr  && "9" >= c.chr
    end

    def match(expected)
        return false if is_at_end
        return false unless expected == @source[@current]

        increment_current
        true
    end

    def number
        while is_digit(peek) do
            advance
        end

        # Look for a fractional part.
        if "." == peek && is_digit(peek_next)
            # Consume the "."
            advance

            while is_digit(peek)
                advance
            end
        end

        add_token(:NUMBER, current_text.to_f)
    end

    def peek
        return "\\0" if is_at_end

        @source[@current]
    end

    def peek_next
        return "\\0" if @current + 1 >= @source.length
        @source[@current + 1]
    end

    def scan_token
        c = advance

        case c
        when "("
            add_token(:LEFT_PAREN)
        when ")"
            add_token(:RIGHT_PAREN)
        when "{"
            add_token(:LEFT_BRACE)
        when "}"
            add_token(:RIGHT_BRACE)
        when ","
            add_token(:COMMA)
        when "."
            add_token(:DOT)
        when "-"
            add_token(:MINUS)
        when "+"
            add_token(:PLUS)
        when ";"
            add_token(:SEMICOLON)
        when "*"
            add_token(:STAR)
        when "!"
            add_token(match("=") ? :BANG_EQUAL : :BANG)
        when "="
            add_token(match("=") ? :EQUAL_EQUAL : :EQUAL)
        when "<"
            add_token(match("=") ? :LESS_EQUAL : :LESS)
        when ">"
            add_token(match("=") ? :GREATER_EQUAL : :EQUAL)
        when "/"
            if match("/")
                while "\n" != peek && !is_at_end do
                    advance
                end
            elsif match("*")
                open_count = 1
                while open_count > 0 && !is_at_end do
                    if peek == '/' && peek_next == '*'
                        open_count += 1
                    elsif peek == '*' && peek_next == '/'
                        open_count -= 1
                    else
                        next advance
                    end

                    3.times { advance }
                end
            else
                add_token(:SLASH)
            end
        when " "
        when "\r"
        when "\t"
        when "\n"
            @line += 1
        when "\""
            string
        else
            if is_digit(c)
                number
            elsif is_alpha(c)
                identifier
            else
                ::Lox.error(line, "Unexpected character.")
            end
        end
    end

    def string
        while "\"" != peek && !is_at_end do
            if "\\n" == peek
                @line += 1
            end
            advance
        end

        # Unterminated string.
        if is_at_end
            Lox.error(line, "Unterminated string.")
            return
        end

        # The closing ".
        advance

        value = @source[@start + 1..@current - 2]
        add_token(:STRING, value)
    end
end
