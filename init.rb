# Include hook code here
require 'acts_as_reportable'
ActiveRecord::Base.send(:include, FanParty::Acts::Reportable)
