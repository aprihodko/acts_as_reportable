# ActsAsReportable
module FanParty
  module Acts #:nodoc:
    module Reportable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_reportable
          has_many :content_reports, :class_name => "ContentReport", :as => :reportable, :dependent => :destroy, :order => 'created_at ASC'
          include FanParty::Acts::Reportable::InstanceMethods
          extend FanParty::Acts::Reportable::SingletonMethods
        end
        
        def before_destroy
          self.content_reports.each do |content|
            ContentReport.delete(content.id)
          end
        end
      end

      # This module contains class methods
      module SingletonMethods
        # Helper method to lookup for content_reports for a given object.
        # This method is equivalent to obj.content_reports.
        def find_content_reports_for(obj)
          reportable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s

          ContentReport.find(:all,
            :conditions => ["reportable_id = ? and reportable_type = ?", obj.id, reportable],
            :order => "created_at DESC"
          )
        end

        # Helper class method to lookup content_reports for
        # the mixin reportable type written by a given fan.
        # This method is NOT equivalent to ContentReport.find_content_reports_for_fan
        def find_content_reports_by_fan(fan)
          reportable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s

          ContentReport.find(:all,
            :conditions => ["fan_id = ? and reportable_type = ?", fan.id, reportable],
            :order => "created_at DESC"
          )
        end
      end

      # This module contains instance methods
      module InstanceMethods

        def content_report(fan, type=0, comment=nil)
          report = ContentReport.new
          report.comment = comment
          report.content_type = type
          report.fan_id = fan
          self.content_reports << report
        end

        # Helper method to sort content_reports by date
        def content_reports_ordered_by_submitted
          ContentReport.find(:all,
            :conditions => ["reportable_id = ? and reportable_type = ?", id, self.class.name],
            :order => "created_at DESC"
          )
        end

        # Helper method that defaults the submitted time.
        def add_content_report(content_report)
          content_reports << content_report
        end

        def reported_by_fan?(fan)
          rtn = false
          if fan
            self.content_reports.each { |v|
              rtn = true if fan.id == v.fan_id
            }
          end
          rtn
        end
      end
    end
  end
end
