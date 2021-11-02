# frozen_string_literal: true

register(:logger, memoize: true) do
  ::Wolffia::Logger.new(name: :cli) do |config|
    config.name = :cli
  end
end
