# frozen_string_literal: true

# @type [Pry::Config]
config = self
# @type [Pathname]
config_path = self.config_path
# @type [Wolffia::Cli::Commands::ConsoleCommand::PromptBuilder]
prompt_builder = self.prompt_builder

# prompt ----------------------------------------------------------------------
%w[> *].map do |sep|
  proc { |*args| prompt_builder.call(*args, sep: sep) }
end.then do |prompts|
  config.prompt = ::Pry::Prompt.new('custom', 'custom prompt', prompts)
end
# history ---------------------------------------------------------------------
config.history_file = config_path.join('history')
config.history_load = true
config.history_save = true
# pager -----------------------------------------------------------------------
config.pager = false
