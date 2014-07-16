module Merchant
  module Sidekick
    module Version
      MAJOR = 1
      MINOR = 2
      TINY = 7
      BUILD = nil
      STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
      NAME = "Merchant::Sidekick v" + [MAJOR, MINOR, TINY, BUILD].compact.join('.')
    end
  end
end
