require 'timeout'

module Splib
    # command:: command to execute
    # timeout:: maximum number of seconds to run
    # maxbytes:: maximum number of result bytes to accept
    # Execute a system command (use with care)
    def self.exec(command, timeout=10, maxbytes=500)
        output = []
        pro = nil
        begin
            Timeout::timeout(timeout) do
                pro = IO.popen(command)
                until(pro.closed? || pro.eof?)
                    if(RUBY_VERSION >= '1.9.0')
                        output << pro.getc
                    else
                        output << pro.getc.chr
                    end
                    raise IOError.new("Maximum allowed output bytes exceeded. (#{maxbytes} bytes)") unless output.size <= maxbytes
                end
            end
            output = output.join('')
        rescue Exception => boom
            raise boom
        ensure
            if(RUBY_PLATFORM == 'java')
                Process.kill('KILL', pro.pid) unless pro.nil?
            else
                Process.kill('KILL', pro.pid) if Process.waitpid2(pro.pid, Process::WNOHANG).nil? # make sure the process is dead
            end
        end
        return output
    end
end