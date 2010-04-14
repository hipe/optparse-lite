require File.dirname(__FILE__)+'/optparse-lite-test-setup.rb'


module OptparseLite::Test
  class Empty
    include OptparseLite
    # o 'bar'
    # x 'bar'
    # def bar; end
  end
  Empty.spec.invocation_name = "empty-app.rb"

  describe Empty do
    it 'empty-app.rb must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m empty-app.rb (this screen. no commands defined.)
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
  end
end
