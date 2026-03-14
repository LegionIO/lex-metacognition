# frozen_string_literal: true

require 'legion/extensions/metacognition/version'
require 'legion/extensions/metacognition/helpers/constants'
require 'legion/extensions/metacognition/helpers/self_model'
require 'legion/extensions/metacognition/helpers/snapshot_store'
require 'legion/extensions/metacognition/helpers/narrator_bridge'
require 'legion/extensions/metacognition/helpers/registry_store'
require 'legion/extensions/metacognition/runners/metacognition'
require 'legion/extensions/metacognition/runners/registry'
require 'legion/extensions/metacognition/client'

module Legion
  module Extensions
    module Metacognition
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
