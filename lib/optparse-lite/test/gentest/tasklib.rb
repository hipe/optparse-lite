module Hipe
  module GenTest
    module TaskLib
      # quick little hack for colored formatting @todo windows
      # to give rake tasks colored/styles help screens
      #
    private
      def hdr(x); "\e[32;m#{x}\e[0m" end
      def cmd(x); "\e[4;m#{x}\e[0m"  end
    end
  end
end
