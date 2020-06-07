require_relative "scanner"

class Lox
    class << self
        attr_accessor :had_error

        def error(line, message)
            report(line, "", message)
        end

        def run_file(file_name)
            file = File.read(file_name)
            run(file)

            exit(64) if @had_error
        end

        def run_prompt
            while true do
                print "> "
                run(STDIN.gets)

                @had_error = false
            end
        end

        private

        def report(line, where, message)
            puts "[line #{line}] Error #{where}: #{message}"
            @had_error = true;
        end

        def run(source)
            scanner = Scanner.new(source)
            tokens = scanner.scan_tokens

            tokens.each { |token| puts token }
        end
    end
end
