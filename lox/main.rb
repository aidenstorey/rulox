require_relative "lox"
require_relative "expr"
require_relative "ast_printer"

def main
    if 1 < ARGV.length
        puts "Usage: rulox [script]"
        exit(64)
    elsif 1 == ARGV.length
        ::Lox.run_file(ARGV[0])
    else
        ::Lox.run_prompt()
    end
rescue Interrupt
end

if __FILE__ == $0
    main
end
