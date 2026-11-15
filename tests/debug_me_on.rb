# frozen_string_literal: true

# Turns debug_me's output on for each test, even when the shell has
# DEBUG_ME=false (which turns it off at require time), and restores the
# old value afterwards. Opt in with `include DebugMeOn` inside a describe.
# $DEBUG_ME is the gem's on/off switch, so the global is unavoidable.
# rubocop:disable Style/GlobalVars
module DebugMeOn
  def before_setup
    super
    @saved_debug_me = $DEBUG_ME
    $DEBUG_ME = true
  end

  def after_teardown
    $DEBUG_ME = @saved_debug_me
    super
  end
end
# rubocop:enable Style/GlobalVars
