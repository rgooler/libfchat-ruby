module Libfchat
  # We're doing this because we might write tests that deal
  # with other versions of Libfchat and we are unsure how to
  # handle this better.
  VERSION = "1.9" unless defined?(::Libfchat::VERSION)
end
