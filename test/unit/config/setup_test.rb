require 'test_helper'
require 'tempest_time/commands/config/setup'

class TempestTime::Commands::Config::SetupTest < Minitest::Test
  def test_executes_config_setup_command_successfully
    output = StringIO.new
    options = {}
    command = TempestTime::Commands::Config::Setup.new(options)

    command.execute(output: output)

    assert_equal "OK\n", output.string
  end
end
